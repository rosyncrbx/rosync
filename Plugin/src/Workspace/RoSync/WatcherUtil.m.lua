local CallBacks={};local PCons={};local ST={};local SCP={};local CConnection;local Selection=Game:service'Selection';local LastSelected={};local Unmounted=false;local HttpUtil;local ItemUtil;local Logger;local Connection;local ItemProperties;local TypeConverter;local WatcherUtil;local Queue={};local WatchList={};local ConList={};local ConList2={};local Names={};local IsTeamCreate=false;Spawn(function()while(true)do if(IsTeamCreate)then return;end;if(#Game.Players:players()>0)then IsTeamCreate=true;--[[Logger.Error('Team create is currently active, if you edit a script inside of studio it wil be placed in the PendingScripts folder, This is to prevent people working on the file not loosing their changes, Check the studio output for what the file is located.');]]end;Wait();end;end);Spawn(function()repeat until(_G['__R_o_s_y_n_c_M_o_d_u_l_e_s__'].Ready);HttpUtil=_G['__R_o_s_y_n_c_M_o_d_u_l_e_s__'].HttpUtil;ItemUtil=_G['__R_o_s_y_n_c_M_o_d_u_l_e_s__'].ItemUtil;Logger=_G['__R_o_s_y_n_c_M_o_d_u_l_e_s__'].Logger;Connection=_G['__R_o_s_y_n_c_M_o_d_u_l_e_s__'].Connection;ItemProperties=_G['__R_o_s_y_n_c_M_o_d_u_l_e_s__'].ItemProperties;TypeConverter=_G['__R_o_s_y_n_c_M_o_d_u_l_e_s__'].TypeConverter;WatcherUtil=_G['__R_o_s_y_n_c_M_o_d_u_l_e_s__'].WatcherUtil;
-- Handle team create commits --
CConnection=Logger.MessageOut:connect(function(a)
if(IsTeamCreate)then
local b=a:split' ';table.remove(b,1);
local c=table.concat(b,' ');
if(c:sub(1,34)=='committed a new version of script ')then
local d=a:split(' ')[1]; -- username of who commited change
local e=c:sub(35):split'.';
local f=Game;for _,g in next,e do ypcall(function()f=f:FindFirstChild(g);end);end;
local Id=f:GetAttribute'RoSyncId';
if((Id)and(f:GetAttribute'RoSyncItem'))then
Logger.Log('Syncing changes from '..d);
table.insert(Queue,{['Type']='ScriptUpdated';['Source']=f.Source;['Id']=Id;});
end;
end;
end;
end);
end);
-- Selection handler --
SConnection=Selection.SelectionChanged:connect(function()LastSelected=Selection:Get();end);
-- Queue handler --
Spawn(function()
while(true)do
if(Unmounted)then return;end;
Wait(1);
local a,b=ypcall(function()
if(Connection:GetDisconnected())then
Queue={};
else
-- send queue --
if(#Queue>0)then
--warn'Sending queue!';
local OQ=Queue;Queue={};
Connection:SendChanges(OQ);
end;
end;
end);if(b)then warn(b);end;
end;
end);
-- Pending changes handler --
Spawn(function()
while(true)do
if(IsTeamCreate)then
break;
end;
for a,b in next,ST do
if(SCP[a])then
if((tick()-b>1)and(SCP[a]))then
SCP[a]=false;
table.insert(Queue,{['Type']='ScriptUpdated';['Source']=a.Source;['Id']=a:GetAttribute'RoSyncId';});
end;
end;
end;
Wait();
end;
end);
self={};
function self:Unmount()
Unmounted=true;
SConnection:disconnect();
CConnection:disconnect();
self:EmptyQueue();
self:UnwatchAll();
end;
function self:EmptyQueue()Queue={};end;
function self:Watch(a,CustomItem)
WatchList[a]=true;
Names[a]=a.Name;
if((a:isA'Script')or(a:isA'LocalScript')or(a:isA'ModuleScript'))then
SCP[a]=false;
ST[a]=tick();
end;
Spawn(function()
for c,d in next,CallBacks do
if((d.Name==a.Name)and(d.Parent==a.Parent))then
d:SetAttribute('RoSyncId',0);
self:Unwatch(d);
d:remove();
end;
end;
end);
-- PROPERTY CHANGE --
PCons[a]=a:GetPropertyChangedSignal'Parent':connect(function()if(not(PCons[a]))then return;end;if(a.Parent==nil)then if(Connection:GetSyncing())then end;table.insert(Queue,{['Type']='ItemDeleted';['Id']=a:GetAttribute'RoSyncId';});WatchList[a]=nil;ConList[a]:disconnect()ConList2[a]:disconnect();return;end;end);
ConList[a]=a.Changed:connect(function(b)
if(not(WatchList[a]))then ConList[a]:disconnect()ConList2[a]:disconnect();return;end;if(a:GetAttribute(b))then return;end;local Id=a:GetAttribute'RoSyncId';
local Canceled=false;if(b=='Name')then if(a.Name:match'[\/:*?"<>|]')then a.Name=table.pack(a.Name:gsub('[\/:*?"<>|]',''))[1];if(a.Name==Names[a])then Canceled=true;return;end;Names[a]=a.Name;end;if(a.Name==Names[a])then Canceled=true;end;if(Canceled)then return;end;end;
if((a:isA'Script')or(a:isA'LocalScript')or(a:isA'ModuleScript'))then
if((b=='Source')and(not(IsTeamCreate)))then
ST[a]=tick();
SCP[a]=true;
return;
end;
if(b=='Name')then
local acn='.lua';if(a:isA'LocalScript')then acn='.c.lua';end;if(a:isA'ModuleScript')then acn='.m.lua';end;
table.insert(Queue,{['Type']='PropertyChanged';['Property']='Name';['New']=('%s%s'):format(a.Name,acn);['Id']=Id;});
return;
end;
if(b=='Parent')then
--[[
* GET NEW PATH
* CONVERT TO FS PATH
]]
end;
else
if(b=='Name')then
if(CustomItem)then
table.insert(Queue,{['Type']='PropertyChanged';['Property']='Name';['New']=a.Name;['Id']=Id;});
table.insert(CallBacks,a);
else
table.insert(Queue,{['Type']='PropertyChanged';['Property']='Name';['New']=('%s%s'):format(a.Name,'.json');['Id']=Id;});
end;
return;
end;
if(b=='Parent')then
--[[
* GET NEW PATH
* CONVERT TO FS PATH
]]
end;
-- OTHER PROPERTY CHANGED --
if((b=='AbsoluteRotation')or(b=='AbsoluteSize')or(b=='Parent'))then
else
ypcall(function()
table.insert(Queue,{['Type']='PropertyChanged';['PropertyName']=b;['PropertyValue']=TypeConverter:Stringify(a[b]);['Id']=Id;});
end);
end;
end;
end);
-- ATTRIBUTE CHANGE --
ConList2[a]=a.AttributeChanged:connect(function()
if(not(WatchList[a]))then return;end;local Id=a:GetAttribute'RoSyncId';
--
end);
end;
function self:Unwatch(a)WatchList[a]=nil;PCons[a]=nil;end;function self:UnwatchAll()ST={};SCP={};WatchList={};for a,b in next,PCons do PCons[a]=nil;b:disconnect();end;end;
return(self);