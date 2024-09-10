Scene:reset();

local genes = {
    head_color = Color:hex(0xa9bc67),
    body_parts = {
        [1] = {
            point_a = vec2(-0.5, -0.1),
            color = Color:hex(0xa9bc67),
            radius = 0.3,
        },
        [2] = {
            point_a = vec2(-0.5, -0.1),
            point_b = vec2(-0.5, -0.8),
            color = Color:hex(0xa9bc67),
            radius = 0.2,
        },
    },
    joints = {
        [1] = vec2(0, 0),
        [2] = vec2(-1, -0.1),
        [3] = vec2(-0.25, -0.025),
    },
    brain = {
        -- coming soon
    },
};

local food_color_min = Color:hex(0xe13b4c);
local food_color_max = Color:hex(0xff3a3a);
local rotten_color_min = Color:hex(0x8d693d);
local rotten_color_max = Color:hex(0x776437);

function spawn_food(pos)
    local rotten = math.random() < 0.05;

    if not rotten then
        local box = Scene:add_box({
            position = pos,
            size = vec2(0.25, 0.25),
            color = Color:mix(food_color_min, food_color_max, math.random()),
            is_static = false,
            name = "food",
        });

        return box;
    else
        local box = Scene:add_box({
            position = pos,
            size = vec2(0.25, 0.25),
            color = Color:mix(rotten_color_min, rotten_color_max, math.random()),
            is_static = false,
            name = "rotten_food",
        });

        return box;
    end;
end;

function spawn_creature(genes, pos)
    local body = Scene:add_capsule({
        position = pos - vec2(0, 0.1),
        local_point_a = vec2(-0.6, 0),
        local_point_b = vec2(0.6, 0),
        color = Color:hex(0xa9bc67),
        is_static = false,
        radius = 0.25,
    });

    local neck_1 = Scene:add_capsule({
        position = pos,
        color = Color:hex(0xa9bc67),
        radius = 0.18,
        local_point_a = vec2(0, 0.1),
        local_point_b = vec2(0, 0.5),
        is_static = false,
    });

    local neck_2 = Scene:add_capsule({
        position = pos,
        color = Color:hex(0xa9bc67),
        radius = 0.18,
        local_point_a = vec2(0, 0.5),
        local_point_b = vec2(0, 0.9),
        is_static = false,
    });

    local head = Scene:add_capsule({
        position = pos + vec2(0, 1),
        local_point_a = vec2(0, 0),
        local_point_b = vec2(0, (0.3 * 0.9)),
        color = Color:hex(0xa9bc67),
        is_static = false,
        radius = 0.25 * 0.9,
    });

    local hash = Scene:add_component({
        code = require('./packages/@bio/bio/lib/head/main.lua', 'string'),
    });
    head:add_component(hash);
    
    local eye = Scene:add_circle({
        position = pos + vec2(0, 1 + (0.3 * 0.9)),
        color = Color:hex(0x0a0a0a),
        is_static = false,
        radius = 0.1 * 0.9,
    });
    
    eye:bolt_to(head);

    local left_leg = Scene:add_capsule({
        position = pos + vec2(-0.6, -0.1),
        local_point_a = vec2(0, 0),
        local_point_b = vec2(0, -0.5),
        color = Color:hex(0xa9bc67),
        is_static = false,
        radius = 0.2,
    });

    local right_leg = Scene:add_capsule({
        position = pos + vec2(0.6, -0.1),
        local_point_a = vec2(0, 0),
        local_point_b = vec2(0, -0.5),
        color = Color:hex(0xa9bc67),
        is_static = false,
        radius = 0.2,
    });

    Scene:add_hinge_at_world_point({
        object_a = body,
        object_b = neck_1,
        point = pos + vec2(0, 0.1),
    });
    Scene:add_hinge_at_world_point({
        object_a = neck_1,
        object_b = neck_2,
        point = pos + vec2(0, 0.5),
    });
    Scene:add_hinge_at_world_point({
        object_a = neck_2,
        object_b = head,
        point = pos + vec2(0, 0.9),
    });

    Scene:add_hinge_at_world_point({
        object_a = body,
        object_b = left_leg,
        point = pos + vec2(-0.6, -0.1),
    });

    Scene:add_hinge_at_world_point({
        object_a = body,
        object_b = right_leg,
        point = pos + vec2(0.6, -0.1),
    });
end;

function spawn_tree(pos)
    local top_offset = (math.random() - 0.5) * 0.5;
    local top_width = 0.5;
    local height = 2.5 + ((math.random() - 0.5) * 2);

    local tree = Scene:add_polygon({
        position = pos,
        points = {
            vec2(-0.3, 0),
            vec2((-top_width / 2) + top_offset, height),
            vec2((top_width / 2) + top_offset, height),
            vec2(0.3, 0),
        },
        color = Color:hex(0xa66240),
        is_static = true,
    });
    tree:temp_set_collides(false);

    local leaf_positions = {};

    for i=1,10 do
        local leaf_pos = pos + vec2(top_offset, height) + vec2(math.random() - 0.5, math.random() - 0.5);
        local leaf = Scene:add_circle({
            position = leaf_pos,
            radius = 0.5,
            color = Color:hex(0x76a637),
            is_static = false,
        });
        leaf:temp_set_collides(false);
        leaf:bolt_to(tree);

        if math.random() > 0.3 then
            table.insert(leaf_positions, leaf_pos);
        end;
    end;

    for i=1,#leaf_positions do
        local food = spawn_food(leaf_positions[i]);
        Scene:add_hinge_at_world_point({
            point = leaf_positions[i] + vec2(0, 0.1),
            object_a = tree,
            object_b = food,
        });
    end;
end;

local x = -2;
for i=1,15 do
    spawn_tree(vec2(x, -10));
    x += (math.random() * 3) + 1;
end;

spawn_creature(genes, vec2(0, -8));
for i=1,20 do
    spawn_food(vec2(2, i - 8));
end;