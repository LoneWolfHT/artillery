artillery = {}

local function param2_to_dir(param2)
	if param2 == 0 then
		return({x=0, y=0, z=1})
	elseif param2 == 1 then
		return({x=1, y=0, z=0})
	elseif param2 == 2 then
		return({x=0, y=0, z=-1})
	elseif param2 == 3 then
		return({x=-1, y=0, z=0})
	else
		return({x=0, y=0, z=0})
	end
end

function artillery.launch_projectile(obj, def)
	local self = obj:get_luaentity()
	local pos = obj:get_pos()
	local dir = param2_to_dir(def.param2)
	local targetpos = vector.add(vector.multiply(dir, def.distance), pos)

	self.startpos = pos
	self.timeout = def.timeout
	self.radius = def.radius

	local newdir = vector.multiply(vector.direction(pos, targetpos), def.speed)
	local dspeed = def.speed/5

	obj:set_velocity({x=newdir.x, y=def.climb*def.speed/8, z=newdir.z})
	obj:setacceleration({x=(-newdir.x/dspeed)+math.random(-7, 7), y=-def.climb*def.speed/3.5, z=(-newdir.z/dspeed)+math.random(-7, 7)})
end

function artillery.explode(pos, radius)
	tnt.boom(pos, {
		radius = radius,
		damage_radius = radius+1,
		explode_center = false,
		ignore_protection = false,
		ignore_on_blast = false
	})
end

dofile(minetest.get_modpath("artillery").."/nodes.lua")
dofile(minetest.get_modpath("artillery").."/turrets.lua")
dofile(minetest.get_modpath("artillery").."/guns.lua")
dofile(minetest.get_modpath("artillery").."/heavy.lua")
dofile(minetest.get_modpath("artillery").."/ammo.lua")
dofile(minetest.get_modpath("artillery").."/throwing.lua")