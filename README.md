# lua-geometry2d - 2D Geometry Algorithms for Lua

[![Build Status](https://travis-ci.org/geoffleyland/lua-geometry2d.svg?branch=master)](https://travis-ci.org/geoffleyland/lua-geometry2d)
[![Coverage Status](https://coveralls.io/repos/github/geoffleyland/lua-geometry2d/badge.svg?branch=master)](https://coveralls.io/github/geoffleyland/lua-geometry2d?branch=master)

## 1. What?

geometry2d is a pure Lua implementation of some 2d geometric algorithms:

+ Distance between two points
+ Left normal to a line segment
+ Distance from a point to a line segment
+ Distance between two line segments
+ Length of a polyline
+ Distance from a point to a polyline
+ Distance between two polylines
+ Is a point in a polygon?
+ Polygon orientation
+ Polygon centroid

To use it you instantiate a geometry object by telling it what you call your
x and y coordinates (which might be 1 and 2) and the index of the first element
in a polyline or polygon array.


## 2. Why?

It's just a collection of geometry bits I've needed from time to time.


## 3. How?

``luarocks install geometry2d``


## 4. Requirements

Lua >= 5.1 or LuaJIT >= 2.0.0.


## 5. Issues

+ Incomplete


## 6. Wishlist

+ Tests?
+ Documentation?

## 6. Alternatives

+ Many!