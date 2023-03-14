local Board = {}
Board.__index = Board

local alphaTbl = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'}
local numericTbl = {'1', '2', '3', '4', '5', '6', '7', '8'}

local PieceSettings = require(game:GetService("ReplicatedStorage").Shared.PieceSettings)
local Draggable = require(script.Parent.Draggable)

local Pieces = {
    Pawn = require(script.Parent.Pieces.Pawn),
    Rook = require(script.Parent.Pieces.Rook),
    Knight = require(script.Parent.Pieces.Knight),
    Bishop = require(script.Parent.Pieces.Bishop),
    Queen = require(script.Parent.Pieces.Queen),
    King = require(script.Parent.Pieces.King),
}

function Board.new(UI)
    local self = setmetatable({}, Board)

    self.Squares = {}
    self.NumPieces = 0

    for i = 1, 8 do
        self.Squares[alphaTbl[i]] = {}
        for j = 1, 8 do
            self.Squares[alphaTbl[i]][numericTbl[j]] = {
                Piece = nil,
            }
        end
    end

    self.TakenPieces = {
        White = {},
        Black = {},
    }

    self.UI = UI

    self.Pieces = {
        White = {
            King = nil,
            Queen = nil,
            Rook = {},
            Bishop = {},
            Knight = {},
            Pawn = {},
        },
        Black = {
            King = nil,
            Queen = nil,
            Rook = {},
            Bishop = {},
            Knight = {},
            Pawn = {},
        },
    }

    self.UIPieces = {
        White = {},
        Black = {},
    }

    self.UISquareColors = {}
    self.lastColoredSquares = {}

    self.MouseOver = nil
    self.selectedPieceOnBoard = nil

    self.Turn = "White"

    return self
end

function Board:Initialize()
    for i, v in pairs(PieceSettings.PieceStart) do
        for j, k in pairs(v) do
            for _, l in pairs(k) do
                local piece = Pieces[j].new(self, nil, i)
                piece.id = self.NumPieces
                self:PlacePiece(piece, l, true)
                self.NumPieces += 1

                if (self.Pieces[i][j] == nil) then
                    self.Pieces[i][j] = {}
                end
                table.insert(self.Pieces[i][j], piece)
            end
        end
    end

    for i = 1, 8 do
        for j = 1, 8 do
            local square = self.UI.Contents[alphaTbl[i] .. numericTbl[j]]
            local squareColor = square.BackgroundColor3

            self.UISquareColors[alphaTbl[i] .. numericTbl[j]] = squareColor
        end
    end

    self.UI.Contents.MouseLeave:Connect(function()
        self.MouseOver = nil
    end)

    for i, v in ipairs(self.UI.Contents:GetChildren()) do
        if (v:IsA("Frame")) then
            v.MouseEnter:Connect(function()
                self.MouseOver = v.Name
            end)
        end
    end
    
end

function Board:PieceOn(Square)
    if (Square == nil) then
        return nil
    end
    if (#Square ~= 2) then
        return nil
    end

    local alpha = string.sub(Square, 1, 1)
    local numeric = string.sub(Square, 2, 2)

    if (self.Squares[alpha] == nil) then
        return nil
    end
    if (self.Squares[alpha][numeric] == nil) then
        return nil
    end

    return self.Squares[alpha][numeric].Piece
end

function Board:TakePiece(Square)
    local piece = self:PieceOn(Square)
    if (piece == nil) then
        return
    end

    local alpha = string.sub(Square, 1, 1)
    local numeric = string.sub(Square, 2, 2)

    self.Squares[alpha][numeric].Piece = nil

    if (piece.id == nil) then
        return
    end

    self.UIPieces[piece.Color][piece.id]:Destroy()
    table.insert(self.TakenPieces[piece.Color], piece)
end

function Board:Reset()
    print('resetting')
    for i = 1, 8 do
        for j = 1, 8 do
            self.Squares[alphaTbl[i]][numericTbl[j]].Piece = nil
        end
    end

    self.TakenPieces = {
        White = {},
        Black = {},
    }

    self.Pieces = {
        White = {
            King = nil,
            Queen = nil,
            Rook = {},
            Bishop = {},
            Knight = {},
            Pawn = {},
        },
        Black = {
            King = nil,
            Queen = nil,
            Rook = {},
            Bishop = {},
            Knight = {},
            Pawn = {},
        },
    }


    for i, v in pairs(self.UIPieces.White) do
        v:Destroy()
    end

    for i, v in pairs(self.UIPieces.Black) do
        v:Destroy()
    end

    self.lastColoredSquares = {}

    self.MouseOver = nil
    self.selectedPieceOnBoard = nil

    self.Turn = "White"
    self:Initialize()
end

function Board:PlacePiece(Piece, Square, init)
    assert(type(Square) == "string", "Square must be a string")
    assert(#Square == 2, "Square must be 2 characters long")

    local alpha = string.sub(Square, 1, 1)
    local numeric = string.sub(Square, 2, 2)

    assert(self.Squares[alpha] ~= nil, "Square must be a valid square")
    assert(self.Squares[alpha][numeric] ~= nil, "Square must be a valid square")


    if (Piece.Square ~= nil) then
        local oldAlpha = string.sub(Piece.Square, 1, 1)
        local oldNumeric = string.sub(Piece.Square, 2, 2)

        self.Squares[oldAlpha][oldNumeric].Piece = nil
    end

    if (init == nil) then
        if (Piece.hasMoved == false) then
            Piece.hasMoved = true
        end
    end

    Piece.Square = Square
    self.Squares[alpha][numeric].Piece = Piece
end

function Board:ValidSquare(Square)
    assert(type(Square) == "string", "Square must be a string")
    assert(#Square == 2, "Square must be 2 characters long")

    local alpha = string.sub(Square, 1, 1)
    local numeric = string.sub(Square, 2, 2)

    if self.Squares[alpha] ~= nil and self.Squares[alpha][numeric] ~= nil then
        return true
    else
        return false
    end
end

function Board:Mount()

    local function getSquareFromString(Square)
        return self.UI.Contents:FindFirstChild(Square)
    end
    
    for i, v in pairs(self.Pieces) do
        for j, k in pairs(v) do
            if (type(k) == "table") then
                for _, l in pairs(k) do
                    local newPiece = Instance.new("ImageLabel")
                    newPiece.Name = j
                    newPiece.BackgroundTransparency = 1
                    newPiece.Image = PieceSettings.Icons[i][j]
                    newPiece.Size = UDim2.new(1, 0, 1, 0)
                    newPiece.Parent = getSquareFromString(l.Square)
                    newPiece.ZIndex = 2

                    local button = Instance.new("TextButton")
                    button.Name = "Button"
                    button.BackgroundTransparency = 1
                    button.Size = UDim2.new(1, 0, 1, 0)
                    button.Parent = newPiece
                    button.ZIndex = 1
                    button.Text = ''
                    button.TextTransparency = 1;
                    button.Active = false

                    self.UIPieces[i][l.id] = newPiece

                    local d = Draggable.new(newPiece, self)
                    d:Connect()

                    button.MouseButton1Down:Connect(function()
                        local validPieces = l:GetMoveableSpaces()
                        for _, s in pairs(validPieces) do
                            local square = getSquareFromString(s)
                            square.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                        end
                        self.lastColoredSquares = validPieces
                    end)

                    d.dragStopped:Connect(function()
                        local square = self.MouseOver
                        local validPieces = l:GetMoveableSpaces()
                        for _, s in pairs(validPieces) do
                            local rsquare = getSquareFromString(s)
                            rsquare.BackgroundColor3 = self.UISquareColors[s]
                        end
                        if (self.Turn ~= l.Color) then
                            self.selectedPieceOnBoard = nil
                            return
                        end
                        if (square ~= nil) then
                            if (table.find(validPieces, square) ~= nil) then
                                if (self:PieceOn(square) == nil) then
                                    if (self.selectedPieceOnBoard ~= nil) then
                                        self:PlacePiece(l, square)
                                        print("Moved " .. l.Name .. " to " .. square)

                                        self.Turn = self.Turn == "White" and "Black" or "White"
                                        print(self.Turn .. "'s turn")
                                        newPiece.Parent = getSquareFromString(square)
                                    end
                                else
                                    -- there is a piece, so we need to check if it is the same color
                                    local piece = self:PieceOn(square)
                                    if (piece.Color ~= l.Color) then
                                        -- it is not the same color, so we can take it
                                        if (l.CanTake) then
                                            if (not l:CanTake(square)) then
                                                self.selectedPieceOnBoard = nil
                                                return
                                            end
                                        end
                                        if (self.selectedPieceOnBoard ~= nil) then
                                            self:TakePiece(square)
                                            self:PlacePiece(l, square)
                                            print("Moved " .. l.Name .. " to " .. square)

                                            self.Turn = self.Turn == "White" and "Black" or "White"
                                            print(self.Turn .. "'s turn")
                                            newPiece.Parent = getSquareFromString(square)
                                        end
                                    end
                                end
                            else
                                if (self.selectedPieceOnBoard ~= nil) then
                                    if (self.selectedPieceOnBoard == l) then
                                        if l.Name == 'Pawn' then
                                            if l:CanTake(square) then
                                                self:TakePiece(square)
                                                self:PlacePiece(l, square)
                                                print("Moved " .. l.Name .. " to " .. square)

                                                self.Turn = self.Turn == "White" and "Black" or "White"
                                                print(self.Turn .. "'s turn")
                                                newPiece.Parent = getSquareFromString(square)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        self.selectedPieceOnBoard = nil
                    end)

                    d.dragStarted:Connect(function()
                        if (self.selectedPieceOnBoard == nil) then
                            self.selectedPieceOnBoard = l
                        end
                    end)
                    --l:Mount(UI)
                end
            else
                print(k)
                --k:Mount(UI)
            end
        end
    end
end

return Board