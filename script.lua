--==================================================
-- GHOST PREMIUM V3 - Compacto (mobile)
-- Criador: eoryush
-- LocalScript: StarterPlayerScripts
--==================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local DESTINO = Vector3.new(-3.011, 6.374, -82.980)
local velocidade = 115
local speedAtivo = false
local velocidadeAnterior = 16

-- PALETA
local C = {
    fundo = Color3.fromRGB(9, 7, 18),
    card = Color3.fromRGB(19, 15, 34),
    card2 = Color3.fromRGB(28, 22, 46),
    borda = Color3.fromRGB(62, 46, 98),
    roxo = Color3.fromRGB(151, 49, 255),
    roxoClaro = Color3.fromRGB(192, 119, 255),
    branco = Color3.fromRGB(247, 243, 255),
    cinza = Color3.fromRGB(160, 150, 185),
    verde = Color3.fromRGB(63, 235, 143),
    ciano = Color3.fromRGB(61, 211, 255),
    off = Color3.fromRGB(52, 44, 68),
}

local old = playerGui:FindFirstChild("GhostPremium")
if old then old:Destroy() end

--==================== HELPERS ====================
local function new(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
end

local function corner(obj, r)
    return new("UICorner", {CornerRadius = UDim.new(0, r)}, obj)
end

local function stroke(obj, color, thick, transp)
    return new("UIStroke", {
        Color = color or C.roxo,
        Thickness = thick or 1,
        Transparency = transp or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    }, obj)
end

local function label(parent, text, size, color, pos, dim, font, align)
    return new("TextLabel", {
        BackgroundTransparency = 1,
        Text = text,
        TextSize = size,
        TextColor3 = color or C.branco,
        Position = pos,
        Size = dim,
        Font = font or Enum.Font.GothamMedium,
        TextXAlignment = align or Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        RichText = true
    }, parent)
end

local function getHum()
    local char = player.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

--==================== GUI ====================
local gui = new("ScreenGui", {
    Name = "GhostPremium",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, playerGui)

-- Painel (240x176) ancorado no canto superior direito
local panel = new("Frame", {
    Name = "MainPanel",
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -10, 0, 100),
    Size = UDim2.fromOffset(240, 176),
    BackgroundColor3 = C.fundo,
    BorderSizePixel = 0
}, gui)
corner(panel, 14)
stroke(panel, C.roxo, 1.5, 0.1)

new("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 12, 38)),
        ColorSequenceKeypoint.new(1, C.fundo)
    }),
    Rotation = 90
}, panel)

----------------------------------------------------
-- CABEÇALHO (44px) - também é a área de arrastar
----------------------------------------------------
local header = new("Frame", {
    Size = UDim2.new(1, 0, 0, 44),
    BackgroundTransparency = 1
}, panel)

local avatarBorder = new("Frame", {
    Position = UDim2.fromOffset(8, 7),
    Size = UDim2.fromOffset(30, 30),
    BackgroundColor3 = C.roxo,
    BorderSizePixel = 0
}, header)
corner(avatarBorder, 15)

local avatar = new("ImageLabel", {
    Position = UDim2.fromOffset(2, 2),
    Size = UDim2.fromOffset(26, 26),
    BackgroundColor3 = C.card2,
    BorderSizePixel = 0
}, avatarBorder)
corner(avatar, 13)

task.spawn(function()
    local ok, image = pcall(function()
        return Players:GetUserThumbnailAsync(
            player.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size100x100
        )
    end)
    if ok and avatar.Parent then avatar.Image = image end
end)

label(header,
    'GHOST <font color="#C077FF">PREMIUM</font>', 13, C.branco,
    UDim2.fromOffset(46, 6), UDim2.new(1, -90, 0, 18),
    Enum.Font.GothamBold)

-- ponto de status + @user
local dot = new("Frame", {
    Position = UDim2.fromOffset(47, 29),
    Size = UDim2.fromOffset(6, 6),
    BackgroundColor3 = C.verde,
    BorderSizePixel = 0
}, header)
corner(dot, 3)

label(header, "@" .. player.Name, 10, C.cinza,
    UDim2.fromOffset(58, 24), UDim2.new(1, -102, 0, 16))

local minimize = new("TextButton", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -8, 0.5, 0),
    Size = UDim2.fromOffset(28, 28),
    BackgroundColor3 = C.card2,
    Text = "-",
    TextSize = 18,
    TextColor3 = C.branco,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0
}, header)
corner(minimize, 8)
stroke(minimize, C.roxo, 1, 0.5)

new("Frame", {
    Position = UDim2.fromOffset(10, 44),
    Size = UDim2.new(1, -20, 0, 1),
    BackgroundColor3 = C.roxo,
    BackgroundTransparency = 0.6,
    BorderSizePixel = 0
}, panel)

----------------------------------------------------
-- CARTÃO VELOCIDADE (input + toggle na mesma linha)
----------------------------------------------------
local speedCard = new("Frame", {
    Position = UDim2.fromOffset(10, 52),
    Size = UDim2.new(1, -20, 0, 54),
    BackgroundColor3 = C.card,
    BorderSizePixel = 0
}, panel)
corner(speedCard, 10)
stroke(speedCard, C.borda, 1, 0.3)

label(speedCard, "VELOCIDADE", 10, C.cinza,
    UDim2.fromOffset(10, 4), UDim2.fromOffset(100, 16),
    Enum.Font.GothamBold)

local speedInput = new("TextBox", {
    Position = UDim2.fromOffset(10, 22),
    Size = UDim2.fromOffset(78, 26),
    BackgroundColor3 = Color3.fromRGB(8, 7, 16),
    Text = tostring(velocidade),
    PlaceholderText = "115",
    TextColor3 = C.branco,
    PlaceholderColor3 = C.cinza,
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    ClearTextOnFocus = false,
    BorderSizePixel = 0
}, speedCard)
corner(speedInput, 8)
stroke(speedInput, C.borda, 1, 0.2)

label(speedCard, "studs/s", 10, C.cinza,
    UDim2.fromOffset(94, 22), UDim2.fromOffset(44, 26))

-- toggle (botão clicável)
local toggle = new("TextButton", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -10, 0.5, 0),
    Size = UDim2.fromOffset(46, 26),
    BackgroundColor3 = C.off,
    Text = "",
    AutoButtonColor = false,
    BorderSizePixel = 0
}, speedCard)
corner(toggle, 13)

local knob = new("Frame", {
    Position = UDim2.fromOffset(3, 3),
    Size = UDim2.fromOffset(20, 20),
    BackgroundColor3 = C.branco,
    BorderSizePixel = 0
}, toggle)
corner(knob, 10)

local function updateToggle()
    local info = TweenInfo.new(0.15, Enum.EasingStyle.Quad)
    TweenService:Create(knob, info, {
        Position = speedAtivo and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3)
    }):Play()
    TweenService:Create(toggle, info, {
        BackgroundColor3 = speedAtivo and C.roxo or C.off
    }):Play()
end

speedInput.FocusLost:Connect(function()
    local n = tonumber(speedInput.Text)
    if n then velocidade = math.clamp(math.floor(n), 1, 1000) end
    speedInput.Text = tostring(velocidade)

    if speedAtivo then
        local hum = getHum()
        if hum then hum.WalkSpeed = velocidade end
    end
end)

toggle.Activated:Connect(function()
    local hum = getHum()
    if not hum then return end

    if not speedAtivo then
        velocidadeAnterior = hum.WalkSpeed
        speedAtivo = true
        hum.WalkSpeed = velocidade
    else
        speedAtivo = false
        hum.WalkSpeed = velocidadeAnterior
    end
    updateToggle()
end)

----------------------------------------------------
-- TELEPORTE
----------------------------------------------------
local tpButton = new("TextButton", {
    Position = UDim2.fromOffset(10, 112),
    Size = UDim2.new(1, -20, 0, 38),
    BackgroundColor3 = Color3.fromRGB(38, 22, 58),
    Text = "",
    BorderSizePixel = 0
}, panel)
corner(tpButton, 10)
stroke(tpButton, C.roxo, 1, 0.2)

local tpIcon = new("Frame", {
    AnchorPoint = Vector2.new(0, 0.5),
    Position = UDim2.new(0, 8, 0.5, 0),
    Size = UDim2.fromOffset(26, 26),
    BackgroundColor3 = Color3.fromRGB(58, 24, 98),
    BorderSizePixel = 0
}, tpButton)
corner(tpIcon, 8)

label(tpIcon, "TP", 11, C.roxoClaro,
    UDim2.fromScale(0, 0), UDim2.fromScale(1, 1),
    Enum.Font.GothamBold, Enum.TextXAlignment.Center)

label(tpButton, "TELEPORTE INSTANTÂNEO", 11, C.branco,
    UDim2.fromOffset(42, 4), UDim2.new(1, -48, 0, 18),
    Enum.Font.GothamBold)

label(tpButton, "Bug para o Boss ignorar", 9, C.ciano,
    UDim2.fromOffset(42, 20), UDim2.new(1, -48, 0, 14))

tpButton.Activated:Connect(function()
    local char = player.Character
    if char then
        char:PivotTo(CFrame.new(DESTINO) * char:GetPivot().Rotation)
    end
end)

----------------------------------------------------
-- RODAPÉ
----------------------------------------------------
label(panel, "Criador: eoryush", 10, C.cinza,
    UDim2.new(0, 12, 1, -20), UDim2.new(0.6, 0, 0, 16))

label(panel, "G", 12, C.roxoClaro,
    UDim2.new(1, -28, 1, -20), UDim2.fromOffset(16, 16),
    Enum.Font.GothamBold, Enum.TextXAlignment.Center)

----------------------------------------------------
-- BOTÃO REABRIR (mesmo canto do painel)
----------------------------------------------------
local reopen = new("TextButton", {
    Name = "Reabrir",
    AnchorPoint = Vector2.new(1, 0),
    Position = panel.Position,
    Size = UDim2.fromOffset(38, 38),
    BackgroundColor3 = C.fundo,
    Text = "G",
    TextSize = 18,
    TextColor3 = C.roxoClaro,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
    Visible = false
}, gui)
corner(reopen, 11)
stroke(reopen, C.roxo, 1.5, 0.1)

minimize.Activated:Connect(function()
    reopen.Position = panel.Position
    panel.Visible = false
    reopen.Visible = true
end)

reopen.Activated:Connect(function()
    panel.Position = reopen.Position
    panel.Visible = true
    reopen.Visible = false
end)

----------------------------------------------------
-- ARRASTAR (cabeçalho do painel e botão reabrir)
----------------------------------------------------
local function makeDraggable(handle, target)
    local dragging, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            local d = input.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
end

makeDraggable(header, panel)
makeDraggable(reopen, reopen)

----------------------------------------------------
-- RESPAWN
----------------------------------------------------
player.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 10)
    if hum and speedAtivo then
        hum.WalkSpeed = velocidade
    end
end)

updateToggle()
