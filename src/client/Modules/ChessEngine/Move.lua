local Move = {}
Move.__index = Move

local files = { 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H' }
local ranks = {'8', '7', '6', '5', '4', '3', '2', '1'}

function Move.new(startSquare, endSquare, board)
    local self = setmetatable({}, Move)

    self.startSquare = startSquare
    self.endSquare = endSquare

    self.startRow = startSquare[1]
    self.startCol = startSquare[2]

    self.endRow = endSquare[1]
    self.endCol = endSquare[2]

    self.pieceMoved = board[self.startRow][self.startCol]
    self.pieceCaptured = board[self.endRow][self.endCol]

    self.id = self.startRow * 1000 + self.startCol * 100 + self.endRow * 10 + self.endCol

    return self
end

function Move:GetNotation()
    return self:GetRankFileNotation(self.startRow, self.startCol) .. ' -> ' .. self:GetRankFileNotation(self.endRow, self.endCol)
end

function Move:GetRankFileNotation(row, col)
    return files[col] .. ranks[row]
end

function Move:__tostring()
    return self:GetNotation()
end

function Move:__equals(other)
    return (self.startRow == other.startRow and self.startCol == other.startCol and self.endRow == other.endRow and self.endCol == other.endCol)
end

return Move