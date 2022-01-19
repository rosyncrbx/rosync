-- // Auto convert from string to type and from type to string \\ --
self={};
function self:Parse(a)
a=tostring(a);
local b=a;
-- // BOOLEAN \\ --
if(a=='true')then
b=true;
end;
if(a=='false')then
b=false;
end;
if(a=='nil')then
b=nil;
end;
-- // INT \\ --
if(tonumber(a))then
b=a;
end;
-- // VECTOR2 \\ --
if(((a:sub(1,12)=='Vector2.new(')and(a:sub(a:len(),a:len())==')'))and(#a:split','==2))then
b=a:sub(13);
local c=b:split',';
if((tonumber(c[1]))and(tonumber(c[2]:split')'[1])))then
b=Vector2.new(tonumber(c[1]),tonumber(c[2]:split')'[1]));
end;
end;
-- // VECTOR3 \\ --
if(((a:sub(1,12)=='Vector3.new(')and(a:sub(a:len(),a:len())==')'))and(#a:split','==3))then
b=a:sub(13);
local c=b:split',';
if(((tonumber(c[1]))and(tonumber(c[2])))and(tonumber(c[3]:split')'[1])))then
b=Vector3.new(tonumber(c[1]),tonumber(c[2]),tonumber(c[3]:split')'[1]));
end;
end;
-- // COLOR3HSV \\ --
if(((a:sub(1,15)=='Color3.fromHSV(')and(a:sub(a:len(),a:len())==')'))and(#a:split','==3))then
b=a:sub(16);
local c=b:split',';
if(((tonumber(c[1]))and(tonumber(c[2])))and(tonumber(c[3]:split')'[1])))then
b=Color3.fromHSV(tonumber(c[1]),tonumber(c[2]),tonumber(c[3]:split')'[1]));
end;
end;
-- // COLOR3RGB \\ --
if(((a:sub(1,15)=='Color3.fromRGB(')and(a:sub(a:len(),a:len())==')'))and(#a:split','==3))then
b=a:sub(16);
local c=b:split',';
if(((tonumber(c[1]))and(tonumber(c[2])))and(tonumber(c[3]:split')'[1])))then
b=Color3.fromRGB(tonumber(c[1]),tonumber(c[2]),tonumber(c[3]:split')'[1]));
end;
end;
-- // COLOR3NEW \\ --
if(((a:sub(1,11)=='Color3.new(')and(a:sub(a:len(),a:len())==')'))and(#a:split','==3))then
b=a:sub(12);
local c=b:split',';
local VAL1=tonumber(c[1]) or 0;
local VAL2=tonumber(c[2]) or 0;
local VAL3=tonumber(c[3]:split')'[1]) or 0;
if(tonumber(c[1]:split'/'[1]))then
VAL1=tonumber(c[1]:split'/'[1])/255;
end;
if(tonumber(c[2]:split'/'[1]))then
VAL2=tonumber(c[2]:split'/'[1])/255;
end;
if(tonumber(c[3]:split'/'[1]))then
VAL3=tonumber(c[3]:split'/'[1])/255;
end;
b=Color3.new(VAL1,VAL2,VAL3);
end;
-- // BRICKCOLOR \\ --
local c=table.pack(a:gsub('[\'"]',''))[1];
if((c:sub(1,15)=='BrickColor.new(')and(c:sub(c:len(),c:len())==')'))then
b=BrickColor.new(('%s'):format(c:sub(16,c:len()-1)));
end;
-- // ENUM \\ --
if(a:sub(1,5)=='Enum.')then
local c=a:split'.';table.remove(c,1);
b=Enum;
for _,d in next,c do
b=b[d];
end;
end;
-- // UDIM \\ --
a=table.pack(a:gsub('[{}]',''))[1];
if(((a:sub(1,9)=='UDim.new(')and(a:sub(a:len(),a:len())==')'))and(#a:split','==2))then
b=a:sub(10);
local c=b:split',';
if((tonumber(c[1]))and(tonumber(c[2]:split')'[1])))then
b=UDim.new(tonumber(c[1]),tonumber(c[2]:split')'[1]));
end;
end;
-- // UDIM2 \\ --
a=table.pack(a:gsub('[{}]',''))[1];
if(((a:sub(1,10)=='UDim2.new(')and(a:sub(a:len(),a:len())==')'))and(#a:split','==4))then
b=a:sub(11);
local c=b:split',';
if(((tonumber(c[1]))and((tonumber(c[2]))))and(((tonumber(c[3])))and(tonumber(c[4]:split')'[1]))))then
b=UDim2.new(tonumber(c[1]),tonumber(c[2]),tonumber(c[3]),tonumber(c[4]:split')'[1]));
end;
end;
-- // RETURN PARSED RESULT OR ORGINAL \\ --
return(b);
end;
function self:Stringify(a)
local b=a;
-- // BOOLEAN \\ --
if(a==false)then
b='false';
end;
if(a==true)then
b='true';
end;
if(a==nil)then
b='nil';
end;
-- // INT \\ --
if(tonumber(a))then
b=tostring(a);
end;
-- // VECTOR2 \\ --
if(typeof(a)=='Vector2')then
b=('Vector2.new(%s)'):format(table.concat(tostring(a):split', ',','));
end;
-- // VECTOR3 \\ --
if(typeof(a)=='Vector3')then
b=('Vector3.new(%s)'):format(table.concat(tostring(a):split', ',','));
end;
-- // COLOR3 \\ --
if(typeof(a)=='Color3')then
local c=tostring(a):split', ';
local d={};
table.insert(d,tostring(c[1]*255));table.insert(d,tostring(c[2]*255));table.insert(d,tostring(c[3]*255));
b=('Color3.fromRGB(%s)'):format(table.concat(d,','));
end;
-- // UDIM \\ --
if(typeof(a)=='UDim')then
b=('UDim.new(%s)'):format(table.concat(tostring(a):split', ',','));
end;
-- // UDIM2 \\ --
if(typeof(a)=='UDim2')then
b=('UDim2.new(%s)'):format(table.concat(table.pack(tostring(a):gsub('[{}]',''))[1]:split', ',','));
end;
-- // BRICKCOLOR \\ --
if(typeof(a)=='BrickColor')then
b=('BrickColor.new(\'%s\')'):format(tostring(a));
end;
-- // ENUM \\ --
if(typeof(a)=='EnumItem')then
b=('%s'):format(tostring(a));
end;
-- // RETURN STRINGIFIED RESULT OR ORGINAL \\ --
return(tostring(b));
end;
return(self);