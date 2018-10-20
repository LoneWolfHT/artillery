local mortar_shell_entity = {
	physical = false,
	timer = 0,
	visual = "sprite",
	visual_size = {x=0.5, y=0.5},
	textures = {"default_stone.png"},
	collisionbox = {0, 0, 0, 0, 0, 0},
	on_step = function(self, dtime)
		if not (self.startpos) or vector.distance(self.object:get_pos(), self.startpos) <= 1 then return end

		self.timer = self.timer + dtime
		local obj = self.object
		local pos = obj:get_pos()
		local node = minetest.get_node(pos)

		if self.timer > self.timeout or (not (node.name == "air" or node.name:find("leaves"))) then
			artillery.explode(pos, self.radius)
			obj:remove()
		end
	end
}

minetest.register_entity("artillery:mortar_shell_entity", mortar_shell_entity)

minetest.register_node("artillery:mortar_cannon", {
	description = "Mortar launcher",
	drawtype = "mesh",
	tiles = {"default_stone.png"},
	groups = {oddly_breakable_by_hand = 3, attached_node = 1, force_floor = 1},
	mesh = "mortar.obj",
	paramtype2 = "facedir",
	force_floor,
	selection_box = {
		type = "fixed",
		fixed = {0.6, -0.3, 0.6, -0.6, -0.5, -0.6},
		},
	collision_box = {
		type = "fixed",
		fixed = {0.6, -0.3, 0.6, -0.6, -0.5, -0.6},
	},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("cooldown", 0)
	end,

	on_punch = function(pos, node, puncher, pointed_thing)
		local inv = puncher:get_inventory()
		local itemstack = puncher:get_wielded_item()
		local meta = minetest.get_meta(pos)

		if meta:get_int("cooldown") == 0 then
			if itemstack:get_name() ~= "artillery:mortar_shell" then
				return itemstack
			end

			if not minetest.setting_getbool("creative_mode") then
				inv:remove_item("main", "artillery:mortar_shell")
			end

			artillery.launch_projectile(minetest.add_entity(pos, "artillery:mortar_shell_entity"), {
				distance = 40,
				climb = 10,
				player = puncher,
				timeout = 10,
				radius = 2,
				speed = 35,
				param2 = node.param2
			})

			meta:set_int("cooldown", 1)
			meta:set_string("infotext", "Mortar Launcher is cooling down")
			minetest.after(2.5, function()
				meta:set_int("cooldown", 0)
				meta:set_string("infotext", "")
			end)
		end
	end,
})