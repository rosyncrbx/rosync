local Syncing=true;local HttpUtil;local ItemUtil;local Logger;local Connection;local ItemProperties;local TypeConverter;local WatcherUtil;local Disconnected=true;ypcall(function()WatcherUtil:UnwatchAll();end);local ServerUrl='';local SessionId='';local __events={['Error']={};['Disconnect']={};['FinishedInitialSync']={};['Sync']={};};Spawn(function()repeat until(_G['__R_o_s_y_n_c_M_o_d_u_l_e_s__'].Ready);HttpUtil=_G['__R_o_s_y_n_c_M_o_d_u_l_e_s__'].HttpUtil;ItemUtil=_G['__R_o_s_y_n_c_M_o_d_u_l_e_s__'].ItemUtil;Logger=_G['__R_o_s_y_n_c_M_o_d_u_l_e_s__'].Logger;Connection=_G['__R_o_s_y_n_c_M_o_d_u_l_e_s__'].Connection;ItemProperties=_G['__R_o_s_y_n_c_M_o_d_u_l_e_s__'].ItemProperties;TypeConverter=_G['__R_o_s_y_n_c_M_o_d_u_l_e_s__'].TypeConverter;WatcherUtil=_G['__R_o_s_y_n_c_M_o_d_u_l_e_s__'].WatcherUtil;end);
self={};
function self:connected(SU,SI,PId)
ServerUrl=SU;
SessionId=SI;
Logger.Log('Connected to server '..ServerUrl);
Disconnected=false;
Spawn(function()
Syncing=true;
-- sync game --
local Success,Error=ypcall(function()
local Result=HttpUtil.Request(ServerUrl..'/getsrc','GET',{},60);
local Parsed=HttpUtil.ParseJSON(Result.Body);
if((not(Result.Success))or(not(Parsed.Success)))then Disconnected=true;ypcall(function()WatcherUtil:UnwatchAll();end);for _,a in next,__events.Error do Spawn(function()a:Fire(true,'InitalSyncFail');end);end;end;if(Disconnected)then return;end;
ItemUtil:ResetMappings();
ItemUtil:PurgeAllItems(PId);
for _,a in next,Parsed['Data']['src']do ItemUtil:CreateItem(a);end;for _,a in next,Parsed['Data']['cis']do ItemUtil:CreateCustomFolder(a);end;
ItemUtil:PurgeDeleted();
for _,a in next,__events.FinishedInitialSync do Spawn(function()a:Fire'';end);end;
Syncing=false;
end);
if(not(Success))then warn(Error);Disconnected=true;ypcall(function()WatcherUtil:UnwatchAll();end);for _,a in next,__events.Error do Spawn(function()a:Fire(false,'InitalSyncFail');end);end;end;if(Disconnected)then return;end;
-- start waiting for changes --
while(not(Disconnected))do
Wait(1);
if(Disconnected)then return;end;
local Success,Error=ypcall(function()
local Result=HttpUtil.Request(ServerUrl..'/changes','GET',{},15);
local Parsed=HttpUtil.ParseJSON(Result.Body);
if(((not(Result.Success))or(not(Parsed.Success)))and(not(Disconnected)))then Disconnected=true;ypcall(function()WatcherUtil:UnwatchAll();end);for _,a in next,__events.Error do Spawn(function()a:Fire(false,'DisconnectByError');end);end;end;if(Disconnected)then return;end;
if(Parsed['Data']['SessionId']~=SessionId)then Disconnected=true;ypcall(function()WatcherUtil:UnwatchAll();end);for _,a in next,__events.Error do Spawn(function()a:Fire(false,'DisconnectByError');end);end;end;if(Disconnected)then return;end;
for _,a in next,Parsed['Data']['src'] do
print(a)
if(a[1]=='Changed')then
local nd=a;
table.remove(nd,1);
ItemUtil:UpdateItem(a);
end;
if(a[1]=='Deleted')then
ypcall(function()
local Item=ItemUtil:GetItemFromId(a[2]);
local P=Item.Parent;
Item:remove();ItemUtil:PurgeEmptyParents(P);
end);
end;
if(a[1]=='Added')then
local nd=a;
table.remove(nd,1);
ItemUtil:CreateItem(a);
end;
end;
end);
if(not(Success))then warn(Error);Disconnected=true;ypcall(function()WatcherUtil:UnwatchAll();end);for _,a in next,__events.Error do Spawn(function()a:Fire(false,'DisconnectByError');end);end;end;if(Disconnected)then return;end;
end;
end);
end;
function self:disconnect()
Disconnected=true;ypcall(function()WatcherUtil:UnwatchAll();end);
ServerUrl='';
Wait(1);
Logger.Log('Disconnected from server',ServerUrl);
for _,a in next,__events.Disconnected do Spawn(function()a:Fire'UserDisconnect';end);end;
end;
self.on=function(a)
local b=Instance.new'BindableEvent';
if(not(__events[a]))then
__events[a]={};
end;
table.insert(__events[a],b);
return(b.Event);
end;
function self:SendChanges(a)
if(Disconnected)then return;end;
local Success,Error=ypcall(function()
local Result=HttpUtil.Request(ServerUrl..'/newchanges','POST',{['SessionId']=SessionId;['Content-Type']='application/json';},15,HttpUtil.StringifyJSON(a)['Data']);
local Parsed=HttpUtil.ParseJSON(Result.Body);
if(((not(Result.Success))or(not(Parsed.Success)))and(not(Disconnected)))then Disconnected=true;ypcall(function()WatcherUtil:UnwatchAll();end);for _,a in next,__events.Error do Spawn(function()a:Fire(false,'DisconnectByError');end);end;end;if(Disconnected)then return;end;
if(Parsed['Data']['SessionId']~=SessionId)then Disconnected=true;ypcall(function()WatcherUtil:UnwatchAll();end);for _,a in next,__events.Error do Spawn(function()a:Fire(false,'DisconnectByError');end);end;end;if(Disconnected)then return;end;
--warn'Changes were sent!'
end);
if(not(Success))then Disconnected=true;ypcall(function()WatcherUtil:UnwatchAll();end);for _,a in next,__events.Error do Spawn(function()a:Fire(false,'DisconnectByError');end);end;end;if(Disconnected)then return;end;
end;
function self:GetDisconnected()return(Disconnected);end;function self:GetSyncing()return(Syncing);end;return(self);