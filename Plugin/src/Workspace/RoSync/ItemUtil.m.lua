local HttpUtil;local ItemUtil;local Logger;local Connection;local ItemProperties;local TypeConverter;local WatcherUtil;Spawn(function()repeat until(_G['__R_o_s_y_n_c_M_o_d_u_l_e_s__'].Ready);HttpUtil=_G['__R_o_s_y_n_c_M_o_d_u_l_e_s__'].HttpUtil;ItemUtil=_G['__R_o_s_y_n_c_M_o_d_u_l_e_s__'].ItemUtil;Logger=_G['__R_o_s_y_n_c_M_o_d_u_l_e_s__'].Logger;Connection=_G['__R_o_s_y_n_c_M_o_d_u_l_e_s__'].Connection;ItemProperties=_G['__R_o_s_y_n_c_M_o_d_u_l_e_s__'].ItemProperties;TypeConverter=_G['__R_o_s_y_n_c_M_o_d_u_l_e_s__'].TypeConverter;WatcherUtil=_G['__R_o_s_y_n_c_M_o_d_u_l_e_s__'].WatcherUtil;end);
local ItemMappings={};
local PathMappings={};
local CustomMappings={};
self={};
function self:ResetMappings()
ItemMappings={};
PathMappings={};
CustomMappings={};
end;
function self:CreateItem(Meta,PId)
local Path=Game;
local FPath=Meta[1];
local Id=Meta[2];
local Data=Meta[3];
local CustomItem=Meta[4];
local a=FPath:sub(7):split'/';
if(CustomItem)then
self:CreateCustomFolder(Meta);
else
for b,c in next,a do
ypcall(function()
if(b==#a)then
-- // .LUA FILES \\ --
if(c:lower():sub(#c-3,#c)=='.lua')then
local Type='Script';
local IName=c:sub(1,#c-4);
local DCreate=false;
if(c:lower():sub(#c-5,#c)=='.c.lua')then
Type='LocalScript';
IName=c:sub(1,#c-6);
end;
if(c:lower():sub(#c-5,#c)=='.m.lua')then
Type='ModuleScript';
IName=c:sub(1,#c-6);
end;
for _,Item in next,Path:children() do
if(Item.Name==IName)then
if(Item.ClassName==Type)then
if(Item:GetAttribute'RoSyncItem'~=nil)then
DCreate=true;
Item.Source=Data;
--Item:SetAttribute('RoSyncPId',PId);
Item:SetAttribute('RoSyncId',Id);
Item:SetAttribute('RoSyncItem',true);
WatcherUtil:Watch(Item);
ItemMappings[Id]=Item;
PathMappings[Id]=FPath;
end;
end;
end;
end;
if(not(DCreate))then
local New=Instance.new(Type);
New.Parent=Path;
New.Name=IName;
New.Source=Data;
--New:SetAttribute('RoSyncPId',PId);
New:SetAttribute('RoSyncId',Id);
New:SetAttribute('RoSyncItem',true);
WatcherUtil:Watch(New);
ItemMappings[Id]=New;
PathMappings[Id]=FPath;
end;
end;
-- // .JSON FILES \\ --
if(c:lower():sub(#c-4,#c)=='.json')then
local Type='';
local IName=c:sub(1,#c-5);
local DCreate=false;
local JSON=HttpUtil.ParseJSON(Data);
local Properties=JSON.Data;
local Attributes={};
if(not(JSON.Success))then
Logger.Error('File '..FPath..' contains invalid json. Skipping.');
return;
end;
Type=(JSON.Data['ClassName'])or(JSON.Data['classname'])or(JSON.Data['Classname'])or('');if(typeof(JSON.Data['Attributes'])=='table')then Attributes=JSON.Data['Attributes'];end;
local New;ypcall(function()New=Instance.new(Type);end);
if(New==nil)then
Logger.Error('File '..FPath..' contains an invalid ClassName. Skipping.');
return;
end;
for _,Item in next,Path:children() do
if(Item.Name==IName)then
if(Item.ClassName==Type)then
if(Item:GetAttribute'RoSyncItem'~=nil)then
DCreate=true;
for PName,Value in next,Properties do
if((PName=='Parent')or(PName=='Name')or(PName=='ClassName')or(PName=='Attributes'))then else
ypcall(function()Item[PName]=TypeConverter:Parse(Value);end);
end;
end;
for AName,Value in next,Attributes do
if((AName=='RoSyncId')or(AName=='RoSyncItem')or(AName=='RoSyncPId'))then else
ypcall(function()Item:SetAttribute(AName,TypeConverter:Parse(Value));end);
end;
end;
for AName,_ in next,Item:GetAttributes() do
if(not(Attributes[AName]))then
if((AName=='RoSyncId')or(AName=='RoSyncItem')or(AName=='RoSyncPId'))then else
ypcall(function()Item:SetAttribute(AName,nil);end);
end;
end;
end;
--New:SetAttribute('RoSyncPId',PId);
New:SetAttribute('RoSyncId',Id);
New:SetAttribute('RoSyncItem',true);
WatcherUtil:Watch(New);
ItemMappings[Id]=Item;
PathMappings[Id]=FPath;
end;
end;
end;
end;
if(not(DCreate))then
New.Parent=Path;
New.Name=IName;
for PName,Value in next,Properties do
if((PName=='Parent')or(PName=='Name')or(PName=='ClassName')or(PName=='Attributes'))then else
ypcall(function()New[PName]=TypeConverter:Parse(Value);end);
end;
end;
for AName,Value in next,Attributes do
if((AName=='RoSyncId')or(AName=='RoSyncItem')or(AName=='RoSyncPId'))then else
ypcall(function()New:SetAttribute(AName,TypeConverter:Parse(Value));end);
end;
end;
--New:SetAttribute('RoSyncPId',PId);
New:SetAttribute('RoSyncId',Id);
New:SetAttribute('RoSyncItem',true);
WatcherUtil:Watch(New);
ItemMappings[Id]=New;
PathMappings[Id]=FPath;
end;
end;
else
if(not(Path:FindFirstChild(c)))then
local d=Instance.new'Folder';
d.Name=c;
d.Parent=Path;
WatcherUtil:Watch(d);
end;
Path=Path:FindFirstChild(c);
end;
end);
end;
end;
end;
function self:UpdateItem(Meta,PId)
local FPath=Meta[1];
local Id=Meta[2];
local Data=Meta[3];
local CustomItem=Meta[4];
local Attributes={};
local Item=self:GetItemFromId(Id);
if(CustomItem)then
local JSON=HttpUtil.ParseJSON(Data);
if(not(JSON.Success))then
return;
end;
local New;ypcall(function()New=Instance.new((JSON.Data['ClassName'])or(JSON.Data['classname'])or(JSON.Data['Classname'])or(''));end);
if(New==nil)then
return;
end;
if(typeof(JSON.Data['Attributes'])=='table')then Attributes=JSON.Data['Attributes'];end;
for PName,Value in next,JSON.Data do
if((PName=='Parent')or(PName=='Name')or(PName=='ClassName')or(PName=='Attributes'))then else
ypcall(function()Item[PName]=TypeConverter:Parse(Value);end);
end;
end;
for AName,Value in next,Attributes do
if((AName=='RoSyncId')or(AName=='RoSyncItem')or(AName=='RoSyncPId'))then else
ypcall(function()Item:SetAttribute(AName,TypeConverter:Parse(Value));end);
end;
end;
if(Item.ClassName~=New.ClassName)then
WatcherUtil:Unwatch(Item);
Item:remove();
self:CreateCustomFolder(Meta);
end;
else
if(Item)then
--// LUA FILES \\--
if(Item.ClassName:match'Script')then
Item.Source=Data;
else
--// JSON FILES \\--
local FPath=PathMappings[Id];
local JSON=HttpUtil.ParseJSON(Data);
local Properties=JSON.Data;
local Attributes={};
local Type='';
if(not(JSON.Success))then
Logger.Error('File '..FPath..' contains invalid json. Skipping.');
return;
end;
Type=(JSON.Data['ClassName'])or(JSON.Data['classname'])or(JSON.Data['Classname'])or('');if(typeof(JSON.Data['Attributes'])=='table')then Attributes=JSON.Data['Attributes'];end;
local New;ypcall(function()New=Instance.new(Type);end);
if(New==nil)then
Logger.Error('File '..FPath..' contains an invalid ClassName. Skipping.');
return;
end;
if(Item.ClassName~=Type)then
New.Parent=Item.Parent;
New.Name=Item.Name;
--New:SetAttribute('RoSyncPId',PId);
New:SetAttribute('RoSyncId',Id);
New:SetAttribute('RoSyncItem',true);
WatcherUtil:Watch(New);
ItemMappings[Id]=New;
WatcherUtil:Unwatch(Item);
Item:remove();
Item=New;
end;
for PName,Value in next,Properties do
if((PName=='Parent')or(PName=='Name')or(PName=='ClassName')or(PName=='Attributes'))then else
ypcall(function()Item[PName]=TypeConverter:Parse(Value);end);
end;
end;
for AName,Value in next,Attributes do
if((AName=='RoSyncId')or(AName=='RoSyncItem')or(AName=='RoSyncPId'))then else
ypcall(function()Item:SetAttribute(AName,TypeConverter:Parse(Value));end);
end;
end;
for AName,_ in next,Item:GetAttributes() do
if(not(Attributes[AName]))then
if((AName=='RoSyncId')or(AName=='RoSyncItem')or(AName=='RoSyncPId'))then else
ypcall(function()Item:SetAttribute(AName,nil);end);
end;
end;
end;
end;
else
self:CreateItem(Meta,PId);
end;
end;
end;
function self:GetItemFromId(a)
return(ItemMappings[a]);
end;
function self:PurgeDeleted()
local All={};
for _,a in next,Game:children() do
ypcall(function()
for _,b in next,a:GetDescendants() do
if(b:GetAttribute'RoSyncItem'~=nil)then
table.insert(All,b);
end;
end;
end);
end;
for _,a in next,All do
if(ItemMappings[a:GetAttribute'RoSyncId']~=a)then
if(CustomMappings[a])then else
local P=a.Parent;
a:remove();
self:PurgeEmptyParents(P);
end;
end;
end;
end;
function self:PurgeEmptyParents(a)
while(true)do
local b=a.Parent;
if(#a:children()==0)then
ypcall(function()a:remove();end);
else
break;
end;
a=b;
Wait();
end;
end;
function self:PurgeAllItems(PId)
for _,a in next,Game:children() do
ypcall(function()
for _,b in next,a:GetDescendants() do
if((b:GetAttribute'RoSyncItem'~=nil)and(b:GetAttribute'RoSyncPId'~=PId))then
b:remove();
end;
end;
end);
end;
end;
function self:CreateCustomFolder(Meta)
local Path=Game;
local FPath=Meta[1];
local Id=Meta[2];
local Data=Meta[3];
local a=FPath:sub(7):split'/';
local JSON=HttpUtil.ParseJSON(Data);
local Attributes={};
if(not(JSON.Success))then
return;
end;
for b,c in next,a do
ypcall(function()
if(b==#a)then
local New;ypcall(function()New=Instance.new((JSON.Data['ClassName'])or(JSON.Data['classname'])or(JSON.Data['Classname'])or('Folder'));end);
if(New==nil)then
return;
end;
New.Parent=Path;
New.Name=c;
if(typeof(JSON.Data['Attributes'])=='table')then Attributes=JSON.Data['Attributes'];end;
for PName,Value in next,JSON.Data do
if((PName=='Parent')or(PName=='Name')or(PName=='ClassName')or(PName=='Attributes'))then else
ypcall(function()New[PName]=TypeConverter:Parse(Value);end);
end;
end;
for AName,Value in next,Attributes do
if((AName=='RoSyncId')or(AName=='RoSyncItem')or(AName=='RoSyncPId'))then else
ypcall(function()New:SetAttribute(AName,TypeConverter:Parse(Value));end);
end;
end;
WatcherUtil:Watch(New,true);
ItemMappings[Id]=New;
PathMappings[Id]=FPath;
New:SetAttribute('RoSyncItem',true);
New:SetAttribute('RoSyncId',Id);
--New:SetAttribute('RoSyncPId',PId);
else
if(not(Path:FindFirstChild(c)))then
local d=Instance.new'Folder';
d.Name=c;
d.Parent=Path;
WatcherUtil:Watch(d);
end;
Path=Path:FindFirstChild(c);
end;
end);
end;
end;
return(self);