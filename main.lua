particles = {}
canvas_size = { x = 600, y = 400 }
camera_pos = { x = 0, y = 0 }
camera_scale = 1
target_camera_pos = camera_pos
target_camera_scale = camera_scale
em_force_constant = 1000
gravity_force_constant = 1000
speed_decay = 0.03
time = 0

love.graphics.DrawMode = { fill = "fill", line = "line" }

do
  next_particle_id = 1
  function new_particle(arg)
    id = next_particle_id
    next_particle_id = next_particle_id + 1
    return {
      id = id,
      mass = arg.mass or 1,
      charge = arg.charge or 0,
      pos = arg.pos or { x = 0, y = 0 },
      v = arg.v or { x = 0, y = 0 },
      f = arg.f or { x = 0, y = 0 },
      radius = arg.radius or 5,
      trail = {},
      trail_length = arg.trail_length or 20,
      trail_index = 0,
      trail_radius = 1,
      trail_interval = 0.1,
      trail_timer = 0,
    }
  end
end

function update_trail(particle, dt)
  particle.trail_timer = particle.trail_timer + dt

  if particle.trail_timer > particle.trail_interval then
    particle.trail_timer = particle.trail_timer - particle.trail_interval
    particle.trail[particle.trail_index] = particle.pos
    particle.trail_index = (particle.trail_index + 1) % particle.trail_length
  end
end

function charge_color(particle)
  return {
    math.max(0, particle.charge),
    math.max(0, -particle.charge),
    (1 - math.abs(particle.charge)),
  }
end

function love.load()
  math.randomseed(os.time())
  for i = 1,10 do
    table.insert(
      particles,
      new_particle{
        charge = math.random(-1, 1),
        pos = {
          x = 0.6 * math.random(-canvas_size.x, canvas_size.x),
          y = 0.6 * math.random(-canvas_size.y, canvas_size.y),
        },
      }
    )
  end

  love.window.setMode(canvas_size.x, canvas_size.y)
end

function vadd(v1, v2)
  return {
    x = v1.x + v2.x,
    y = v1.y + v2.y,
  }
end

function vsub(v1, v2)
  return {
    x = v1.x - v2.x,
    y = v1.y - v2.y,
  }
end

function vneg(v)
  return {
    x = -v.x,
    y = -v.y,
  }
end

function vmul(scalar, vector)
  return {
    x = scalar * vector.x,
    y = scalar * vector.y,
  }
end

function vlerp(from, to, scale)
  return vadd(from, vmul(scale, vsub(to, from)))
end

function lerp(from, to, scale)
  return from + (to - from) * scale
end

function norm(v)
  return math.sqrt(v.x^2 + v.y^2)
end

function distance(p1, p2)
  return norm(vsub(p1, p2))
end

-- Force exerted on particle1 by particle2
function em_force(particle1, particle2)
  return vmul(
    particle1.charge * particle2.charge * em_force_constant / distance(particle1.pos, particle2.pos)^2,
    vsub(particle1.pos, particle2.pos)
  )
end

-- Force exerted on particle1 by particle2
function gravity_force(particle1, particle2)
  return vmul(
    particle1.mass * particle2.mass * gravity_force_constant / distance(particle1.pos, particle2.pos)^2,
    vsub(particle2.pos, particle1.pos)
  )
end

function love.update(dt)
  time = time + dt

  local minx, maxx, miny, maxy = math.huge, -math.huge, math.huge, -math.huge
  for _, particle in pairs(particles) do
    minx = math.min(minx, particle.pos.x)
    maxx = math.max(maxx, particle.pos.x)
    miny = math.min(miny, particle.pos.y)
    maxy = math.max(maxy, particle.pos.y)
  end
  local center = { x = (maxx + minx) / 2, y = (maxy + miny) / 2 }

  local maxx, maxy = 0, 0
  for _, particle in pairs(particles) do
    maxx = math.max(maxx, math.abs(particle.pos.x - center.x))
    maxy = math.max(maxy, math.abs(particle.pos.y - center.y))
  end

  local maxx_ratio = maxx / (canvas_size.x / 2)
  local maxy_ratio = maxy / (canvas_size.y / 2)
  local max_ratio = math.max(maxx_ratio, maxy_ratio)

  target_camera_pos = center
  target_camera_scale = 1 / (max_ratio / 0.7)

  camera_pos = vlerp(camera_pos, target_camera_pos, 0.5 * dt)
  camera_scale = lerp(camera_scale, target_camera_scale, 0.5 * dt)

  for _, particle in pairs(particles) do
    update_trail(particle, dt)
  end

  for _, particle1 in pairs(particles) do
    particle1.f = {x=0, y=0}
    for _, particle2 in pairs(particles) do
      if particle1.id ~= particle2.id then 
        particle1.f = vadd(particle1.f, em_force(particle1, particle2))
        particle1.f = vadd(particle1.f, gravity_force(particle1, particle2))
      end
    end
  end

  for _, particle in pairs(particles) do
    particle.v = vmul(1 - speed_decay * dt, particle.v)
  end

  for _, particle in pairs(particles) do
    particle.v = vadd(particle.v, vmul(dt / particle.mass, particle.f))
    particle.pos = vadd(particle.pos, vmul(dt, particle.v))
  end
end

function world_to_view_pos(pos, camera_pos, camera_scale, canvas_size)
  return vadd(vmul(camera_scale, vsub(pos, camera_pos)), vmul(0.5, canvas_size))
end

function love.draw()

  local rect_topleft = world_to_view_pos({ x = -canvas_size.x / 2, y = -canvas_size.y / 2 }, camera_pos, camera_scale, canvas_size)
  local rect_btmright = world_to_view_pos({ x = canvas_size.x / 2, y = canvas_size.y / 2 }, camera_pos, camera_scale, canvas_size)
  love.graphics.setColor(1, 1, 1, 0.5)
  love.graphics.rectangle(love.graphics.DrawMode.line, rect_topleft.x, rect_topleft.y, rect_btmright.x - rect_topleft.x, rect_btmright.y - rect_topleft.y)
  love.graphics.line(canvas_size.x / 2 - 10, canvas_size.y / 2, canvas_size.x / 2 + 10, canvas_size.y / 2)
  love.graphics.line(canvas_size.x / 2, canvas_size.y / 2 - 10, canvas_size.x / 2, canvas_size.y / 2 + 10)

  local rect_topleft = world_to_view_pos(vsub(target_camera_pos, vmul(0.5, canvas_size)), camera_pos, camera_scale / target_camera_scale, canvas_size)
  local rect_btmright = world_to_view_pos(vadd(target_camera_pos, vmul(0.5, canvas_size)), camera_pos, camera_scale / target_camera_scale, canvas_size)
  love.graphics.setColor(1, 0, 0, 0.5)
  love.graphics.rectangle(love.graphics.DrawMode.line, rect_topleft.x, rect_topleft.y, rect_btmright.x - rect_topleft.x, rect_btmright.y - rect_topleft.y)
  local rect_center = world_to_view_pos(target_camera_pos, camera_pos, camera_scale, canvas_size)
  love.graphics.line(rect_center.x - 10, rect_center.y, rect_center.x + 10, rect_center.y)
  love.graphics.line(rect_center.x, rect_center.y - 10, rect_center.x, rect_center.y + 10)

  for _, particle in pairs(particles) do
    local pos_in_view = world_to_view_pos(particle.pos, camera_pos, camera_scale, canvas_size)
    love.graphics.setColor(charge_color(particle))
    love.graphics.circle(love.graphics.DrawMode.fill, pos_in_view.x, pos_in_view.y, particle.radius * camera_scale)

    for _, trail_pos in pairs(particle.trail) do
      local pos_in_view = world_to_view_pos(trail_pos, camera_pos, camera_scale, canvas_size)
      love.graphics.circle(love.graphics.DrawMode.fill, pos_in_view.x, pos_in_view.y, particle.trail_radius * camera_scale)
    end
  end
end
