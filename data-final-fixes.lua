require("lib")


--local tgt=1
--local px=32




local function ResizeLayer(v,z)
	if(v.shift)then v.shift[1]=v.shift[1]*z v.shift[2]=v.shift[2]*z end v.scale=(v.scale or 1)*z
	if(v.hr_version)then ResizeLayer(v.hr_version,z) end
end
local function ResizeOffsets(vx,z) if(vx[1] and istable(vx[1]))then for a,b in pairs(vx)do for c,d in pairs(b)do vx[a][c]=d*z end end else vx[1]=vx[1]*z vx[2]=vx[2]*z end end

local function IsImageTable(t) if(t.filename)then return t.filename:find(".png") elseif(t.filenames)then for k,v in pairs(t.filenames)do if(v:find(".png"))then return true end end end return false end
local OffsetTableKeys={"north_position","south_position","east_position","west_position"}
local function IsOffsetTable(k,v) return (istable(v) and isstring(k) and (k:find("offset") or table.HasValue(OffsetTableKeys,k))) end

local function ResizeLayers(t,z) for k,v in pairs(t)do ResizeLayer(v,z) end end

local function FindLayers(tbl,zx)
	for k,v in pairs(tbl)do if(type(v)=="table" and k~="sound")then
		if(v.layers)then ResizeLayers(v.layers,zx)
		elseif(IsImageTable(v))then ResizeLayer(v,zx)
		elseif(IsOffsetTable(k,v))then ResizeOffsets(v,zx)
		else FindLayers(v,zx)
		end
	end end
end

local function ResizeBBox(v,zx,vf) if(math.abs(v[1][1])>0 and math.abs(v[1][2])>0 and math.abs(v[2][1])>0 and math.abs(v[2][2])>0)then
	vf=vf or 0 v[1][1]=v[1][1]*zx-vf v[1][2]=v[1][2]*zx-vf v[2][1]=v[2][1]*zx+vf v[2][2]=v[2][2]*zx+vf
end end

local function ResizePrototype(t,z)
	FindLayers(t,z)
	if(t.collision_box)then ResizeBBox(t.collision_box,z) end
	if(t.selection_box)then ResizeBBox(t.selection_box,z) end
	if(t.map_generator_bounding_box)then ResizeBBox(t.map_generator_bounding_box,z) end
end
local function SetPrototypeSize(t,z)
	local bbox=t.selection_box or t.collision_box local bbx=vector(math.ceil(math.abs(bbox[1][1])+math.abs(bbox[2][1])),math.ceil(math.abs(bbox[1][2])+math.abs(bbox[2][2])))
	local bmax=math.max(bbx.x,bbx.y)
	ResizePrototype(t,z/bmax)
end
local function ScalePrototypeSize(t,z)
	local bbox=t.selection_box or t.collision_box local bbx=vector(math.ceil(math.abs(bbox[1][1])+math.abs(bbox[2][1])),math.ceil(math.abs(bbox[1][2])+math.abs(bbox[2][2])))
	local bmax=math.max(bbx.x,bbx.y)
	ResizePrototype(t,(bmax*z)/bmax)
end


local function ReadFluidbox(tbl,fb)
	for kp,kv in pairs(tbl.pipe_connections)do
		local w=kv.position --or kv.positions[1]
		if(w)then
			local x,y=math.sign(w[1] or w.x),math.sign(w[2] or w.y) fb[x]=fb[x] or {} fb[x][y]={pipe=kp,pos={x,y}}
		else
			for k,w in pairs(kv.positions)do
				local x,y=math.sign(w[1] or w.x),math.sign(w[2] or w.y) fb[x]=fb[x] or {} fb[x][y]={pipe=kp,pos={x,y}}
			end
		end
	end
end

local function ReadFluidboxes(tbl,fb) for k,v in pairs(tbl)do if(type(v)=="table")then ReadFluidbox(v,fb) end end end


local function ScanFluidboxes(v)
	local fb={}
	if(v.fluid_boxes)then ReadFluidboxes(v.fluid_boxes,fb) end
	if(v.fluid_box)then ReadFluidbox(v.fluid_box,fb) end
	if(v.input_fluid_box)then ReadFluidbox(v.input_fluid_box,fb) end
	if(v.output_fluid_box)then ReadFluidbox(v.output_fluid_box,fb) end
	return fb
end


local function ResizeFluidbox(fbox,z)
	for pi,pv in pairs(fbox.pipe_connections)do
		if(pv.position)then
			pv.position[1]=(pv.position[1]/z)+(0.125/z)*math.sign(pv.position[1])
			pv.position[2]=(pv.position[2]/z)+(0.125/z)*math.sign(pv.position[2])

			--pv.position[1]=math.round((pv.position[1]*4)/z)/4
			--pv.position[2]=math.round((pv.position[2]*4)/z)/4
			--pv.position=vector(vector.Snap(vector(pv.position)*2,0.25))/2
		elseif(pv.positions)then
			for k,v in pairs(pv.positions)do
				pv.positions[k]={math.floor(v[1]/z*2)/2,math.floor(v[2]/z*2)/2}
				--pv.positions[k]=vector(vector.Snap(vector(pv.positions[k])*2,0.25))/2
			end
		end
	end
end
local function ApplyFluidbox(v,z)
	if(v.fluid_boxes)then for k,fbox in pairs(v.fluid_boxes)do if(istable(fbox))then ResizeFluidbox(fbox,z) end end end
	if(v.fluid_box)then ResizeFluidbox(v.fluid_box,z) end
	if(v.input_fluid_box)then ResizeFluidbox(v.input_fluid_box,z) end
	if(v.output_fluid_box)then ResizeFluidbox(v.output_fluid_box,z) end
end


local BadCats={"rail","locomotive","cargo-wagon","fluid-wagon","artillery-wagon","item","item-on-ground","item-entity","transport-belt",
"pipe","pipe-to-ground","underground-belt","tile","resource",
"item-request-proxy","construction-robot","logistic-robot","combat-robot","electric-pole","rocket-silo","rocket-silo-rocket",
"infinity-pipe"}

--[[ Notes on categories
Construction-robots need selection box at most 0.5 from 0,0 ??

]]


for cat,ctbl in pairs(data.raw)do

if(not table.HasValue(BadCats,cat))then
for n,object in pairs(ctbl)do
if(not table.HasValue(BadCats,object.type) and (object.collision_box or object.selection_box))then

	local fb=ScanFluidboxes(object)
	local fbh=(table_size(fb)>1)
	local fbz=table_size(fb)
	local z=1
	local vzero=false

	if(fbz>1)then
		local count={x={},y={}}
		for x,t in pairs(fb)do for y,val in pairs(t)do
			if(x==0 or y==0)then vzero=true else
				count.x[x]=(count.x[x] or 0)+1
				count.y[y]=(count.y[y] or 0)+1
			end
		end end
		local mx=1
		local my=1
		for k,v in pairs(count.x)do mx=math.max(mx,v) end
		for k,v in pairs(count.y)do my=math.max(my,v) end
		z=math.max(mx,my)
		--if(vzero)then z=z+1 end
	end

	local bbox=object.selection_box or object.collision_box
	local bbx=vector(math.ceil(math.abs(bbox[1][1])+math.abs(bbox[2][1])),math.ceil(math.abs(bbox[1][2])+math.abs(bbox[2][2])))

	--local dn,dt="steam-engine","generator" local dx=(object.name==dn and object.type==dt)

	--local dn,dt="boiler","boiler" local dx=(object.name==dn and object.type==dt)

	--local dn,dt="oil-refinery","assembling-machine" local dx=(object.name==dn and object.type==dt)

--if(dx)then error(z .. " , " .. serpent.block(bbx)) end

	local zx
	if(fbz>1)then
		local bmax=math.max(bbx.x,bbx.y)
		zx=1/(z)
	else
		zx=1/math.max(bbx.x,bbx.y)
	end

	local zxsnap=1

	if(cat=="character")then zx=0.75 end

	--z=0.5


	if(fbz>1)then
		ApplyFluidbox(object,z)
	elseif(fbz>0)then
		ApplyFluidbox(object,1/zx)
	end


	object.next_upgrade=nil

	ResizePrototype(object,zx)


	--local dn,dt="crash-site-electric-pole","electric-pole"
	--local dn,dt="small-spitter","unit"
	--local dn,dt="hidden-electric-energy-interface","electric-energy-interface"
	--local dn,dt="electric-mining-drill","mining-drill"

	--local dn,dt="pumpjack","mining-drill"

	--local dn,dt="item-request-proxy","item-request-proxy"

	--local dn,dt="chemical-plant","assembling-machine"
	--local dn,dt="assembling-machine-2","assembling-machine"


	--local dn,dt="oil-refinery","assembling-machine" local dx=(object.name==dn and object.type==dt)
	--if(dx)then error(serpent.block(object)) end


	--local dn,dt="steam-engine","generator" local dx=(object.name==dn and object.type==dt)
	if(dx)then
		--error(serpent.block(object))

		--local pipe=object.fluid_box.pipe_connections
		--pipe[1].position={0,1}
		--pipe[2].position={0,-1}	


--[[ Steam Boxes
pipe_connections={
position={0,3}
position={0,-3}

after:
{0,1.5}
{0,-1.5}

]]


--[[
		object.fluid_boxes[1].pipe_connections[1].position={-0.25,1}
		object.fluid_boxes[2].pipe_connections[1].position={-1.5,32}
]]


		local dg=0
		if(dg==1)then
		local s=""
		s=s.."ZX: " .. tostring(zx)
		s=s..", Z: " .. tostring(z)
		s=s.." ||| "
		s=s.." MX: " .. tostring(mx)
		s=s.." MY: " .. tostring(my)
		s=s.." ||| "
		s=s.."[[[[[[[FLUIDBOX:]]]]]]]"
		s=s..serpent.block(object.fluid_boxes)
		s=s.."[[[[[[[COLLISION BOX:]]]]]]]"
		s=s..serpent.block(object.selection_box)
		s=s.."[[[[[[[[FB]]]]]]]]]"
		s=s..serpent.block(fb)

		local fbt=ScanFluidboxes(object)
		s=s.."[[[[[[[[FB2222222]]]]]]]]]"
		s=s..serpent.block(fbt)

		error(s)
		end
	end


end
end end
end


--[[ test ]]--

--[[
/c local e=game.player.selected e.rocket_parts=100

]]





--[[
	local sbox=object.selection_box
	if(sbox and zx==1 and (not fbh))then
		local vx=math.abs(sbox[1][1])+math.abs(sbox[1][2]) local vy=math.abs(sbox[1][2])+math.abs(sbox[2][2]) --=5 ("picture scale")
		local vm=math.max(vx,vy) if(vm>0)then zx=(zxsnap/vm)*z end
	end


	local cbox=object.collision_box
	if(cbox and zx==1 and (not fbh))then
		local vx=math.abs(cbox[1][1])+math.abs(cbox[1][2]) local vy=math.abs(cbox[1][2])+math.abs(cbox[2][2]) --=5 ("picture scale")
		local vm=math.max(vx,vy) if(vm>0)then zx=(zxsnap/vm)*z end

	end
]]




--[[ object.drawing_box



new boiler
Collision box {-0.64,-0.39},{0.64,0.39}






-- {-1.2,-1.2},{1.2,1.2} ---- pipes: {-0.5,-1},
]]


--[[NewBoiler

zx=0.33 z=3

box={0.42,0.26}

pipes={-0.6,0.15},{0.6,0.16}




--[[ Boiler

        pipe_connections = {
          {
            position = {
              -2,
              0.5
            },
            type = "input-output"
          },
          {
            position = {
              2,
              0.5
            },
            type = "input-output"
          }
        },

]]


--[[ Storage Tank
        pipe_connections = {
          {
            position = {
              -1,
              -2
            }
          },
          {
            position = {
              2,
              1
            }
          },
          {
            position = {
              1,
              2
            }
          },
          {
            position = {
              -2,
              -1
            }
          }
]]





--[[ OIL REFINERY


      collision_box = {
        {
          -2.3999999999999999,
          -2.3999999999999999
        },
        {
          2.3999999999999999,
          2.3999999999999999
        }
      },




      selection_box = {
        {
          -2.5,
          -2.5
        },
        {
          2.5,
          2.5
        }
      },


              position = {
                -1,3
              },
              position = {
                1,3
              },
              position = {
                -2,-3
              }
              position = {
                0,-3
              }
     
              position = {
                2,-3
              }
]]





--[[ Chemical Plant

          pipe_connections = {
            {
              position = {
                -1,
                -2
              },
              type = "input"
            }


            {
              position = {
                1,
                -2
              },
              type = "input"
            }


            {
              position = {
                -1,
                2
              }
            }
          },

            {
              position = {
                1,
                2
              }
            }


]]
