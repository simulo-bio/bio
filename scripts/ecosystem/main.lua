Scene:reset();

Scene:add_capsule({
    position = vec2(0, 0),
    local_point_a = vec2(-0.5, 0),
    local_point_b = vec2(0.5, 0),
    color = Color:hex(0xffffff),
    is_static = false,
    radius = 0.5,
});