local Grid = {}

Grid.__index = Grid;

local Cell = require(script.Cell)

Grid.new = function(sizeX, sizeY, cellPart)
	
	if(sizeX < 1 or sizeY < 1) then

		return
	end
	

	local newGrid = {}
	
	local self = setmetatable(newGrid, Grid)
	
	self.Map = {}
	
	self.NumericalMap = {}
	
	local xCoord = Instance.new("IntValue")
	local yCoord = Instance.new("IntValue")
	
	
	local gridInfo = {x = sizeX, y = sizeY}
	
	local i = 1
	
	for X = 1, sizeX do
		
		self.Map[X] = {}
		
		
		for Y = 1, sizeY do
			
			self.Map[X][Y] = Cell.new(X,Y, cellPart)			

			self.Map[X][Y].CellPart.Name = i
			
			local xCoordClone = xCoord:Clone()
			local yCoordClone = yCoord:Clone()
			
			xCoordClone.Parent = self.Map[X][Y].CellPart
			yCoordClone.Parent = self.Map[X][Y].CellPart
			
			xCoordClone.Name = X
			yCoordClone.Name = Y
			
			self.Map[X][Y].NumericalValue = self.Map[X][Y].NumericalValue + i
			
			self.Map[X][Y].NumericalValue = i
			
			self.NumericalMap[self.Map[X][Y].NumericalValue] = self.Map[X][Y]
			
			i = i + 1

			
		end
		
	end
	
	
	self.gridSizeX = sizeX
	
	self.gridSizeY = sizeY
		
	return newGrid
	
end


--Returns the number of neighbors a given cell has

function Grid:NeighborCount(cell)
	
	local neighborCount = 0;

	local neighborNorth = self.NumericalMap[cell.NumericalValue + -(self.gridSizeY)]

	local neighborEast = self.NumericalMap[cell.NumericalValue + 1]

	local neighborSouth = self.NumericalMap[cell.NumericalValue + self.gridSizeY]

	local neighborWest = self.NumericalMap[cell.NumericalValue + -1]

	neighborCount = neighborNorth.OccupiedInt + neighborEast.OccupiedInt + neighborSouth.OccupiedInt + neighborWest.OccupiedInt

	return neighborCount
	

end



return Grid 
