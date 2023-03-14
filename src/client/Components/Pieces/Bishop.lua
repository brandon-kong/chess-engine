local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.knit)

local Bishop = {}
Bishop.__index = Bishop

function Bishop.new(Board, Square, Color)
    local self = setmetatable({}, Bishop)

    self.Square = Square
    self.hasMoved = false
    self.Name = "Bishop"
    self.Board = Board
    self.Color = Color or "White"

    return self
end

function Bishop:GetMoveableSpaces()
    local MovementController = Knit.GetController("MovementController")

    local alpha = string.sub(self.Square, 1, 1)
    local numeric = string.sub(self.Square, 2, 2)
    local numericNum = tonumber(numeric)

    return MovementController:GetDiagonalSquaresFromSquare(self.Square, self.Board)
end


return Bishop