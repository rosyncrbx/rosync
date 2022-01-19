local Version='0.1.5';
local RunService=Game:service'RunService';if(RunService:IsRunning())then return;end;local TweenService=Game:service'TweenService';ypcall(function()for a,b in next,_G['__R_o_s_y_n_c_M_o_d_u_l_e_s__'] do ypcall(function()b:Unmount();end);end;end);if(_G['__ROSYNC__MUTEX__']~=nil)then warn'[RoSync]: To finish updating RoSync please restart studio AFTER you save your work.';return;end;_G['__R_o_s_y_n_c_M_o_d_u_l_e_s__']={['Ready']=true;['Logger']=require(script.Parent:WaitForChild'Logger');['HttpUtil']=require(script.Parent:WaitForChild'HttpUtil');['Connection']=require(script.Parent:WaitForChild'Connection');['WatcherUtil']=require(script.Parent:WaitForChild'WatcherUtil');['ItemUtil']=require(script.Parent:WaitForChild'ItemUtil');['ItemProperties']=require(script.Parent:WaitForChild'ItemProperties');['TypeConverter']=require(script.Parent:WaitForChild'TypeConverter');};local Logger=_G['__R_o_s_y_n_c_M_o_d_u_l_e_s__'].Logger;local WatcherUtil=_G['__R_o_s_y_n_c_M_o_d_u_l_e_s__'].WatcherUtil;local Connection=_G['__R_o_s_y_n_c_M_o_d_u_l_e_s__'].Connection;local HttpUtil=_G['__R_o_s_y_n_c_M_o_d_u_l_e_s__'].HttpUtil;
local Gui;local Button;Logger.MessageOut:connect(function(m)if(m:lower():match'plugin "rosync" was denied script injection permission.')then Logger.Error('Rosync is not allowed the Script Injection permission. Rosync cannot continue without this permission as it is required for Live sync to sync scripts. Please grant it this permission.');Wait();Gui.Enabled=false;Button:SetActive(false);end;end);
local ContextMenu;Button=plugin:CreateToolbar'Rosync':CreateButton('Rosync','Show or hide the Rosync control menu','http://www.roblox.com/asset/?id=8437548740');Button.ClickableWhenViewportHidden=true;
local Connecting=false;Gui=plugin:CreateDockWidgetPluginGui('Rosync',DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float,false,false,300,200,300,200,true));for _,a in next,script.Parent:WaitForChild'UI':children()do a.Parent=Gui;end;Gui.Title='Rosync';Gui.Name='Rosync';Button.Click:connect(function()local Script=Instance.new'Script';Script.Parent=Game.CoreGui;Script:remove();Gui.Enabled=(not(Gui.Enabled));end);Gui:GetPropertyChangedSignal'Enabled':connect(function()Button:SetActive(Gui.Enabled);end);Spawn(function()local Script=Instance.new'Script';Script.Parent=Game.CoreGui;Script:remove();Gui.Enabled=true;Button:SetActive(true);end);
local HomePage=Gui:WaitForChild'Home';local SpinnerPage=Gui:WaitForChild'Spinner';local ErrorPage=Gui:WaitForChild'Error';local ConnectedPage=Gui:WaitForChild'Connected';local ToolsPage=Gui:WaitForChild'Tools';
local ShowErrorPage=function(e,l)if(e:match'VersionMismatch')then ErrorPage.Main.Contents.Message.Text='It appears that your plugin may be out of date or the Rosync server is out of date.\nPlease update your plugin or update the server and try again.';ErrorPage.Main.Contents.CanvasPosition=Vector2.new(0,0);ErrorPage.Main.Contents.CanvasSize=UDim2.new(0,0,0,116);elseif(e:match'InitalSyncFail')then ErrorPage.Main.Contents.Message.Text='Something went wrong while syncing with the server.\nPlease try reconnecting to the server.';ErrorPage.Main.Contents.CanvasPosition=Vector2.new(0,0);ErrorPage.Main.Contents.CanvasSize=UDim2.new(0,0,0,0);elseif(e:match'DisconnectByError')then ErrorPage.Main.Contents.Message.Text='It appears that the server stopped responding.\nIt may have crashed so please restart it.';ErrorPage.Main.Contents.CanvasPosition=Vector2.new(0,0);ErrorPage.Main.Contents.CanvasSize=UDim2.new(0,0,0,0);else ErrorPage.Main.Contents.Message.Text='Couldn\'t connect to the Rosync server.\nPlease ensure that the server url and port are correct.';ErrorPage.Main.Contents.CanvasPosition=Vector2.new(0,0);ErrorPage.Main.Contents.CanvasSize=UDim2.new(0,0,0,0);end;Logger.Error(ErrorPage.Main.Contents.Message.Text);ErrorPage.Position=UDim2.new(-1,0,0,0);TweenService:Create(ErrorPage,TweenInfo.new(.4),{Position=UDim2.new(0,0,0,0)}):Play();TweenService:Create(l,TweenInfo.new(.4),{Position=UDim2.new(1,0,0,0)}):Play();Wait(.4);ErrorPage.Buttons.Okay.MouseButton1Click:wait();HomePage.Position=UDim2.new(-1,0,0,0);TweenService:Create(HomePage,TweenInfo.new(.4),{Position=UDim2.new(0,0,0,0)}):Play();TweenService:Create(ErrorPage,TweenInfo.new(.4),{Position=UDim2.new(1,0,0,0)}):Play();Wait(.4);Connecting=false;end;
HomePage:WaitForChild'Header':WaitForChild'Version'.Text='Version '..Version;ConnectedPage:WaitForChild'Header':WaitForChild'Version'.Text='Version '..Version;
HomePage:WaitForChild'Buttons':WaitForChild'Connect'.MouseButton1Click:connect(function()
if(Connecting)then return;end;
Connecting=true;
SpinnerPage.Spinner.Icon.Rotation=0;
SpinnerPage.Label.Text='Connecting';
SpinnerPage.Position=UDim2.new(-1,0,0,0);
TweenService:Create(HomePage,TweenInfo.new(.4),{Position=UDim2.new(1,0,0,0)}):Play();
TweenService:Create(SpinnerPage,TweenInfo.new(.4),{Position=UDim2.new(0,0,0,0)}):Play();
Wait(.4);
local ServerUrl='http://';
local PName='';local PId='';
local SessionId='';
if((table.pack(table.pack(table.pack(table.pack(HomePage.ServerUrl.Host.Text:gsub('http://',''))[1]:gsub('https://',''))[1]:gsub('/',''))[1]:gsub(':',''))[1]):match('%a'))then ServerUrl=ServerUrl..(table.pack(table.pack(table.pack(table.pack(HomePage.ServerUrl.Host.Text:gsub('http://',''))[1]:gsub('https://',''))[1]:gsub('/',''))[1]:gsub(':',''))[1]);else ServerUrl='http://localhost';end;if(HomePage.ServerUrl.Port.Text~='0')then if(tonumber(table.pack(HomePage.ServerUrl.Port.Text:gsub(':',''))[1]))then ServerUrl=ServerUrl..':'..table.pack(HomePage.ServerUrl.Port.Text:gsub(':',''))[1];else ServerUrl=ServerUrl..':14812';end;end;
local Success,Error=ypcall(function()
if(ServerUrl:match'repl.co')then
error'Error';
end;
local Result=HttpUtil.Request(ServerUrl..'/rosyncserverinfo','GET',{},5);
local ServerInfo=HttpUtil.ParseJSON(Result.Body);
if((not(ServerInfo.Success))or(not(Result.Success)))then
error'Error';
end;
ServerInfo=ServerInfo['Data'];
if(ServerInfo['IsRosyncServer'])then
PName=ServerInfo['PName'];
if((PName=='')or(PName==nil))then
error'Error';
end;
PId=ServerInfo['PId'];
if((PId=='')or(PId==nil))then
error'Error';
end;
SessionId=ServerInfo['SessionId'];
if((SessionId=='')or(SessionId==nil)or(SessionId:len()~=10))then
error'Error';
end;
if(Version~=ServerInfo['Version'])then
error'VersionMismatch';
end;
else
error'Error';
end;
end);
local Success1,Error1;
if(not(Success)and(not(Error:match'VersionMismatch')))then
if(ServerUrl:match'.repl.co')then else Logger.Error'Couldn\'t connect to server using specified port. Trying with another port.';end;
Success1,Error1=ypcall(function()
ServerUrl='http:'..ServerUrl:split':'[2];
local Result=HttpUtil.Request(ServerUrl..'/rosyncserverinfo','GET',{},5);
local ServerInfo=HttpUtil.ParseJSON(Result.Body);
if((not(ServerInfo.Success))or(not(Result.Success)))then
error'Error';
end;
ServerInfo=ServerInfo['Data'];
if(ServerInfo['IsRosyncServer'])then
PName=ServerInfo['PName'];
if((PName=='')or(PName==nil))then
error'Error';
end;
PId=ServerInfo['PId'];
if((PId=='')or(PId==nil))then
error'Error';
end;
SessionId=ServerInfo['SessionId'];
if((SessionId=='')or(SessionId==nil)or(SessionId:len()~=10))then
error'Error';
end;
if(Version~=ServerInfo['Version'])then
error'VersionMismatch';
end;
else
error'Error';
end;
end);
end;
if((Success)or(Success1))then
Connection:connected(ServerUrl,SessionId,PId);
ConnectedPage.Details.Contents.PName.Text=PName;
SpinnerPage.Label.Text='Syncing';
else
if(Error1)then Error=Error1;end;
ShowErrorPage(Error,SpinnerPage);
end;
end);
HomePage:WaitForChild'Buttons':WaitForChild'Connect'.MouseEnter:connect(function()TweenService:Create(HomePage.Buttons.Connect,TweenInfo.new(.15),{BackgroundColor3=Color3.new(.392157,.392157,.392157);}):Play();end);
HomePage:WaitForChild'Buttons':WaitForChild'Connect'.MouseLeave:connect(function()TweenService:Create(HomePage.Buttons.Connect,TweenInfo.new(.15),{BackgroundColor3=Color3.new(.313725,.313725,.313725);}):Play();end);
ErrorPage:WaitForChild'Buttons':WaitForChild'Okay'.MouseEnter:connect(function()TweenService:Create(ErrorPage.Buttons.Okay,TweenInfo.new(.15),{BackgroundColor3=Color3.new(.392157,.392157,.392157);}):Play();end);
ErrorPage:WaitForChild'Buttons':WaitForChild'Okay'.MouseLeave:connect(function()TweenService:Create(ErrorPage.Buttons.Okay,TweenInfo.new(.15),{BackgroundColor3=Color3.new(.313725,.313725,.313725);}):Play();end);
ConnectedPage:WaitForChild'Buttons':WaitForChild'Tools'.MouseEnter:connect(function()TweenService:Create(ConnectedPage.Buttons.Tools,TweenInfo.new(.15),{BackgroundColor3=Color3.new(.392157,.392157,.392157);}):Play();end);
ConnectedPage:WaitForChild'Buttons':WaitForChild'Tools'.MouseLeave:connect(function()TweenService:Create(ConnectedPage.Buttons.Tools,TweenInfo.new(.15),{BackgroundColor3=Color3.new(.313725,.313725,.313725);}):Play();end);
ConnectedPage:WaitForChild'Details':WaitForChild'Disconnect'.MouseEnter:connect(function()TweenService:Create(ConnectedPage.Details.Disconnect,TweenInfo.new(.15),{BackgroundTransparency=.4;}):Play();end);
ConnectedPage:WaitForChild'Details':WaitForChild'Disconnect'.MouseLeave:connect(function()TweenService:Create(ConnectedPage.Details.Disconnect,TweenInfo.new(.15),{BackgroundTransparency=.2;}):Play();end);
ToolsPage:WaitForChild'Topbar':WaitForChild'Back'.MouseEnter:connect(function()TweenService:Create(ToolsPage.Topbar.Back,TweenInfo.new(.15),{BackgroundTransparency=.7;}):Play();end);
ToolsPage:WaitForChild'Topbar':WaitForChild'Back'.MouseLeave:connect(function()TweenService:Create(ToolsPage.Topbar.Back,TweenInfo.new(.15),{BackgroundTransparency=1;}):Play();end);
ToolsPage:WaitForChild'Topbar':WaitForChild'Back'.MouseButton1Click:connect(function()
ConnectedPage.Position=UDim2.new(-1,0,0,0);
TweenService:Create(ConnectedPage,TweenInfo.new(.4),{Position=UDim2.new(0,0,0,0)}):Play();
TweenService:Create(ToolsPage,TweenInfo.new(.4),{Position=UDim2.new(1,0,0,0)}):Play();
end);
ConnectedPage:WaitForChild'Details':WaitForChild'Disconnect'.MouseButton1Click:connect(function()
SpinnerPage.Spinner.Icon.Rotation=0;
SpinnerPage.Label.Text='Disconnecting';
SpinnerPage.Position=UDim2.new(-1,0,0,0);
TweenService:Create(SpinnerPage,TweenInfo.new(.4),{Position=UDim2.new(0,0,0,0)}):Play();
TweenService:Create(ConnectedPage,TweenInfo.new(.4),{Position=UDim2.new(1,0,0,0)}):Play();
Wait(.4);
Connection:disconnect();
end);
ConnectedPage:WaitForChild'Buttons':WaitForChild'Tools'.MouseButton1Click:connect(function()
ToolsPage.Position=UDim2.new(-1,0,0,0);
TweenService:Create(ToolsPage,TweenInfo.new(.4),{Position=UDim2.new(0,0,0,0)}):Play();
TweenService:Create(ConnectedPage,TweenInfo.new(.4),{Position=UDim2.new(1,0,0,0)}):Play();
end);
Connection.on'Error':connect(function(NotLoaded,Error)
WatcherUtil:EmptyQueue();
if(NotLoaded)then
ShowErrorPage(Error,SpinnerPage);
else
ShowErrorPage(Error,ConnectedPage);
end;
end);
Connection.on'Disconnected':connect(function(Reason)
WatcherUtil:EmptyQueue();
if(Reason=='UserDisconnect')then
HomePage.Position=UDim2.new(-1,0,0,0);
TweenService:Create(HomePage,TweenInfo.new(.4),{Position=UDim2.new(0,0,0,0)}):Play();
TweenService:Create(SpinnerPage,TweenInfo.new(.4),{Position=UDim2.new(1,0,0,0)}):Play();
Wait(.4);
Connecting=false;
end;
end);
Connection.on'FinishedInitialSync':connect(function()
ConnectedPage.Position=UDim2.new(-1,0,0,0);
TweenService:Create(ConnectedPage,TweenInfo.new(.4),{Position=UDim2.new(0,0,0,0)}):Play();
TweenService:Create(SpinnerPage,TweenInfo.new(.4),{Position=UDim2.new(1,0,0,0)}):Play();
end);
Spawn(function()while(true)do if(SpinnerPage.Spinner.Icon.Rotation>=360)then SpinnerPage.Spinner.Icon.Rotation=0;end;SpinnerPage.Spinner.Icon.Rotation+=20;Wait();end;end);
Wait();script.Parent:remove();
_G['__ROSYNC__MUTEX__']=true;
_G['Rosync']={}; -- TODO: make api for cmd bar (cmdbar api for Rosync) --