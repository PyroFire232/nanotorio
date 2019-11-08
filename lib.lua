function istable(v) return type(v)=="table" end
function isstring(v) return type(v)=="string" end
function isnumber(v) return type(v)=="number" end

function isvalid(v) return v and v.valid end


function new(x,a,b,c,d,e,f,g) local t,v=setmetatable({},x),rawget(x,"__init") if(v)then v(t,a,b,c,d,e,f,g) end return t end

local function toKeyValues(t) local r={} for k,v in pairs(t)do table.insert(r,{k=k,v=v}) end return r end
local function keyValuePairs(x) x.i=x.i+1 local kv=x.kv[x.i] if(not kv)then return end return kv.k,kv.v end
function RandomPairs(t,d) local rt=toKeyValues(t) for k,v in pairs(rt)do v.rand=math.random(1,1000000) end
	if(d)then table.sort(rt,function(a,b) return a.rand>b.rand end) else table.sort(rt,function(a,b) return a.rand>b.rand end) end
	return keyValuePairs, {i=0,kv=rt}
end


function table.Count(t) local x=0 for k in pairs(t)do x=x+1 end return x end
function table.First(t) for k,v in pairs(t)do return k,v end end
function table.Random(t) local c,i=table_size(t),1 if(c==0)then return end local rng=math.random(1,c) for k,v in pairs(t)do if(i==rng)then return v,k end i=i+1 end end
function table.HasValue(t,a) for k,v in pairs(t)do if(v==a)then return true end end return false end
function table.GetValueIndex(t,a) for k,v in pairs(t)do if(v==a)then return k end end return false end
function table.RemoveByValue(t,a) local i=table.GetValueIndex(t,a) if(i)then table.remove(t,i) end end
function table.insertExclusive(t,a) if(not table.HasValue(t,a))then return table.insert(t,a) end return false end
function table.deepmerge(s,t) for k,v in pairs(t)do if(istable(v) and s[k] and istable(s[k]))then if(table_size(v)==0)then s[k]=s[k] or {} else table.deepmerge(s[k],v) end else s[k]=v end end end
function table.merge(s,t) local x={} for k,v in pairs(s)do x[k]=v end for k,v in pairs(t)do x[k]=v end return x end

function table.KeyFromValue(t,x) for k,v in pairs(t)do if(v==x)then return k end end return false end


function math.round(x) return math.floor(x+0.5) end
function math.radtodeg(x) return x*(180/math.pi) end
function math.nroot(r,n) return n^(1/r) end
function math.sign(v) return v>0 and 1 or (v<0 and -1 or 0) end
function math.signx(v) return v>=0 and 1 or (v<0 and -1 or 0) end
math.uint32=4294967295

math.compass={east={1,0},west={-1,0},south={0,1},north={0,-1},se={1,1},sw={-1,1},ne={1,-1},nw={-1,-1}}

string.compass={"east","west","south","north"}
string.compasscorn={"nw","ne","sw","se"}
string.compassall={"east","west","south","north","nw","ne","sw","se"}
string.compassopp={east="west",west="east",north="south",south="north",nw="se",se="nw",sw="ne",ne="sw"}


vector={} local vectorMeta={__index=vector} setmetatable(vector,vectorMeta)
setmetatable(vectorMeta,{__index=function(t,k) if(k=="x")then return rawget(t,"k") or t[1] elseif(k=="y")then return rawget(t,"y") or t[2] end end})
function vectorMeta:__call(x,y) if(type(x)=="table")then return vector(vector.getx(x),vector.gety(x)) else return setmetatable({[1]=x or 0,[2]=y or 0,x=x or 0,y=y or 0},vector) end end
function vectorMeta.__tostring(v) return "{"..vector.getx(v) .. ", " .. vector.gety(v) .."}" end
function vector.__add(x,y) return vector.add(x,y) end
function vector.__sub(x,y) return vector.sub(x,y) end
function vector.__mul(x,y) return vector.mul(x,y) end
function vector.__div(x,y) return vector.div(x,y) end
function vector.__pow(x,y) return vector.pow(x,y) end
function vector.__mod(x,y) return vector.mod(x,y) end
function vector.__eq(x,y) return vector.equal(x,y) end
function vector.__lt(x,y) return vector.getx(x)<vector.getx(y) and vector.gety(x)<vector.gety(y) end
function vector.__le(x,y) return vector.getx(x)<=vector.getx(y) and vector.gety(x)<=vector.gety(y) end
function vector.getx(vec) return vec[1] or vec.x or 0 end
function vector.gety(vec) return vec[2] or vec.y or 0 end
function vector.raw(v) local x,y=vector.getx(v),vector.gety(v) return {x,y,x=x,y=y} end
function vector.add(va,vb) if(isnumber(va))then return vector(va+vb.x,va+vb.y) elseif(isnumber(vb))then return vector(va.x+vb,va.y+vb) end local x=va.x+vb.x local y=va.y+vb.y return vector(x,y) end
function vector.sub(va,vb) if(isnumber(va))then return vector(va-vb.x,va-vb.y) elseif(isnumber(vb))then return vector(va.x-vb,va.y-vb) end local x=va.x-vb.x local y=va.y-vb.y return vector(x,y) end
function vector.mul(va,vb) if(isnumber(va))then return vector(va*vb.x,va*vb.y) elseif(isnumber(vb))then return vector(va.x*vb,va.y*vb) end local x=va.x*vb.x local y=va.y*vb.y return vector(x,y) end
function vector.div(va,vb) if(isnumber(va))then return vector(va/vb.x,va/vb.y) elseif(isnumber(vb))then return vector(va.x/vb,va.y/vb) end local x=va.x/vb.x local y=va.y/vb.y return vector(x,y) end
function vector.pow(va,vb) if(isnumber(va))then return vector(va^vb.x,va^vb.y) elseif(isnumber(vb))then return vector(va.x^vb,va.y^vb) end local x=va.x^vb.x local y=va.y^vb.y return vector(x,y) end
function vector.mod(va,vb) if(isnumber(va))then return vector(va%vb.x,va%vb.y) elseif(isnumber(vb))then return vector(va.x%vb,va.y%vb) end local x=va.x%vb.x local y=va.y%vb.y return vector(x,y) end
function vector.abs(v) return vector(math.abs(v.x),math.abs(v.y)) end
function vector.normal(v) return v/vector.mag(v) end
function vector.mag(v) return vector.length(v)*vector(math.sign(v.x),math.sign(v.y)) end
function vector.sign(v) return vector(math.sign(v.x),math.sign(v.y)) end
function vector.equal(va,vb) return vector.getx(va)==vector.getx(vb) and vector.gety(va)==vector.gety(vb) end
function vector.pos(t) if(t.x)then t[1]=t.x elseif(t[1])then t.x=t[1] end if(t.y)then t[2]=t.y elseif(t[2])then t.y=t[2] end return t end
function vector.size(va,vb) return math.sqrt((va^2)+(vb^2)) end
function vector.distance(va,vb) return math.sqrt((va.x-vb.x)^2+(va.y-vb.y)^2) end
function vector.length(v) return math.sqrt(math.abs(vector.getx(v))^2+math.abs(vector.gety(v))^2) end
function vector.floor(v) return vector(math.floor(vector.getx(v)),math.floor(vector.gety(v))) end
function vector.round(v,k) return vector(math.round(v.x,k),math.round(v.y,k)) end
function vector.ceil(v) return vector(math.ceil(v.x),math.ceil(v.y)) end
function vector.min(va,vb) return vector(math.min(va.x,vb.x),math.min(va.y,vb.y)) end
function vector.max(va,vb) return vector(math.max(va.x,vb.x),math.max(va.y,vb.y)) end
function vector.clamp(v,vmin,vmax) return vector.min(vector.max(v.x,vmin.x),vmax.x) end
function vector.area(va,vb) local t={va,vb,left_top=va,right_bottom=vb} return t end
function vector.square(va,vb) if(isnumber(vb))then vb=vector(vb,vb) end local area={vector.add(va,vector.mul(vb,-0.5)),vector.add(va,vector.mul(vb,0.5))} area.left_top=area[1] area.right_bottom=area[2] return area end
function vector.playsound(pth,f,x) for k,v in pairs(game.connected_players)do if(v.surface.name==f)then v.play_sound{path=pth,position=x} end end end
function vector.isinbbox(p,a,b) local x,y=(p.x or p[1]),(p.y or p[2]) return not ( (x<(a.x or a[1]) or y<(a.y or a[2])) or (x>(b.x or b[1]) or y>(b.y or b[2]) ) ) end
function vector.inarea(v,a) local x,y=(v.x or v[1]),(v.y or v[2]) return not ( (x<(a[1].x or a[1][1]) or y<(a[1].y or a[1][2])) or (x>(a[2].x or a[2][1]) or y>(a[2].y or a[2][2]))) end
function vector.table(area) local t={} for x=area[1].x,area[2].x,1 do for y=area[1].y,area[2].y,1 do table.insert(t,vector(x,y)) end end return t end
function vector.circle(p,z) local t,c,d={},math.round(z/2) for x=p.x-c,p.x+c,1 do for y=p.y-c,p.y+c,1 do d=math.sqrt(((x-p.x)^2)+((y-p.y)^2)) if(d<=c)then table.insert(t,vector(x,y)) end end end return t end
function vector.circleEx(p,z) local t,c,d={},z/2 for x=p.x-c,p.x+c,1 do for y=p.y-c,p.y+c,1 do d=math.sqrt(((x-p.x)^2)+((y-p.y)^2)) if(d<c)then table.insert(t,vector(x,y)) end end end return t end
function vector.ovalInverted(p,z,curve) local t,xz,yz={},math.round(z.x/2),math.round(z.y/2) for x=-xz,xz do for y=-yz,yz do
	if((math.abs(x^2)*math.abs(y^2)) < math.abs(xz^2)*math.abs(yz^2)*(curve or 0.5))then table.insert(t,vector(vector.getx(p)+x,vector.gety(p)+y)) end
end end return t end
function vector.ovalFan(p,z,curve) local t,xz,yz={},math.round(z.x/2),math.round(z.y/2) for x=-xz,xz do for y=-yz,yz do
	local deg=math.radtodeg(180-math.atan2(x,y)*math.pi)
	if(not(math.abs(x)<math.abs(math.sin(deg/180)*xz) and math.abs(y)<math.abs(math.cos(deg/180)*yz) ))then table.insert(t,vector(vector.getx(p)+x,vector.gety(p)+y)) end
end end return t end
function vector.oval(p,z,curve) local t,xz,yz={},math.round(z.x/2),math.round(z.y/2) for x=-xz,xz do for y=-yz,yz do
	if( (x^2)/(xz^2)+(y^2)/(yz^2) <1 )then table.insert(t,vector(vector.getx(p)+x,vector.gety(p)+y)) end
end end return t end


function vector.LayTiles(tex,f,area) local t={} for x=area[1].x,area[2].x do for y=area[1].y,area[2].y do table.insert(t,{name=tex,position={x,y}}) end end f.set_tiles(t) return t end
function vector.LayCircle(tex,f,cir) local t={} for k,v in pairs(cir)do table.insert(t,{name=tex,position=v}) end f.set_tiles(t) return t end
function vector.LayBorder(tex,f,a) local t={} for x=a[1].x,a[2].x do table.insert(t,{name=tex,position=vector(x,a[1].y)}) end for y=a[1].y,a[2].y do table.insert(t,{name=tex,position=vector(a[1].x,y)}) end f.set_tiles(t) return t end
function vector.clearplayers(f,area,tpo) for k,v in pairs(players.find(f,area))do players.safeclean(v,tpo) end end
function vector.clear(f,area,tpo) local e=f.find_entities(area) for k,v in pairs(e)do if(v and v.valid)then
	if(v.type=="character")then if(tpo)then entity.safeteleport(v,f,tpo) end else entity.destroy(v) end
end end end
function vector.clearFiltered(f,area,tpo) for k,v in pairs(f.find_entities_filtered{type="character",invert=true,area=area})do if(v.force.name~="player" and v.force.name~="enemy" and v.name:sub(1,9)~="warptorio")then entity.destroy(v) end end end

function vector.snapclean(f,area) -- clean players because factorio likes to be glitchy about placing out of map tiles
	for k,v in pairs(f.find_entities_filtered{type="character",area=area})do entity.safeteleport(v.player,v.surface,v.position,true) end
end

vector.clean=vector.clear --alias
vector.cleanplayers=vector.clearplayers --alias
vector.cleanFiltered=vector.clearFiltered --alias


function vector.GridPos(pos,g) g=g or 0.5 return vector.round(vector(pos)/g) end
function vector.GridSnap(pos,g) g=g or 0.5 return vector.raw(vector(pos)*g) end -- *g+0.5
function vector.Snap(pos,g) g=g or 0.5 local x=vector.GridPos(pos,g) return vector.GridSnap(x) end



entity={}
function entity.protect(e,min,des) if(min~=nil)then e.minable=min end if(des~=nil)then e.destructible=des end return e end
function entity.spawn(f,n,pos,dir,t) t=t or {} local tx=t or {} tx.name=n tx.position={vector.x(pos),vector.y(pos)} tx.direction=dir tx.player=(t.player or game.players[1])
	tx.force=t.force or game.forces.player
	tx.raise_built=true --(t.raise_built~=nil and t.raise_built or true)
	local e=f.create_entity(tx) return e
end
entity.create=entity.spawn -- alias

function entity.destroy(e,r,c) if(e and e.valid)then e.destroy{raise_destroy=(r~=nil and r or true),do_cliff_correction=(c~=nil and c or true)} end end
function entity.ChestRequestMode(e) local cb=e.get_or_create_control_behavior() cb.circuit_mode_of_operation=defines.control_behavior.logistic_container.circuit_mode_of_operation.set_requests end
function entity.safeteleport(e,f,pos,bsnap) f=f or e.surface e.teleport(f.find_non_colliding_position(e.is_player() and "character" or e.name,pos or e.position,0,1,bsnap),f) end
function entity.shouldClean(v) return (v.force.name~="player" and v.force.name~="enemy" and v.name:sub(1,9)~="warptorio") end
function entity.tryclean(v) if(v.valid and entity.shouldClean(v))then entity.destroy(v) end end


entity.copy={} entity.copy.__index=entity.copy setmetatable(entity.copy,entity.copy)
function entity.copy.__call(e) end
function entity.copy.chest(a,b) local c=b.get_inventory(defines.inventory.chest) for k,v in pairs(a.get_inventory(defines.inventory.chest).get_contents())do c.insert{name=k,count=v} end
	local net=a.circuit_connection_definitions
	for c,tbl in pairs(net)do b.connect_neighbour{target_entity=tbl.target_entity,wire=tbl.wire,source_circuit_id=tbl.source_circuit_id,target_circuit_id=tbl.target_circuit_id} end
end
function entity.emitsound(e,path) for k,v in pairs(game.connected_players)do if(v.surface==e.surface)then v.play_sound{path=path,position=e.position} end end end


players={}
function players.find(f,area) local t={} for k,v in pairs(game.players)do if(v.surface==f and vector.inarea(v.position,area))then table.insert(t,v) end end return t end
function players.playsound(path,f,pos)
	if(f)then f.play_sound{path=path,position=pos} else game.forces.player.play_sound{path=path,position=pos} end
end
function players.safeclean(e,tpo) local f=e.surface local pos=tpo or e.position
	if(tpo or f.count_entities_filtered{area=vector.square(vector.pos(pos),vector(0.5,0.5))}>1)then entity.safeteleport(e,f,pos) end
end

research={}
function research.get(n,f) f=f or game.forces.player return f.technologies[n] end
function research.has(n,f) return research.get(n,f).researched end
function research.can(n,f) local r=research.get(n,f) if(r.researched)then return true end local x=table_size(r.prerequisites) for k,v in pairs(r.prerequisites)do if(v.researched)then x=x-1 end end return (x==0) end
--function research.level(n,f) f=f or game.forces.player local ft=f.technologies local r=ft[n.."-0"] or ft[n.."-1"] local i=0 while(r)do if(r.researched)then i=r.level r=ft[n.."-".. i+1] else r=nil end end return i end
function research.level(n,f) f=f or game.forces.player local ft=f.technologies local i,r=0,ft[n.."-0"] or ft[n.."-1"]
	while(r)do if not r.researched then i=r.level-1 r=nil else i=r.level r=ft[n.."-".. i+1] end end
	return i
end -- Thanks Bilka!!


