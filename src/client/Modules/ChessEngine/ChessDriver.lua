--Dependencies--
local ChessSettings = require(script.Parent.ChessSettings)
local Draggable = require(script.Parent.Parent.Draggable)
local Move = require(script.Parent.Move)

local ChessDriver = {}
ChessDriver.__index = ChessDriver

function ChessDriver.new(screen, board)
    local self = {}

    self.pieces = {}
    self.screen = screen
    self.boardObj = board
    self.board = board.board

    self.pieceSelected = nil
    self.lastSquareSelected = nil
    self.validMoves = board:GetValidMoves()

    return setmetatable(self, ChessDriver)
end

function ChessDriver.arrayIndicesToBoardSquare(i, j)
    local alpha = { 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H' }
    return alpha[j] .. tostring(i)
end

function ChessDriver:drawBoard()
    --[[
        Draws the board on the screen
        @param screen: the screen to draw the board on

        @return: nil

        screen hierarchy: Board -> Contents
    ]]
    local screen = self.screen

    screen.MouseLeave:Connect(function()
        self.lastSquareSelected = nil
    end)

    screen.Contents:ClearAllChildren()
    for i = 1, ChessSettings.dimensions do
        for j = 1, ChessSettings.dimensions do
            local square = Instance.new('Frame')
            square.BorderSizePixel = 0
            square.Name = i .. j
            square.Size = UDim2.new(1/ChessSettings.dimensions, 0, 1/ChessSettings.dimensions, 0)
            square.Position = UDim2.new((j-1)/ChessSettings.dimensions, 0, (i-1)/ChessSettings.dimensions, 0)
            square.BackgroundColor3 = (i+j) % 2 == 0 and ChessSettings.colors.light or ChessSettings.colors.dark
            square.Parent = screen.Contents

            square.MouseEnter:Connect(function()
                self.lastSquareSelected = {i, j}
            end)
        end
    end
end

function ChessDriver:drawPieces()
    --[[
        Draws the pieces on the board
        @param screen: the screen to draw the pieces on
        @param board: the state of the board

        @return: array of pieces as UI elements

        board hierarchy: Board -> Contents
    ]]

    local pieces = {}

    local screen = self.screen
    local board = self.board

    screen.Pieces:ClearAllChildren()

    for i = 1, ChessSettings.dimensions do
        for j = 1, ChessSettings.dimensions do
            local piece = board[i][j]
            if piece ~= '--' then
                local pieceUI = screen.Pieces:FindFirstChild(piece)
                local squareUI = screen.Contents:FindFirstChild(i..j)
                if (squareUI) then
                    pieceUI = Instance.new('ImageButton')
                    pieceUI.Name = piece
                    pieceUI.Image = ChessSettings.icons[piece]
                    pieceUI.BackgroundTransparency = 1
                    pieceUI.Size = UDim2.new(1/ChessSettings.dimensions, 0, 1/ChessSettings.dimensions, 0)
                    pieceUI.Position = UDim2.new((j-1)/ChessSettings.dimensions, 0, (i-1)/ChessSettings.dimensions, 0)
                    pieceUI.Parent = screen.Pieces
                    pieceUI.ZIndex = 2

                    local dragObj = Draggable.new(pieceUI)
                    dragObj:Connect()

                    dragObj.dragStopped:Connect(function()
                        if (self.lastSquareSelected) then
                            local newMove = Move.new({i, j}, self.lastSquareSelected, self.board)
                            for _, move in pairs(self.validMoves) do
                                if (move:__equals(newMove)) then
                                    self.boardObj:MakeMove(newMove)
                                    self:draw()

                                    self.validMoves = self.boardObj:GetValidMoves()
                                    break
                                end
                            end
                        end
                    end)

                    pieceUI.MouseButton1Down:Connect(function()
                        self:VisualizeValidSquares(piece, i..j)
                    end)

                    pieceUI.MouseButton1Up:Connect(function()
                        self:RecolorSquares()
                    end)
                end
            end
        end
    end

    return pieces
end

function ChessDriver:UndoMove()
    self.boardObj:UndoMove()
    self:draw()

    self.validMoves = self.boardObj:GetValidMoves()
end

function ChessDriver:VisualizeValidSquares(piece, square)
    --[[
        Highlights the valid squares for a piece
        @param piece: the piece to highlight the valid squares for
        @param square: the square the piece is on

        @return: nil
    ]]

    local screen = self.screen
    local board = self.board

    local pieceUI = screen.Pieces:FindFirstChild(piece)
    local squareUI = screen.Contents:FindFirstChild(square)

    local i, j = tonumber(square:sub(1, 1)), tonumber(square:sub(2, 2))
    if (pieceUI and squareUI) then
        for _, move in pairs(self.validMoves) do
            if (move.pieceMoved == piece and move.startSquare[1] == i and move.startSquare[2] == j) then
                local uisquare = screen.Contents:FindFirstChild(move.endSquare[1] .. move.endSquare[2])
                if (uisquare) then
                    local color = (move.endSquare[1] + move.endSquare[2]) % 2 == 0 and ChessSettings.colors.valid_light or ChessSettings.colors.valid_dark
                    if (move.pieceCaptured ~= '--') then
                        color = (move.endSquare[1] + move.endSquare[2]) % 2 == 0 and ChessSettings.colors.take_light or ChessSettings.colors.take_dark
                    end
                    uisquare.BackgroundColor3 = color
                end
            end
        end
    end
end

function ChessDriver:RecolorSquares()
    for i = 1, ChessSettings.dimensions do
        for j = 1, ChessSettings.dimensions do
            local square = self.screen.Contents:FindFirstChild(i..j)
            if (square) then
                square.BackgroundColor3 = (i+j) % 2 == 0 and ChessSettings.colors.light or ChessSettings.colors.dark
            end
        end
    end
end

function ChessDriver:draw()
    self:drawBoard()
    self:drawPieces()
end

return ChessDriver