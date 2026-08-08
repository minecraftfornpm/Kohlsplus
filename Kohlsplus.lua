local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "kohls+",
    Size = UDim2.fromOffset(340, 740),
    Theme = "Crimson",
    AutoShow = true,
})

local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local prefix = "."
local TS = game:GetService("TeleportService")
local HS = game:GetService("HttpService")
local ChatService = game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents")
local __sayRequest = ChatService:WaitForChild("SayMessageRequest")
local OnMessageDoneFiltering = ChatService:WaitForChild("OnMessageDoneFiltering")

local function tchat(msg) __sayRequest:FireServer(msg, "System") end
local function chat(msg) __sayRequest:FireServer(msg, "All") end
local commands = {}

function addcommand(name, desc, func)
    commands[name:lower()] = func
end

local function executeCommand(text)
    if text:sub(1, 1) == prefix then text = text:sub(2) end
    local parts = text:split(" ")
    local cmd = parts[1]:lower()
    local func = commands[cmd]
    if func then
        local args = {}
        for i = 2, #parts do table.insert(args, parts[i]) end
        func(args)
    else
        WindUI:Notify({Title = "kohls+", Content = "Command not found: " .. cmd, Duration = 3})
    end
end

function GetPlayers(target)
    local all = Players:GetPlayers()
    target = tostring(target or ""):lower()
    if target == "all" then return all end
    if target == "others" then local r = {} for _, p in ipairs(all) do if p ~= plr then table.insert(r, p) end end return r end
    if target == "me" then return {plr} end
    if target == "bacons" then local r = {} for _, p in ipairs(all) do if p.Character and (p.Character:FindFirstChild("Pal Hair") or p.Character:FindFirstChild("Kate Hair")) then table.insert(r, p) end end return r end
    local r = {}
    for _, p in ipairs(all) do
        if p.Name:lower():find(target, 1, true) or p.DisplayName:lower():find(target, 1, true) then table.insert(r, p) end
    end
    return r
end

local blacklisted = {}
local recentlyKicked = {}
local whitelist = {
    "Simonko_30", "EgorYa900", "nowhudhejeir", "EgorYa900Alt"
}
local ownerName = "nowhudhejeir"

if not isfile or not readfile or not writefile then
    isfile = function() return false end; readfile = function() return "" end; writefile = function() end
end
if not appendfile then
    appendfile = function(f, d) local o = (isfile(f) and readfile(f)) or ""; writefile(f, o .. d) end
end
if isfile("Blacklisted.txt") then
    for _, name in ipairs(readfile("Blacklisted.txt"):split("\n")) do
        if name ~= "" and name ~= "agspureiam" then table.insert(blacklisted, name) end
    end
else
    writefile("Blacklisted.txt", "AZLANPLATTERS\n")
    table.insert(blacklisted, "AZLANPLATTERS")
end

local Terrain = workspace:FindFirstChild("Terrain") or workspace:FindFirstChild("terrain")
local GameFolder = Terrain and (Terrain:FindFirstChild("_Game") or Terrain:FindFirstChild("GameFolder"))
local Admin = GameFolder and GameFolder:FindFirstChild("Admin")
local Pads = Admin and Admin:FindFirstChild("Pads")
local Folder = GameFolder and GameFolder:FindFirstChild("Folder")
local myjail = plr.Name .. "'s jail"
local safeTools = {["Building Tools"] = true, ["F3X"] = true, ["Delete Tool"] = true}

local antipunish = false
local antijail = false
local antikill = false
local antifling = false
local antiblind = false
local guis = false
local antifreeze = false
local antiBanHammer = false
local antimessage = false
local antikillRunning = false
local antiflingRunning = false
local antijailRunning = false
local Loops = {
    antifly = false,
    antivoid = false,
    antiskydive = false,
    antigrav = false,
    antiname = false,
    antitripmine = false,
    antieggbomb = false
}
local cageLoops = {}
local spamConnection = nil
local autoGod = false
local autoName = false
local permNotified = false
local nokEnabled = false
local takeAllPads = false
local antimusic = false
local boxcmd = nil

local function isWhitelisted(player)
    if plr.Name == ownerName then return false end
    return table.find(whitelist, player.Name) ~= nil
end

local function __hasRealAdmin() return Pads and Pads:FindFirstChild(plr.Name .. "'s admin") ~= nil end
local function __getFreePad() if not Pads then return nil end return Pads:FindFirstChild("Touch to get admin") end
local function __claimPad(pad)
    if not pad or not firetouchinterest then return false end
    local chr = plr.Character if not chr or not chr:FindFirstChild("Head") then return false end
    local spr = chr.Head local a = pad:FindFirstChild("Head") if not a then return false end
    firetouchinterest(a, spr, 1) firetouchinterest(a, spr, 0) firetouchinterest(a, spr, 1) task.wait(0.05) firetouchinterest(a, spr, 0)
    return true
end

local __permEnabled = false
local __permCoroutine
local function __permLoop()
    if __permCoroutine then task.cancel(__permCoroutine) end
    permNotified = false
    __permCoroutine = task.spawn(function()
        while __permEnabled do
            if not __hasRealAdmin() then
                local free = __getFreePad()
                if free then
                    if __claimPad(free) then
                        if not permNotified then
                            tchat("h \n✨ kohls+ activated ✨\ncreator: nowhudhejeir")
                            permNotified = true
                        end
                    end
                else
                    if GameFolder and GameFolder:FindFirstChild("Admin") then
                        local regen = GameFolder.Admin:FindFirstChild("Regen")
                        if regen and regen:FindFirstChild("ClickDetector") then
                            if fireclickdetector then fireclickdetector(regen.ClickDetector) else pcall(function() regen.ClickDetector:Fire() end) end
                            task.wait(0.3)
                        end
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end

plr.CharacterAdded:Connect(function(chr)
    if autoGod then tchat("god me") tchat("health me inf") tchat("loopheal me") end
    if autoName and not Loops.antiname then
        local role = "User"
        if plr.Name == ownerName then role = "Owner"
        elseif isWhitelisted(plr) then role = "Support" end
        tchat("name me [Kohls+]\n" .. role .. "\n" .. plr.DisplayName)
    end
    chr.ChildAdded:Connect(function(ch)
        if antifling and ch.Name == "BFRC" and ch:IsDescendantOf(workspace:WaitForChild(plr.Name)) then
            local hum = chr:FindFirstChild("Humanoid") if hum then hum.Sit = false end
            local torso = chr:FindFirstChild("Torso") if torso then torso.AssemblyLinearVelocity = Vector3.new(0,0,0) end
            game:GetService("RunService").Heartbeat:Wait()
            pcall(function() ch:Destroy() end)
            if torso then torso.AssemblyLinearVelocity = Vector3.new(0,0,0) end
        end
        if antifreeze and (ch.Name == "ice" or ch.Name == "Frozen" or ch.Name == "Freeze") then
            pcall(function() ch:Destroy() end)
            for _, d in ipairs(chr:GetDescendants()) do if d:IsA("BasePart") then d.Anchored = false end end
            tchat("thaw me")
        end
        if antiBanHammer and ch.Name == "BanHammer" then
            ch:Destroy()
            tchat("ungear me")
        end
    end)
end)

plr.Backpack.ChildAdded:Connect(function(child)
    if antiBanHammer and child.Name == "BanHammer" then
        child:Destroy()
        tchat("ungear me")
    end
end)

spawn(function()
    while true do
        if antifling then
            local chr = plr.Character
            if chr and chr:FindFirstChild("HumanoidRootPart") then
                local r = chr.HumanoidRootPart
                local vel = r.Velocity
                if math.abs(vel.X) > 150 or math.abs(vel.Z) > 150 then
                    r.Velocity = Vector3.new(0, vel.Y, 0)
                end
            end
        end
        game:GetService("RunService").RenderStepped:Wait()
    end
end)

spawn(function()
    while task.wait(0.1) do
        if antiblind then
            local blind = plr.PlayerGui:FindFirstChild("EFFECTGUIBLIND")
            if blind then blind:Destroy() end
            local confirm = plr.PlayerGui:FindFirstChild("ConfirmationPrompt")
            if confirm then confirm:Destroy() end
        end

        if antimessage then
            pcall(function()
                for _, v in ipairs(plr.PlayerGui:GetDescendants()) do
                    if v.Name == "MessageGUI" or v.Name == "Message" or v.Name == "HintGUI" then v:Destroy() end
                end
                if Folder then for _, v in ipairs(Folder:GetDescendants()) do if v.Name == "Message" then v:Destroy() end end end
            end)
        end

        if antiBanHammer then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= plr then
                    local bh = p.Backpack and p.Backpack:FindFirstChild("BanHammer")
                    if bh then bh:Destroy() tchat("ungear " .. p.Name) end
                    if p.Character then
                        local chbh = p.Character:FindFirstChild("BanHammer")
                        if chbh then chbh:Destroy() tchat("ungear " .. p.Name) end
                    end
                end
            end
        end

        if antijail then
            pcall(function()
                if Folder and Folder:FindFirstChild(myjail) then tchat("unjail me") end
            end)
        end

        if Loops.antifly then
            pcall(function()
                local chr = plr.Character
                if chr and chr:FindFirstChild("Humanoid") then
                    local state = chr.Humanoid:GetState()
                    if not chr:FindFirstChild("Seizure") and (state == Enum.HumanoidStateType.PlatformStanding or state == Enum.HumanoidStateType.Flying) then
                        tchat("unfly me")
                        tchat("clip me")
                        if chr:FindFirstChild("Torso") then chr.Torso.Anchored = false end
                        chr.Humanoid.PlatformStand = false
                    end
                end
            end)
        end

        if Loops.antivoid then pcall(function() local chr = plr.Character if chr and chr:FindFirstChild("HumanoidRootPart") then local r = chr.HumanoidRootPart if r.Position.Y < -7 then r.CFrame = CFrame.new(r.Position.X, 5, r.Position.Z) r.Velocity = Vector3.new(r.Velocity.X, 0, r.Velocity.Z) end end end) end
        if Loops.antiskydive then pcall(function() local chr = plr.Character if chr and chr:FindFirstChild("HumanoidRootPart") then local r = chr.HumanoidRootPart if r.Position.Y > 256 then r.CFrame = CFrame.new(r.Position.X, 5, r.Position.Z) r.Velocity = Vector3.new(r.Velocity.X, 0, r.Velocity.Z) end end end) end
        if Loops.antigrav then pcall(function() local chr = plr.Character if chr and chr:FindFirstChild("Torso") then local bf = chr.Torso:FindFirstChildOfClass("BodyForce") if bf then bf:Destroy() end end end) end
        if Loops.antiname then pcall(function() local chr = plr.Character if chr then local m = chr:FindFirstChildOfClass("Model") if m and #m:GetChildren() == 2 then tchat("unname me") m:Destroy() end end end) end
        if Loops.antitripmine then pcall(function() local tm = workspace:FindFirstChild("SubspaceTripmine") if tm then tm:Destroy() tchat("clr") end end) end
        if Loops.antieggbomb then pcall(function() local eb = workspace:FindFirstChild("EggBomb") if eb then eb:Destroy() tchat("clr") end end) end

        if antikill then
            pcall(function()
                local chr = plr.Character
                if chr and chr:FindFirstChild("Humanoid") and chr.Humanoid.Health <= 0 then
                    tchat("reset me")
                end
            end)
        end

        if antifreeze then
            pcall(function()
                local chr = plr.Character
                if not chr or chr.Parent ~= workspace then
                    tchat("reset me")
                    return
                end
                local hum = chr:FindFirstChild("Humanoid")
                if hum and hum.WalkSpeed == 0 and hum.Health > 0 then
                    tchat("thaw me")
                    return
                end
                local head = chr:FindFirstChild("Head")
                local torso = chr:FindFirstChild("Torso")
                if not head or not torso then
                    tchat("reset me")
                    return
                end
                local root = chr:FindFirstChild("HumanoidRootPart")
                if root and ((head.Position - root.Position).Magnitude > 20 or (torso.Position - root.Position).Magnitude > 20) then
                    tchat("reset me")
                end
            end)
        end

        if takeAllPads and Pads then
            pcall(function()
                local chr = plr.Character
                if chr and chr:FindFirstChild("Head") then
                    local spr = chr.Head
                    for _, pad in ipairs(Pads:GetChildren()) do
                        if pad:IsA("BasePart") and pad:FindFirstChild("Head") then
                            firetouchinterest(spr, pad.Head, 1)
                            firetouchinterest(spr, pad.Head, 0)
                        end
                    end
                end
            end)
        end
    end
end)

game:GetService("Lighting").ChildAdded:Connect(function(child)
    if antipunish and child.Name == plr.Name then child.Parent = workspace tchat("unpunish me") end
end)

plr.PlayerGui.ChildAdded:Connect(function(child)
    if antiblind then if child.Name == "EFFECTGUIBLIND" or child.Name == "ConfirmationPrompt" then child:Destroy() end end
    if guis then if child.Name ~= "ScrollGui" and child.Name ~= "CommandsGui" then child:Destroy() end end
end)

-- No Kill (obby)
local function TNOK(mode)
    pcall(function()
        local targetMode = (mode == "true")
        local obby1 = workspace.Terrain and workspace.Terrain._Game and workspace.Terrain._Game.Workspace and workspace.Terrain._Game.Workspace.Obby
        local obby2 = workspace.Terrain and workspace.Terrain.GameFolder and workspace.Terrain.GameFolder.Workspace and workspace.Terrain.GameFolder.Workspace.Obby
        local obby3 = workspace:FindFirstChild("Tabby") and workspace.Tabby.Admin_House and workspace.Tabby.Admin_House.Obby
        for _, obby in ipairs({obby1, obby2, obby3}) do
            if obby then
                for _, v in ipairs(obby:GetChildren()) do
                    if v:IsA("BasePart") then v.CanTouch = not targetMode end
                end
            end
        end
    end)
end

addcommand("nokill", "Disable obby kill", function() nokEnabled = true TNOK("true") WindUI:Notify({Title="kohls+", Content="Obby Kill disabled", Duration=2}) end)
addcommand("unnokill", "Enable obby kill", function() nokEnabled = false TNOK("false") WindUI:Notify({Title="kohls+", Content="Obby Kill enabled", Duration=2}) end)

-- Кастомное окно логов
local logsVisible = false
local logsGui
local logsScrollingFrame
local logsList

local function initLogsGui()
    if logsGui then return end
    logsGui = Instance.new("ScreenGui")
    logsGui.Name = "KohlsLogs"
    logsGui.Parent = game.CoreGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 350, 0, 400)
    mainFrame.Position = UDim2.new(1, -360, 0, 10)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = logsGui

    local titleBar = Instance.new("TextLabel")
    titleBar.Size = UDim2.new(1,0,0,30)
    titleBar.BackgroundColor3 = Color3.fromRGB(50,50,50)
    titleBar.Text = "Logs"
    titleBar.TextColor3 = Color3.new(1,1,1)
    titleBar.Parent = mainFrame

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0,30,0,30)
    closeBtn.Position = UDim2.new(1,-30,0,0)
    closeBtn.Text = "X"
    closeBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
    closeBtn.Parent = mainFrame
    closeBtn.MouseButton1Click:Connect(function()
        logsVisible = false
        logsGui.Enabled = false
    end)

    logsScrollingFrame = Instance.new("ScrollingFrame")
    logsScrollingFrame.Size = UDim2.new(1,0,1,-30)
    logsScrollingFrame.Position = UDim2.new(0,0,0,30)
    logsScrollingFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    logsScrollingFrame.CanvasSize = UDim2.new(0,0,0,0)
    logsScrollingFrame.ScrollBarThickness = 5
    logsScrollingFrame.Parent = mainFrame

    logsList = Instance.new("UIListLayout")
    logsList.Parent = logsScrollingFrame
end

local function addLogMessage(speaker, message)
    initLogsGui()
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,0,20)
    label.BackgroundTransparency = 1
    label.Text = speaker .. ": " .. message
    label.TextColor3 = Color3.new(1,1,1)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = logsScrollingFrame
    logsScrollingFrame.CanvasSize = UDim2.new(0,0,0,logsScrollingFrame.CanvasSize.Y.Offset + 20)
end

addcommand("logs", "Toggle logs window", function()
    initLogsGui()
    logsVisible = not logsVisible
    logsGui.Enabled = logsVisible
end)

-- Admin spy (упрощён: только наши команды)
local adminTargetName = nil
local adminConn = nil

local function cleanMessage(msg)
    -- оставляем только печатные ASCII, включая дефис/минус
    return (msg:gsub("[^\32-\126]", ""))
end

local function onMessageReceived(data, channel)
    local speaker = data.FromSpeaker
    local message = cleanMessage(data.Message)

    -- Всегда добавляем в лог
    addLogMessage(speaker, message)

    -- Наши команды через ?
    if speaker == plr.Name and message:sub(1,1) == "?" then
        local cmdText = message:sub(2)
        executeCommand(cmdText)
        return
    end

    -- Отслеживание только наших кастомных команд
    if adminTargetName and speaker == adminTargetName then
        if message:sub(1,1) == "?" then return end
        local parts = message:split(" ")
        local cmd = parts[1]:lower()

        if cmd == "cmds" then
            local cmdList = "?ban ?unban ?fpunish ?kick ?kid ?spam ?unspam ?clearlogs ?fixfilter ?bypassmessage ?cage ?loopcage ?unloopcage ?gearbl ?ungearbl ?nokill ?unnokill ?fixvel ?regen ?fixregen ?tptoregen ?rmoveregen ?deletetool ?jerk ?bang ?unbang ?ping ?rejoin ?serverhop ?nocam ?fcam ?fixcam ?weld ?slag ?joinppl ?r15 ?r6 ?nomusic ?resmusic"
            tchat("pm " .. adminTargetName .. " " .. cmdList)
            return
        end

        -- Обрабатываем только наши кастомные команды, остальное игнорируем
        if commands[cmd] then
            local newCmd = cmd .. " " .. adminTargetName
            for i = 2, #parts do
                local arg = parts[i]
                if arg:lower() == "me" then arg = adminTargetName end
                newCmd = newCmd .. " " .. arg
            end
            tchat(newCmd)
        end
    end
end

adminConn = OnMessageDoneFiltering.OnClientEvent:Connect(function(data, channel) onMessageReceived(data, channel) end)
addcommand("admin", "Spy on a player's commands", function(args)
    local target = args[1] if not target then return end
    local tgtPlayer = GetPlayers(target)[1]
    if tgtPlayer then
        adminTargetName = tgtPlayer.Name
        WindUI:Notify({Title="kohls+", Content="Now tracking " .. tgtPlayer.DisplayName, Duration=3})
    end
end)
addcommand("unadmin", "Stop spying", function() adminTargetName = nil WindUI:Notify({Title="kohls+", Content="Stopped tracking", Duration=3}) end)

local function handleBannedPlayer(p)
    if table.find(blacklisted, p.Name) then
        chat("you have 3 seconds before been kicked")
        task.wait(3)
        chat("good byeee, ".. p.Name .. "!")
        executeCommand("kick " .. p.Name)
    end
end

Players.PlayerAdded:Connect(function(p)
    if p ~= plr and table.find(whitelist, p.Name) then
        WindUI:Notify({Title="kohls+", Content="Whitelisted, " .. p.Name .. " join in server", Duration=5})
    end
    if p ~= plr then
        if recentlyKicked[p.Name] then
            local dialog = Instance.new("ScreenGui")
            dialog.Name = "ReturnDialog"
            dialog.Parent = game.CoreGui
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(0, 300, 0, 120)
            frame.Position = UDim2.new(0.5, -150, 0.5, -60)
            frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
            frame.Parent = dialog
            local title = Instance.new("TextLabel")
            title.Size = UDim2.new(1,0,0,30)
            title.BackgroundTransparency = 1
            title.Text = p.Name .. " joined back, kick him?"
            title.TextColor3 = Color3.new(1,1,1)
            title.Parent = frame
            local ignoreBtn = Instance.new("TextButton")
            ignoreBtn.Size = UDim2.new(0,100,0,30)
            ignoreBtn.Position = UDim2.new(0.05,0,0.7,0)
            ignoreBtn.Text = "Ignore"
            ignoreBtn.Parent = frame
            local kickBtn = Instance.new("TextButton")
            kickBtn.Size = UDim2.new(0,100,0,30)
            kickBtn.Position = UDim2.new(0.55,0,0.7,0)
            kickBtn.Text = "Kick"
            kickBtn.Parent = frame
            ignoreBtn.MouseButton1Click:Connect(function() dialog:Destroy() end)
            kickBtn.MouseButton1Click:Connect(function()
                dialog:Destroy()
                executeCommand("kick " .. p.Name)
            end)
            task.delay(30, function() recentlyKicked[p.Name] = nil end)
        end
        handleBannedPlayer(p)
    end
end)

local __commandsTab = Window:Tab({ Title = "Commands", Icon = "lucide:terminal" })
__commandsTab:Paragraph({
    Title = "Commands 1",
    Desc = "ban <player> – add to blacklist & kick if online\nunban <player> – remove from blacklist\nfpunish <player> – fake punish\nkick <player> – hot potato kick\nkid <player> – make a kid\nspam <message> – spam\nunspam – stop spam\nclearlogs – clear logs\nfixfilter – fix chat filter\nbypassmessage <msg> – bypass filter\ncage <player> – cage player\nloopcage <player> – loop cage\nunloopcage <player> – stop loop\ngearbl <player> – gear ban\nungearbl <player> – ungear ban\nnokill – disable obby kill\nunnokill – enable obby kill\nadmin <player> – spy on player\nunadmin – stop spying\nlogs – toggle logs window"
})
__commandsTab:Paragraph({
    Title = "Commands 2",
    Desc = "fixvel – fix velocity\nregen – click regen\nfixregen – move regen to spawn\ntptoregen – teleport to regen\nrmoveregen – remove regen\ndeletetool – get delete tool\njerk – you know\nbang <player> – bang animation\nunbang – stop bang\nping – show ping\nrejoin (rj) – rejoin server\nserverhop (shop) – hop server\nnocam – break camera (shiftlock)\nfcam <player> – break player's camera\nfixcam <player> – fix player's camera\nweld <player> [mode] – weld player\nslag – server lag (2 stones)\nslag2 – server lag (4 stones)\nserverlag – server lag (2 stones)\njoinppl <username/userId> – join a player's server\nr15 – switch to R15\nr6 – switch to R6\nnomusic – force stop all music\nresmusic – resume normal music"
})

local __mainTab = Window:Tab({ Title = "Main", Icon = "home" })
__mainTab:Toggle({ Title = "Auto Perm", Value = false, Callback = function(v) __permEnabled = v if v then __permLoop() else if __permCoroutine then task.cancel(__permCoroutine) end end end })
__mainTab:Toggle({ Title = "Auto God", Value = false, Callback = function(v) autoGod = v end })
__mainTab:Toggle({ Title = "Auto Name", Value = false, Callback = function(v) autoName = v end })

local __toolsTab = Window:Tab({ Title = "Tools", Icon = "tool" })
__toolsTab:Button({ Title = "Fix Regen", Callback = function() commands["fixregen"]({}) end })
__toolsTab:Button({ Title = "TP to Regen", Callback = function() commands["tptoregen"]({}) end })
__toolsTab:Button({ Title = "Rmove Regen", Callback = function() commands["rmoveregen"]({}) end })
__toolsTab:Button({ Title = "Delete Tool", Callback = function() commands["deletetool"]({}) end })

local __protectTab = Window:Tab({ Title = "Protection", Icon = "shield" })
__protectTab:Toggle({ Title = "Anti Punish", Value = false, Callback = function(v) antipunish = v end })
__protectTab:Toggle({ Title = "Anti Kill", Value = false, Callback = function(v) antikill = v end })
__protectTab:Toggle({ Title = "Anti Freeze", Value = false, Callback = function(v) antifreeze = v end })
__protectTab:Toggle({ Title = "Anti Jail", Value = false, Callback = function(v) antijail = v end })
__protectTab:Toggle({ Title = "Anti Fling/Speed", Value = false, Callback = function(v) antifling = v end })
__protectTab:Toggle({ Title = "Anti Blind", Value = false, Callback = function(v) antiblind = v end })
__protectTab:Toggle({ Title = "Anti Screen Guis", Value = false, Callback = function(v) guis = v end })
__protectTab:Toggle({ Title = "Anti Fly", Value = false, Callback = function(v) Loops.antifly = v end })
__protectTab:Toggle({ Title = "Anti Void", Value = false, Callback = function(v) Loops.antivoid = v end })
__protectTab:Toggle({ Title = "Anti Skydive", Value = false, Callback = function(v) Loops.antiskydive = v end })
__protectTab:Toggle({ Title = "Anti Grav", Value = false, Callback = function(v) Loops.antigrav = v end })
__protectTab:Toggle({ Title = "Anti Name", Value = false, Callback = function(v) Loops.antiname = v end })
__protectTab:Toggle({ Title = "Anti Tripmine", Value = false, Callback = function(v) Loops.antitripmine = v end })
__protectTab:Toggle({ Title = "Anti Eggbomb", Value = false, Callback = function(v) Loops.antieggbomb = v end })
__protectTab:Toggle({ Title = "Anti BanHammer", Value = false, Callback = function(v) antiBanHammer = v end })
__protectTab:Toggle({ Title = "Anti Message", Value = false, Callback = function(v) antimessage = v end })
__protectTab:Toggle({ Title = "No Kill (obby)", Value = false, Callback = function(v) nokEnabled = v TNOK(v and "true" or "false") end })
__protectTab:Toggle({ Title = "Take All Pads", Value = false, Callback = function(v) takeAllPads = v end })

spawn(function()
    local UI = Instance.new("ScreenGui")
    CommandBar = UI
    local dairyQueenBalls = Instance.new("TextButton") local holyshidt11 = Instance.new("TextBox")
    UI.Name = "&!)!@@#$(~(UI" UI.Parent = game.CoreGui UI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling UI.ResetOnSpawn = false
    dairyQueenBalls.Name = "dairyQueenBalls" dairyQueenBalls.Parent = UI dairyQueenBalls.AnchorPoint = Vector2.new(1,1) dairyQueenBalls.BackgroundColor3 = Color3.fromRGB(255,255,255) dairyQueenBalls.BackgroundTransparency = 1.000 dairyQueenBalls.BorderSizePixel = 0 dairyQueenBalls.Position = UDim2.new(1,0,1,0) dairyQueenBalls.Size = UDim2.new(0,61,0,61) dairyQueenBalls.Font = Enum.Font.Roboto dairyQueenBalls.Text = "]" dairyQueenBalls.TextColor3 = Color3.fromRGB(255,255,255) dairyQueenBalls.TextSize = 75.000 dairyQueenBalls.TextStrokeTransparency = 0.000 dairyQueenBalls.TextWrapped = true
    holyshidt11.Name = "holyshidt11" holyshidt11.Parent = dairyQueenBalls holyshidt11.AnchorPoint = Vector2.new(1,0) holyshidt11.BackgroundColor3 = Color3.fromRGB(255,255,255) holyshidt11.BackgroundTransparency = 0.750 holyshidt11.BorderSizePixel = 5 holyshidt11.BorderMode = "Inset" holyshidt11.Size = UDim2.new(0,0,0,61) holyshidt11.Visible = false holyshidt11.Font = Enum.Font.Code holyshidt11.Text = "" holyshidt11.AutomaticSize = "X" holyshidt11.TextColor3 = Color3.fromRGB(255,255,255) holyshidt11.TextSize = 50.000 holyshidt11.TextStrokeTransparency = 0.000 holyshidt11.TextXAlignment = Enum.TextXAlignment.Right
    local isCmdBarOpen = false
    function openUI() isCmdBarOpen = true holyshidt11:CaptureFocus() holyshidt11.Visible = true game:GetService("TweenService"):Create(holyshidt11, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0), {Size = UDim2.new(0,200,0,61)}):Play() game:GetService("RunService").RenderStepped:Wait() holyshidt11.Text = "" end
    local Connections = {}
    Connections[tostring(math.random(-9999999,9999999))] = game:GetService("UserInputService").InputBegan:Connect(function(key,gp) if not gp then if key.KeyCode == Enum.KeyCode.RightBracket then openUI() end end end)
    Connections[tostring(math.random(-9999999,9999999))] = dairyQueenBalls.MouseButton1Click:Connect(openUI)
    Connections[tostring(math.random(-9999999,9999999))] = holyshidt11.FocusLost:Connect(function(shouldSend)
        spawn(function() isCmdBarOpen = false game:GetService("TweenService"):Create(holyshidt11, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0), {Size = UDim2.new(0,0,0,61)}):Play() holyshidt11.Text = "" end)
        if shouldSend then
            local text = holyshidt11.Text
            if text ~= "" then executeCommand(text) end
        end
    end)
end)

addcommand("bl", "Add player to blacklist & kick if online", function(args)
    local target = args[1] if not target then return end
    for _, tgt in pairs(GetPlayers(target)) do
        if isWhitelisted(tgt) then WindUI:Notify({Title="kohls+", Content=tgt.Name.." is whitelisted, you can't ban him", Duration=4}) return end
        if not table.find(blacklisted, tgt.Name) then
            appendfile("Blacklisted.txt", tgt.Name.."\n")
            table.insert(blacklisted, tgt.Name)
        end
        executeCommand("kick " .. tgt.Name)
    end
end)
addcommand("ban", "", function(args) commands["bl"](args) end)
addcommand("unban", "Remove player from blacklist", function(args)
    local target = args[1] if not target then return end
    for _, tgt in pairs(GetPlayers(target)) do
        for i = #blacklisted, 1, -1 do if blacklisted[i] == tgt.Name then table.remove(blacklisted, i) end end
        local content = readfile("Blacklisted.txt")
        local newContent = content:gsub(tgt.Name .. "\n", "")
        writefile("Blacklisted.txt", newContent)
        WindUI:Notify({Title="kohls+", Content=tgt.Name.." unbanned", Duration=3})
    end
end)
addcommand("unbl", "", function(args) commands["unban"](args) end)
addcommand("fpunish", "Fake punish a player", function(args) local target = args[1] if not target then return end for _, tgt in pairs(GetPlayers(target)) do if isWhitelisted(tgt) then WindUI:Notify({Title="kohls+", Content=tgt.Name.." is whitelisted, you can't touch him", Duration=3}) return end tchat("unff "..tgt.Name) tchat("freeze "..tgt.Name) tchat("invisible "..tgt.Name) end end)
addcommand("spam", "Spam a message", function(args) local msg = table.concat(args, " ") if msg == "" then return end if spamConnection then spamConnection:Disconnect() end spamConnection = game:GetService("RunService").Heartbeat:Connect(function() tchat(msg) end) WindUI:Notify({Title="kohls+", Content="Spam started: "..msg, Duration=2}) end)
addcommand("unspam", "Stop spamming", function() if spamConnection then spamConnection:Disconnect() spamConnection = nil end WindUI:Notify({Title="kohls+", Content="Spam stopped", Duration=2}) end)
addcommand("clearlogs", "Clear chat logs", function() for i=1,50 do local block = "ff ███████████████████████████████\n███████████████████████████████\n███████████████████████████████\n███████████████████████████████\n███████████████████████████████\n███████████████████████████████\n███████████████████████████████\n███████████████████████████████\n███████████████████████████████\n███████████████████████████████" tchat(block) wait() end end)
addcommand("fixfilter", "Fix chat filter", function() commands["bypassmessage"]({"filtercheck"}) end)
addcommand("bypassmessage", "Bypass chat filter", function(args) local msg = table.concat(args, " ") if msg == "" then return end local a = {} for letter in msg:gmatch(".") do if letter ~= "\r" and letter ~= "\n" then table.insert(a, letter) end end for b, c in ipairs(a) do local e = string.rep("  ", 2*(b-1)) tchat("h the\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"..e..c) end end)
addcommand("cage", "Cage a player", function(args)
    local target = args[1] if not target then return end
    for _, tgt in pairs(GetPlayers(target)) do
        if isWhitelisted(tgt) then WindUI:Notify({Title="kohls+", Content=tgt.Name.." is whitelisted, you can't touch him", Duration=3}) return end
        local prev = antifreeze antifreeze = false
        spawn(function()
            _G.cagecheck = false tchat("gear me 000000000000000000000000000000000000000000082357101") repeat task.wait() until plr.Backpack:FindFirstChild('PortableJustice') plr.Backpack.PortableJustice.Parent = plr.Character repeat task.wait() until game.Workspace[plr.Name].PortableJustice:FindFirstChild('MouseClick') local oldpos = plr.Character.HumanoidRootPart.CFrame plr.Character.HumanoidRootPart.CFrame = tgt.Character.HumanoidRootPart.CFrame tchat('unff '..tgt.Name) repeat coroutine.wrap(function() game.Workspace[plr.Name].PortableJustice.MouseClick:FireServer(game.Workspace[tgt.Name]) end)() task.wait() until tgt.Character:FindFirstChild('DisableBackpack') pcall(function() game.Workspace[plr.Name]["PortableJustice"]:Destroy() end) _G.cagecheck = false plr.Character.HumanoidRootPart.CFrame = oldpos antifreeze = prev
        end)
    end
end)
addcommand("loopcage", "Loop cage a player", function(args) local target = args[1] if not target then return end for _, tgt in pairs(GetPlayers(target)) do if isWhitelisted(tgt) then WindUI:Notify({Title="kohls+", Content=tgt.Name.." is whitelisted, you can't touch him", Duration=3}) return end if cageLoops[tgt.Name] then return end cageLoops[tgt.Name] = true spawn(function() while cageLoops[tgt.Name] do commands["cage"]({tgt.Name}) tgt.CharacterAdded:Wait() wait(0.5) end end) end end)
addcommand("unloopcage", "Stop loop caging", function(args) local target = args[1] if not target then return end for _, tgt in pairs(GetPlayers(target)) do cageLoops[tgt.Name] = nil end end)
addcommand("gearbl", "Gear ban a player", function(args)
    local xplayer = args[1] if not xplayer then return end
    local xplr = GetPlayers(xplayer)[1]
    if not xplr then return end
    tchat("gear me 000000000000000000000000000000000000000000082357101")
    tchat("unff "..xplayer)
    tchat("speed "..xplayer.." 0")
    tchat("unfly "..xplayer)
    local pos = plr.Character.HumanoidRootPart.CFrame
    plr.Character.HumanoidRootPart.CFrame = xplr.Character.HumanoidRootPart.CFrame
    local cappy = xplr.Character
    repeat task.wait() until plr.Backpack:FindFirstChild("PortableJustice")
    local tool = plr.Backpack:FindFirstChild("PortableJustice")
    tool.Parent = plr.Character
    tool.MouseClick:FireServer(cappy)
    task.wait(1)
    tchat("reload "..xplayer)
    tchat("h \n\n\n\n\n " .. xplayer .. " got gearbanned! \n\n\n\n\n")
    tool:Destroy()
    plr.Character.HumanoidRootPart.CFrame = pos
    tchat("ungear me")
end)
addcommand("ungearbl", "Remove gear ban", function(args)
    local target = args[1] if not target then return end
    for _, tgt in pairs(GetPlayers(target)) do
        if isWhitelisted(tgt) then WindUI:Notify({Title="kohls+", Content=tgt.Name.." is whitelisted, you can't touch him", Duration=3}) return end
        local prev = antifreeze antifreeze = false
        spawn(function()
            tchat("ungear me") tchat("tp " .. tgt.Name .. " me") tchat("speed " .. tgt.Name .. " 0") task.wait(0.5) tchat("gear me 0000000000000000000000000000000000000000000071037101") repeat task.wait() until plr.Backpack:FindFirstChild("DaggerOfShatteredDimensions") local ungear = plr.Backpack:FindFirstChild("DaggerOfShatteredDimensions") task.wait() ungear.Parent = plr.Character task.wait(0.5) plr.Character.DaggerOfShatteredDimensions.Remote:FireServer(Enum.KeyCode.Q) task.wait(0.5) tchat("ungear me") tchat("speed " .. tgt.Name .. " 16") antifreeze = prev
        end)
    end
end)
addcommand("fixvel", "Fix velocity of map parts", function() pcall(function() local Workspace_Folder = workspace.Terrain["GameFolder"].Workspace local Admin_Folder = workspace.Terrain["GameFolder"].Admin Workspace_Folder.Baseplate.Velocity = Vector3.new(0,0,0) Workspace_Folder.Baseplate.RotVelocity = Vector3.new(0,0,0) for _, v in ipairs(Workspace_Folder["Basic House"]:GetChildren()) do v.Velocity = Vector3.new(0,0,0) v.RotVelocity = Vector3.new(0,0,0) end for _, v in ipairs(Workspace_Folder["Obby"]:GetChildren()) do v.Velocity = Vector3.new(0,0,0) v.RotVelocity = Vector3.new(0,0,0) end for _, v in ipairs(Workspace_Folder["Admin Dividers"]:GetChildren()) do v.Velocity = Vector3.new(0,0,0) v.RotVelocity = Vector3.new(0,0,0) end for _, v in ipairs(Workspace_Folder["Obby Box"]:GetChildren()) do v.Velocity = Vector3.new(0,0,0) v.RotVelocity = Vector3.new(0,0,0) end for _, v in ipairs(Workspace_Folder["Building Bricks"]:GetChildren()) do v.Velocity = Vector3.new(0,0,0) v.RotVelocity = Vector3.new(0,0,0) end Admin_Folder.Regen.Velocity = Vector3.new(0,0,0) Admin_Folder.Regen.RotVelocity = Vector3.new(0,0,0) for _, v in ipairs(Admin_Folder.Pads:GetDescendants()) do if v.Name == "Head" then v.Velocity = Vector3.new(0,0,0) v.RotVelocity = Vector3.new(0,0,0) end end end) WindUI:Notify({Title="kohls+", Content="Velocity fixed!", Duration=2}) end)
addcommand("regen", "Click regen button", function() local regen = Admin and Admin:FindFirstChild("Regen") if regen and regen:FindFirstChild("ClickDetector") then fireclickdetector(regen.ClickDetector) WindUI:Notify({Title="kohls+", Content="Regen clicked", Duration=2}) end end)
addcommand("fixregen", "Move regen to spawn", function()
    local regen = Admin and Admin:FindFirstChild("Regen")
    if regen then
        regen.CFrame = CFrame.new(-7.16500044, 5.42999268, 91.7430038) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(-90))
        WindUI:Notify({Title="kohls+", Content="Regen moved to default position", Duration=2})
    end
end)
addcommand("tptoregen", "Teleport to regen", function() local regen = Admin and Admin:FindFirstChild("Regen") if regen and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then plr.Character.HumanoidRootPart.CFrame = regen.CFrame * CFrame.new(0, 2.5, 0) end end)
addcommand("rmoveregen", "Remove regen", function() local regen = Admin and Admin:FindFirstChild("Regen") if regen and regen.CFrame.Y < 500 then spawn(function() local chr = plr.Character if not chr or not chr:FindFirstChild("Humanoid") then return end local cf = chr.HumanoidRootPart local looping = true spawn(function() while true do game:GetService("RunService").Heartbeat:Wait() pcall(function() chr.Humanoid:ChangeState(11) cf.CFrame = regen.CFrame * CFrame.new(-(regen.Size.X/2)-(chr.Torso.Size.X/2),0,0) end) if not looping then break end end end) spawn(function() while looping do wait(0.1) tchat("unpunish me") end end) wait(0.3) looping = false tchat("trip me") wait(0.2) tchat("respawn me") end) else WindUI:Notify({Title="kohls+", Content="Regen already moved or not found", Duration=2}) end end)
addcommand("deletetool", "Get delete tool", function() local btool = Instance.new("Tool", plr.Backpack) local SelectionBox = Instance.new("SelectionBox", workspace) local hammer = Instance.new("Part") hammer.Parent = btool hammer.Name = "Handle" hammer.CanCollide = false hammer.Anchored = false SelectionBox.Name = "oof" SelectionBox.LineThickness = 0.05 SelectionBox.Adornee = nil SelectionBox.Color3 = Color3.fromRGB(0,0,255) SelectionBox.Visible = false btool.Name = "Delete Tool" btool.RequiresHandle = false local IsEquipped = false local Mouse = plr:GetMouse() btool.Equipped:Connect(function() IsEquipped = true SelectionBox.Visible = true SelectionBox.Adornee = nil end) btool.Unequipped:Connect(function() IsEquipped = false SelectionBox.Visible = false SelectionBox.Adornee = nil end) btool.Activated:Connect(function() if IsEquipped then btool.Parent = game.Chat local ex = Instance.new("Explosion") ex.BlastRadius = 0 ex.Position = Mouse.Target.Position ex.Parent = workspace local prevcfarchive = plr.Character.HumanoidRootPart.CFrame local target = Mouse.Target local function movepart() local cf = plr.Character.HumanoidRootPart local looping = true spawn(function() while true do game:GetService("RunService").Heartbeat:Wait() pcall(function() plr.Character.Humanoid:ChangeState(11) cf.CFrame = target.CFrame * CFrame.new(-(target.Size.X/2)-(plr.Character.Torso.Size.X/2),0,0) end) if not looping then break end end end) spawn(function() while looping do wait(0.1) tchat("unpunish me") end end) wait(0.25) looping = false end movepart() repeat wait() until plr.Character.Torso:FindFirstChild("Weld") tchat("skydive me") wait(0.1) tchat("respawn me") wait(0.25) game.Chat["Delete Tool"].Parent = plr.Backpack plr.Character.HumanoidRootPart.CFrame = prevcfarchive spawn(function() wait(3) if game.Chat:FindFirstChild("Delete Tool") then game.Chat["Delete Tool"]:Destroy() end end) end end) WindUI:Notify({Title="kohls+", Content="Delete Tool added to backpack", Duration=2}) end)

local function transferHotPotato(player)
    for _=1,3 do
        tchat("gear me 000000000000000000000000000000000000000000025741198")
        repeat task.wait() until plr.Backpack:FindFirstChild("HotPotato")
        local potato = plr.Backpack.HotPotato
        potato.Parent = plr.Character
        potato:Activate()
        spawn(function()
            while potato.Parent == plr.Character do
                task.wait()
                pcall(function()
                    firetouchinterest(potato:WaitForChild("Handle"), player.Character.Torso, 0)
                    firetouchinterest(potato:WaitForChild("Handle"), player.Character.Torso, 1)
                    firetouchinterest(potato:WaitForChild("Handle"), player.Character.Torso, 0)
                    firetouchinterest(potato:WaitForChild("Handle"), player.Character.Torso, 1)
                end)
            end
        end)
    end
end

addcommand("kick", "Hot potato kick", function(args)
    local target = args[1] if not target then return end
    for _, tgt in pairs(GetPlayers(target)) do
        if isWhitelisted(tgt) then WindUI:Notify({Title="Kohls+", Content=tgt.Name.." is whitelisted, you can't touch him", Duration=3}) return end
        local prev = antifreeze antifreeze = false
        spawn(function()
            tchat("unff me") tchat("ff me") tchat("ff " .. tgt.Name) tchat("blind " .. tgt.Name) tchat("size " .. tgt.Name .. " nan")
            task.wait(0.2)
            tchat("freeze " .. tgt.Name)
            transferHotPotato(tgt)
            task.wait(1.5)
            tchat("reset " .. tgt.Name)
            task.wait(0.6)
            tchat("rainbowify " .. tgt.Name) tchat("ff " .. tgt.Name) tchat("god " .. tgt.Name)
            tchat("name " .. tgt.Name .. " [Kohls+]\nKicked by hot potato, " .. plr.DisplayName .. "\n" .. tgt.DisplayName)
            recentlyKicked[tgt.Name] = true
            antifreeze = prev
        end)
    end
end)

addcommand("kid", "Make a player small with a candy", function(args)
    local target = args[1] if not target then return end
    for _, tgt in pairs(GetPlayers(target)) do
        if isWhitelisted(tgt) then WindUI:Notify({Title="kohls+", Content=tgt.Name.." is whitelisted, you can't touch him", Duration=3}) return end
        local prev = antifreeze antifreeze = false
        spawn(function() tchat("size " .. tgt.Name .. " 0.5") tchat("gear " .. tgt.Name .. " candy") tchat("name " .. tgt.Name .. " Good Kid") antifreeze = prev end)
    end
end)

addcommand("nocam", "Break camera (shiftlock)", function()
    tchat("gear me 000000000000000000000000000000000000000004842207161")
    repeat task.wait() until plr.Backpack:FindFirstChild("AR")
    local cambrek = plr.Backpack:FindFirstChild("AR")
    cambrek.Parent = plr.Character
    task.wait(0.2)
    cambrek:Activate()
    WindUI:Notify({Title="kohls+", Content="The camera is now broken into shiftlock - you won't see the effect until you rejoin.", Duration=5})
end)

addcommand("fcam", "Break a player's camera", function(args)
    local target = args[1] if not target then return end
    local cplr = GetPlayers(target)[1]
    if not cplr then return end
    if not firetouchinterest then WindUI:Notify({Title="kohls+", Content="firetouchinterest not supported", Duration=3}) return end
    plr.Character.HumanoidRootPart.CFrame = CFrame.new(99999,99999,99999)
    local instancechina = Instance.new("Part", plr.Character)
    instancechina.Anchored = true
    instancechina.Size = Vector3.new(10,1,10)
    instancechina.CFrame = plr.Character.HumanoidRootPart.CFrame * CFrame.new(0,-5,0)
    tchat("gear me 000000000000000000000000000000000000000000094794847")
    repeat task.wait() until plr.Backpack:FindFirstChild("VampireVanquisher")
    local VampireVanquisher = plr.Backpack:FindFirstChild("VampireVanquisher")
    VampireVanquisher.Parent = plr.Character
    repeat task.wait() until not plr.Character.VampireVanquisher:FindFirstChild("Coffin")
    repeat
        task.wait()
        firetouchinterest(VampireVanquisher.Handle, cplr.Character.Head, 0)
        firetouchinterest(VampireVanquisher.Handle, cplr.Character.Head, 1)
    until plr:DistanceFromCharacter(cplr.Character.Head.Position) < 10
    tchat("respawn me")
end)

addcommand("fixcam", "Fix camera for a player", function(args)
    local target = args[1] if not target then return end
    tchat("reset " .. target)
    WindUI:Notify({Title="kohls+", Content="Sent reset to "..target, Duration=2})
end)

addcommand("weld", "Weld player (mode: hold, right arm, left arm, torso)", function(args)
    local welder = args[1]
    local mode = args[2] or "hold"
    if not welder then return end
    local wld = GetPlayers(welder)[1]
    if not wld then return end
    tchat("speed "..welder.." 0")
    tchat("freeze "..welder)
    tchat("unfreeze "..welder)
    repeat wait() until wld.Character:FindFirstChild("ice")
    wld.Character.ice:Destroy()
    tchat("gear me 000000000000000000000000000000000000000000074385399")
    repeat wait() until plr.Backpack:FindFirstChild("RemoteExplosiveDetonator")
    local Detonator = plr.Backpack:FindFirstChild("RemoteExplosiveDetonator")
    Detonator.Parent = plr.Character
    if mode == "right arm" then
        plr.Character.HumanoidRootPart.CFrame = wld.Character.HumanoidRootPart.CFrame*CFrame.new(0,0,1.5)
    elseif mode == "left arm" then
        plr.Character.HumanoidRootPart.CFrame = wld.Character.HumanoidRootPart.CFrame*CFrame.new(-2.5,0,1.5)
    elseif mode == "torso" then
        plr.Character.HumanoidRootPart.CFrame = wld.Character.HumanoidRootPart.CFrame*CFrame.new(-1.5,0,1.5)
    elseif mode == "hold" then
        plr.Character.HumanoidRootPart.CFrame = wld.Character.HumanoidRootPart.CFrame*CFrame.new(-0.5,0,1.5)
    else
        plr.Character.HumanoidRootPart.CFrame = wld.Character.HumanoidRootPart.CFrame*CFrame.new(-0.5,0,1.5)
    end
    wait(0.2)
    Detonator.RemoteEvent:FireServer("Activate", wld.Character.HumanoidRootPart.Position)
    wait(0.3)
    if mode == "hold" then
        Detonator:Destroy()
        tchat("ungear me"); task.wait(0.1)
        tchat("gear me 000000000000000000000000000000000000000000022787248")
        repeat wait() until plr.Backpack:FindFirstChild("Watermelon")
        local wat = plr.Backpack:FindFirstChild("Watermelon")
        wat.Parent = plr.Character
    end
end)

-- slag (2 камня) и slag2 (4 камня)
local function stoneMapLogic(count)
    tchat("ungear me")
    task.wait(0.5)
    for _=1,count do
        tchat("gear me 000000000000000000000000000000000000000000059190534")
        task.wait(0.05)
    end
    repeat task.wait() until #plr.Backpack:GetChildren() >= count
    task.wait(0.1)
    local stones = {}
    for i=1,count do
        local stone = plr.Backpack:GetChildren()[i]
        stone.Parent = plr.Character
        table.insert(stones, stone)
    end
    task.wait(0.1)
    for _, stone in ipairs(stones) do
        spawn(function()
            stone.ServerControl:InvokeServer("KeyPress", {["Key"] = "x", ["Down"] = true})
        end)
    end
end

addcommand("slag", "Server lag (2 stones)", function() stoneMapLogic(2) end)
addcommand("slag2", "Server lag (4 stones)", function() stoneMapLogic(4) end)
addcommand("serverlag", "Server lag (2 stones)", function() stoneMapLogic(2) end)

-- joinppl (аватарный поиск)
addcommand("joinppl", "Join a player's server (by username or userId)", function(args)
    local target = args[1]
    if not target then return end
    WindUI:Notify({Title="kohls+", Content="Joining may cause lag while searching servers", Duration=5})

    local function HttpGet(url) return game:HttpGet(url) end
    local function HttpPost(url, data, headers) return game:HttpPost(url, data, headers or {}) end

    local function joinPlayer(plrID)
        local userID = plrID
        local gameID = tostring(game.PlaceId)
        local httpService = HS
        local cursor = nil

        local success, response = pcall(function()
            local url = string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Desc&limit=100", gameID)
            if cursor then url = url .. "&cursor=" .. cursor end
            local serverResponse = HttpGet(url)
            local serverJson = httpService:JSONDecode(serverResponse)
            cursor = serverJson.nextPageCursor
            local serverData = serverJson

            local avatarResponse = HttpGet("https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds="..userID.."&size=150x150&format=Png&isCircular=false")
            local avatarJson = httpService:JSONDecode(avatarResponse)
            local playerImageURL = avatarJson.data[1].imageUrl

            for _, server in ipairs(serverData.data) do
                local playerIcons = {}
                for i = 1, #server.playerTokens do
                    table.insert(playerIcons, {
                        token = server.playerTokens[i],
                        type = "AvatarHeadshot",
                        size = "150x150",
                        requestId = server.id
                    })
                end
                local postResponse = HttpPost("https://thumbnails.roblox.com/v1/batch", httpService:JSONEncode(playerIcons), {["Content-Type"] = "application/json"})
                local recvData = httpService:JSONDecode(postResponse).data
                if recvData then
                    for _, v in ipairs(recvData) do
                        if v.imageUrl == playerImageURL then
                            TS:TeleportToPlaceInstance(gameID, v.requestId)
                            return
                        end
                    end
                end
            end
        end)
        if not success then
            WindUI:Notify({Title="kohls+", Content="Failed to fetch servers, retrying...", Duration=3})
            task.wait(5)
            joinPlayer(plrID)
        end
    end

    local userId = tonumber(target)
    if not userId then
        local userResponse = HttpGet("https://api.roblox.com/users/get-by-username?username=" .. HS:UrlEncode(target))
        local userData = HS:JSONDecode(userResponse)
        if userData and userData.Id then
            userId = userData.Id
        else
            WindUI:Notify({Title="kohls+", Content="Player not found", Duration=3})
            return
        end
    end
    joinPlayer(userId)
end)

addcommand("r15", "Switch to R15", function()
    tchat("!experiment adaptiver6 on")
    task.wait(2)
    tchat("unchar me")
end)
addcommand("r6", "Switch to R6", function()
    tchat("!experiment adaptiver6 off")
end)

addcommand("nomusic", "Force stop all music", function()
    antimusic = true
    tchat("music")
    if Folder then
        Folder.ChildAdded:Connect(function(s)
            if s:IsA("Sound") and antimusic then
                tchat("stop")
            end
        end)
    end
    boxcmd = plr.Chatted:Connect(function(cmd)
        if cmd:sub(1, 5) == 'music' then
            local id = cmd:split(" ")
            local args = {
                [1] = "PlaySong",
                [2] = tonumber(id[2])
            }
            if plr.Character:FindFirstChild("SuperFlyGoldBoombox") then
                plr.Character.SuperFlyGoldBoombox.Remote:FireServer(unpack(args))
            end
        end
    end)
end)

addcommand("resmusic", "Resume normal music", function()
    antimusic = false
    if boxcmd then
        boxcmd:Disconnect()
        boxcmd = nil
    end
end)

addcommand("ping", "Show ping", function() local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5) tchat("Ping is " .. ping .. "ms.") end)
addcommand("jerk", "You know", function() local humanoid = plr.Character and plr.Character:FindFirstChildWhichIsA("Humanoid") local backpack = plr.Backpack if not humanoid or not backpack then return end local tool = Instance.new("Tool") tool.Name = "Jerk Off" tool.RequiresHandle = false tool.Parent = backpack local jorkin = false local track = nil local function stopTomfoolery() jorkin = false if track then track:Stop() track = nil end end tool.Equipped:Connect(function() jorkin = true end) tool.Unequipped:Connect(stopTomfoolery) humanoid.Died:Connect(stopTomfoolery) spawn(function() while task.wait() do if not jorkin then continue end local isR15 = humanoid.RigType == Enum.HumanoidRigType.R15 if not track then local anim = Instance.new("Animation") anim.AnimationId = not isR15 and "rbxassetid://72042024" or "rbxassetid://698251653" track = humanoid:LoadAnimation(anim) end track:Play() track:AdjustSpeed(isR15 and 0.7 or 0.65) track.TimePosition = 0.6 task.wait(0.1) while track and track.TimePosition < (not isR15 and 0.65 or 0.7) do task.wait(0.1) end if track then track:Stop() track = nil end end end) end)
addcommand("bang", "Bang animation on a player", function(args) local target = args[1] local humanoid = plr.Character and plr.Character:FindFirstChildWhichIsA("Humanoid") if not humanoid then return end if bangAnim and bang then bang:Stop() bangAnim:Destroy() end bangAnim = Instance.new("Animation") bangAnim.AnimationId = humanoid.RigType == Enum.HumanoidRigType.R15 and "rbxassetid://5918726674" or "rbxassetid://148840371" bang = humanoid:LoadAnimation(bangAnim) bang:Play(0.1, 1, 1) bang:AdjustSpeed(3) bangDied = humanoid.Died:Connect(function() bang:Stop() bangAnim:Destroy() bangDied:Disconnect() if bangLoop then bangLoop:Disconnect() end end) if target then local players = GetPlayers(target) for _, v in ipairs(players) do local other = v.Character if other and other:FindFirstChild("Torso") then local otherRoot = other.Torso bangLoop = game:GetService("RunService").Stepped:Connect(function() pcall(function() plr.Character.HumanoidRootPart.CFrame = otherRoot.CFrame * CFrame.new(0, 0, 1.1) end) end) break end end end end)
addcommand("unbang", "Stop bang animation", function() if bangDied then bangDied:Disconnect() end if bang then bang:Stop() bang = nil end if bangAnim then bangAnim:Destroy() bangAnim = nil end if bangLoop then bangLoop:Disconnect() bangLoop = nil end end)
addcommand("rejoin", "Rejoin the server", function() TS:TeleportToPlaceInstance(game.PlaceId, game.JobId, plr) end)
addcommand("rj", "", function() commands["rejoin"]({}) end)
addcommand("serverhop", "Hop to another server", function() local success, result = pcall(function() return game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100") end) if not success then WindUI:Notify({Title="kohls+", Content="Failed to fetch servers", Duration=3}) return end local servers = HS:JSONDecode(result) local goodServers = {} for _, server in ipairs(servers.data) do if server.playing < server.maxPlayers then table.insert(goodServers, server) end end if #goodServers > 0 then local targetServer = goodServers[math.random(1, #goodServers)] TS:TeleportToPlaceInstance(game.PlaceId, targetServer.id, plr) else WindUI:Notify({Title="kohls+", Content="No available servers", Duration=3}) end end)
addcommand("shop", "", function() commands["serverhop"]({}) end)
