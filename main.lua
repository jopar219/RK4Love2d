math.randomseed(os.time())

local Circle = {}
Circle.__index = Circle

function Circle.new(color, x, y, radius)
	local self = setmetatable({}, Circle)
	self.color = color
	self.radius = radius
	self.x = x
	self.y = y
	
	return self
end

function Circle.draw(self)
	love.graphics.setColor(self.color.r, self.color.g, self.color.b, 255)
	love.graphics.circle("fill", self.x, self.y, self.radius)
end


local circles = {}

function love.draw()
	for i=1,#circles do
		circles[i]:draw()
	end
end

function randomColor()
	return {r = math.random(0,255), g = math.random(0,255), b = math.random(0,255), 255}
end

function love.mousereleased(x, y)
	table.insert(circles, Circle.new( randomColor(), x, y, math.random(5,50) ) )
end
