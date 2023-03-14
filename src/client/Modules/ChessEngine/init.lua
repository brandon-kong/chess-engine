local Move = require(script.Move)

--[[
    Stores the chess engine and provides a wrapper for it while storing information/state within the game's environment. 
    Determines valid moves at the current state of the game
    Keeps track of move log (undo, redo, etc.)
]]

local ChessEngine = {}
ChessEngine.__index = ChessEngine

function ChessEngine.new()
    local self = {}
    --[[
        8x8 2D array of strings representing the board
        Each string is a piece name, or a blank space
        first index of string represents piece color
        second index of string represents piece type
        '--' represents a blank space
    ]]
    self.board = {
        {'bR', 'bN', 'bB', 'bQ', 'bK', 'bB', 'bN', 'bR'},
        {'bP', 'bP', 'bP', 'bP', 'bP', 'bP', 'bP', 'bP'},
        {'--', '--', '--', '--', '--', '--', '--', '--'},
        {'--', '--', '--', '--', '--', '--', '--', '--'},
        {'--', '--', '--', '--', '--', '--', '--', '--'},
        {'--', '--', '--', '--', '--', '--', '--', '--'},
        {'wP', 'wP', 'wP', 'wP', 'wP', 'wP', 'wP', 'wP'},
        {'wR', 'wN', 'wB', 'wQ', 'wK', 'wB', 'wN', 'wR'}
    }

    --[[
        keep track of pawn moves to determine double move forward
        keep track of rook movements and king movements to determine castling
    ]]
    self.moveLog = {}
    
    self.whitesTurn = true

    return setmetatable(self, ChessEngine)
end

function ChessEngine:isWhitesTurn()
    return self.whitesTurn
end

function ChessEngine:MakeMove(moveObj)
    self.board[moveObj.startRow][moveObj.startCol] = '--'
    self.board[moveObj.endRow][moveObj.endCol] = moveObj.pieceMoved
    print(moveObj)
    self.whitesTurn = not self.whitesTurn -- switch turns
    table.insert(self.moveLog, moveObj)
end

function ChessEngine:UndoMove()
    --[[
        if there are no moves to undo, return

        get the last move from the move log
    ]]

    if (#self.moveLog == 0) then
        return
    end

    local lastMove = self.moveLog[#self.moveLog]
    self.board[lastMove.startRow][lastMove.startCol] = lastMove.pieceMoved
    self.board[lastMove.endRow][lastMove.endCol] = lastMove.pieceCaptured

    self.whitesTurn = not self.whitesTurn -- switch turns
    table.remove(self.moveLog, #self.moveLog)
end

function ChessEngine:GetValidMoves()
    return self:GetPossibleMoves()
end

function ChessEngine:GetPossibleMoves()
    local possibleMoves = {}

    for row = 1, #self.board do
        for col = 1, #self.board[row] do
            local piece = self.board[row][col]
            if (piece ~= '--') then
                local pieceColor = piece:sub(1, 1)
                if (pieceColor == 'w' and self.whitesTurn) or (pieceColor == 'b' and not self.whitesTurn) then
                    local pieceType = piece:sub(2, 2)
                    self:GetMoveFunction(pieceType)(self, row, col, possibleMoves)
                end
            end
        end
    end
    return possibleMoves
end

function ChessEngine:GetMoveFunction(piece)
    self.moveFunctions = {
        ['P'] = self.GetPawnMoves,
        ['R'] = self.GetRookMoves,
        ['N'] = self.GetKnightMoves,
        ['B'] = self.GetBishopMoves,
        ['Q'] = self.GetQueenMoves,
        ['K'] = self.GetKingMoves
    }

    return self.moveFunctions[piece]
end

function ChessEngine:GetPawnMoves(row, col, moves)
    if (self.whitesTurn) then
        if (self.board[row-1]) then
            if (self.board[row - 1][col] == '--') then
                table.insert(moves, Move.new({row, col}, {row - 1, col}, self.board))
                if (row == 7 and self.board[row - 2][col] == '--') then
                    table.insert(moves, Move.new({row, col}, {row - 2, col}, self.board))
                end
            end
            if (col-1 >= 1 and self.board[row - 1][col - 1]:sub(1, 1) == 'b') then
                table.insert(moves, Move.new({row, col}, {row - 1, col - 1}, self.board))
            end
            if (col+1 <= 8 and self.board[row - 1][col + 1]:sub(1, 1) == 'b') then
                table.insert(moves, Move.new({row, col}, {row - 1, col + 1}, self.board))
            end
        end
    else
        if (self.board[row+1]) then
            if (self.board[row + 1][col] == '--') then
                table.insert(moves, Move.new({row, col}, {row + 1, col}, self.board))
                if (row == 2 and self.board[row + 2][col] == '--') then
                    table.insert(moves, Move.new({row, col}, {row + 2, col}, self.board))
                end
            end
            if (col-1 >= 1 and self.board[row + 1][col - 1]:sub(1, 1) == 'w') then
                table.insert(moves, Move.new({row, col}, {row + 1, col - 1}, self.board))
            end
            if (col+1 <= 8 and self.board[row + 1][col + 1]:sub(1, 1) == 'w') then
                table.insert(moves, Move.new({row, col}, {row + 1, col + 1}, self.board))
            end
        end
    end
end

function ChessEngine:GetKnightMoves(row, col, moves)
    local knightMoves = {
        {-2, -1}, {-2, 1}, {-1, -2}, {-1, 2}, {1, -2}, {1, 2}, {2, -1}, {2, 1}
    }

    for _, move in ipairs(knightMoves) do
        local newRow = row + move[1]
        local newCol = col + move[2]
        if (newRow >= 1 and newRow <= 8 and newCol >= 1 and newCol <= 8) then
            if (self.board[newRow][newCol]:sub(1, 1) ~= self.board[row][col]:sub(1, 1)) then
                table.insert(moves, Move.new({row, col}, {newRow, newCol}, self.board))
            end
        end
    end
end

function ChessEngine:GetRookMoves(row, col, moves)
    local directions = {
        {-1, 0}, {1, 0}, {0, -1}, {0, 1}
    }

    for _, direction in ipairs(directions) do
        local newRow = row + direction[1]
        local newCol = col + direction[2]
        while (newRow >= 1 and newRow <= 8 and newCol >= 1 and newCol <= 8) do
            if (self.board[newRow][newCol] == '--') then
                table.insert(moves, Move.new({row, col}, {newRow, newCol}, self.board))
            else
                if (self.board[newRow][newCol]:sub(1, 1) ~= self.board[row][col]:sub(1, 1)) then
                    table.insert(moves, Move.new({row, col}, {newRow, newCol}, self.board))
                end
                break
            end
            newRow = newRow + direction[1]
            newCol = newCol + direction[2]
        end
    end
end

function ChessEngine:GetQueenMoves(row, col, moves)
    self:GetRookMoves(row, col, moves)
    self:GetBishopMoves(row, col, moves)
end

function ChessEngine:GetKingMoves(row, col, moves)
    local kingMoves = {
        {-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}
    }

    for _, move in ipairs(kingMoves) do
        local newRow = row + move[1]
        local newCol = col + move[2]
        if (newRow >= 1 and newRow <= 8 and newCol >= 1 and newCol <= 8) then
            if (self.board[newRow][newCol]:sub(1, 1) ~= self.board[row][col]:sub(1, 1)) then
                table.insert(moves, Move.new({row, col}, {newRow, newCol}, self.board))
            end
        end
    end
end

function ChessEngine:GetBishopMoves(row, col, moves)
    local directions = {
        {-1, -1}, {-1, 1}, {1, -1}, {1, 1}
    }

    for _, direction in ipairs(directions) do
        local newRow = row + direction[1]
        local newCol = col + direction[2]
        while (newRow >= 1 and newRow <= 8 and newCol >= 1 and newCol <= 8) do
            if (self.board[newRow][newCol] == '--') then
                table.insert(moves, Move.new({row, col}, {newRow, newCol}, self.board))
            else
                if (self.board[newRow][newCol]:sub(1, 1) ~= self.board[row][col]:sub(1, 1)) then
                    table.insert(moves, Move.new({row, col}, {newRow, newCol}, self.board))
                end
                break
            end
            newRow = newRow + direction[1]
            newCol = newCol + direction[2]
        end
    end
end

return ChessEngine