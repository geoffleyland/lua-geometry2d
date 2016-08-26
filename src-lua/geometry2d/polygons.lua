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
function polygons.orientation(p, first, last, X, Y)
  local imin, xmin, ymin = first, p[first][X], p[first][Y]
  for i = first + 1, last - 1 do
    if p[i][Y] < ymin or
       (p[i][Y] == ymin and p[i][X] > xmin) then
      xmin, ymin = p[i][X], p[i][Y]
    end
  end

  local prev, next = imin == first and last - 1 or imin - 1, imin + 1
  local l = P.to_left(p[next][X], p[next][Y],
                    p[prev][X], p[prev][Y], p[imin][X], p[imin][Y])

  if l < 0 then return "counterclockwise"
  elseif l > 0 then return "clockwise"
  else return "degenerate" end
end


------------------------------------------------------------------------------

function polygons.centroid(p, first, last, X, Y)
  local x, y, A = 0, 0, 0

  for i = first, last - 1 do
    local p, q = p[i], p[i+1]
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


function polygons.area(p, first, last, X, Y)
  local area = p[first][X] * (p[first+1][Y] - p[last-1][Y])
  for i = first + 1, last -1 do
    area = area + p[i][X] * (p[i+1][Y] - p[i-1][Y])
  end
  return area * 0.5
end


------------------------------------------------------------------------------

return polygons

------------------------------------------------------------------------------
