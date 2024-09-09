Scene:reset();

local genes = {
    head_color = Color:hex(0xa9bc67),
    body_parts = {
        [1] = {
            point_a = vec2(-1, -0.1),
            point_b = vec2(0, 0),
            color = Color:hex(0xa9bc67),
            radius = 0.35,
        },
        [2] = {
            point_a = vec2(-1, -0.1),
            point_b = vec2(-1, -0.8),
            color = Color:hex(0xa9bc67),
            radius = 0.2,
        },
        [3] = {
            point_a = vec2(-0.25, -0.025),
            point_b = vec2(-0.25, -0.025 - 0.7),
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
    else
        local box = Scene:add_box({
            position = pos,
            size = vec2(0.25, 0.25),
            color = Color:mix(rotten_color_min, rotten_color_max, math.random()),
            is_static = false,
            name = "rotten_food",
        });
    end;
end;

function spawn_creature(genes, pos)
    for i=1,#genes.body_parts do
        Scene:add_capsule({
            position = pos,
            local_point_a = genes.body_parts[i].point_a,
            local_point_b = genes.body_parts[i].point_b,
            color = genes.body_parts[i].color,
            is_static = false,
            radius = genes.body_parts[i].radius,
        });
    end;

    local head = Scene:add_capsule({
        position = pos,
        local_point_a = vec2(0, 0),
        local_point_b = vec2(0.3, 0),
        color = genes.head_color,
        is_static = false,
        radius = 0.25,
    });
    
    local eye = Scene:add_circle({
        position = pos + vec2(0.3, 0),
        color = Color:hex(0x0a0a0a),
        is_static = false,
        radius = 0.1,
    });
    
    eye:bolt_to(head);

    for i=1,#genes.joints do
        local objs = Scene:get_objects_in_circle({
            position = pos + genes.joints[i],
            radius = 0,
        });
        if (objs[1] ~= nil) and (objs[2] ~= nil) then
            Scene:add_hinge_at_world_point({
                object_a = objs[1],
                object_b = objs[2],
                point = pos + genes.joints[i],
            });
        end;
    end;
end;

function spawn_tree(pos)
    local top_offset = (math.random() - 0.5) * 0.5;
    local top_width = 0.5;
    local height = 2.5;

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
end;

spawn_tree(vec2(-2, -10));

spawn_creature(genes, vec2(0, -8));
for i=1,20 do
    spawn_food(vec2(2, i - 8));
end;