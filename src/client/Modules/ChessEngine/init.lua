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

return ChessEngine