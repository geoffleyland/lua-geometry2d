--- @module nz.co.incremental.geometry2d.polyline_offset
-- (c) Copyright 2013-2016 Geoff Leyland.

--local math_sqrt, math_min, math_max, math_atan2, math_pi =
--      math.sqrt, math.min, math.max, math.atan2, math.pi

local math_abs, math_atan2, math_cos, math_floor, math_pi, math_sin, math_sqrt =
      math.abs, math.atan2, math.cos, math.floor, math.pi, math.sin, math.sqrt

local pretty = require"pl.pretty"


------------------------------------------------------------------------------

local function round(x)
  return math_floor(x + 0.5)
end


local function sign(x)
  return x>0 and 1 or x<0 and -1 or 0
end


--- Compute the normal to a line segment
local function normal(x1, y1, x2, y2)
  local dx, dy = x2 - x1, y2 - y1
  local di = 1.0 / math_sqrt(dx*dx + dy*dy)
  return { -dy * di, dx * di }
end


--- Compute the angle between two normals
local function normal_angle(normals, i, j)
  local angle = math_atan2(normals[j][2], normals[j][1]) - math_atan2(normals[i][2], normals[i][1])
  while (angle < -math_pi) do angle = angle + 2.0 * math_pi end
  while (angle >  math_pi) do angle = angle - 2.0 * math_pi end
  return angle
end


local function smooth_corner(points, normals, new_points, new_normals, d, i, j)
  local corner_angle = normal_angle(normals, i, j)
  if (d > 0.0 and (corner_angle < -math_pi*0.25 or corner_angle >  math_pi*0.9999)) or
     (d < 0.0 and (corner_angle >  math_pi*0.25 or corner_angle < -math_pi*0.9999)) then

    local start_angle = math_atan2(normals[i][2], normals[i][1])

    local section_count = round(math_abs(corner_angle / math_pi * 8))
    local angle_step = -math_abs(corner_angle / section_count) * sign(d)
    for k = 1, section_count-1 do
      local section_angle = start_angle + k * angle_step;
      new_normals[#new_normals+1] = { math_cos(section_angle), math_sin(section_angle) }
      new_points[#new_points+1] = { points[j][1], points[j][2] }
    end
  end
end


--- Smooth off outside corners over 45 degrees
--  It adds copies of the points on outside corner to points (so all the
--  points are coincident), but makes the normals to the sections between
--  them do the right thing.
local function smooth_corners(points, normals, d, polygon, length)
  local new_normals = { normals[1] }
  local new_points = { points[1] }
  for i = 2, length-1 do
    new_points[#new_points+1] = points[i]
    smooth_corner(points, normals, new_points, new_normals, d, i-1, i)
    new_normals[#new_normals+1] = normals[i]
  end

  if polygon then
    smooth_corner(points, normals, new_points, new_normals, d, length-1, 1)
  end
  new_points[#new_points+1] = points[length]

  return new_points, new_normals;
end


--- Work out the direction a point that is at the intersection of two
--  line segments with the given normals will move in.
local function direction(normals, i, j)
  local dot = normals[i][1]*normals[j][1] + normals[i][2]*normals[j][2]
  local multiplier = 1 / (1 + dot)
  return { multiplier * (normals[i][1] + normals[j][1]),
           multiplier * (normals[i][2] + normals[j][2]) }
end


--- Work out when a line segment will disappear if its two ends
--  are moving in the given directions.
local function disappear(offset, x1, y1, dx1, dy1, x2, y2, dx2, dy2)
  local d
  if x2 == x1 then
    if dy1 == dy2 then return false end
    d = (y2 - y1) / (dy1 - dy2)
  else
    if dx1 == dx2 then return false end
    d = (x2 - x1) / (dx1 - dx2)
  end
  if offset < 0.0 then
    return d < 0.0 and d >= offset
  else
    return d > 0.0 and d <= offset
  end
end


------------------------------------------------------------------------------

--- Work out the intersection of two line segments given a point on the
--  segments and a normal to them (we do it this way because the segments might
--  have no length if they were produced by smooth_corners)
local function intersection(p1, n1, p2, n2)
  local x1, y1 = p1[1], p1[2]
  local dx1, dy1 = n1[2], -n1[1]

  local x2, y2 = p2[1], p2[2]
  local dx2, dy2 = n2[2], -n2[1]

  local den = dx1*dy2 - dy1*dx2
  -- if the lines are too parallel, then we don't need the intermediate point
  -- at all.
  if math.abs(den) < 0.1 then return end

  local w = ((x2 - x1) * dy2 - (y2 - y1) * dx2) / den
  return { x1 + w * dx1, y1 + w * dy1 }
end


local function offset(points, d, polygon, first, last, X, Y)
  if d == 0 then
    return points
  end

  -- The easiest thing to do here is just take a copy of the polyline
  -- into a table
  local length
  if (first ~= 1 or X ~= 1 or Y ~= 2) then
    length = 0
    local p2 = {}
    for i = first, last do
      length = length + 1
      p2[length] = { points[i][X], points[i][Y] }
    end
    points = p2
  else
    length = last - first + 1
  end

  -- Compute normals to all the line segments in the polyline
  local normals = {}
  for i = 1, length-1 do
    normals[i] = normal(points[i][1], points[i][2], points[i+1][1], points[i+1][2])
  end

  -- Smooth out any corners over 45 degress
  points, normals = smooth_corners(points, normals, d, polygon, length)

  -- Compute the directions every intersection is going to move in
  local directions = {}
  if polygon then
    directions[1] = direction(normals, #normals, 1, d)
  else
    directions[1] = normals[1]
  end
  for i = 2, #normals do
    directions[i] = direction(normals, i-1, i, d)
  end
  if polygon then
    directions[#points] = direction(normals, #normals, 1, d)
  else
    directions[#points] = normals[#normals]
  end

  -- run through this loop until we see no changes
  while true do
    -- Run through all the line segments, checking if they'll disappear
    -- at this level of offset.  If so, mark them to disappear and note
    -- that we saw a change.
    local changes, keep_any = false, false
    local keep = {}
    for i = 2, #directions do
      if disappear(d,
         points[i-1][1], points[i-1][2],
         directions[i-1][1], directions[i-1][2],
         points[i][1], points[i][2],
         directions[i][1], directions[i][2]) then
        changes = true
        keep[i-1] = false
      else
        keep[i-1] = true
        keep_any = true
      end
    end

    -- If nothing's going to disappear, we're done.
    if not changes then break end
    if not keep_any then points = {} break end

    local i = 1
    while not keep[i] do i = i + 1 end

    local new_normals, new_points, new_directions = {}, {}, {}

    local function add_point(j)
      new_normals[#new_normals+1] = normals[j]
      new_points[#new_points+1] = points[j]
      new_directions[#new_directions+1] = directions[j]
    end
    add_point(i)

    while true do
      local j = i + 1
      if keep[j] then
        add_point(j)
      else
        -- If we drop a segment (or segments) we have to replace it/them
        -- with a point at the intersection of the surrounding kept segments.
        while not keep[j] and j <= #keep do j = j + 1 end
        if keep[j] then
          local new_point = intersection(points[i], normals[i], points[j], normals[j])
          if new_point then
            new_points[#new_points+1] = new_point
            new_normals[#new_normals+1] = normals[j]
            new_directions[#new_directions+1] = direction(normals, i, j)
          end
        else
          new_directions[#new_directions+1] = normals[i]
          new_points[#new_points+1] = points[i+1]
          break
        end
      end

      i = j
    end

    normals = new_normals
    points = new_points
    directions = new_directions
  end

  -- Now we've got all the points we're keeping.  Offsetting them is easy.
  local result = {}
  for i = 1, #points do
    result[first+i-1] =
    {
      [X] = points[i][1] + d * directions[i][1],
      [Y] = points[i][2] + d * directions[i][2]
    }
    if result[first+i-1][X] == -1/0 then
      print(pretty.write(result[first+i-1]))
      print(pretty.write(directions[i]))
      print(pretty.write(points[i]))
    end
  end

  return result
end


------------------------------------------------------------------------------

return { offset = offset }

------------------------------------------------------------------------------
