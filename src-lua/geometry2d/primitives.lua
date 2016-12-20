--- @module nz.co.incremental.geometry2d.primitives
-- (c) Copyright 2013-2016 Geoff Leyland.
-- See LICENSE for license information

local math_abs, math_sqrt =
      math.abs, math.sqrt


local DEFAULT_SMALL = 1e-8

------------------------------------------------------------------------------
--- @section Point primitives

--- 2D dot product.
local function dot(dx1, dy1, dx2, dy2)
  return dx1*dx2 + dy1*dy2
end


local function point_to_point_squared(x1, y1, x2, y2)
  local dx, dy = x2 - x1, y2 - y1
  return dx*dx + dy*dy
end


--- Distance between two points.
local function point_to_point(x1, y1, x2, y2)
  return math_sqrt(point_to_point_squared(x1, y1, x2, y2))
end


------------------------------------------------------------------------------
--- @section Points and line segments

--- Is a point to the left of a line segment?
--  @return
--    a positive number if the point is to the left
--    zero if it's on the line
--    a negative number if it's on the right.
local function to_left(x, y, x1, y1, x2, y2)
  return (x - x1) * (y1 - y2) + (y - y1) * (x2 - x1)
end


--- Left side normal to a line segment
local function left_normal(x1, y1, x2, y2)
  local nx, ny = y1 - y2, x2 - x1
  local id = 1 / math_sqrt(nx*nx + ny*ny)
  return nx * id, ny * id
end


--- Squared distance between a point and a finite line segment
--  http://geomalgorithms.com/a02-_lines.html (dist_Point_to_Segment)
--  @return squared distance between point and line segment
--  @return x coordinate of nearest point on the segment
--  @return y coordinate of nearest point on the segment
--  @return the "location" (p1=0, p2=1) of the nearest point on the segment
local function point_to_segment_squared(x, y, x1, y1, x2, y2)
  local dx, dy = x2 - x1, y2 - y1
  local px, py = x - x1, y - y1

  local c1 = dot(dx, dy, px, py)
  if c1 <= 0 then
    return point_to_point_squared(x, y, x1, y1), x1, y1, 0
  end

  local c2 = dot(dx, dy, dx, dy)
  if c1 >= c2 then
    return point_to_point_squared(x, y, x2, y2), x2, y2, 1
  end

  local w = c1 / c2
  local ix, iy = x1 + w * dx, y1 + w * dy
  return point_to_point_squared(x, y, ix, iy), ix, iy, w
end


--- Distance between a point and a finite line segment
--  http://geomalgorithms.com/a02-_lines.html (dist_Point_to_Segment)
--  @return squared distance between point and line segment
--  @return x coordinate of nearest point on the segment
--  @return y coordinate of nearest point on the segment
--  @return the "location" (p1=0, p2=1) of the nearest point on the segment
local function point_to_segment(x, y, x1, y1, x2, y2)
  local d, xr, yr, w = point_to_segment_squared(x, y, x1, y1, x2, y2)
  return math_sqrt(d), xr, yr, w
end


------------------------------------------------------------------------------
--- @section Line segments to line segments

--- Squared distance between one line segment and another
-- http://geomalgorithms.com/a07-_distance.html (dist3D_Segment_to_Segment)
--  @return squared distance between the line segments
--  @return x coordinate of nearest point on the first segment
--  @return y coordinate of nearest point on the first segment
--  @return x coordinate of nearest point on the second segment
--  @return y coordinate of nearest point on the second segment
--  @return the "location" (p1=0, p2=1) of the nearest point on the first segment
--  @return the "location" (p1=0, p2=1) of the nearest point on the second segment
local function segment_to_segment_squared(ax1, ay1, ax2, ay2, bx1, by1, bx2, by2, SMALL)
  SMALL = SMALL or DEFAULT_SMALL

  local ux, uy = ax2 - ax1, ay2 - ay1
  local vx, vy = bx2 - bx1, by2 - by1
  local wx, wy = ax1 - bx1, ay1 - by1
  local a = ux*ux + uy*uy
  local b = ux*vx + uy*vy
  local c = vx*vx + vy*vy
  local d = ux*wx + uy*wy
  local e = vx*wx + vy*wy
  local D = a*c - b*b
  local sD, tD = D, D
  local sN, tN

  if D < SMALL then           -- lines are parallel
    sN, sD = 0, 1
    tN, tD = e, c
  else
    sN = b*e - c*d
    tN = a*e - b*d
    if sN < 0 then            -- sc < 0 => the s == 0 edge is visible
      sN = 0
      tN, tD = e, c
    elseif sN > sD then       -- sc > 1  => the s == 1 edge is visible
      sN = sD
      tN, tD = e + b, c
    end
  end

  if tN < 0 then              -- tc < 0 => the t == 0 edge is visible
    tN = 0
    if     -d < 0 then sN = 0
    elseif -d > a then sN = sD
    else
      sN = -d
      sD = a
    end
  elseif tN > tD then         -- tc > 1  => the t == 1 edge is visible
    tN = tD
    if     -d + b < 0 then sN = 0
    elseif -d + b > a then sN = sD
    else
      sN = -d + b
      sD = a
    end
  end

  local sc = ((math_abs(sN) < SMALL) and 0) or (sN / sD)
  local tc = ((math_abs(tN) < SMALL) and 0) or (tN / tD)

  local ax, ay = ax1 + sc*ux, ay1 + sc*uy
  local bx, by = bx1 + tc*vx, by1 + tc*vy

  local d2 = point_to_point_squared(ax, ay, bx, by)

  return d2, ax, ay, bx, by, sc, tc
end


local function segment_to_segment(ax1, ay1, ax2, ay2, bx1, by1, bx2, by2, SMALL)
  local d2, ax, ay, bx, by, sc, tc =
    segment_to_segment_squared(ax1, ay1, ax2, ay2, bx1, by1, bx2, by2, SMALL)
  return math_sqrt(d2), ax, ay, bx, by, sc, tc
end


------------------------------------------------------------------------------

return
{
  DEFAULT_SMALL = DEFAULT_SMALL,
  dot = dot,
  point_to_point_squared = point_to_point_squared,
  point_to_point = point_to_point,
  to_left = to_left,
  left_normal = left_normal,
  point_to_segment_squared = point_to_segment_squared,
  point_to_segment = point_to_segment,
  segment_to_segment_squared = segment_to_segment_squared,
  segment_to_segment = segment_to_segment,
}

------------------------------------------------------------------------------
