local math_sqrt = math.sqrt

------------------------------------------------------------------------------

-- Simplify a polyline using what I believe is the Douglas-Peucker algorithm
-- (eg. http://www.softsurfer.com/Archive/algorithm_0205/algorithm_0205.htm)
-- Initial approximation is a straight line between the end points of the
-- polyline.  Then find the error in every intermediate point, and pick the
-- worst.  If it's worse than a tolerance, add it to the set of points, and
-- re-apply the algorithm to the two halves (start to new point, new point to
-- end).  As much as possible we work with distances squared to avoid square
-- roots.

-- Distance squared between two points
local function d2(x1, y1, x2, y2)
  local dx, dy = x1 - x2, y1 - y2
  return dx*dx + dy*dy
end

------------------------------------------------------------------------------

local function init(BASE, X, Y)
  BASE = BASE or 1
  local END = -(BASE - 1)
  X = X or 1
  Y = Y or 2


  -- Find the the intermediate point worst approximated by a straight line
  -- between j and k
  local function find_worst(points, j, k)
    if k <= j+1 then return end                       -- If there aren't any intermediate points, stop.
    
    local maxd2 = -1
    local worst_index = nil
    
    local pj, pk = points[j], points[k]
    local v0x, v0y = pk[X]-pj[X], pk[Y]-pj[Y]         -- Vector between the two points.
    local d02 = v0x*v0x + v0y*v0y                     -- Length^2 of the vector.

    for i = j+1,k-1 do
      local pi = points[i]
      local vix, viy = pi[X]-pj[X], pi[Y]-pj[Y]       -- Vector from pj to pi.
      local wi = vix*v0x + viy*v0y                    -- Component of length in direction of v0 (squared)
      local di2
      if wi <= 0 then                                 -- pi is "behind" pj - measure from pj
        di2 = d2(pi[X], pi[Y], pj[X], pj[Y])
      elseif wi >= d02 then                           -- pi is "ahead" of pk - measure from pk
        di2 = d2(pi[X], pi[Y], pk[X], pk[Y])
      else                                            -- pi is "between" pj and pk - measure perpendicular distance from nearest point on v0.
        wi = wi / d02                                 -- I used to think you had to take the square root, but no.  Work it out.
        local zx, zy = pj[X]+v0x*wi, pj[Y]+v0y*wi
        di2 = d2(pi[X], pi[Y], zx, zy)
      end
      if di2 > maxd2 then                             -- Remember the furthest.
        worst_index = i
        maxd2 = di2
      end
    end
    return worst_index, maxd2
  end


  -- Find the points that make up a simplification of tolerance tol^2.
  -- Returns (in result) a vector of booleans specifying which points
  -- are in the approximation.
  local function find_points(points, tol2, result, j, k)
    -- Find the worst point for this approximation.
    local i, d2 = find_worst(points, j, k)
    if i and d2 > tol2 then
      result[i] = true
      -- Repeat on the two halves we've created.
      find_points(points, tol2, result, j, i)
      find_points(points, tol2, result, i, k)
    end
--    result[1] = true
--    result[#points] = true
  end


  -- Calculate the error from leaving out each point
  -- Adds a value (delta) to each point, that is the error of leaving the
  -- point out.
  -- Returns the maximum error
  local function classify_points(points, j, k)
    local i, d2 = find_worst(points, j, k)
    if i then
      local d = math_sqrt(d2)
      points[i].delta = d
      -- Repeat on the two halves we've created.
      d = math_max(d,
        classify_points(points, j, i),
        classify_points(points, i, k))
      return d
    end
    return 0
  end


  local function useful_points(points, tol, n)
    n = n or #points

    local chosen = {}
    for i = BASE, n - END do
      chosen[i] = false
    end
    chosen[BASE], chosen[n - END] = true, true
    find_points(points, tol*tol, chosen, BASE, n - END)
    return chosen
  end


  local function simplify_polyline(points, tol, n)
    n = n or #points

    local chosen = useful_points(points, tol, n)

    local copy
    for i = BASE, n - END do
      if not chosen[i] then copy = true break end
    end
    
    if not copy then return points end

    local r, j = {}, BASE
    for i = BASE, n - END do
      if chosen[i] then
        r[j] = points[i]
        j = j + 1
      end
    end
    return r
  end

  return useful_points, simplify_polyline
end


------------------------------------------------------------------------------

return { init = init }

------------------------------------------------------------------------------


