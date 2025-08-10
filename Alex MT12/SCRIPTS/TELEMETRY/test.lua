-- Get the path of the current file and its directory
-- The 'debug.getinfo(1, "S").source' returns the full path of the current script
-- The 'string.match' extracts the directory part
local script_dir = debug.getinfo(1, "S").short_src:match("(.*/)")

-- Append the 'lib' directory to the package.path
package.path = package.path .. ";" .. script_dir .. "?.lua"

local GUI = require("gui")

--
-- Example usage:
--
-- We'll use the same grid-drawing approach as before.
--
local grid = {}
local function plot_to_grid(x, y)
    local x_int = math.floor(x + 0.5)
    local y_int = math.floor(y + 0.5)

    if not grid[x_int] then
        grid[x_int] = {}
    end
    grid[x_int][y_int] = true
end

local y_center = 8

GUI.draw_arc_midpoint(20, y_center, 0, 1, 360, plot_to_grid)
GUI.draw_arc_midpoint(20, y_center, 1, 1, 360, plot_to_grid)

GUI.draw_arc_midpoint(20, y_center + 5, 8, 330, 30, plot_to_grid)
GUI.draw_arc_midpoint(20, y_center + 11, 16, 330, 30, plot_to_grid)
GUI.draw_arc_midpoint(20, y_center + 17, 24, 330, 30, plot_to_grid)

-- Print a section of the grid to verify the arcs
print("Printing a section of the grid to show the arcs:")
local min_x = 0
local max_x = 127
local min_y = 0
local max_y = 11

for y = min_y, max_y do
    local line = string.format("%3d: ", y)
    for x = min_x, max_x do
        if grid[x] and grid[x][y] then
            line = line .. "o"
        else
            line = line .. "."
        end
    end
    print(line)
end
