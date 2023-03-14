local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.knit)

local Board = require(script.Parent.Parent.Components.Board)

local BoardController = Knit.CreateController {
    Name = "BoardController";
}

function BoardController:KnitInit()
    print("BoardController Initialized")

    Knit.Player:WaitForChild("PlayerGui"):WaitForChild("Game"):WaitForChild("Background")
end

function BoardController:KnitStart()
    print("BoardController Started")

    local BoardUI  = Knit.Player.PlayerGui.Game.Background
    local newBoard = Board.new(BoardUI.Board)
    newBoard:Initialize()
    
    newBoard:Mount()

    BoardUI.Reset.MouseButton1Click:Connect(function()
        newBoard:Reset()
        newBoard:Mount()
    end)
end

return BoardController