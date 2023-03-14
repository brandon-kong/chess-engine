local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.knit)

for i, v in ipairs(script.Controllers:GetChildren()) do
    if v:IsA("ModuleScript") then
        require(v)
    end
end

Knit.Start():andThen(function()
    print("Client started!")
end):catch(warn)