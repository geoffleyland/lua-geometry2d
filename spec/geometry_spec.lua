-- luacheck: std max+busted

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
    assert.equal(math.sqrt(8), G2D12:polyline_length({{0,0}, {1,1}, {2,0}}))
  end)

  test("polyline_length_to", function()
    assert.equal(2,   G2D12:polyline_length_to({{0,0}, {1,0}, {1,1}}, 3, 0))
    assert.equal(1,   G2D12:polyline_length_to({{0,0}, {1,0}, {1,1}}, 2, 0))
    assert.equal(1.5, G2D12:polyline_length_to({{0,0}, {1,0}, {1,1}}, 2, 0.5))
  end)

  test("point_to_polyline", function()
    assert.equal(math.sqrt(0.5), G2D12:point_to_polyline(0, 0, {{0,1},{1,0}}))
    assert.equal(1, G2D12:point_to_polyline(0, 0, {{2,0},{2,1},{-2,1}}))
  end)

  test("polyline_to_polyline", function()
    assert.equal(1, G2D12:polyline_to_polyline({{0,0},{1,0},{2,0},{3,0}}, {{0,1},{1,1},{3,1}}))
    assert.equal(1, G2D12:polyline_to_polyline({{0,0},{1,0},{2,1},{3,0}}, {{0,3},{1,2},{3,2}}))
    assert.equal(0, G2D12:polyline_to_polyline({{0,0},{1,1},{5,5}}, {{0,5},{1,4},{5,0}}))
  end)

  test("reverse_points", function()
    assert.are_same({{1,0},{0,0}}, G2D12:reverse_points({{0,0},{1,0}}))
    assert.are_same({{2,0},{1,0},{0,0}}, G2D12:reverse_points({{0,0},{1,0},{2,0}}))
  end)

  test("reverse_coordinates", function()
    assert.are_same({{1,0},{0,0}}, G2D12:reverse_coordinates({{0,0},{1,0}}))
    assert.are_same({{2,0},{1,0},{0,0}}, G2D12:reverse_coordinates({{0,0},{1,0},{2,0}}))
  end)
end)


describe("Polygons", function()
  local G2D, G2D12
  local squares

  setup(function()
    G2D = require"geometry2d"
    G2D12 = G2D:new(1, 2, 1)
    local square_data = {{ -1, -1 }, { -1, 1 }, { 1, 1 }, { 1, -1 }}
    squares = {}
    for i = 1, 4 do
      squares[i] = {}
      for j = 1, 5 do
        squares[i][j] = square_data[(i + j - 2) % 4 + 1]
      end
    end
    for i = 5, 8 do
      squares[i] = {}
      for j = 1, 5 do
        squares[i][j] = square_data[-(i + j - 2) % 4 + 1]
      end
    end
  end)

  test("inside_polygon", function()
    for _, p in ipairs{{0,0},{0.9,0.9}} do
      for i = 1, 8 do
        assert(G2D12:inside_polygon(p[1], p[2], squares[i]))
      end
    end

    for _, p in ipairs{{2,2},{0,1.1},{1.1,1.1}} do
      for i = 1, 8 do
        assert(not G2D12:inside_polygon(p[1], p[2], squares[i]))
      end
    end
  end)

  test("polygon_orientation", function()
    assert.equal("degenerate", G2D12:polygon_orientation({{0,0},{0,1},{0,0}}))
    for i = 1, 4 do
      assert.equal("clockwise", G2D12:polygon_orientation(squares[i]))
    end
    for i = 5, 8 do
      assert.equal("counterclockwise", G2D12:polygon_orientation(squares[i]))
    end
  end)

  test("polygon_centroid", function()
    for i = 1, 8 do
      assert.are.same({0,0}, { G2D12:polygon_centroid(squares[i]) })
    end
  end)

  test("polygon_area", function()
    assert.equal(0, G2D12:polygon_area({{0,0},{0,1},{0,0}}))
    for i = 1, 4 do
      assert.equal(4, G2D12:polygon_area(squares[i]))
    end
    for i = 5, 8 do
      assert.equal(-4, G2D12:polygon_area(squares[i]))
    end
  end)


end)