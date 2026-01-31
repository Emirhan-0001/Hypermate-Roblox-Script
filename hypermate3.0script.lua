local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- GUI Parent
local Parent = game:GetService("CoreGui")
if Parent:FindFirstChild("XenoRed") then Parent.XenoRed:Destroy() end

local ScreenGui = Instance.new("ScreenGui", Parent)
ScreenGui.Name = "XenoRed"

-- Main Frame
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 220, 0, 400)
Main.Position = UDim2.new(0.5, -110, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(25, 0, 0)Main.BorderSizePixel = 2
Main.BorderColor3 = Color3.fromRGB(255, 0, 0)
Main.Active = true

-- Dragging Logic
local dragging, dragInput, dragStart, startPos
Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
Main.InputChanged:Connect(function(input)    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(150, 0, 0)Title.Text = "XENO RED ADMIN"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold

-- Variables
local noclip = false
local flying = false
local loopTarget = nil
local flySpeed = 50

-- Core Functions
RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character then        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
    if loopTarget and Players:FindFirstChild(loopTarget) then
        local p = Players[loopTarget].Character
        if p and p:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = p.HumanoidRootPart.CFrame
        end
    end
end)

local function toggleFly()
    flying = not flying    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if flying then
        local bv = Instance.new("BodyVelocity", root)
        bv.Name = "XFlyV"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        local bg = Instance.new("BodyGyro", root)
        bg.Name = "XFlyG"
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        task.spawn(function()
            while flying do
                RunService.RenderStepped:Wait()
                local cam = workspace.CurrentCamera.CFrame
                local dir = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.RightVector end
                bv.Velocity = dir * flySpeed                bg.CFrame = cam
            end
            bv:Destroy()
            bg:Destroy()
        end)
    end
end

-- UI Elements
local targetInput = Instance.new("TextBox", Main)
targetInput.Size = UDim2.new(0.9, 0, 0, 25)targetInput.Position = UDim2.new(0.05, 0, 0.1, 0)
targetInput.PlaceholderText = "Target Name"
targetInput.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
targetInput.TextColor3 = Color3.new(1, 1, 1)

local function createBtn(text, pos, cb)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(0.9, 0, 0, 28)
    b.Position = pos
    b.BackgroundColor3 = Color3.fromRGB(70, 0, 0)
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.MouseButton1Click:Connect(cb)
end

createBtn("Dex Explorer", UDim2.new(0.05, 0, 0.2, 0), function() loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))() end)
createBtn("Fly", UDim2.new(0.05, 0, 0.3, 0), toggleFly)
createBtn("Noclip", UDim2.new(0.05, 0, 0.4, 0), function() noclip = not noclip end)
createBtn("Speed 100", UDim2.new(0.05, 0, 0.5, 0), function() LocalPlayer.Character.Humanoid.WalkSpeed = 100 end)
createBtn("SkyJump", UDim2.new(0.05, 0, 0.6, 0), function() LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0, 200, 0) end)
createBtn("Goto Player", UDim2.new(0.05, 0, 0.7, 0), function()
    local t = Players:FindFirstChild(targetInput.Text)
    if t and t.Character then LocalPlayer.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame end
end)
createBtn("Loop Goto", UDim2.new(0.05, 0, 0.8, 0), function() loopTarget = (loopTarget == nil) and targetInput.Text or nil end)
createBtn("Close UI", UDim2.new(0.05, 0, 0.9, 0), function() ScreenGui:Destroy() end)
