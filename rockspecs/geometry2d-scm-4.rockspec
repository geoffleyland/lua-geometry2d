package = "geometry2d"
version = "scm-4"
source =
{
  url = "https://github.com/geoffleyland/lua-geometry2d.git"
}
description =
{
  summary = "2D Geometry",
  homepage = "https://github.com/geoffleyland/lua-geometry2d",
  license = "MIT/X11",
  maintainer = "Geoff Leyland <geoff.leyland@incremental.co.nz>",
}
dependencies =
{
  "lua >= 5.1",
}
build =
{
  type = "builtin",
  modules =
  {
    ["geometry2d"] = "src-lua/geometry2d.lua",
    ["geometry2d.primitives"] = "src-lua/geometry2d/primitives.lua",
    ["geometry2d.polylines"] = "src-lua/geometry2d/polylines.lua",
    ["geometry2d.polygons"] = "src-lua/geometry2d/polygons.lua",
    ["geometry2d.polyline_offset"] = "src-lua/geometry2d/polyline_offset.lua",
  },
}
