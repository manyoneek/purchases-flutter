// Runs only against the locally served demo in the managed openclaw Chrome profile.
// Captures actual browser-rendered frames. Does not replace SDK functions or responses.
const {chromium}=require('/opt/homebrew/lib/node_modules/openclaw/node_modules/playwright-core');
const fs=require('fs'); const path=require('path'); const {spawnSync}=require('child_process');
(async()=>{
 const browser=await chromium.connectOverCDP('http://127.0.0.1:18800');
 const context=browser.contexts()[0]; const p=context.pages().find(page=>page.url().startsWith('http://127.0.0.1:8902/')) || await context.newPage(); await p.goto('http://127.0.0.1:8902/');
 if(!p) throw Error('Open the permitted local demo in profile openclaw first.');
 await p.setViewportSize({width:1280,height:1040});
 const cdp=await p.context().newCDPSession(p);
 const network=[];
 p.on('requestfailed',r=>network.push({event:'failed',url:r.url(),method:r.method(),error:r.failure(),time:Date.now()}));
 p.on('response',r=>{if(r.url().includes('revenuecat'))network.push({event:'response',url:r.url(),status:r.status(),time:Date.now()})});
 const consoleLog=[];p.on('console',m=>consoleLog.push({type:m.type(),text:m.text()}));
 async function ready(){await p.locator('flutter-view').waitFor();await p.evaluate(()=>document.querySelector('flt-semantics-placeholder')?.click());await p.getByRole('button',{name:'Run proxy case',exact:true}).waitFor();}
 async function record(name,action){
  const dir=path.join('evidence',name+'-frames');fs.mkdirSync(dir,{recursive:true});const frames=[];let started=Date.now();
  const listener=async e=>{const f=`${String(frames.length).padStart(5,'0')}.png`;frames.push({file:f,time:e.metadata.timestamp});fs.writeFileSync(path.join(dir,f),Buffer.from(e.data,'base64'));await cdp.send('Page.screencastFrameAck',{sessionId:e.sessionId});};
  cdp.on('Page.screencastFrame',listener);await cdp.send('Page.startScreencast',{format:'png',maxWidth:1280,maxHeight:1040,everyNthFrame:1});
  await p.waitForTimeout(1800);await action();await p.waitForTimeout(6000);await p.screenshot({path:`evidence/${name}.png`});const text=await p.evaluate(()=>document.body.innerText+'\n'+Array.from(document.querySelectorAll('input,textarea')).map(x=>x.value).join('\n'));fs.writeFileSync(`evidence/${name}.txt`,text);console.log(name,text);
  await cdp.send('Page.stopScreencast');cdp.off('Page.screencastFrame',listener);
  const end=Date.now()/1000;const lines=[];for(let i=0;i<frames.length;i++){lines.push(`file '${frames[i].file}'`);lines.push(`duration ${Math.max(.016,((frames[i+1]?.time??end)-frames[i].time)).toFixed(6)}`)}if(frames.length)lines.push(`file '${frames.at(-1).file}'`);
  fs.writeFileSync(path.join(dir,'frames.ffconcat'),lines.join('\n'));fs.writeFileSync(path.join(dir,'timestamps.json'),JSON.stringify(frames,null,2));
  const out=spawnSync('ffmpeg',['-y','-f','concat','-safe','0','-i',path.join(dir,'frames.ffconcat'),'-vf','fps=30,scale=1280:-2','-c:v','libx264','-preset','fast','-crf','24','-pix_fmt','yuv420p',`evidence/${name}.mp4`],{encoding:'utf8'});if(out.status)throw Error(out.stderr);
 }
 try {
  await p.reload();await ready();
  await record('flutter-proxy',async()=>{await p.getByRole('button',{name:'Run proxy case',exact:true}).click();await p.getByText(/Proxy setter completed successfully/).waitFor();});
  await p.reload();await ready();
  await cdp.send('Network.enable');
  await record('flutter-attributes',async()=>{
    await p.getByRole('button',{name:'Initialize Test Store',exact:true}).click();
    await p.getByText(/Real backend initialized/).waitFor({timeout:30000});
    await cdp.send('Network.emulateNetworkConditions',{offline:true,latency:0,downloadThroughput:-1,uploadThroughput:-1});
    await p.getByRole('button',{name:'Run attribute setters',exact:true}).click();
    await p.waitForFunction(()=>window.rcEventsJSON!=='[]',{timeout:30000});
    await p.waitForTimeout(1500);
  });
 } finally {
  await cdp.send('Network.emulateNetworkConditions',{offline:false,latency:0,downloadThroughput:-1,uploadThroughput:-1});
  fs.writeFileSync('evidence/web-network.json',JSON.stringify(network,null,2));fs.writeFileSync('evidence/web-console.json',JSON.stringify(consoleLog,null,2));await p.close(); await browser.close();
 }
})().catch(e=>{console.error(e);process.exit(1)});
