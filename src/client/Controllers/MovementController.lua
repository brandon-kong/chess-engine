local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.knit)

local AlphaSquares = {"A", "B", "C", "D", "E", "F", "G", "H"}
local NumericSquares = {"1", "2", "3", "4", "5", "6", "7", "8"}

local MovementController = Knit.CreateController {
    Name = "MovementController";
}

function MovementController:KnitInit()
    print("MovementController Initialized")

    Knit.Player:WaitForChild("PlayerGui"):WaitForChild("Game"):WaitForChild("Background")
end

function MovementController:KnitStart()
    print("MovementController Started")

    --self:GetDiagonalSquaresFromSquare("D4")
    --self:GetVerticalSquaresFromSquare("H1")
    --self:GetHorizontalSquaresFromSquare("H1")

    local b = self:GetHorseSquaresFromSquare("D5")
    --self:ColorSquares(b)
end

function MovementController:GetDiagonalSquaresFromSquare(Square, Board)
    local alpha = string.sub(Square, 1, 1)
    local numeric = string.sub(Square, 2, 2)
    local numericNum = tonumber(numeric)

    local squares = {}

    local pieceOnBlock = Board:PieceOn(Square)

    local topRight, bottomRight, bottomLeft, topLeft = true, true, true, true

    for i = table.find(AlphaSquares, alpha)+1, #AlphaSquares do
        local numTop = numericNum + (i - table.find(AlphaSquares, alpha))
        local numBottom = numericNum - (i - table.find(AlphaSquares, alpha))

        if numTop <= #NumericSquares and numTop >= 1 then
            if (topRight) then
                local pieceOnTopRight = Board:PieceOn(AlphaSquares[i] .. NumericSquares[numTop])
                if pieceOnTopRight then
                    if pieceOnTopRight.Color ~= pieceOnBlock.Color then
                        table.insert(squares, AlphaSquares[i] .. NumericSquares[numTop])
                    end
                    topRight = false
                else
                    table.insert(squares, AlphaSquares[i] .. NumericSquares[numTop])
                end
            end
        end

        if numBottom >= 1 and numBottom <= 8 then
            if (bottomRight) then
                local pieceOnBottomRight = Board:PieceOn(AlphaSquares[i] .. NumericSquares[numBottom])
                if pieceOnBottomRight then
                    if pieceOnBottomRight.Color ~= pieceOnBlock.Color then
                        table.insert(squares, AlphaSquares[i] .. NumericSquares[numBottom])
                    end
                    bottomRight = false
                else
                    table.insert(squares, AlphaSquares[i] .. NumericSquares[numBottom])
                end
            end
        end
    end

    for i = table.find(AlphaSquares, alpha)-1, 1, -1 do
        local numTop = numericNum + (i - table.find(AlphaSquares, alpha))
        local numBottom = numericNum - (i - table.find(AlphaSquares, alpha))

        if numTop <= #NumericSquares and numTop >= 1 then
            if (topLeft) then
                local pieceOnTopLeft = Board:PieceOn(AlphaSquares[i] .. NumericSquares[numTop])
                if pieceOnTopLeft then
                    if pieceOnTopLeft.Color ~= pieceOnBlock.Color then
                        table.insert(squares, AlphaSquares[i] .. NumericSquares[numTop])
                    end
                    topLeft = false
                else
                    table.insert(squares, AlphaSquares[i] .. NumericSquares[numTop])
                end
            end
        end

        if numBottom >= 1 and numBottom <= 8 then
            if (bottomLeft) then
                local pieceOnBottomLeft = Board:PieceOn(AlphaSquares[i] .. NumericSquares[numBottom])
                if pieceOnBottomLeft then
                    if pieceOnBottomLeft.Color ~= pieceOnBlock.Color then
                        table.insert(squares, AlphaSquares[i] .. NumericSquares[numBottom])
                    end
                    bottomLeft = false
                else
                    table.insert(squares, AlphaSquares[i] .. NumericSquares[numBottom])
                end
            end
        end

    end
    return squares
end

function MovementController:GetVerticalSquaresFromSquare(Square, Board)
    local alpha = string.sub(Square, 1, 1)
    local numeric = string.sub(Square, 2, 2)

    local squares = {}

    local pieceOnBlock = Board:PieceOn(Square)

    local top, bottom = true, true
    for i = table.find(NumericSquares, numeric)+1, #NumericSquares do
        if (top) then
            local pieceOnTop = Board:PieceOn(alpha .. NumericSquares[i])
            if pieceOnTop then
                if pieceOnTop.Color ~= pieceOnBlock.Color then
                    table.insert(squares, alpha .. NumericSquares[i])
                end
                top = false
            else
                table.insert(squares, alpha .. NumericSquares[i])
            end
        end
    end

    for i = table.find(NumericSquares, numeric)-1, 1, -1 do
        if (bottom) then
            local pieceOnBottom = Board:PieceOn(alpha .. NumericSquares[i])
            if pieceOnBottom then
                if pieceOnBottom.Color ~= pieceOnBlock.Color then
                    table.insert(squares, alpha .. NumericSquares[i])
                end
                bottom = false
            else
                table.insert(squares, alpha .. NumericSquares[i])
            end
        end
    end

    return squares
end

function MovementController:GetHorizontalSquaresFromSquare(Square, Board)
    local alpha = string.sub(Square, 1, 1)
    local numeric = string.sub(Square, 2, 2)

    local squares = {}
    
    local pieceOnBlock = Board:PieceOn(Square)

    local top, bottom = true, true
    for i = table.find(AlphaSquares, alpha)+1, #AlphaSquares do
        if (top) then
            local pieceOnTop = Board:PieceOn(AlphaSquares[i] .. numeric)
            if pieceOnTop then
                if pieceOnTop.Color ~= pieceOnBlock.Color then
                    table.insert(squares, AlphaSquares[i] .. numeric)
                end
                top = false
            else
                table.insert(squares, AlphaSquares[i] .. numeric)
            end
        end
    end

    for i = table.find(AlphaSquares, alpha)-1, 1, -1 do
        if (bottom) then
            local pieceOnBottom = Board:PieceOn(AlphaSquares[i] .. numeric)
            if pieceOnBottom then
                if pieceOnBottom.Color ~= pieceOnBlock.Color then
                    table.insert(squares, AlphaSquares[i] .. numeric)
                end
                bottom = false
            else
                table.insert(squares, AlphaSquares[i] .. numeric)
            end
        end
    end

    return squares
end

function MovementController:GetHorseSquaresFromSquare(Square)
    local alpha = string.sub(Square, 1, 1)
    local numeric = string.sub(Square, 2, 2)
    local numericNum = tonumber(numeric)

    local squares = {}

    local alphaIndex = table.find(AlphaSquares, alpha)

    if (alphaIndex + 2 <= #AlphaSquares) then
        if (numericNum + 1 <= #NumericSquares) then
            table.insert(squares, AlphaSquares[alphaIndex + 2] .. NumericSquares[numericNum + 1])
        end

        if (numericNum - 1 >= 1) then
            table.insert(squares, AlphaSquares[alphaIndex + 2] .. NumericSquares[numericNum - 1])
        end
    end

    if (alphaIndex - 2 >= 1) then
        if (numericNum + 1 <= #NumericSquares) then
            table.insert(squares, AlphaSquares[alphaIndex - 2] .. NumericSquares[numericNum + 1])
        end

        if (numericNum - 1 >= 1) then
            table.insert(squares, AlphaSquares[alphaIndex - 2] .. NumericSquares[numericNum - 1])
        end
    end

    if (numericNum + 2 <= #NumericSquares) then
        if (alphaIndex + 1 <= #AlphaSquares) then
            table.insert(squares, AlphaSquares[alphaIndex + 1] .. NumericSquares[numericNum + 2])
        end

        if (alphaIndex - 1 >= 1) then
            table.insert(squares, AlphaSquares[alphaIndex - 1] .. NumericSquares[numericNum + 2])
        end
    end

    if (numericNum - 2 >= 1) then
        if (alphaIndex + 1 <= #AlphaSquares) then
            table.insert(squares, AlphaSquares[alphaIndex + 1] .. NumericSquares[numericNum - 2])
        end

        if (alphaIndex - 1 >= 1) then
            table.insert(squares, AlphaSquares[alphaIndex - 1] .. NumericSquares[numericNum - 2])
        end
    end
    return squares
end

function MovementController:GetKingSquaresFromSquare(Square, Board)
    local alpha = string.sub(Square, 1, 1)
    local numeric = string.sub(Square, 2, 2)
    local numericNum = tonumber(numeric)

    local squares = {}

    local squareOnBlock = Board:PieceOn(Square)

    local alphaIndex = table.find(AlphaSquares, alpha)

    if (alphaIndex + 1 <= #AlphaSquares) then
        if (numericNum + 1 <= #NumericSquares) then
            if (Board:PieceOn(AlphaSquares[alphaIndex + 1] .. NumericSquares[numericNum + 1]) == nil or Board:PieceOn(AlphaSquares[alphaIndex + 1] .. NumericSquares[numericNum + 1]).Color ~= squareOnBlock.Color) then
                table.insert(squares, AlphaSquares[alphaIndex + 1] .. NumericSquares[numericNum + 1])
            end
        end

        if (numericNum - 1 >= 1) then
            if (Board:PieceOn(AlphaSquares[alphaIndex + 1] .. NumericSquares[numericNum - 1]) == nil or Board:PieceOn(AlphaSquares[alphaIndex + 1] .. NumericSquares[numericNum - 1]).Color ~= squareOnBlock.Color) then
                table.insert(squares, AlphaSquares[alphaIndex + 1] .. NumericSquares[numericNum - 1])
            end
        end

        if (Board:PieceOn(AlphaSquares[alphaIndex + 1] .. numeric) == nil or Board:PieceOn(AlphaSquares[alphaIndex + 1] .. numeric).Color ~= squareOnBlock.Color) then
            table.insert(squares, AlphaSquares[alphaIndex + 1] .. numeric)
        end
    end

    if (alphaIndex - 1 >= 1) then
        if (numericNum + 1 <= #NumericSquares) then
            if (Board:PieceOn(AlphaSquares[alphaIndex - 1] .. NumericSquares[numericNum + 1]) == nil or Board:PieceOn(AlphaSquares[alphaIndex - 1] .. NumericSquares[numericNum + 1]).Color ~= squareOnBlock.Color) then
                table.insert(squares, AlphaSquares[alphaIndex - 1] .. NumericSquares[numericNum + 1])
            end
        end

        if (numericNum - 1 >= 1) then
            if (Board:PieceOn(AlphaSquares[alphaIndex - 1] .. NumericSquares[numericNum - 1]) == nil or Board:PieceOn(AlphaSquares[alphaIndex - 1] .. NumericSquares[numericNum - 1]).Color ~= squareOnBlock.Color) then
                table.insert(squares, AlphaSquares[alphaIndex - 1] .. NumericSquares[numericNum - 1])
            end
        end

        if (Board:PieceOn(AlphaSquares[alphaIndex - 1] .. numeric) == nil or Board:PieceOn(AlphaSquares[alphaIndex - 1] .. numeric).Color ~= squareOnBlock.Color) then
            table.insert(squares, AlphaSquares[alphaIndex - 1] .. numeric)
        end
    end

    if (numericNum + 1 <= #NumericSquares) then
        if (Board:PieceOn(alpha .. NumericSquares[numericNum + 1]) == nil or Board:PieceOn(alpha .. NumericSquares[numericNum + 1]).Color ~= squareOnBlock.Color) then
            table.insert(squares, alpha .. NumericSquares[numericNum + 1])
        end
    end

    if (numericNum - 1 >= 1) then
        if (Board:PieceOn(alpha .. NumericSquares[numericNum - 1]) == nil or Board:PieceOn(alpha .. NumericSquares[numericNum - 1]).Color ~= squareOnBlock.Color) then
            table.insert(squares, alpha .. NumericSquares[numericNum - 1])
        end
    end

    return squares
end

function MovementController:ColorSquares(Squares)
    local UI = Knit.Player.PlayerGui.Game.Background.Board.Contents
    for i = 1, #Squares do
        local square = UI:FindFirstChild(Squares[i])
        if (square) then
            square.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        end
    end
end

return MovementController