particles = {}
canvas_size = { x = 600, y = 400 }
camera_pos = { x = 0, y = 0 }
em_force_constant = 1000
gravity_force_constant = 100
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
      radius = arg.radius or 5
    }
  end
end

function charge_color(particle)
  return {
    math.max(0, particle.charge * 255),
    math.max(0, -particle.charge * 255),
    (1 - math.abs(particle.charge)) * 255,
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
          x = 0.3 * math.random(-canvas_size.x, canvas_size.x),
          y = 0.3 * math.random(-canvas_size.y, canvas_size.y),
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
    particle.v = vadd(particle.v, vmul(dt / particle.mass, particle.f))
    particle.pos = vadd(particle.pos, vmul(dt, particle.v))

    view_pos = world_to_view_pos(particle.pos, camera_pos, canvas_size)
    if view_pos.x > canvas_size.x then
      particle.pos = vsub(particle.pos, { x = canvas_size.x, y = 0 })
    end
    if view_pos.x < 0 then
      particle.pos = vadd(particle.pos, { x = canvas_size.x, y = 0 })
    end
    if view_pos.y > canvas_size.y then
      particle.pos = vsub(particle.pos, { x = 0, y = canvas_size.y })
    end
    if view_pos.y < 0 then
      particle.pos = vadd(particle.pos, { x = 0, y = canvas_size.y })
    end
  end
end

function world_to_view_pos(pos, camera_pos, canvas_size)
  return vadd(vsub(pos, camera_pos), vmul(0.5, canvas_size))
end

function love.draw()
  for _, particle in pairs(particles) do
    local pos_in_view = world_to_view_pos(particle.pos, camera_pos, canvas_size)
    love.graphics.setColor(charge_color(particle))
    love.graphics.circle(love.graphics.DrawMode.fill, pos_in_view.x, pos_in_view.y, particle.radius)
  end
end
