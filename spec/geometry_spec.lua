
describe("Primitives", function()
  local G2D, G2D12
 
  setup(function()
    G2D = require"geometry2d"
    G2D12 = G2D:new(1, 2, 1)
  end)

  test("dot", function()
    assert.equal(1, G2D12:dot(0, 1, 0, 1))
    assert.equal(0, G2D12:dot(0, 1, 1, 0))
    assert.equal(2, G2D12:dot(1, 1, 1, 1))
    assert.equal(1, G2D12:dot(0, 1, 1, 1))
  end)

  test("point_to_point", function()
    assert.equal(0, G2D12:point_to_point(0, 1, 0, 1))
    assert.equal(1, G2D12:point_to_point(0, 0, 0, 1))
    assert.equal(math.sqrt(2), G2D12:point_to_point(0, 0, 1, 1))
    assert.equal(math.sqrt(2), G2D12:point_to_point(0, 0, -1, -1))
  end)

  test("to_left", function()
    assert(G2D12:to_left(-1, 0, 0, -1, 0,  1)  > 0)
    assert(G2D12:to_left( 1, 0, 0, -1, 0,  1)  < 0)
    assert(G2D12:to_left( 0, 0, 0, -1, 0,  1) == 0)
    assert(G2D12:to_left(-1, 0, 0,  1, 0, -1)  < 0)
    assert(G2D12:to_left( 1, 0, 0,  1, 0, -1)  > 0)
    assert(G2D12:to_left( 0, 0, 0,  1, 0, -1) == 0)
  end)

  test("left_normal", function()
    assert.are.same({ -1,  0 }, { G2D12:left_normal(0, 0,  0,  1) })
    assert.are.same({  1,  0 }, { G2D12:left_normal(0, 0,  0, -1) })
    assert.are.same({  0,  1 }, { G2D12:left_normal(0, 0,  1,  0) })
    assert.are.same({  0, -1 }, { G2D12:left_normal(0, 0, -1,  0) })
    assert.are.same({ -1,  0 }, { G2D12:left_normal(1, 1,  1,  2) })
    -- If you change this to math.sqrt(0.5), then it's not floating-point exact.
    -- This should really be a test for closeness, but...
    assert.are.same({ -1 / math.sqrt(2), 1 / math.sqrt(2) }, { G2D12:left_normal(1, 1,  2,  2) })
  end)

  test("point_to_segment", function()
    assert.equal(1, G2D12:point_to_segment(-1,  0, 0, 0, 2, 0))
    assert.equal(0, G2D12:point_to_segment( 0,  0, 0, 0, 2, 0))
    assert.equal(0, G2D12:point_to_segment( 1,  0, 0, 0, 2, 0))
    assert.equal(0, G2D12:point_to_segment( 2,  0, 0, 0, 2, 0))
    assert.equal(1, G2D12:point_to_segment( 3,  0, 0, 0, 2, 0))
    assert.equal(math.sqrt(2), G2D12:point_to_segment(-1, 1, 0, 0, 2, 0))
    assert.equal(1, G2D12:point_to_segment( 0,  1, 0, 0, 2, 0))
    assert.equal(1, G2D12:point_to_segment( 1,  1, 0, 0, 2, 0))
    assert.equal(1, G2D12:point_to_segment( 2,  1, 0, 0, 2, 0))
    assert.equal(math.sqrt(2), G2D12:point_to_segment( 3, 1, 0, 0, 2, 0))

    assert.equal(1, G2D12:point_to_segment( 0, -1, 0, 0, 0, 2))
    assert.equal(0, G2D12:point_to_segment( 0,  0, 0, 0, 0, 2))
    assert.equal(0, G2D12:point_to_segment( 0,  1, 0, 0, 0, 2))
    assert.equal(0, G2D12:point_to_segment( 0,  2, 0, 0, 0, 2))
    assert.equal(1, G2D12:point_to_segment( 0,  3, 0, 0, 0, 2))
    assert.equal(math.sqrt(2), G2D12:point_to_segment(1, -1, 0, 0, 0, 2))
    assert.equal(1, G2D12:point_to_segment( 1,  0, 0, 0, 0, 2))
    assert.equal(1, G2D12:point_to_segment( 1,  1, 0, 0, 0, 2))
    assert.equal(1, G2D12:point_to_segment( 1,  2, 0, 0, 0, 2))
    assert.equal(math.sqrt(2), G2D12:point_to_segment(1, 3, 0, 0, 0, 2))
  end)

  test("segment_to_segment", function()
    assert.equal(1, G2D12:segment_to_segment( 0, 0, 1, 0, -2, 0, -1, 0))
    assert.equal(0, G2D12:segment_to_segment( 0, 0, 1, 0, -1, 0,  0, 0))
    assert.equal(0, G2D12:segment_to_segment( 0, 0, 1, 0,  0, 0,  1, 0))
    assert.equal(0, G2D12:segment_to_segment( 0, 0, 1, 0,  1, 0,  2, 0))
    assert.equal(1, G2D12:segment_to_segment( 0, 0, 1, 0,  2, 0,  3, 0))

    assert.equal(math.sqrt(2), G2D12:segment_to_segment( 0, 0, 1, 0, -2, 1, -1, 1))
    assert.equal(1, G2D12:segment_to_segment( 0, 0, 1, 0, -1, 1,  0, 1))
    assert.equal(1, G2D12:segment_to_segment( 0, 0, 1, 0,  0, 1,  1, 1))
    assert.equal(1, G2D12:segment_to_segment( 0, 0, 1, 0,  1, 1,  2, 1))
    assert.equal(math.sqrt(2), G2D12:segment_to_segment( 0, 0, 1, 0,  2, 1,  3, 1))

    assert.equal(1, G2D12:segment_to_segment( 0, 0, 2, 0, 1, -3, 1, -1))
    assert.equal(0, G2D12:segment_to_segment( 0, 0, 2, 0, 1, -2, 1,  0))
    assert.equal(0, G2D12:segment_to_segment( 0, 0, 2, 0, 1, -1, 1,  1))
    assert.equal(0, G2D12:segment_to_segment( 0, 0, 2, 0, 1,  0, 1,  1))
    assert.equal(1, G2D12:segment_to_segment( 0, 0, 2, 0, 1,  1, 1,  2))

    assert.equal(math.sqrt(2), G2D12:segment_to_segment( 0, 0, 2, 0, -1, -3, -1, -1))
    assert.equal(1, G2D12:segment_to_segment( 0, 0, 2, 0, -1, -2, -1,  0))
    assert.equal(1, G2D12:segment_to_segment( 0, 0, 2, 0, -1, -1, -1,  1))
    assert.equal(1, G2D12:segment_to_segment( 0, 0, 2, 0, -1,  0, -1,  1))
    assert.equal(math.sqrt(2), G2D12:segment_to_segment( 0, 0, 2, 0, -1,  1, -1,  2))

    assert.equal(math.sqrt(2), G2D12:segment_to_segment( 0, 0, 2, 0,  3, -3,  3, -1))
    assert.equal(1, G2D12:segment_to_segment( 0, 0, 2, 0,  3, -2,  3,  0))
    assert.equal(1, G2D12:segment_to_segment( 0, 0, 2, 0,  3, -1,  3,  1))
    assert.equal(1, G2D12:segment_to_segment( 0, 0, 2, 0,  3,  0,  3,  1))
    assert.equal(math.sqrt(2), G2D12:segment_to_segment( 0, 0, 2, 0,  3,  1,  3,  2))
  end)
end)


describe("Polylines", function()
  local G2D, G2D12

  setup(function()
    G2D = require"geometry2d"
    G2D12 = G2D:new(1, 2, 1)
  end)

  test("polyline_length", function()
    assert.equal(2, G2D12:polyline_length({{0,0}, {1,0}, {1,1}}))
  end)
end)


describe("Polygons", function()
  local G2D, G2D12
  local squares

  setup(function()
    G2D = require"geometry2d"
    G2D12 = G2D:new(1, 2, 1)
    squares =
    {
      { { -1, -1 }, { -1, 1 }, { 1, 1 }, { 1, -1 }, { -1, -1 } }
    }
  end)

  test("orientation", function()
    assert.equal("clockwise", G2D12:polygon_orientation(squares[1]))
  end)

end)