--- @module nz.co.incremental.geometry2d.polygons
-- (c) Copyright 2013-2016 Geoff Leyland.
-- See LICENSE for license information

local P = require"geometry2d.primitives"
local polygons = {}


------------------------------------------------------------------------------

--- Winding method for determining if a point is in a polygon.
-- The polygon must be closed (ie points[first] = points[last])
-- http://geomalgorithms.com/a03-_inclusion.html (wn_PnPoly)
function polygons.inside(x, y, points, first, last, X, Y)
  local winding = 0
  for i = first, last - 1 do
    if points[i][Y] <= y then
      if points[i+1][Y] > y and
         P.to_left(x, y, points[i][X], points[i][Y], points[i+1][X], points[i+1][Y]) > 0 then
        winding = winding + 1
      end
    elseif points[i+1][Y] <= y and
           P.to_left(x, y, points[i][X], points[i][Y], points[i+1][X], points[i+1][Y]) < 0 then
      winding = winding - 1
    end
  end
  return winding ~= 0
end


------------------------------------------------------------------------------

--- Is a polygon wound clockwise or anticlockwise?
--  The polygon must be closed (ie points[first] = points[last])
--  We find the lowest point on the polygon, and then check whether
--  it is to the left or right of the line segment joining the points
--  surrounding it.
--  @return "clockwise", "counterclockwise"
function polygons.orientation(points, first, last, X, Y)
  local imin, xmin, ymin = first, points[first][X], points[first][Y]
  for i = first + 1, last - 1 do
    if points[i][Y] < ymin or
       (points[i][Y] == ymin and points[i][X] > xmin) then
      imin = i
      xmin, ymin = points[i][X], points[i][Y]
    end
  end

  local prev, next = imin == first and last - 1 or imin - 1, imin + 1
  local l = P.to_left(points[imin][X], points[imin][Y],
                      points[prev][X], points[prev][Y],
                      points[next][X], points[next][Y])

  if l < 0 then return "counterclockwise"
  elseif l > 0 then return "clockwise"
  else return "degenerate" end
end


------------------------------------------------------------------------------

--- Compute the centroid of a polygon
function polygons.centroid(points, first, last, X, Y)
  local x, y, A = 0, 0, 0

  for i = first, last - 1 do
    local p, q = points[i], points[i+1]
    local z = (p[X]*q[Y] - q[X]*p[Y])
    A = A + z
    x = x + z * (p[X] + q[X])
    y = y + z * (p[Y] + q[Y])
  end
  A = A / 2
  x = x / (6 * A)
  y = y / (6 * A)

  return x, y
end


--- Compute the area of a polygon.
--  A clockwise-wound polygon has a positive area,
--  and a counter-clockwise wound polygon has a negative area.
function polygons.area(points, first, last, X, Y)
  local area = points[first][X] * (points[last-1][Y] - points[first+1][Y])
  for i = first + 1, last -1 do
    area = area + points[i][X] * (points[i-1][Y] - points[i+1][Y])
  end
  return area * 0.5
end


------------------------------------------------------------------------------

return polygons

------------------------------------------------------------------------------
