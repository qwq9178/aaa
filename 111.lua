-- 服务引用
local RunService = game:GetService("RunService")
local LocalPlayer = game.Players.LocalPlayer

-- 穿墙状态变量
local NoClipActive = false
local ClipLoop = nil

-- ========== 穿墙主函数，绑定你的UI按钮 ==========
local function SetNoClip(switch)
    NoClipActive = switch
    if switch then
        -- 开启穿墙循环
        ClipLoop = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            -- 关闭自身碰撞、开启漂浮
            for _,obj in ipairs(char:GetDescendants()) do
                if obj:IsA("BasePart") then
                    obj.CanCollide = false
                end
            end
            hum.GravityScale = 0
            hum:SetStateEnabled(Enum.HumanoidStateType.Physics,false)
        end)
        -- ========== 修改【你的悬浮按钮】文字颜色（UI可视化反馈） ==========
        ToggleBtn.Text = "穿墙开启"
        ToggleBtn.BackgroundColor3 = Color3.new(0, 0.6, 0)
    else
        -- 关闭穿墙，销毁循环
        if ClipLoop then ClipLoop:Disconnect() end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.GravityScale = 1
            hum:SetStateEnabled(Enum.HumanoidStateType.Physics,true)
            for _,obj in ipairs(char:GetDescendants()) do
                if obj:IsA("BasePart") then
                    obj.CanCollide = true
                end
            end
        end
        -- ========== 修改【你的悬浮按钮】文字颜色 ==========
        ToggleBtn.Text = "穿墙关闭"
        ToggleBtn.BackgroundColor3 = Color3.new(0.7, 0, 0)
    end
end

-- ========== 绑定你现有的ToggleBtn按钮点击事件（手机触屏兼容） ==========
ToggleBtn.Activated:Connect(function()
    SetNoClip(not NoClipActive)
end)

-- 重生自动恢复穿墙状态
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.3)
    if NoClipActive then
        SetNoClip(true)
    end
end)

