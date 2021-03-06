--Functions
--

--Slabs And Stairs

local function rotate_and_place(itemstack, placer, pointed_thing)
    local p0 = pointed_thing.under
    local p1 = pointed_thing.above
    local param2 = 0

    local placer_pos = placer:getpos()
    if placer_pos then
        param2 = minetest.dir_to_facedir(vector.subtract(p1, placer_pos))
    end

    local finepos = minetest.pointed_thing_to_face_pos(placer, pointed_thing)
    local fpos = finepos.y % 1

    if p0.y - 1 == p1.y or (fpos > 0 and fpos < 0.5)
            or (fpos < -0.5 and fpos > -0.999999999) then
        param2 = param2 + 20
        if param2 == 21 then
            param2 = 23
        elseif param2 == 23 then
            param2 = 21
        end
    end
    return minetest.item_place(itemstack, placer, pointed_thing, param2)
end

local function register_stair_and_slab(node_name)
    local node_def = minetest.registered_nodes[node_name]

    local stair_def = table.copy(node_def)
    -- Add stair specific stuff
    stair_def.groups.stair = 1
    stair_def.description = stair_def.description.." Stair"
    stair_def.drawtype = "mesh"
    stair_def.mesh = "stairs_stair.obj"
    stair_def.selection_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
            {-0.5, 0, 0, 0.5, 0.5, 0.5},
        },
    }
    stair_def.collision_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
            {-0.5, 0, 0, 0.5, 0.5, 0.5},
        },
    }
    stair_def.on_place = function(itemstack, placer, pointed_thing)
        if pointed_thing.type ~= "node" then
            return node_def.on_place(itemstack, placer, pointed_thing)
        end

        return rotate_and_place(itemstack, placer, pointed_thing)
    end

    minetest.register_node(node_name.."_stair", stair_def)

    local slab_def = table.copy(node_def)
    slab_def.groups.slab = 1
    slab_def.drawtype = "nodebox"
    paramtype2 = "facedir"
    slab_def.node_box = {
                type = "fixed",
                fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
            }
    slab_def.on_place = function(itemstack, placer, pointed_thing)
        if pointed_thing.type ~= "node" then
            return node_def.on_place(itemstack, placer, pointed_thing)
        end

        return rotate_and_place(itemstack, placer, pointed_thing)
    end
    minetest.register_node(node_name.."_slab", slab_def)
end

local function register_cracked(number)
    minetest.register_node("artillery:concrete_cracked_"..number, {
        description = "Cracked Concrete",
        paramtype2 = "facedir",
        tiles = {"concrete.png^crack_"..number..".png"},
        groups = {cracky = 2, level = 2, not_in_creative_inventory = 1},
        drop = "default:gravel 2",
    })
    register_stair_and_slab("artillery:concrete_cracked_"..number)
end

--
--Concrete | It's as tough as a mixture of sand, gravel, and water!
--

register_cracked(1)
register_cracked(2)
register_cracked(3)

minetest.register_node("artillery:concrete", {
    description = "Concrete",
    tiles = {"concrete.png"},
    paramtype2 = "facedir",
    groups = {cracky = 1, level = 2},
    on_blast = function(pos, intensity)
        local meta = minetest.get_meta(pos)
        local current_node = minetest.get_node(pos).name
        local suffix = (current_node:split("_")[2] and "_"..current_node:split("_")[2] or "")
        
        if meta:get_int("blast") == 0 then
            meta:set_int("blast", 1)
            return false
        elseif meta:get_int("blast") == 1 then
            meta:set_int("blast", 2)
            return false
        elseif meta:get_int("blast") == 2 then
            minetest.set_node(pos, {name = "artillery:concrete_cracked_"..math.random(1,3)..suffix})
        end
    end,
})

register_stair_and_slab("artillery:concrete")

--
--SandBags | Bags with sand in them
--

minetest.register_node("artillery:sandbag", {
	description = "Sandbag",
	tiles = {
        "sandbag_top.png",
        "sandbag_bottom.png",
        "sandbag_right.png",
        "sandbag_left.png",
        "sandbag_back.png",
        "sandbag_front.png"
    },
    paramtype2 = "facedir",
    groups = {crumbly = 3},
    on_blast = function(pos, intensity)
		minetest.set_node(pos, {name = "air"})
		minetest.add_item(pos, "default:sand")
	end,
})

register_stair_and_slab("artillery:sandbag")

--
--Barbed Wire | Don't touch the pointy things. They hurt
--

minetest.register_node("artillery:barbedwire", {
    description = "Barbed Wire",
    drawtype = "firelike",
    visual_scale = 1.2,
    tiles = {"barbedwire.png"},
    paramtype = "light",
    walkable = false,
    damage_per_second = 3.5,
    groups = {snappy=1, attached_node=1},
    on_blast = function(pos, intensity)
        return false
    end
})