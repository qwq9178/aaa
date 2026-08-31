-- 移动端触屏穿墙GUI脚本 | 可拖动悬浮按钮
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- 穿墙开关变量
local NoClipActive = false
local UpdateLoop = nil
local OriginCollisionData = {} -- 存储身体零件原始碰撞状态

-- ===================== 创建手机悬浮UI按钮 =====================
local ScreenUI = Instance.new("ScreenGui")
ScreenUI.Name = "MobileNoClipUI"
ScreenUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenUI.Parent = CoreGui

-- 主按钮
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 120, 0, 55) -- 适配手机触屏大小
ToggleBtn.Position = UDim2.new(0.82, 0, 0.2, 0)
ToggleBtn.BackgroundColor3 = Color3.new(0.1,0.1,0.1)
ToggleBtn.Text = "穿墙 关闭"
ToggleBtn.TextColor3 = Color3.new(1,1,1)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextScaled = true
ToggleBtn.Parent = ScreenUI

-- 圆角美化
local Radius = Instance.new("UICorner")
Radius.CornerRadius = UDim.new(0,12)
Radius.Parent = ToggleBtn

-- 按钮拖动逻辑（手机长按拖动）
local DragStart, StartPos
ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        DragStart = input.Position
        StartPos = ToggleBtn.AbsolutePosition
    end
end)
ToggleBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch and DragStart then
        local Delta = input.Position - DragStart
        ToggleBtn.Position = UDim2.new(0, StartPos.X + Delta.X, 0, StartPos.Y + Delta.Y)
    end
end)

-- ===================== 穿墙核心函数 =====================
local function SetNoClip(State)
    NoClipActive = State
    local Char = LocalPlayer.Character
    if not Char then return end
    local Humanoid = Char:FindFirstChildOfClass("Humanoid")
    if not Humanoid then return end

    if State then
        ToggleBtn.Text = "穿墙 开启"
        ToggleBtn.BackgroundColor3 = Color3.new(0,0.6,0) -- 绿色开启
        Humanoid.GravityScale = 0 -- 无重力自由漂浮
        -- 持续循环关闭所有身体碰撞
        UpdateLoop = RunService.Stepped:Connect(function()
            for _,Part in ipairs(Char:GetDescendants()) do
                if Part:IsA("BasePart") then
                    OriginCollisionData[Part] = Part.CanCollide
                    Part.CanCollide = false
                end
            end
        end)
    else
        ToggleBtn.Text = "穿墙 关闭"
        ToggleBtn.BackgroundColor3 = Color3.new(0.8,0,0) -- 红色关闭
        Humanoid.GravityScale = 1
        -- 停止循环，恢复原始碰撞
        if UpdateLoop then UpdateLoop:Disconnect() end
        for Part,OriginState in pairs(OriginCollisionData) do
            if Part:IsA("BasePart") then
                Part.CanCollide = OriginState
            end
        end
        table.clear(OriginCollisionData)
    end
end

-- 点击按钮切换穿墙
ToggleBtn.MouseButton1Click:Connect(function()
    SetNoClip(not NoClipActive)
end)

-- 角色重生自动重置穿墙
LocalPlayer.CharacterAdded:Connect(function()
    if NoClipActive then
        SetNoClip(false)
        task.wait(0.3)
        SetNoClip(true)
    end
end)

