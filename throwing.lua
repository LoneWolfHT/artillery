local function throw_grenade(name, player)
    local dir = player:get_look_dir()
    local pos = player:get_pos()
    local obj = minetest.add_entity({x=pos.x+dir.x, y=pos.y+2.3, z=pos.z+dir.z}, name)

    obj:setvelocity({x=dir.x * 27, y=dir.y*20, z=dir.z * 27})
    obj:setacceleration({x=dir.x * -5, y=-30, z=dir.z * -5})
    obj:get_luaentity().thrower_name = player:get_player_name()

    return(obj:get_luaentity())
end

function artillery.damage_players_in_area(pos, radius, dmg, puncher)
    local objs = minetest.get_objects_inside_radius(pos, radius)

    for k, obj in pairs(objs) do
        if obj:is_player() then
            obj:punch(puncher, 1, {damage_groups = {fleshy = dmg}}, nil)
        end
    end
end

function artillery.register_grenade(name, def)

    local grenade_entity = {
        physical = true,
        timer = 0,
        visual = "sprite",
        mesh = def.mesh,
        visual_size = {x=0.5, y=0.5, z=0.5},
        textures = {def.image},
        collisionbox = {1, 1, 1, 1, 1, 1},
        on_step = function(self, dtime)
            local pos = self.object:getpos()
            local node = minetest.get_node(pos)

            if self.timer then
                self.timer = self.timer + dtime
            else
                self.timer = dtime
            end
    
            if self.timer > def.timeout or node.name ~= "air" then
                if def.custom_explode == false then

                    artillery.explode(pos, 1)

                    if self.thrower_name and minetest.get_player_by_name(self.thrower_name) then
                        artillery.damage_players_in_area(pos, 2, 13, minetest.get_player_by_name(self.thrower_name))
                    end
                else
                    def.on_explode(player, self)
                end

                self.object:remove()
            end
        end
    }
    
    minetest.register_entity("artillery:grenade_"..name, grenade_entity)

    minetest.register_node("artillery:grenade_"..name, {
        description = def.description,
        stack_max = 1,
        range = 4,
        drawtype = "plantlike",
        tiles = {def.image},
        inventory_image = def.image,
        groups = {grenade = def.radius, oddly_breakable_by_hand = 1},
        on_use = function(itemstack, user, pointed_thing)
            local player_name = user:get_player_name()
            local inv = user:get_inventory()

            grenade = throw_grenade("artillery:grenade_"..name, user)
            inv:remove_item("main", "artillery:grenade_"..name)
        end
    })
end

artillery.register_grenade("regular", {
    description = "A regular grenade",
    image = "default_apple.png",
    radius = 0,
    custom_explode = false,
    timeout = 3
})