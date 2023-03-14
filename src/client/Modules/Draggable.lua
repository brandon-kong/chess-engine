local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local Maid = require(Packages.maid)
local Signal = require(Packages.signal)

local Draggable = {}
Draggable.__index = Draggable

function Draggable.new(UI)
    local self = setmetatable({}, Draggable)

    self.UI = UI
    self.dragging = nil
    self.dragInput = nil
    self.dragStart = nil
    self.startPos = UI.Position
    self._Maid = Maid.new()

    self.dragStarted = Signal.new()
    self.dragStopped = Signal.new()

    return self
end

function Draggable:Update(input)
    local delta = input.Position - self.dragStart
    self.UI.Position = UDim2.new(self.startPos.X.Scale, self.startPos.X.Offset + delta.X, self.startPos.Y.Scale, self.startPos.Y.Offset + delta.Y)
end

function Draggable:Connect()
    self._Maid:GiveTask(self.UI.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            self.dragInput = input
        end
    end))

    self._Maid:GiveTask(self.UI.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            self.dragging = true
            self.dragStarted:Fire()
            self.dragStart = input.Position
            self.UI.ZIndex = 3
        end
    end))

    self._Maid:GiveTask(self.UI.InputEnded:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            self.dragging = false
            self.UI.Position = self.startPos
            self.dragStopped:Fire()
            self.UI.ZIndex = 2
        end
    end))

    self._Maid:GiveTask(self.UI.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            self.dragInput = input
        end
    end))

    self._Maid:GiveTask(UserInputService.InputChanged:Connect(function(input)
        if input == self.dragInput and self.dragging then
            self:Update(input)
        end
    end))
end

function Draggable:Destroy()
    self._Maid:DoCleaning()
    self = nil
end

return Draggable