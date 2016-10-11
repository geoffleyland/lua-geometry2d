-- luacheck: std max+busted

describe("Polyline Offset", function()
  local G2D = require"geometry2d"
  local G2D12 = G2D:new(1, 2, 1)

  test("simple line", function()
    local p1 = {{0, 0}, {1, 0}}
    assert.are.same({{0,  0.5}, {1,  0.5}}, G2D12.polyline_offset(p1,  0.5))
    assert.are.same({{0,  1  }, {1,  1  }}, G2D12.polyline_offset(p1,  1))
    assert.are.same({{0, -0.5}, {1, -0.5}}, G2D12.polyline_offset(p1, -0.5))
    assert.are.same({{0, -1  }, {1, -1  }}, G2D12.polyline_offset(p1, -1))

    local p2 = {{0, 0}, {0, 1}}
    assert.are.same({{-0.5, 0}, {-0.5, 1}}, G2D12.polyline_offset(p2,  0.5))
    assert.are.same({{-1,   0}, {-1,   1}}, G2D12.polyline_offset(p2,  1))
    assert.are.same({{ 0.5, 0}, { 0.5, 1}}, G2D12.polyline_offset(p2, -0.5))
    assert.are.same({{ 1,   0}, { 1,   1}}, G2D12.polyline_offset(p2, -1))
  end)


  test("right angle", function()
    local p1 = {{0, 0}, {10, 0}, {10, 10}}
    assert.are.same({{0,  1}, {9, 1}, {9, 10}}, G2D12.polyline_offset(p1,  1))
    assert.are.same({{0,  2}, {8, 2}, {8, 10}}, G2D12.polyline_offset(p1,  2))
    local r1 = G2D12.polyline_offset(p1, -1)
    assert.are.same({ 0,  -1}, r1[1])
    assert.are.same({11,  10}, r1[#r1])
    assert.are.same(-1, r1[2][2])
    assert.are.same(11, r1[#r1-1][1])
  end)


  test("disappear", function()
    local p1 = {{-10, 9}, {-1, 0}, {1, 0}, {10, 9}}
    local r1 = G2D12.polyline_offset(p1, 0.1)
    assert.near(-r1[1][1], r1[4][1], 1e-9)
    assert.near(-r1[1][1], 10 - 0.1/math.sqrt(2), 1e-9)
    assert.near( r1[1][2], r1[4][2], 1e-9)
    assert.near( r1[1][2], 9 + 0.1/math.sqrt(2), 1e-9)
    assert.near(-r1[2][1], r1[3][1], 1e-9)
    assert.near( r1[2][2], r1[3][2], 1e-9)
    assert.near( r1[2][2], 0.1, 1e-9)

    local r2 = G2D12.polyline_offset(p1,  1)
    assert.near(-r2[1][1], r2[4][1], 1e-9)
    assert.near( r2[1][2], r2[4][2], 1e-9)
    assert.near(-r2[2][1], r2[3][1], 1e-9)
    assert.near( r2[2][2], r2[3][2], 1e-9)
    assert.near( r2[2][2], 1, 1e-9)

    local r3 = G2D12.polyline_offset(p1,  2)
    assert.near(-r3[1][1], r3[4][1], 1e-9)
    assert.near( r3[1][2], r3[4][2], 1e-9)
    assert.near(-r3[2][1], r3[3][1], 1e-9)
    assert.near( r3[2][2], r3[3][2], 1e-9)
    assert.near( r3[2][2], 2, 1e-9)

    local r4 = G2D12.polyline_offset(p1,  3)
    assert.near(-r4[1][1], r4[3][1], 1e-9)
    assert.near( r4[1][2], r4[3][2], 1e-9)
    assert.near(-r4[2][1], 0, 1e-9)
  end)

  test("polygon outset", function()
    local p1 = {{-1, 1}, {1, 1}, {1, -1}, {-1, -1}, {-1, 1}}
    local r1 = po.offset(p1, 1, true, 1, 5, 1, 2)
    assert.same(r1[1], r1[#r1])

    assert.same(r1[1][1], -r1[2][1])
    assert.same(r1[1][2], 2)
    assert.same(r1[2][2], 2)

    assert.same(r1[5][2], -r1[6][2])
    assert.same(r1[5][1], 2)
    assert.same(r1[6][1], 2)

    assert.same(r1[9][1], -r1[10][1])
    assert.same(r1[9][2], -2)
    assert.same(r1[10][2], -2)

    assert.same(r1[13][2], -r1[14][2])
    assert.same(r1[13][1], -2)
    assert.same(r1[14][1], -2)
  end)

  test("polygon inset", function()
    local p1 = {{-1, 1}, {1, 1}, {1, -1}, {-1, -1}, {-1, 1}}
    local r1 = po.offset(p1, -0.1, true, 1, 5, 1, 2)
    assert.same({{-0.9, 0.9}, {0.9, 0.9}, {0.9, -0.9}, {-0.9, -0.9}, {-0.9, 0.9}}, r1)
  end)
end)