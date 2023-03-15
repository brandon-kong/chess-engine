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
    self.wKing = {8, 5}
    self.bKing = {1, 5}

    self.inCheck = false
    self.pins = {}
    self.checks = {}

    return setmetatable(self, ChessEngine)
end

function ChessEngine:isWhitesTurn()
    return self.whitesTurn
end

function ChessEngine:MakeMove(moveObj)
    self.board[moveObj.startRow][moveObj.startCol] = '--'
    self.board[moveObj.endRow][moveObj.endCol] = moveObj.pieceMoved
    self.whitesTurn = not self.whitesTurn -- switch turns

    table.insert(self.moveLog, moveObj)

    if (moveObj.pieceMoved == 'wK') then
        self.wKing = {moveObj.endRow, moveObj.endCol}
    elseif (moveObj.pieceMoved == 'bK') then
        self.bKing = {moveObj.endRow, moveObj.endCol}
    end
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
    local moves = {}
    self.inCheck, self.pins, self.checks = self:CheckForPinsAndChecks()

    local kingRow, kingCol
    if self.whitesTurn then
        kingRow = self.wKing[1]
        kingCol = self.wKing[2]
    else
        kingRow = self.bKing[1]
        kingCol = self.bKing[2]
    end

    if (self.inCheck) then
        if (#self.checks == 1) then
            moves = self:GetPossibleMoves()
            local check = self.checks[1]
            local checkRow = check[1]
            local checkCol = check[2]
            local pieceChecking = self.board[checkRow][checkCol]
            print('pieceChecking: ' .. pieceChecking)
            local validSquares = {}

            if (pieceChecking:sub(2, 2) == 'N') then
                validSquares = {{checkRow, checkCol}}
            else
                for i = 1, 8 do
                    local validSquare = {kingRow + check[3] * i, kingCol + check[4] * i}
                    table.insert(validSquares, validSquare)
                    if (validSquare[1] == checkRow and validSquare[2] == checkCol) then
                        break
                    end
                end
            end

            for i = #moves, 1, -1 do
                
                if (moves[i] and moves[i].pieceMoved:sub(2, 2) ~= 'K') then
                    local moveValid = false
                    for j = 1, #validSquares do
                        if (moves[i].endRow == validSquares[j][1] and moves[i].endCol == validSquares[j][2]) then
                            moveValid = true
                            break
                        end
                    end
                    if (not moveValid) then
                        table.remove(moves, i)
                    end
                else
                    print('hi')
                end
            end
        else
            -- double check, king has to move
            self:GetKingMoves(kingRow, kingCol, moves)
        end
    else
        moves = self:GetPossibleMoves()
    end

    --[[ Stalemate ]]

    if (#moves == 0) then
        if (self.inCheck) then
            print('CHECKMATE')
        else
            print('STALEMATE')
        end
    else
        --print('VALID MOVES')
    end

    return moves
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

    local allyColor = self.whitesTurn and 'w' or 'b'

    for _, move in ipairs(kingMoves) do
        local newRow = row + move[1]
        local newCol = col + move[2]
        if (newRow >= 1 and newRow <= 8 and newCol >= 1 and newCol <= 8) then
            local endPiece = self.board[newRow][newCol]
            if (endPiece:sub(1, 1) ~= allyColor) then
                if (allyColor == 'w') then
                    self.wKing = {newRow, newCol}
                else
                    self.bKing = {newRow, newCol}
                end

                local inCheck, pins, checks = self:CheckForPinsAndChecks()
                if (not inCheck) then
                    table.insert(moves, Move.new({row, col}, {newRow, newCol}, self.board))
                end

                if (allyColor == 'w') then
                    self.wKing = {row, col}
                else
                    self.bKing = {row, col}
                end
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

function ChessEngine:isInCheck()
    if (self.whitesTurn) then
        return self:squareUnderAttack(self.wKing[1], self.wKing[2])
    else
        return self:squareUnderAttack(self.bKing[1], self.bKing[2])
    end
end

function ChessEngine:squareUnderAttack(row, col)
    self.whitesTurn = not self.whitesTurn
    local moves = self:GetPossibleMoves()
    self.whitesTurn = not self.whitesTurn

    for _, move in ipairs(moves) do
        if (move.endRow == row and move.endCol == col) then
            return true
        end
    end

    return false
end

function ChessEngine:CheckForPinsAndChecks()
    local pins = {}
    local checks = {}

    local enemyColor
    local allyColor
    local startRow
    local startCol
    local inCheck = false

    if (self.whitesTurn) then
        enemyColor = 'b'
        allyColor = 'w'
        startRow = self.wKing[1]
        startCol = self.wKing[2]
    else
        enemyColor = 'w'
        allyColor = 'b'
        startRow = self.bKing[1]
        startCol = self.bKing[2]
    end

    local directions = {
        {-1, 0}, {0, -1}, {1, 0}, {0, 1}, {-1, -1}, {-1, 1}, {1, -1}, {1, 1}
    }

    for j = 1, #directions do
        local d = directions[j]
        local possiblePin = {}

        for i = 1, 8 do
            local endRow = startRow + d[1] * i
            local endCol = startCol + d[2] * i
            if 1 <= endRow and endRow <= 8 and 1 <= endCol and endCol <= 8 then
                local endPiece = self.board[endRow][endCol]
                local color = endPiece:sub(1, 1)
                local type = endPiece:sub(2, 2)
                if color == allyColor and type ~= 'K' then

                        if possiblePin.length == 0 then
                            possiblePin = {endRow, endCol, d[1], d[2]}
                            print(possiblePin)
                        else
                            break
                        end
                elseif color == enemyColor then
                    if (type == 'R' and j >= 1 and j <= 4) or (type == 'B' and j >= 5 and j <= 8) or (type == 'P' and i == 1 and ((enemyColor == 'w' and j >= 7 and j <= 8) or (enemyColor == 'b' and j >= 5 and j <= 6))) or (type == 'Q') or (i == 1 and type == 'K') then
                        if #possiblePin == 0 then
                            inCheck = true
                            table.insert(checks, {endRow, endCol, d[1], d[2]})
                        else
                            table.insert(pins, possiblePin)
                            break
                        end
                    else
                        break
                    end

                end

            else
                break
            end
        end
    end

    local knightMoves = {
        {-2, -1}, {-2, 1}, {-1, -2}, {-1, 2}, {1, -2}, {1, 2}, {2, -1}, {2, 1}
    }

    for _, move in ipairs(knightMoves) do
        local endRow = startRow + move[1]
        local endCol = startCol + move[2]
        if 1 <= endRow and endRow <= 8 and 1 <= endCol and endCol <= 8 then
            local endPiece = self.board[endRow][endCol]
            if endPiece ~= '--' and endPiece:sub(1, 1) == enemyColor and endPiece:sub(2, 2) == 'N' then
                inCheck = true
                table.insert(checks, {endRow, endCol, move[1], move[2]})
            end
        end
    end

    return inCheck, pins, checks, {startRow, startCol}
end

return ChessEngine