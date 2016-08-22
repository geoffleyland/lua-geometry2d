package = "geometry2d"
version = "scm-1"
source =
{
  url = "git://github.com/geoffleyland/lua-geometry2d.git"
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
    ["nz.co.incremental.geometry2d"] = "src-lua/geometry2d.lua",
    ["nz.co.incremental.geometry2d.primitives"] = "src-lua/geometry2d/primitives.lua",
    ["nz.co.incremental.geometry2d.polylines"] = "src-lua/geometry2d/polylines.lua",
    ["nz.co.incremental.geometry2d.polygons"] = "src-lua/geometry2d/polygons.lua",
  },
}
