local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.knit)

local Pawn = {}
Pawn.__index = Pawn

function Pawn.new(Board, Square, Color)
    local self = setmetatable({}, Pawn)

    self.Square = Square
    self.hasMoved = false
    self.Name = "Pawn"
    self.Board = Board
    self.Color = Color or "White"

    return self
end

function Pawn:GetMoveableSpaces()
    local alpha = string.sub(self.Square, 1, 1)
    local numeric = string.sub(self.Square, 2, 2)
    local numericNum = tonumber(numeric)

    local MovementController = Knit.GetController("MovementController")

    local squares = {}

    local alphaTable = MovementController:GetAlpha()
    local alphaIndex = table.find(alphaTable, alpha)

    if (self.Color == "White") then
        if (numericNum - 1 >= 1) then
            local leftSquare = alphaTable[alphaIndex - 1]
            local rightSquare = alphaTable[alphaIndex + 1]
            if (leftSquare) then
                if (self.Board:PieceOn(leftSquare .. (numericNum - 1)) ~= nil) then
                    table.insert(squares, leftSquare .. (numericNum - 1))
                end
            end
            if (rightSquare) then
                if (self.Board:PieceOn(rightSquare .. (numericNum - 1)) ~= nil) then
                    table.insert(squares, rightSquare .. (numericNum - 1))
                end
            end
        end
    else
        if (numericNum + 1 <= 8) then
            local leftSquare = alphaTable[alphaIndex - 1]
            local rightSquare = alphaTable[alphaIndex + 1]
            if (leftSquare) then
                if (self.Board:PieceOn(leftSquare .. (numericNum + 1)) ~= nil) then
                    table.insert(squares, rightSquare .. (numericNum + 1))
                end
            end
            if (rightSquare) then
                if (self.Board:PieceOn(rightSquare .. (numericNum + 1)) ~= nil) then
                    table.insert(squares, rightSquare .. (numericNum + 1))
                end
            end
        end
    end

    if self.Color == "White" then
        if numericNum - 1 >= 1 then
            if (self.Board:PieceOn(alpha .. (numericNum - 1)) == nil) then
                table.insert(squares, alpha .. (numericNum - 1))
            else
                return squares
            end
        end
    else
        if numericNum + 1 <= 8 then
            if (self.Board:PieceOn(alpha .. (numericNum + 1)) == nil) then
                table.insert(squares, alpha .. (numericNum + 1))
            else
                return squares
            end
        end
    end

    if self.hasMoved == false then
        if (self.Color == "White") then
            if (numericNum - 2 >= 1) then   
                if (self.Board:PieceOn(alpha .. (numericNum - 2)) == nil) then
                    table.insert(squares, alpha .. (numericNum - 2))
                end
            end
        else
            if (numericNum + 2 <= 8) then
                if (self.Board:PieceOn(alpha .. (numericNum + 2)) == nil) then
                    table.insert(squares, alpha .. (numericNum + 2))
                end
            end
        end
    end

    return squares
end

function Pawn:CanTake(Square)
    local MovementController = Knit.GetController("MovementController")

    local thisAlpha = string.sub(self.Square, 1, 1)
    local thisNumeric = string.sub(self.Square, 2, 2)
    local thisNumericNum = tonumber(thisNumeric)

    local alphaTable = MovementController:GetAlpha()
    local alphaIndex = table.find(alphaTable, thisAlpha)
    local pieceOn = self.Board:PieceOn(Square)

    if pieceOn == nil then
        return false
    end

    if pieceOn.Color == self.Color then
        return false
    end

    if (self.Color == "White") then
        if (thisNumeric - 1 >= 1) then
            local leftSquare = alphaTable[alphaIndex - 1]
            local rightSquare = alphaTable[alphaIndex + 1]
            if (leftSquare and Square == leftSquare .. (thisNumericNum - 1)) then
                return true
            end
            if (rightSquare and Square == rightSquare .. (thisNumericNum - 1)) then
                return true
            end
        end
    else
        if (thisNumeric + 1 <= 8) then
            local leftSquare = alphaTable[alphaIndex - 1]
            local rightSquare = alphaTable[alphaIndex + 1]
            if (leftSquare and Square == leftSquare .. (thisNumericNum + 1)) then
                return true
            end
            if (rightSquare and Square == rightSquare .. (thisNumericNum + 1)) then
                return true
            end
        end
    end

    return false
end

return Pawn