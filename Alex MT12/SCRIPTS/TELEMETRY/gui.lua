local M = {}

--
-- Mid-Point Arc Drawing Algorithm Implementation
--
-- This function draws a circular arc on a 2D grid. It's a modification of
-- the mid-point circle algorithm that only plots pixels within a specified
-- angular range.
--
-- Parameters:
--   x_center        - The x-coordinate of the arc's center.
--   y_center        - The y-coordinate of the arc's center.
--   radius          - The radius of the arc.
--   start_angle_deg - The starting angle in degrees (e.g., 0 for positive x-axis).
--   end_angle_deg   - The ending angle in degrees.
--   plot_point_func - A function that takes x and y coordinates and "draws" the point.
--
function M.draw_arc_midpoint(x_center, y_center, radius, start_angle_deg, end_angle_deg, plot_point_func)
    local function rotate_90_ccw_deg(angle_deg)
        return (angle_deg - 90) % 360
    end

    -- Convert angles from degrees to radians for Lua's math functions
    local start_angle_rad = math.rad(rotate_90_ccw_deg(start_angle_deg))
    local end_angle_rad = math.rad(rotate_90_ccw_deg(end_angle_deg))

    -- Normalize the angles to be within a 2*pi range.
    -- This helps with the comparison logic, especially for arcs that cross 360/0 degrees.
    local function normalize_angle(angle)
        angle = math.fmod(angle, 2 * math.pi)
        if angle < 0 then
            angle = angle + 2 * math.pi
        end
        return angle
    end

    start_angle_rad = normalize_angle(start_angle_rad)
    end_angle_rad = normalize_angle(end_angle_rad)

    -- A helper function to check if an angle is within the specified range.
    -- This handles ranges that cross the 0 boundary (e.g., 350 to 10 degrees).
    local function is_angle_in_range(current_angle)
        current_angle = normalize_angle(current_angle)
        if start_angle_rad <= end_angle_rad then
            return current_angle >= start_angle_rad and current_angle <= end_angle_rad
        else
            -- The range crosses the 0/2*pi boundary
            return current_angle >= start_angle_rad or current_angle <= end_angle_rad
        end
    end

    -- The function to plot all 8 symmetric points if they are within the angle range
    local function plot_8_points_conditional(x_c, y_c, x_p, y_p)
        local points = {
            { x_p,  y_p }, { y_p, x_p },
            { -x_p, y_p }, { y_p, -x_p },
            { x_p,  -y_p }, { -y_p, x_p },
            { -x_p, -y_p }, { -y_p, -x_p }
        }
        for _, point in ipairs(points) do
            local current_x_rel = point[1]
            local current_y_rel = point[2]

            -- Calculate the angle of the current point relative to the center
            local angle = math.atan2(current_y_rel, current_x_rel)

            -- If the angle is in the range, plot the point
            if is_angle_in_range(angle) then
                plot_point_func(x_c + current_x_rel, y_c + current_y_rel)
            end
        end
    end

    -- Initial coordinates and decision parameter for the first octant
    local x = radius
    local y = 0
    local p = 1 - radius

    -- Plot the first point
    plot_8_points_conditional(x_center, y_center, x, y)

    -- Loop to generate points for the first octant
    while x > y do
        y = y + 1

        if p <= 0 then
            p = p + 2 * y + 1
        else
            x = x - 1
            p = p + 2 * y + 1 - 2 * x
        end

        plot_8_points_conditional(x_center, y_center, x, y)
    end
end

return M
