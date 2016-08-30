--- @module nz.co.incremental.geometry2d.polylines
-- (c) Copyright 2013-2016 Geoff Leyland.
-- See LICENSE for license information

local P = require"geometry2d.primitives"

local math_huge, math_min, math_max, math_sqrt =
      math.huge, math.min, math.max, math.sqrt

local polylines = {}


------------------------------------------------------------------------------

--- Length of a polyline
function polylines.length(points, first, last, X, Y)
  local length = 0
  for i = first, last-1 do
    length = length + P.point_to_point(points[i]  [X], points[i]  [Y],
                                       points[i+1][X], points[i+1][Y])
  end
  return length
end


--- Length along a polyline up to a point
function polylines.length_to(points, first, last, w, X, Y)
  local length = polylines.length(points, first, last, X, Y)
  if w > 0 then
    local e = P.point_to_point(
      points[last]  [X], points[last]  [Y],
      points[last+1][X], points[last+1][Y])
    length = length + e * w
  end
  return length
end


--- Find the point on a polyline closest to a given point
--  @return the distance between the point and the polyline
--  @return x coordinate of the nearest point on the polyline
--  @return y coordinate of the nearest point on the polyline
--  @return "location" of the point (p[i]=0, p[i+1]=1) of the point on the nearest segment
--  @return index of the polyline point before the nearest point
function polylines.to_point(x, y, points, first, last, X, Y)
  local d2, xd, yd, wd, id = math_huge
  for i = first, last-1 do
    local d2t, xt, yt, wt = P.point_to_segment_squared(
      x, y, points[i][X], points[i][Y], points[i+1][X], points[i+1][Y])
    if d2t < d2 then
      d2, xd, yd, wd, id = d2t, xt, yt, wt, i
    end
  end
  return math_sqrt(d2), xd, yd, wd, id
end


------------------------------------------------------------------------------
--- @section closest approach of two polylines
--  We try to do this a bit quickly, and there's probably literature to do
--  it a better way.  We work out the bounds of the first polyline, then
--  we order the segments of the second polyline based on the furthest
--  the segment is in one dimension from the bounds of the first polyline.
--  This gives a lower bound on the distance between the segment and the first
--  polyline.
--  We run through the segments in this order until the lower bound we see is
--  greater than the best distance we've found so far.
local function bounds_from_points(points, first, last, X, Y)
  local xmin, ymin, xmax, ymax = math_huge, math_huge, -math_huge, -math_huge
  for i = first, last do
    xmin, ymin, xmax, ymax =
      math_min(xmin, points[i][X]),
      math_min(ymin, points[i][Y]),
      math_max(xmax, points[i][X]),
      math_max(ymax, points[i][Y])
  end
  return xmin, ymin, xmax, ymax
end


local function quick_point_to_bounds(x, y, xmin, ymin, xmax, ymax)
  return math.max(0, xmin - x, x - xmax, ymin - y, y - ymax)
end


local function order_segments(p1, p2, first1, last1, first2, last2, X, Y)
  local p1xmin, p1ymin, p1xmax, p1ymax = bounds_from_points(p1, first1, last1, X, Y)
  local order, count = {}, 0
  for i = first2, last2 - 1 do
    local d = math.min(
      quick_point_to_bounds(p2[i][X], p2[i][Y], p1xmin, p1ymin, p1xmax, p1ymax),
      quick_point_to_bounds(p2[i+1][X], p2[i+1][Y], p1xmin, p1ymin, p1xmax, p1ymax))
    count = count + 1
    order[count] = { d2 = d*d, index = i }
  end
  table.sort(order, function(a, b) return a.d2 < b.d2 end)
  return order
end


function polylines.closest_approach(p1, p2, first1, last1, first2, last2, X, Y, SMALL)
  local o1 = order_segments(p2, p1, first2, last2, first1, last1, X, Y)
  local o2 = order_segments(p1, p2, first1, last1, first2, last2, X, Y)

  local d2 = math_huge
  local x1, y1, x2, y2, w1, w2, i1, i2

  local length_o2 = last2-first2
  for i = 1, last1-first1 do
    if o1[i].d2 > d2 then break end
    local ii = o1[i].index
    for j = 1, length_o2 do
      if o2[j].d2 > d2 then break end
      local jj = o2[j].index
      local d2t, x1t, y1t, x2t, y2t, w1t, w2t = 
        P.segment_to_segment_squared(
          p1[ii][X], p1[ii][Y], p1[ii+1][X], p1[ii+1][Y],
          p2[jj][X], p2[jj][Y], p2[jj+1][X], p2[jj+1][Y], SMALL)
      if d2t < d2 then
        d2 = d2t
        x1, y1, x2, y2 = x1t, y1t, x2t, y2t
        w1, w2 = w1t, w2t
        i1, i2 = ii, jj
      end
    end
  end

  return math_sqrt(d2), x1, y1, x2, y2, w1, w2, i1, i2
end


------------------------------------------------------------------------------

function polylines.reverse_points(points, first, last)
  for i = 0, math.floor((last - first - 1)/2) do
    points[first+i], points[last-i] = points[last-i], points[first+i]
  end
  return points
end


function polylines.reverse_coordinates(points, first, last, X, Y)
  for i = 0, math.floor((last - first - 1)/2) do
    points[first+i][X], points[last-i][X] = points[last-i][X], points[first+i][X]
    points[first+i][Y], points[last-i][Y] = points[last-i][Y], points[first+i][Y]
  end
  return points
end


------------------------------------------------------------------------------

return polylines

------------------------------------------------------------------------------
