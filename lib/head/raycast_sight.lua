require './packages/@bio/bio/lib/gizmos.lua';

local laser_color = 0xff6a6a;

function rgba_to_hsva(color)
    local r, g, b, a = color.r / 255, color.g / 255, color.b / 255, color.a

    local maxVal = math.max(r, g, b)
    local minVal = math.min(r, g, b)
    local delta = maxVal - minVal

    local h = 0
    if delta ~= 0 then
        if maxVal == r then
            h = (g - b) / delta
        elseif maxVal == g then
            h = 2 + (b - r) / delta
        else
            h = 4 + (r - g) / delta
        end
        h = h * 60
        if h < 0 then
            h = h + 360
        end
    end

    local s = 0
    if maxVal ~= 0 then
        s = delta / maxVal
    end

    local v = maxVal

    -- Convert to the ranges you're using
    h = h -- stays 0-360
    s = s * 255 -- scale to 0-255
    v = v * 255 -- scale to 0-255

    return h, s, v, a
end;

-- Function to calculate the dot product of two vec2 vectors
local function dot(v1, v2)
    return v1.x * v2.x + v1.y * v2.y
end

-- Function to multiply a vec2 by a scalar
local function mul_scalar(v, scalar)
    return vec2(v.x * scalar, v.y * scalar)
end

-- Function to subtract one vec2 from another
local function sub(v1, v2)
    return vec2(v1.x - v2.x, v1.y - v2.y)
end

-- Function to reflect a vector `I` across a surface normal `N`
local function reflect(I, N)
    -- R = I - 2 * (dot(I, N)) * N
    local dotIN = dot(I, N)
    local reflectDir = sub(I, mul_scalar(N, 2 * dotIN))
    return reflectDir
end

function transform_vector(vector, angle)
    local x = vector.x * math.cos(angle) - vector.y * math.sin(angle)
    local y = vector.x * math.sin(angle) + vector.y * math.cos(angle)
    return vec2(x, y)
end

function on_step()
    clear_gizmos();

    local offset = 0;

    local forward = transform_vector(vec2(0, 1), self:get_angle());
    local right = transform_vector(vec2(-1, 0), self:get_angle());

    local ray_offset = 0;
    local ray_gap = 0.02;

    local self_pos = self:get_position() + (forward * 0.3 * 0.9);

    local ray_count = 150;

    for i=1,ray_count do
        local realer = step({
            origin = self_pos,
            direction = forward + (right * (ray_offset - (ray_count * ray_gap * 0.5))),
            distance = 50,
            closest_only = true,
        }, 0, 0, (i == 1) or (i == 150), i);

        if realer == nil then
            --[[local box = Scene:add_box({
                position = vec2(0 + offset + (0.25 * 150) - 0.25, 0),
                size = vec2(0.5, 50),
                color = 0x000000,
                is_static = true,
            });
            box:temp_set_collides(false);
            table.insert(gizmos, box);]]
        else
            local box = Scene:add_box({
                position = vec2(0, 0 + offset + (0.25 * ray_count) - 0.25),
                size = vec2(math.min(50, 50 / realer.distance), 0.5),
                color = realer.color,
                is_static = true,
            });
            box:temp_set_collides(false);
            table.insert(gizmos, box);
        end;

        offset += 0.5;
        ray_offset += ray_gap;
    end;
end;

function vec2_cross(v1, v2)
    return v1.x * v2.y - v1.y * v2.x
end

function point_to_line_distance(P, A, B)
    local AB = B - A;
    local AP = P - A;
    local cross_product = vec2_cross(AB, AP);
    local magnitude_AB = AB:magnitude();
    local distance = math.abs(cross_product) / magnitude_AB
    return distance
end

function step(cast, distance_so_far, reflect_tint, should_draw, i)
    if cast.distance <= 0 then
        return;
    end;

    if i % 5 == 0 then
        gizmo_circle(cast.origin + cast.direction, 0x00ff00);
    end;

    local hits = Scene:raycast(cast);
    if #hits == 0 then
        if should_draw then draw_line(cast.origin, cast.origin + (cast.direction:normalize() * cast.distance), 0.0125, 0xff6a6a, true); end;
        return nil;
    end;

    local right = transform_vector(vec2(-1, 0), self:get_angle());
    local forward = transform_vector(vec2(0, 1), self:get_angle());
    local self_pos = self:get_position() + (forward * 0.3 * 0.9);

    local distance = point_to_line_distance(hits[1].point, self_pos + forward + right, self_pos + forward - right);

    if distance < 0 then return nil; end;

    --gizmo_raycast(cast, 0xff0000);
    if should_draw then draw_line(cast.origin, hits[1].point, 0.0125, 0xff6a6a, true); end;

    if hits[1].object:get_name() ~= "mirror" then
        return {
            object = hits[1].object,
            distance = distance_so_far + distance,
            color = shade(hits[1].normal, hits[1].object:get_color(), reflect_tint),
            reflect_tint = reflect_tint
        };
    end;

    --draw_line(hits[1].point, hits[1].point + hits[1].normal, 0.05, 0x0000ff, true);

    local reflected = reflect(cast.direction, hits[1].normal);

    --draw_line(hits[1].point, hits[1].point + reflected, 0.05, 0xffff00, true);

    return step({
        origin = hits[1].point,
        direction = reflected,
        distance = cast.distance - distance,
        closest_only = true,
    }, distance_so_far + distance, reflect_tint + 1, should_draw, i);
end;

function shade(normal, color, reflect_tint)
    -- Step 1: Convert the normal to an angle
    local angle = math.atan2(normal.y, normal.x)

    -- Step 2: Convert angle to a number from 0 to 1
    local factor = math.max(math.min((math.sin(angle) + 1) / 2, 1), 0);

    -- Step 3: Convert the color from RGB to HSVA
    local h, s, v, a = rgba_to_hsva(color)

    -- Adjust V by 0.1 and S by -0.1
    v = math.min(255, math.max(0, v - 40)) -- Clamp v between 0 and 255
    s = math.min(255, math.max(0, s + 40)) -- Clamp s between 0 and 255

    -- Step 4: Mix the original color with the adjusted HSVA color
    local adjusted_color = Color:hsva(h, s, v, a)
    local final_color = Color:mix(color, adjusted_color, factor)

    final_color = Color:mix(final_color, Color:hex(0x9e9f9f), math.min(1, reflect_tint * 0.1));

    -- Step 5: Return the final color
    return final_color
end