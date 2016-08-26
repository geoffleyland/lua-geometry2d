--- @module nz.co.incremental.geometry2d.polyline_offset
-- (c) Copyright 2013-2016 Geoff Leyland.

local math_sqrt, math_min, math_max =
      math.sqrt, math.min, math.max

local pretty = require"pl.pretty"

--local P = require"nz.co.incremental.geometry2d.primitives"


local function movement(normals, i, j)
  local dot = normals[i][1]*normals[j][1] + normals[i][2]*normals[j][2]
  local multiplier = math_max(-1000, math_min(1000, 1 / (1 + dot)))

  return multiplier * (normals[i][1] + normals[j][1]),
         multiplier * (normals[i][2] + normals[j][2])
end


local function intersection(x1, y1, dx1, dy1, x2, y2, dx2, dy2)
  print(x1, y1, dx1, dy1, x2, y2, dx2, dy2)
  print("Y", (y2 - y1), (dy1 - dy2), (y2 - y1) / (dy1 - dy2))
  print("X", (x2 - x1), (dx1 - dx2), (x2 - x1) / (dx1 - dx2))

  local d
  if x2 == x1 then
    if (dy1 == dy2) then return math.huge end
    d = (y2 - y1) / (dy1 - dy2)
  else
    if (dx1 == dx2) then return math.huge end
    d = (x2 - x1) / (dx1 - dx2)
  end
  print("p1", x1 + d * dx1, y1 + d * dy1)
  print("p2", x2 + d * dx2, y2 + d * dy2)
  return d < 0 and math.huge or d
end


local function intersection2(points, i, j)
  local x1, y1 = points[i][1], points[i][2]
  local dx1, dy1 = points[i+1][1] - x1, points[i+1][2] - y1

  local x2, y2 = points[j][1], points[j][2]
  local dx2, dy2 = points[j+1][1] - x2, points[j+1][2] - y2

  local w = ((x2 - x1) * dy2 - (y2 - y1) * dx2) / (dx1*dy2 - dy1*dx2)
  return x1 + w * dx1, y1 + w * dy1
end


local function offset(points_in, offset, first, last, X, Y)
  -- compute normals to all the line segments in the polyline
  local count = last - first + 1
  local points = {}
  local j = 1
  for i = first, last do
    points[j] = { points_in[i][X], points_in[i][Y] }
    j = j + 1
  end

  local normals = {}
  for i = 1, count-1 do
    local dx = points[i+1][1] - points[i][1]
    local dy = points[i+1][2] - points[i][2]
    local di = 1 / math_sqrt(dx * dx + dy * dy)
    normals[i] = { -dy * di, dx * di }
  end

  print(pretty.write(normals))

  local directions = {}
  directions[1] = normals[1]
  for i = 2, #normals do
    directions[i] = { movement(normals, i-1, i) }
  end
  directions[#directions+1] = normals[#normals]

  print(pretty.write(directions))

  repeat
    local keep = {}
    local changes
    for i = 2, #directions do
      if intersection(
        points[i-1][1], points[i-1][2],
        directions[i-1][1], directions[i-1][2],
        points[i][1], points[i][2],
        directions[i][1], directions[i][2]) <= offset then
        changes = true
        keep[i-1] = false
      else
        keep[i-1] = true
      end
    end

    local i = 1
    while not keep[i] do i = i + 1 end

    local new_normals = { normals[i] }
    local new_directions = { normals[i] }
    local new_points = { points[i] }

    while true do
      local j = i + 1
      if keep[j] then
        new_normals[#new_normals+1] = normals[j]
        new_points[#new_points+1] = points[j]
        new_directions[#new_directions+1] = directions[j]
      else
        while not keep[j] and j <= #normals do j = j + 1 end
        if j <= #normals then
          new_normals[#new_normals+1] = normals[j]
          new_directions[#new_directions+1] = { movement(normals, i, j) }
          new_points[#new_points+1] = { intersection2(points, i, j) }
        end
      end
      if j > #normals then
        new_directions[#new_directions+1] = normals[i]
        new_points[#new_points+1] = points[i+1]
        break
      end

      i = j
    end

    points, directions, normals = new_points, new_directions, new_normals
  until not changes

  for i = 1, #points do
    points[i][1] = points[i][1] + offset * directions[i][1]
    points[i][2] = points[i][2] + offset * directions[i][2]
  end

  print(pretty.write(points))
end



local test = {{0,0}, {10,0}, {11, 1}, {11, 11}}
offset(test, 1, 1, 4, 1, 2)


print("HELLO")

local test = {{0,0}, {11,0}, {11, 11}}
offset(test, 2, 1, 3, 1, 2)

print("HELLO")

local test = {{0,0}, {6,0}, {8, 1}, {9, 2}, {10, 4}, {10, 10}}
offset(test, 6, 1, 6, 1, 2)

--[[

  -- run through each line segment trying to work out whether it's in
  -- or it's out
  local i, j = 1, 2
  while true do
    local direction = movement(normals, i, j)

  local directions = normals[1]
  local prev_normal = normals[1]
  local j = 2
  for i = first + 1, last - 1 do
    local dot = prev_normal[1]*normals[j][1] + prev_normal[2]*normals[j][2]
    local multiplier = math.max(-1000, math.min(1000, 1 / (1 + dot)))

  local length = 0
  for i = first, last-1 do
    length = length + P.point_to_point(points[i]  [X], points[i]  [Y],
                                       points[i+1][X], points[i+1][Y])
  end
  return length
end
--]]