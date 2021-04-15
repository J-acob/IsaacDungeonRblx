local Cell = {}

--local cellPart = script.Cell


Cell.__Index = Cell;


function Cell.new(x, y, cellPart)
	
	local newCell = {}
	
	local self = setmetatable(newCell, Cell)
	
	self.x = x
	
	self.y = y
	
	self.NumericalValue = 0
	
	self.Occupied = false
	
	self.OccupiedInt = 0
	
	self.NeighborCount = 0
	
	self.Visited = false
		
	self.AvailDirs = {N = false, E = false, S = false, W = false}
	
	--This is critically important as it allows us to link cell to room 
	self.LinkedRoom = nil
	
	local newCellPart = cellPart:Clone()
	
	self.CellPart = newCellPart
	
	--the actual placement of the cell is relative to the actual size of the grid pieces
	--we're using, so it must be placed onto the "grid" by using it's size 

	
	newCellPart.Position = Vector3.new(
		-((self.CellPart.CFrame.X) + self.CellPart.Size.X * self.x),
		
		self.CellPart.CFrame.Y,
		
		((self.CellPart.CFrame.Z) + self.CellPart.Size.Z * self.y)
	)
	
	self.CellPart.Parent = workspace
	
	return newCell
	
end




return Cell
