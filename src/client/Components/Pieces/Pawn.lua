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

    local squares = {}

    if self.hasMoved == false then
        if (self.Color == "White") then
            if (numericNum - 2 >= 1) then
                table.insert(squares, alpha .. (numericNum - 2))
            end
        else
            if (numericNum + 2 <= 8) then
                table.insert(squares, alpha .. (numericNum + 2))
            end
        end
    end

    if self.Color == "White" then
        if numericNum - 1 >= 1 then
            table.insert(squares, alpha .. (numericNum - 1))
        end
    else
        if numericNum + 1 <= 8 then
            table.insert(squares, alpha .. (numericNum + 1))
        end
    end

    return squares
end

return Pawn