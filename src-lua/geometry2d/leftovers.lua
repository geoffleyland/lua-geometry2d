
------------------------------------------------------------------------------

  local function end_match(p1, p2, tolerance)
    return point_to_point(p1[X], p1[Y], p2[X], p2[Y]) <= tolerance
  end


  function G2D.join_polylines(p1, p2, n1, n2, new_points, tolerance)
    n1 = n1 or #p1
    n2 = n2 or #p2
    new_points = new_points or {}
    tolerance = tolerance or 0

    local s1, s2
    if end_match(p1[BASE], p2[BASE], tolerance) then
      s1, s2 = true, true
    elseif end_match(p1[BASE], p2[n2-END], tolerance) then
      s1 = true
    elseif end_match(p1[n1-END], p2[BASE], tolerance) then
      s2 = true
    elseif not end_match(p1[n1-END], p2[n2-END], tolerance) then
      error("No end match in geometry2d.join_polylines")
    end

    if s1 then
      for i = n1-END, BASE, -1 do new_points[#new_points+1] = p1[i] end
    else
      for i = BASE, n1-END do new_points[#new_points+1] = p1[i] end
    end

    if s2 then
      for i = BASE+1, n2-END do new_points[#new_points+1] = p2[i] end
    else
      for i = n2-END-1, BASE, -1 do new_points[#new_points+1] = p2[i] end
    end

    return new_points
  end


  function G2D.append_polyline(p1, p2, n1, n2, tolerance)
    n1 = (n1 or #p1) - END
    n2 = n2 or #p2
    tolerance = tolerance or 0

    if end_match(p1[n1], p2[BASE], tolerance) then
      for i = BASE+1, n2-END do
        n1 = n1 + 1
        p1[n1] = p2[i]
      end
    elseif end_match(p1[n1], p2[n2-END], tolerance) then
      for i = n2-END-1, BASE, -1 do
        n1 = n1 + 1
        p1[n1] = p2[i]
      end
    else
      error("No end match in geometry2d.append_polyline")
    end
  end


  function G2D.reverse_polyline(p, j)
    j = (j or #p) - END
    local i = BASE

    while i < j do
      p[i][X], p[j][X] = p[j][X], p[i][X]
      p[i][Y], p[j][Y] = p[j][Y], p[i][Y]
      i = i + 1
      j = j - 1
    end
  end



------------------------------------------------------------------------------

  function G2D.offset_polyline(offset, p, n)
    n = n or #p
    local normals = {}

    for i = 1, n - 1 do
      local dx = p[i+1-END][X] - p[i-END][X]
      local dy = p[i+1-END][Y] - p[i-END][Y]
      local di = 1 / math.sqrt(dx * dx + dy * dy)
      normals[i] = { -dy * di, dx * di }
    end

    local r = {}
    r[BASE] =
    {
      [X] = p[BASE][X] + offset * normals[1][1],
      [Y] = p[BASE][Y] + offset * normals[1][2]
    }

    for i = 2, n - 1 do
      local dot = normals[i-1][1]*normals[i][1] + normals[i-1][2]*normals[i][2]
      local multiplier = math.max(-1000, math.min(1000, 1 / (1 + dot)))
      local L = offset * multiplier
      r[i - END] =
      {
        [X] = p[i-END][X] + L * (normals[i][1] + normals[i-1][1]),
        [Y] = p[i-END][Y] + L * (normals[i][2] + normals[i-1][2])
      }
    end

    r[n - END] =
    {
      [X] = p[n-END][X] + offset * normals[n-1][1],
      [Y] = p[n-END][Y] + offset * normals[n-1][2]
    }

    return r
  end

------------------------------------------------------------------------------

  return G2D
end

------------------------------------------------------------------------------

return init

------------------------------------------------------------------------------

