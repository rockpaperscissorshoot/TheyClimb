-- MADE BY SHAGGYFOX

local bit = require("bit")
local lshift = bit.lshift
local band = bit.band
local bxor = bit.bxor

local module = {
  seed = math.random(0, 100000)
}

local function int_noise(x)
  x = bxor( lshift(x,13), x);
  return ( 1.0 - band( (x * (x * x * 15731 + 789221) + 1376312589), 0x7fffffff) / 1073741824.0);
end

local function normalize_vector(in_vec)
  local d = math.sqrt(math.pow(in_vec.x, 2) + math.pow(in_vec.y, 2))
  in_vec.x = in_vec.x / d
  in_vec.y = in_vec.y / d
  return in_vec
end

local function get_rnd_vec(in_x, in_y)
  local x = int_noise(module.seed + in_y * 1000 + in_x)
  local y = int_noise(module.seed * 2 + in_y * 1000 + in_x)
  return normalize_vector({x = x, y = y})
end

local function dot(vec_a, vec_b)
  return vec_a.x * vec_b.x + vec_a.y * vec_b.y
end

local function lerp(v0, v1, t)
  return (1.0 - t) * v0 + t * v1
end

local function fade(t)
  return t * t * t * ( t * ( t * 6 - 15) + 10)
end

local function perlin2d(x, y)
  local x_f = math.floor(x)
  local x_c = math.ceil(x)
  local y_f = math.floor(y)
  local y_c = math.ceil(y)

  local vec_a = get_rnd_vec(x_f, y_f)
  local vec_b = get_rnd_vec(x_c, y_f)
  local vec_c = get_rnd_vec(x_c, y_c)
  local vec_d = get_rnd_vec(x_f, y_c)

  local pos_a = {x = x - x_f,       y = y - y_f}
  local pos_b = {x = (x - x_f) - 1, y = y - y_f}
  local pos_c = {x = (x - x_f) - 1, y = (y - y_f) - 1}
  local pos_d = {x = x - x_f,       y = (y - y_f) - 1}

  local dot_a = dot(vec_a, pos_a)
  local dot_b = dot(vec_b, pos_b)
  local dot_c = dot(vec_c, pos_c)
  local dot_d = dot(vec_d, pos_d)

  local horizontal_t = fade(x - x_f)
  local vertical_t = fade(y - y_f)

  local dot_ab = lerp(dot_a, dot_b, horizontal_t)
  local dot_dc = lerp(dot_d, dot_c, horizontal_t)

  return lerp(dot_ab, dot_dc, vertical_t)
end

module.perlin2d = perlin2d

return module