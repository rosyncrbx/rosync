const Version='0.1.5';let CustomItems=[];const express=require('express');const chokidar=require('chokidar');const md5=require('md5');const chalk=require('nanocolors');const fs=require('fs');const JSONEncode=JSON.stringify;const JSONDecode=JSON.parse;const GenerateProjectId=()=>{function GRDCFS(s){return(s.charAt(Math.floor(Math.random()*s.length)))};return Array.from({length:10}).map(()=>{return(GRDCFS('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'))}).join('');};const GenerateSessionId=()=>{function GRDCFS(s){return(s.charAt(Math.floor(Math.random()*s.length)))};return Array.from({length:10}).map(()=>{return(GRDCFS('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'))}).join('');};const SessionId=GenerateSessionId();const FileMap=new Map();const IdMap=new Map();let count=0;let FilesDebounce=new Map();
const ScanDirectories=(a)=>{let results=[];
fs.readdirSync(a).forEach((b)=>{
let c=fs.statSync(`${a}/${b}`);
if(c.isDirectory()){let d=ScanDirectories(`${a}/${b}`);d.forEach(e=>{results.push(e);});};
if(c.isFile()&&(b.toLowerCase().endsWith('.lua')||b.toLowerCase().endsWith('.json'))){
count++;results.push([`${a}/${b}`,count,fs.readFileSync(`${a}/${b}`).toString()]);FileMap.set(`${a}/${b}`,count);IdMap.set(count,`${a}/${b}`);
};
if(c.isFile()&&b.toLowerCase()=='config.ini'){
count++;CustomItems.push([`${a}`,count,fs.readFileSync(`${a}/${b}`).toString()]);FileMap.set(`${a}`,count);IdMap.set(count,`${a}`);
};
});return(results);};const RecentlySynced=new Map();const dirwatch=chokidar.watch('./src',{atomic:0,persistent:true});
/**
* @param {int} Port The port where to open the server on
* @returns {null}
*/
exports.StartServer=async(Port)=>{
try{
if(!(fs.existsSync(`./project.rosync`)&&fs.existsSync(`./src`))){console.error(chalk.red('It looks like no Rosync project has been initialized here. Use the init function to create one.'));return;};
let Config=JSONDecode(fs.readFileSync('./project.rosync'));
if(Config.version!==Version){
console.error(chalk.red('It looks like the Rosync project was made for an older version of Rosync. Upgrading...'));
this.fix();
};
let ServerReady=false;
let WatcherReady=false;
let Changes=[];
let app=express();
app.use(express.json());
app.listen(Port||14812,()=>{
let srt=setInterval(()=>{
if(WatcherReady){
clearInterval(srt);
console.log(chalk.blue(`Rosync server started on port ${Port||14812}`));
console.log(chalk.blue(`If you need help with your RoSync project make sure to check the documentation https://rosyncrbx.github.io/docs/`));
ServerReady=true;
};
},20);
});
app.get('/rosyncserverinfo',(q,s)=>{
if(!ServerReady){
return;
};
s.end(JSONEncode({"IsRosyncServer":"true","PName":Config.name,"Version":Version,"SessionId":SessionId,"PId":Config.id}));
});
app.get('/changes',(q,s)=>{
let OChanges=Changes;
Changes=[];
s.end(JSONEncode({"SessionId":SessionId,"src":OChanges}));
});
app.post('/newchanges',(q,s)=>{
s.end(JSONEncode({"IsRosyncServer":"true","PName":Config.name,"Version":Version,"SessionId":SessionId,"PId":Config.id}));
q.body.forEach(a=>{
// Property changed \\
if(a.Type=='PropertyChanged'){
// Name \\
if(a.Property=='Name'){
let Path=IdMap.get(a.Id);
let New=Path.replace(/\//g,'\\').split('\\');
New.pop();New.push(a.New);New=New.join('\\');
IdMap.set(a.Id,New);
FileMap.delete(Path);
FileMap.set(New.slice(2),a.Id);
fs.renameSync(Path,New);
return;
};
// Path \\
if(a.Property=='Path'){
// TODO
return;
};
// Other properties \\
try{
let New=JSONDecode(fs.readFileSync(IdMap.get(a.Id)));
New[a.PropertyName]=a.PropertyValue;
RecentlySynced.set(IdMap.get(a.Id),Date.now());
fs.writeFileSync(IdMap.get(a.Id),JSONEncode(New,null,4));
}catch{};
return;
};
if(a.Type=='ItemDeleted'){
let Path=IdMap.get(a.Id);
IdMap.delete(a.Id);
FileMap.delete(Path);
if(fs.existsSync(Path)){
if(fs.lstatSync(Path).isDirectory()){
fs.rmSync(Path,{recursive:true});
}else{
fs.unlinkSync(Path);
};
};
Changes.push(['Deleted',a.Id]);
return;
};
if(a.Type='ScriptUpdated'){
let hash=md5(a.Source);
if(FilesDebounce.get(a.Id)===hash){
}else{
FilesDebounce.set(a.Id,hash);
fs.writeFileSync(IdMap.get(a.Id),a.Source);
};
return;
};
});
});
app.get('/getsrc',(q,s)=>{
s.writeHead(200);
count=0;
let results=[];
CustomItems=[];
fs.readdirSync('./src').forEach((f)=>{
let fi=fs.statSync(`./src/${f}`);
if(fi.isDirectory()){
let Files=ScanDirectories(`./src/${f}`);
Files.forEach(e=>{results.push(e);});
};
if(fi.isFile()&&(f.toLowerCase().endsWith('.lua')||f.toLowerCase().endsWith('.json'))){
count++;results.push([`./src/${f}`,count,fs.readFileSync(`./src/${f}`).toString()]);FileMap.set(`./src/${f}`,count);IdMap.set(count,`./src/${f}`);
};
});
s.end(JSONEncode({"src":results,"SessionId":SessionId,"cis":CustomItems}));
});
dirwatch.on('add',(f)=>{
if(WatcherReady&&(f.toLowerCase().endsWith('.lua')||f.toLowerCase().endsWith('.json'))){
//console.log(`${f.replace('src\\','')} added`);
count++;Changes.push(['Added',`./${f.replace(/\\/g,'/')}`,count,fs.readFileSync(`./${f}`).toString()]);FileMap.set(`./${f.replace(/\\/g,'/')}`,count);IdMap.set(count,`./${f.replace(/\\/g,'/')}`);
};
if(WatcherReady&&f.toLowerCase().endsWith('config.ini')){
count++;Changes.push(['Added',`./${f.replace(/\\/g,'/').replace(/\/config.ini/gi,'')}`,count,fs.readFileSync(`./${f}`).toString(),true]);FileMap.set(`./${f.replace(/\\/g,'/').replace(/\/config.ini/gi,'')}`,count);IdMap.set(count,`./${f.replace(/\\/g,'/').replace(/\/config.ini/gi,'')}`);
};
});
dirwatch.on('change',(f)=>{
if(WatcherReady&&(f.toLowerCase().endsWith('.lua')||f.toLowerCase().endsWith('.json'))){
//console.log(`${f.replace('src\\','')} changed`);
let source=fs.readFileSync(f);
let hash=md5(source);
let id=FileMap.get(`./${f.replace(/\\/g,'/')}`);
if(FilesDebounce.get(id)===hash){
}else{
Changes.push(['Changed',`./${f.replace(/\\/g,'/')}`,id,fs.readFileSync(`./${f}`).toString()]);
};
};
if(WatcherReady&&f.toLowerCase().endsWith('config.ini')){
Changes.push(['Changed',`./${f.replace(/\\/g,'/').replace(/\/config.ini/gi,'')}`,FileMap.get(`./${f.replace(/\\/g,'/').replace(/\/config.ini/gi,'')}`),fs.readFileSync(`./${f}`).toString(),true]);
};
});
dirwatch.on('unlink',(f)=>{
if(WatcherReady&&(f.toLowerCase().endsWith('.lua')||f.toLowerCase().endsWith('.json'))){
//console.log(`${f.replace('src\\','')} removed`);
IdMap.delete(count);
let FMC=FileMap.get(`./${f.replace(/\\/g,'/')}`);
FileMap.delete(`./${f.replace(/\\/g,'/')}`);
IdMap.delete(FMC);
FilesDebounce.delete(FMC);
Changes.push(['Deleted',FMC]);
};
if(WatcherReady&&f.toLowerCase().endsWith('config.ini')){
IdMap.delete(count);
let FMC=FileMap.get(`./${f.replace(/\\/g,'/').replace(/\/config.ini/gi,'')}`);
FileMap.delete(`./${f.replace(/\\/g,'/').replace(/\/config.ini/gi,'')}`);
Changes.push(['Deleted',FMC]);
};
});
/*dirwatch.on('unlinkDir',(f)=>{
if(WatcherReady&&FileMap.get(`${f.replace(/\\/g,'/')}`)){
IdMap.delete(count);
let FMC=FileMap.get(`${f.replace(/\\/g,'/')}`);
FileMap.delete(`${f.replace(/\\/g,'/')}`);
Changes.push(['Deleted',FMC]);
};
});*/
dirwatch.once('ready',()=>{WatcherReady=true;});
}catch(e){
console.error(chalk.red('It looks like something went wrong while trying to start the Rosync project.'));
process.exit(0);
};
};
/**
* @param {string} Name The name of the new Rosync project
* @returns {null}
*/
exports.init=async(Name)=>{
if(!Name){
console.error(chalk.red('It looks like you forgot to provide a name for the new project.'));
process.exit(0);
};
try{
if(fs.existsSync(`./project.rosync`)||fs.existsSync(`./src`)){throw new Error('');};
fs.mkdirSync(`./src`);
let Locations=['Workspace','Players','Lighting','ReplicatedFirst','ReplicatedStorage','ServerScriptService','ServerStorage','StarterGui','StarterPack','StarterPlayer','StarterPlayer/StarterCharacterScripts','StarterPlayer/StarterPlayerScripts','Teams','SoundService','LocalizationService','TestService'];
let Files=[['ServerScriptService/README.lua','--[[\nThank you for using RoSync. If you have a feature request or a bug you would like to submit,\nGo to the official github and create an issue: https://github.com/xynnylol/rosync/issues\nIf you want to read the documentation feel free to do so here: https://xynnylol.github.io/rosync/docs/\nIf you have not used RoSync before I suggest that you read the documentation.\n]]']];
Locations.forEach(d=>{try{fs.mkdirSync(`./src/${d}`);}catch{};});
Files.forEach(f=>{try{fs.writeFileSync(`./src/${f[0]}`,f[1]);}catch{};});
fs.writeFileSync(`./project.rosync`,JSONEncode({"name":Name,"version":Version,"src":Locations,"id":GenerateProjectId()}));
}catch{
console.error(chalk.red('It looks like a Rosync project is already initialized in this location.'));
};
process.exit(0);
};
/**
* @returns {null}
*/
exports.fix=()=>{
return(new Promise(async(r)=>{
try{
if(!(fs.existsSync(`./project.rosync`)&&fs.existsSync(`./src`))){console.error(chalk.red('It looks like no Rosync project has been initialized here. Use the init function to create one.'));return;};
let Locations=['Workspace','Players','Lighting','ReplicatedFirst','ReplicatedStorage','ServerScriptService','ServerStorage','StarterGui','StarterPack','StarterPlayer','StarterPlayer/StarterCharacterScripts','StarterPlayer/StarterPlayerScripts','Teams','SoundService','LocalizationService','TestService'];
let Files=[['ServerScriptService/README.lua','--[[\nThank you for using RoSync. If you have a feature request or a bug you would like to submit,\nGo to the official github and create an issue: https://github.com/xynnylol/rosync/issues\nIf you want to read the documentation feel free to do so here: https://xynnylol.github.io/rosync/docs/\nIf you have not used RoSync before I suggest that you read the documentation.\n]]']];
Locations.forEach(d=>{try{fs.mkdirSync(`./src/${d}`);}catch{};});
Files.forEach(f=>{try{fs.writeFileSync(`./src/${f[0]}`,f[1]);}catch{};});
let NewData=JSONDecode(fs.readFileSync('./project.rosync'));
NewData.version=Version;
NewData.src=Locations;
if(!NewData.id){NewData.id=GenerateProjectId();};
fs.writeFileSync(`./project.rosync`,JSONEncode(NewData));
r();
return;
}catch{
console.error(chalk.red('Sorry something went wrong while trying to fix the Rosync project.'));
};
r();
process.exit(0);
}));
};