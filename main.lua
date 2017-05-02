math.randomseed(os.time())
_W, _H = love.graphics.getWidth(), love.graphics.getHeight()

local Circle = {}
Circle.__index = Circle

function Circle.new(color, x, y, radius)
	local self = setmetatable({}, Circle)
	self.color = color
	self.radius = radius
	self.x = x
	
	self.y = y
	self.vy = 0
	
	return self
end

function Circle.draw(self)
	love.graphics.setColor(self.color.r, self.color.g, self.color.b, 255)
	love.graphics.circle("fill", self.x, self.y, self.radius)
end

function Circle.rk4(self, t, dt)
	k1y = self:evaluate(t, 0, {dy = 0, dvy = 0})
	k2y = self:evaluate(t, dt*0.5, k1y)
	k3y = self:evaluate(t, dt*0.5, k2y)
	k4y = self:evaluate(t, dt, k3y)
	
	self.y = self.y + dt/6*(k1y.dy + 2 * (k2y.dy + k3y.dy) + k4y.dy)
	self.vy = self.vy + dt/6*(k1y.dvy + 2 * (k2y.dvy + k3y.dvy) + k4y.dvy)
end

function Circle.evaluate(self, t, dt, derivative)
	--self.speedX = self.speedX + self.accelX*dt
	--self.pos = self.pos + self.speed*dt
	local state = {}
	
	state.y = self.y + derivative.dy*dt
	state.vy = self.vy + derivative.dvy*dt
	
	return {dy = state.vy, dvy = self.ay(state, t+dt)}
end

function Circle.euler(self, t, dt)
	
	self.y = self.y + self.vy * dt
	self.vy = self.vy + self:ay(t+dt)*dt
end

function Circle.ay(self, t)
	return 500
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
		if circles[i].y+circles[i].radius > _H then
			-- Lo que se intersecta, separar a misma distancia
			-- Calcular la velocidad usando equaciones de movimiento
			-- vi² = vf² - 2xa
			circles[i].vy = -math.sqrt(math.abs(circles[i].vy*circles[i].vy-2*2*(circles[i].y+circles[i].radius-_H)*circles[i].ay(0)))
			circles[i].y = 2*(_H-circles[i].radius)-circles[i].y
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
