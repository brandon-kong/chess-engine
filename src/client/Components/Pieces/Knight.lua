local Knight = {}
Knight.__index = Knight

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.knit)

function Knight.new(Board, Square, Color)
    local self = setmetatable({}, Knight)

    self.Square = Square
    self.hasMoved = false
    self.Name = "Knight"
    self.Color = Color or "White"

    return self
end

function Knight:GetMoveableSpaces()
    local MovementController = Knit.GetController("MovementController")

    local alpha = string.sub(self.Square, 1, 1)
    local numeric = string.sub(self.Square, 2, 2)
    local numericNum = tonumber(numeric)

    return MovementController:GetHorseSquaresFromSquare(self.Square)
end

return Knight