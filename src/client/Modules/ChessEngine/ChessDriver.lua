--Dependencies--
local ChessSettings = require(script.Parent.ChessSettings)
local Draggable = require(script.Parent.Parent.Draggable)

local ChessDriver = {}
ChessDriver.__index = ChessDriver

function ChessDriver.new(screen, board)
    local self = {}

    self.pieces = {}
    self.screen = screen
    self.boardObj = board
    self.board = board.board

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
    screen.Contents:ClearAllChildren()
    for i = 1, ChessSettings.dimensions do
        for j = 1, ChessSettings.dimensions do
            local square = Instance.new('Frame')
            square.BorderSizePixel = 0
            square.Name = i .. j --ChessDriver.arrayIndicesToBoardSquare(i, j)
            square.Size = UDim2.new(1/ChessSettings.dimensions, 0, 1/ChessSettings.dimensions, 0)
            square.Position = UDim2.new((j-1)/ChessSettings.dimensions, 0, (i-1)/ChessSettings.dimensions, 0)
            square.BackgroundColor3 = (i+j) % 2 == 0 and ChessSettings.colors.light or ChessSettings.colors.dark
            square.Parent = screen.Contents
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
                       
                    end)

                    pieceUI.MouseButton1Click:Connect(function()
                    end)
                end
            end
        end
    end

    return pieces
end

return ChessDriver