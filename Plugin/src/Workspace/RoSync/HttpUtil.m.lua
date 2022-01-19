local HttpService=Game:service'HttpService';local RunService=Game:service'RunService';local HttpUtil;local ItemUtil;local Logger;local Connection;local ItemProperties;local TypeConverter;local WatcherUtil;Spawn(function()repeat until(_G['__R_o_s_y_n_c_M_o_d_u_l_e_s__'].Ready);HttpUtil=_G['__R_o_s_y_n_c_M_o_d_u_l_e_s__'].HttpUtil;ItemUtil=_G['__R_o_s_y_n_c_M_o_d_u_l_e_s__'].ItemUtil;Logger=_G['__R_o_s_y_n_c_M_o_d_u_l_e_s__'].Logger;Connection=_G['__R_o_s_y_n_c_M_o_d_u_l_e_s__'].Connection;ItemProperties=_G['__R_o_s_y_n_c_M_o_d_u_l_e_s__'].ItemProperties;TypeConverter=_G['__R_o_s_y_n_c_M_o_d_u_l_e_s__'].TypeConverter;WatcherUtil=_G['__R_o_s_y_n_c_M_o_d_u_l_e_s__'].WatcherUtil;end);
self={};
function self.Request(a,b,c,d,e)
if(not(d))then
d=10;
end;
if(not(e))then
e={};
end;
assert(a,'Request URL was not provided');
assert(b,'Request Method was not provided');
assert(c,'Request Headers were not provided');
assert(typeof(a)=='string','Request URL provided was invalid (NOT A STRING)');
assert(typeof(b)=='string','Request Method provided was invalid (NOT A STRING)');
assert(typeof(c)=='table','Request Headers provided were invalid (NOT A TABLE)');
assert(typeof(d)=='number','Request Timeout provided was invalid (NOT A NUMBER)');
local f=b:upper();
assert(((f=='GET')or(f=='POST')),'Invalid Request Method was provided ('..f..')');
local RequestParameters;
local Response;
if(f=='POST')then
RequestParameters={Url=a;Method=f;Headers=c;Body=e;};
else
RequestParameters={Url=a;Method=f;Headers=c;};
end;
Spawn(function()
Delay(d+0.05,function()
if(Response==nil)then
Response={Success=false;StatusCode=524;StatusMessage='Timeout';Headers={};Body={};};
end;
end);
ypcall(function()
Response=HttpService:RequestAsync(RequestParameters);
end);
end);
while(Response==nil)do
Wait();
end;
return(Response);
end;
function self.ParseJSON(a)
local b={};
local c=ypcall(function()
b=HttpService:JSONDecode(a);
end);
return({Success=c;Data=b;});
end;
function self.StringifyJSON(a)
local b='{}';
local c=ypcall(function()
b=HttpService:JSONEncode(a);
end);
return({Success=c;Data=b;});
end;
return(self);