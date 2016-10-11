--- @module nz.co.incremental.geometry2d
-- (c) Copyright 2013-2016 Geoff Leyland.
-- See LICENSE for license information

local primitives = require"geometry2d.primitives"
local polylines = require"geometry2d.polylines"
local polygons = require"geometry2d.polygons"
local offset = require"geometry2d.polyline_offset"

local geometry2d = {}
geometry2d.__index = geometry2d


------------------------------------------------------------------------------

-- luacheck: push no self

function geometry2d:new(X, Y, BASE, SMALL)
  return setmetatable(
    {
      X = X or "x",
      Y = Y or "y",
      BASE = BASE or 1,
      SMALL = SMALL or primitives.DEFAULT_SMALL,
    }, geometry2d)
end


------------------------------------------------------------------------------

function geometry2d:dot(dx1, dy1, dx2, dy2)
  return primitives.dot(dx1, dy1, dx2, dy2)
end


function geometry2d:point_to_point(x1, y1, x2, y2)
  return primitives.point_to_point(x1, y1, x2, y2)
end


function geometry2d:to_left(x, y, x1, y1, x2, y2)
  return primitives.to_left(x, y, x1, y1, x2, y2)
end


function geometry2d:left_normal(x1, y1, x2, y2)
  return primitives.left_normal(x1, y1, x2, y2)
end


function geometry2d:point_to_segment(x, y, x1, y1, x2, y2)
  return primitives.point_to_segment(x, y, x1, y1, x2, y2)
end


function geometry2d:segment_to_segment(ax1, ay1, ax2, ay2, bx1, by1, bx2, by2)
  return primitives.segment_to_segment(ax1, ay1, ax2, ay2, bx1, by1, bx2, by2)
end

-- luacheck: pop

------------------------------------------------------------------------------

function geometry2d:_std_args(p, n)
  return p, self.BASE, (n or #p) + self.BASE - 1, self.X, self.Y
end


------------------------------------------------------------------------------

function geometry2d:polyline_length(p, n)
  return polylines.length(self:_std_args(p, n))
end


function geometry2d:polyline_length_to(p, i, w)
  return polylines.length_to(p, self.BASE, i, w, self.X, self.Y)
end


function geometry2d:point_to_polyline(x, y, p, n)
  return polylines.to_point(x, y, self:_std_args(p, n))
end


function geometry2d:polyline_to_polyline(p1, p2, n1, n2)
  return polylines.closest_approach(p1, p2,
    self.BASE, (n1 or #p1) + self.BASE - 1,
    self.BASE, (n2 or #p2) + self.BASE - 1,
    self.X, self.Y)
end


function geometry2d:reverse_points(p, n)
  return polylines.reverse_points(self:_std_args(p, n))
end


function geometry2d:reverse_coordinates(p, n)
  return polylines.reverse_coordinates(self:_std_args(p, n))
end


------------------------------------------------------------------------------

function geometry2d:inside_polygon(x, y, p, n)
  return polygons.inside(x, y, self:_std_args(p, n))
end


function geometry2d:polygon_orientation(p, n)
  return polygons.orientation(self:_std_args(p, n))
end


function geometry2d:polygon_centroid(p, n)
  return polygons.centroid(self:_std_args(p, n))
end


function geometry2d:polygon_area(p, n)
  return polygons.area(self:_std_args(p, n))
end


------------------------------------------------------------------------------

function geometry2d:offset_polyline(p, d, n)
  return offset.offset(p, d, false, self.BASE, (n or #p) + self.BASE - 1, self.X, self.Y)
end


function geometry2d:offset_polygon(p, d, n)
  return offset.offset(p, d, true, self.BASE, (n or #p) + self.BASE - 1, self.X, self.Y)
end


------------------------------------------------------------------------------

return geometry2d

------------------------------------------------------------------------------

