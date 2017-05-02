math.randomseed(os.time())
_W, _H = love.graphics.getWidth(), love.graphics.getHeight()

local Vector = {}
function Vector.new(x,y)
	local self = setmetatable({}, Vector)
	self.x = x
	self.y = y
	return self
end
function Vector.__add(v1,v2)
	return Vector.new(v1.x + v2.x,v1.y + v2.y)
end
function Vector.__mul(v1,c)
	return Vector.new(v1.x*c, v1.y*c)
end
Vector.zero = Vector.new(0,0)

local Circle = {}
Circle.__index = Circle

function Circle.new(color, x, y, radius)
	local self = setmetatable({}, Circle)
	self.color = color
	self.radius = radius
	self.pos = Vector.new(x,y)
	self.vel = Vector.new(0,0)
	
	return self
end

function Circle.draw(self)
	love.graphics.setColor(self.color.r, self.color.g, self.color.b, 255)
	love.graphics.circle("fill", self.pos.x, self.pos.y, self.radius)
end

function Circle.rk4(self, t, dt)
	k1 = self:evaluate(t, 0, {vel = Vector.zero, accel = Vector.zero})
	k2 = self:evaluate(t, dt*0.5, k1)
	k3 = self:evaluate(t, dt*0.5, k2)
	k4 = self:evaluate(t, dt, k3)
	
	self.pos = self.pos + (k1.vel + (k2.vel + k3.vel)*2 + k4.vel)*(dt/6)
	self.vel = self.vel + (k1.accel + (k2.accel + k3.accel)*2 + k4.accel)*(dt/6)
end

function Circle.evaluate(self, t, dt, derivative)
	local state = {}
	
	state.pos = self.pos + derivative.vel*dt
	state.vel = self.vel + derivative.accel*dt
	
	return {vel = state.vel, accel = self.accel(state, t+dt)}
end

function Circle.euler(self, t, dt)
	self.pos = self.pos + self.vel * dt
	self.vel = self.vel + self:accel(t+dt)*dt
end

function Circle.accel(self, t)
	return Vector.new(0,1000)
end

local integrator = 'rk4'

function changeIntegrator()
	if integrator == 'rk4' then
		integrator = 'euler'
	elseif integrator == 'euler' then
		integrator = 'rk4'
	end
end

local circles = {}

function love.update(dt)
	for i=1,#circles do
		circles[i][integrator](circles[i], 0, dt)
		if circles[i].pos.y+circles[i].radius > _H then
			-- Lo que se intersecta, separar a misma distancia
			-- Calcular la velocidad usando equaciones de movimiento
			-- vi² = vf² - 2xa
			local vf2 = circles[i].vel.y*circles[i].vel.y
			local x = 2*(circles[i].pos.y+circles[i].radius-_H)
			
			circles[i].vel.y = -math.sqrt(math.abs(vf2 - 2*x*circles[i].accel(0).y))
			circles[i].pos.y = 2*(_H-circles[i].radius)-circles[i].pos.y
		end
		if circles[i].pos.x+circles[i].radius > _W then
			local vf2 = circles[i].vel.x*circles[i].vel.x
			local x = 2*(circles[i].pos.x+circles[i].radius-_W)
			
			circles[i].vel.x = -math.sqrt(math.abs(vf2 - 2*x*circles[i].accel(0).x))
			circles[i].pos.x = 2*(_W-circles[i].radius)-circles[i].pos.x
		elseif circles[i].pos.x-circles[i].radius < 0 then
			local vf2 = circles[i].vel.x*circles[i].vel.x
			local x = -2*(circles[i].pos.x-circles[i].radius)
			circles[i].vel.x = math.sqrt(math.abs(vf2 + 2*x*circles[i].accel(0).x))
			circles[i].pos.x = 2*circles[i].radius - circles[i].pos.x
		end
	end
end

function love.draw()
	for i=1,#circles do
		circles[i]:draw()
	end
	
	love.graphics.setColor(255,255,255,255)
	love.graphics.print("Using integrator: "..integrator, 0, 0)
end

function randomColor()
	return {r = math.random(0,255), g = math.random(0,255), b = math.random(0,255), 255}
end

function love.mousereleased(x, y)
	table.insert(circles, Circle.new( randomColor(), x, y, math.random(5,50) ) )
end

function love.keyreleased(key)
	if key == 'space' then
		changeIntegrator()
	end
end
