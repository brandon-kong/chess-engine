local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.knit)

local TableConcat = require(ReplicatedStorage.Shared.TableConcat)

local Rook = {}
Rook.__index = Rook

function Rook.new(Board, Square, Color)
    local self = setmetatable({}, Rook)

    self.Square = Square
    self.hasMoved = false
    self.Name = "Rook"
    self.Color = Color or "White"
    self.Board = Board

    return self
end

function Rook:GetMoveableSpaces()
    local MovementController = Knit.GetController("MovementController")

    local alpha = string.sub(self.Square, 1, 1)
    local numeric = string.sub(self.Square, 2, 2)
    local numericNum = tonumber(numeric)

    local horizontalSquares = MovementController:GetHorizontalSquaresFromSquare(self.Square, self.Board)
    local verticalSquares = MovementController:GetVerticalSquaresFromSquare(self.Square, self.Board)

    return TableConcat(horizontalSquares, verticalSquares)
end

return Rook