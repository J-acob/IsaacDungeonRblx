local Queue = {}

Queue.__index  = Queue


function Queue.new()

	local self = setmetatable({}, Queue)
	
	return self
	
end

function Queue:push(value)
	
	table.insert(self, value)
	
end


function Queue:pop()
	
	local value = table.remove(self, 1)
	
	return value
end


function Queue:shift()
	
	
	return self:pop()
		
end

function Queue:length()
	

	return(table.getn(self))
	
	
end

function Queue:poprandom()
	
	local index = math.random(1, #self)
	
	print("Popping at random index:... ", index)
	
	local randomvalue = table.remove(self, index)
	
	return randomvalue
	
end

function Queue:clear()
	
	table.clear(self)
	
end

return Queue
