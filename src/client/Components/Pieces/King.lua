local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.knit)

local TableConcat = require(ReplicatedStorage.Shared.TableConcat)

local King = {}
King.__index = King


function King.new(Board, Square, Color)
    local self = setmetatable({}, King)

    self.Square = Square
    self.hasMoved = false
    self.Name = "King"
    self.Board = Board
    self.Color = Color or "White"
    self.hasCastled = false

    return self
end

function King:GetMoveableSpaces()
    local MovementController = Knit.GetController("MovementController")

    return MovementController:GetKingSquaresFromSquare(self.Square, self.Board)
end

return King