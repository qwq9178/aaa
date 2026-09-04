local Player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

-- 功能全局变量
local FlyEnabled = false
local NoclipEnabled = false
local FlySpeed = 50
local MainUIVisible = true -- 主面板显示状态

-- 屏蔽重置弹窗
StarterGui:SetCore("ResetButtonCallback", false)

-- 总顶层GUI（最高渲染层级）
local TopGui = Instance.new("ScreenGui")
TopGui.Name = "TopCheatGui"
TopGui.Parent = Player.PlayerGui
TopGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
TopGui.DisplayOrder = 9999 -- 最高显示优先级，覆盖所有游戏UI

-- ========== 迷你拖动总开关小方框 ==========
local ToggleCircle = Instance.new("TextButton")
ToggleCircle.Size = UDim2.new(0,36,0,36)
ToggleCircle.Position = UDim2.new(0.01,0,0.4,0)
ToggleCircle.BackgroundColor3 = Color3.new(0.1,0.6,0.9)
ToggleCircle.BorderSizePixel = 2
ToggleCircle.BorderColor3 = Color3.new(1,1,1)
ToggleCircle.Text = "开"
ToggleCircle.TextColor3 = Color3.new(1,1,1)
ToggleCircle.Font = Enum.Font.GothamBold
ToggleCircle.TextSize = 16
ToggleCircle.ZIndex = 9999
ToggleCircle.Parent = TopGui

-- 小方框拖动逻辑
local dragMiniStart, miniStartPos
ToggleCircle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragMiniStart = input.Position
        miniStartPos = ToggleCircle.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragMiniStart and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragMiniStart
        ToggleCircle.Position = UDim2.new(
            miniStartPos.X.Scale, miniStartPos.X.Offset + delta.X,
            miniStartPos.Y.Scale, miniStartPos.Y.Offset + delta.Y
        )
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragMiniStart = nil
    end
end)

-- 点击小方框 显示/隐藏主功能面板
ToggleCircle.MouseButton1Click:Connect(function()
    MainUIVisible = not MainUIVisible
    MainFrame.Visible = MainUIVisible
    ToggleCircle.Text = MainUIVisible and "关" or "开"
end)

-- ========== 主功能窗口 ==========
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 180, 0, 240)
MainFrame.Position = UDim2.new(0.08, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.new(0.12,0.12,0.12)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.new(0.4,0.6,1)
MainFrame.ClipsDescendants = true
MainFrame.Visible = true
MainFrame.ZIndex = 9998
MainFrame.Parent = TopGui

-- 顶部拖动标题栏
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1,0,0,28)
TitleBar.BackgroundColor3 = Color3.new(0.25,0.45,0.8)
TitleBar.Parent = MainFrame

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(0.8,0,1,0)
TitleText.Position = UDim2.new(0,8,0,0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "功能面板(可拖动)"
TitleText.TextColor3 = Color3.new(1,1,1)
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 14
TitleText.Parent = TitleBar

-- 关闭按钮
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0,26,0,26)
CloseBtn.Position = UDim2.new(1,-28,0,1)
CloseBtn.BackgroundColor3 = Color3.new(0.8,0.2,0.2)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.Parent = TitleBar
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    MainUIVisible = false
    ToggleCircle.Text = "开"
end)

-- 滚动滑动容器
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1,0,1,-28)
ScrollFrame.Position = UDim2.new(0,0,0,28)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.CanvasSize = UDim2.new(0,0,0,160)
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarBackgroundColor3 = Color3.new(0.3,0.5,0.9)
ScrollFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0,12)
UIList.Position = UDim2.new(0,10,0,10)
UIList.Parent = ScrollFrame

-- 飞行按钮
local FlyBtn = Instance.new("TextButton")
FlyBtn.Size = UDim2.new(0,150,0,32)
FlyBtn.BackgroundColor3 = Color3.new(0.2,0.2,0.2)
FlyBtn.BorderColor3 = Color3.new(0.2,0.7,0.3)
FlyBtn.Text = "飞行: 关闭"
FlyBtn.TextColor3 = Color3.new(1,1,1)
FlyBtn.Font = Enum.Font.Gotham
FlyBtn.TextSize = 13
FlyBtn.Parent = ScrollFrame
FlyBtn.MouseButton1Click:Connect(function()
    FlyEnabled = not FlyEnabled
    if FlyEnabled then
        FlyBtn.Text = "飞行: 开启"
        FlyBtn.BackgroundColor3 = Color3.new(0,0.4,0.15)
    else
        FlyBtn.Text = "飞行: 关闭"
        FlyBtn.BackgroundColor3 = Color3.new(0.2,0.2,0.2)
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.GravityScale = 1
            Player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        end
    end
end)

-- 穿墙按钮
local NoclipBtn = Instance.new("TextButton")
NoclipBtn.Size = UDim2.new(0,150,0,32)
NoclipBtn.BackgroundColor3 = Color3.new(0.2,0.2,0.2)
NoclipBtn.BorderColor3 = Color3.new(0.7,0.3,0.2)
NoclipBtn.Text = "穿墙: 关闭"
NoclipBtn.TextColor3 = Color3.new(1,1,1)
NoclipBtn.Font = Enum.Font.Gotham
NoclipBtn.TextSize = 13
NoclipBtn.Parent = ScrollFrame
NoclipBtn.MouseButton1Click:Connect(function()
    NoclipEnabled = not NoclipEnabled
    if NoclipEnabled then
        NoclipBtn.Text = "穿墙: 开启"
        NoclipBtn.BackgroundColor3 = Color3.new(0.4,0,0.1)
    else
        NoclipBtn.Text = "穿墙: 关闭"
        NoclipBtn.BackgroundColor3 = Color3.new(0.2,0.2,0.2)
        if Player.Character then
            for _,v in ipairs(Player.Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = true
                end
            end
        end
    end
end)

-- 主窗口拖动逻辑
local dragMainStart, mainStartPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragMainStart = input.Position
        mainStartPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragMainStart and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragMainStart
        MainFrame.Position = UDim2.new(
            mainStartPos.X.Scale, mainStartPos.X.Offset + delta.X,
            mainStartPos.Y.Scale, mainStartPos.Y.Offset + delta.Y
        )
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragMainStart = nil
    end
end)

-- 实时功能循环
 RunService.RenderStepped:Connect(function()
     local char = Player.Character
     if not char then return end
     local hum = char:FindFirstChild("Humanoid")
     local root = char:FindFirstChild("HumanoidRootPart")
     if not hum or not root then return end
     -- 穿墙逻辑
     if NoclipEnabled then
         for _,part in ipairs(char:GetDescendants()) do
             if part:IsA("BasePart") then
                 part.CanCollide = false
             end
         end
     end
     -- 飞行逻辑
     if FlyEnabled then
         hum.GravityScale = 0
         hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
         local cam = workspace.CurrentCamera
         local moveDir = Vector3.new()
         if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.CFrame.LookVector end
         if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.CFrame.LookVector end
         if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.CFrame.RightVector end
         if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.CFrame.RightVector end
         if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0,1,0) end
         if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir -= Vector3.new(0,1,0) end
         if moveDir.Magnitude > 0 then
             moveDir = moveDir.Unit * FlySpeed
         end
         root.Velocity = moveDir
     end
 end)
 -- 重生重置功能状态
 Player.CharacterAdded:Connect(function()
     FlyEnabled = false
     NoclipEnabled = false
     FlyBtn.Text = "飞行: 关闭"
     NoclipBtn.Text = "穿墙: 关闭"
     FlyBtn.BackgroundColor3 = Color3.new(0.2,0.2,0.2)
     NoclipBtn.BackgroundColor3 = Color3.new(0.2,0.2,0.2)
 end)
