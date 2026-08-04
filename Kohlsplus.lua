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

local function tchat(msg) __sayRequest:FireServer(msg, "System") end
local function chat(msg) __sayRequest:FireServer(msg, "All") end
local commands = {}

function addcommand(name, desc, func) commands[name:lower()] = func end

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
local whitelist = {
    "Simonko_30", "EgorYa900", "nowhudhejeir", "2spinthelegend",
    "DVZYNFFVJNG", "2spintheIegend", "monssro90", "FFVRVGV",
    "3spinthelegend", "MONSTRO0060", "ngyckd82", "monsr20",
    "FGTVNUGVFHNJKGVFJHN", "1love2dadw1", "EgorYa900Alt"
}
local ownerName = "nowhudhejeir"

if not isfile or not readfile or not writefile then
    isfile = function() return false end; readfile = function() return "" end; writefile = function() end
end
if not appendfile then
    appendfile = function(f, d) local o = (isfile(f) and readfile(f)) or ""; writefile(f, o .. d) end
end
if isfile("Blacklisted.txt") then
    for _, name in ipairs(readfile("Blacklisted.txt"):split("\n")) do if name ~= "" then table.insert(blacklisted, name) end end
else
    writefile("Blacklisted.txt", "agspureiam\n"); table.insert(blacklisted, "agspureiam")
end

local Terrain = workspace:FindFirstChild("Terrain") or workspace:FindFirstChild("terrain")
local GameFolder = Terrain and (Terrain:FindFirstChild("_Game") or Terrain:FindFirstChild("GameFolder"))
local Admin = GameFolder and GameFolder:FindFirstChild("Admin")
local Pads = Admin and Admin:FindFirstChild("Pads")
local Folder = GameFolder and GameFolder:FindFirstChild("Folder")
local myjail = plr.Name .. "'s jail"
local safeTools = {["Building Tools"] = true, ["Delete Tool"] = true}

local antipunish = false
local antijail = false
local _G_antifreeze = false
local antikill = false
local antifling = false
local antiblind = false
local guis = false
local antisize = false
local antiBanHammer = false
local antikillRunning = false
local antiflingRunning = false
local antijailRunning = false
local Loops = {
    antikick = false,
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
local permNotified = false
local nokillEnabled = false

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

plr.Backpack.ChildAdded:Connect(function(child)
    if Loops.antikick and child:IsA("Tool") and not safeTools[child.Name] then
        child:Destroy()
        tchat("removetools me")
    end
end)
plr.CharacterAdded:Connect(function(chr)
    chr.ChildAdded:Connect(function(child)
        if Loops.antikick and child:IsA("Tool") and not safeTools[child.Name] then
            child:Destroy()
            tchat("removetools me")
        end
    end)
end)

plr.CharacterAdded:Connect(function(chr)
    if autoGod then tchat("god me") tchat("health me inf") tchat("loopheal me") end
    chr.ChildAdded:Connect(function(ch)
        if antifling and ch.Name == "BFRC" and ch:IsDescendantOf(workspace:WaitForChild(plr.Name)) then
            local hum = chr:FindFirstChild("Humanoid") if hum then hum.Sit = false end
            local torso = chr:FindFirstChild("Torso") if torso then torso.AssemblyLinearVelocity = Vector3.new(0,0,0) end
            game:GetService("RunService").Heartbeat:Wait()
            pcall(function() ch:Destroy() end)
            if torso then torso.AssemblyLinearVelocity = Vector3.new(0,0,0) end
        end
        if _G_antifreeze and ch.Name == "ice" then
            pcall(function() ch:Destroy() end)
            for _, d in ipairs(chr:GetDescendants()) do if d:IsA("BasePart") then d.Anchored = false end end
            tchat("unfreeze me")
        end
    end)
end)

spawn(function()
    while true do
        if Loops.antikick then
            pcall(function()
                local chr = plr.Character
                if chr then for _, obj in ipairs(chr:GetChildren()) do if obj:IsA("Tool") and not safeTools[obj.Name] then obj:Destroy() tchat("removetools me") end end end
                if plr.Backpack then for _, obj in ipairs(plr.Backpack:GetChildren()) do if obj:IsA("Tool") and not safeTools[obj.Name] then obj:Destroy() tchat("removetools me") end end end
                for _, v in ipairs(workspace:GetDescendants()) do if v.Name == "Rocket" and v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end end
            end)
        end
        if Loops.antifly then pcall(function() if plr.PlayerGui:FindFirstChild("Fly") then plr.PlayerGui:FindFirstChild("Fly"):Destroy() local chr = plr.Character if chr and chr:FindFirstChild("Torso") then chr.Torso.Anchored = false end if chr and chr:FindFirstChild("Humanoid") then chr.Humanoid.PlatformStand = false end tchat("unfly me") end end) end
        if Loops.antivoid then pcall(function() local chr = plr.Character if chr and chr:FindFirstChild("HumanoidRootPart") then local r = chr.HumanoidRootPart if r.Position.Y < -7 then r.CFrame = CFrame.new(r.Position.X, 5, r.Position.Z) r.Velocity = Vector3.new(r.Velocity.X, 0, r.Velocity.Z) end end end) end
        if Loops.antiskydive then pcall(function() local chr = plr.Character if chr and chr:FindFirstChild("HumanoidRootPart") then local r = chr.HumanoidRootPart if r.Position.Y > 256 then r.CFrame = CFrame.new(r.Position.X, 5, r.Position.Z) r.Velocity = Vector3.new(r.Velocity.X, 0, r.Velocity.Z) end end end) end
        if Loops.antigrav then pcall(function() local chr = plr.Character if chr and chr:FindFirstChild("Torso") then local bf = chr.Torso:FindFirstChildOfClass("BodyForce") if bf then bf:Destroy() end end end) end
        if Loops.antiname then pcall(function() local chr = plr.Character if chr then local m = chr:FindFirstChildOfClass("Model") if m and #m:GetChildren() == 2 then tchat("unname me") m:Destroy() end end end) end
        if Loops.antitripmine then pcall(function() local tm = workspace:FindFirstChild("SubspaceTripmine") if tm then tm:Destroy() tchat("clr") end end) end
        if Loops.antieggbomb then pcall(function() local eb = workspace:FindFirstChild("EggBomb") if eb then eb:Destroy() tchat("clr") end end) end
        game:GetService("RunService").RenderStepped:Wait()
    end
end)

spawn(function()
    while task.wait(0.5) do
        if _G_antifreeze then for _, v in ipairs(Players:GetPlayers()) do if v ~= plr and v.Character and v.Character:FindFirstChild("ice") then tchat("thaw " .. v.Name) end end end
        if antisize and plr.Character and plr.Character:FindFirstChild("Torso") and plr.Character.Torso.Size.Y ~= 2 then tchat("unsize me") end
        if antiblind then
            local blind = plr.PlayerGui:FindFirstChild("EFFECTGUIBLIND") if blind then blind:Destroy() end
            local confirm = plr.PlayerGui:FindFirstChild("ConfirmationPrompt") if confirm then confirm:Destroy() end
        end
        if antiBanHammer then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= plr and p.Backpack and p.Backpack:FindFirstChild("BanHammer") then
                    tchat("ungear " .. p.Name)
                    tchat("h " .. p.Name .. " NICE TRYYYY")
                end
            end
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

local __commandsTab = Window:Tab({ Title = "Commands", Icon = "lucide:terminal" })
__commandsTab:Paragraph({
    Title = "Commands 1",
    Desc = "ban <player>\nunban <player>\nfpunish <player>\nkick <player>\nkid <player>\nspam <message>\nunspam\nclearlogs\nfixfilter\nbypassmessage <message>\ncage <player>\nloopcage <player>\nunloopcage <player>\ngearbl <player>\nungearbl <player>\nnokill\nunnokill"
})
__commandsTab:Paragraph({
    Title = "Commands 2",
    Desc = "fixvel\nloadregen <distance>\nregen\nfixregen\ntptoregen\nrmoveregen\ndeletetool\nmoveobby\nrmobby\njerk\nbang <player>\nunbang\nping\nrejoin (rj)\nserverhop (shop)\nfrespawn\nmrespawn"
})

local __mainTab = Window:Tab({ Title = "Main", Icon = "home" })
__mainTab:Toggle({ Title = "Auto Perm", Value = false, Callback = function(v) __permEnabled = v if v then __permLoop() else if __permCoroutine then task.cancel(__permCoroutine) end end end })
__mainTab:Toggle({ Title = "Auto God", Value = false, Callback = function(v) autoGod = v end })

local __toolsTab = Window:Tab({ Title = "Tools", Icon = "tool" })
__toolsTab:Button({ Title = "Load Regen", Callback = function() commands["loadregen"]({"100"}) end })
__toolsTab:Button({ Title = "Fix Regen", Callback = function() commands["fixregen"]({}) end })
__toolsTab:Button({ Title = "TP to Regen", Callback = function() commands["tptoregen"]({}) end })
__toolsTab:Button({ Title = "Rmove Regen", Callback = function() commands["rmoveregen"]({}) end })
__toolsTab:Button({ Title = "Delete Tool", Callback = function() commands["deletetool"]({}) end })
__toolsTab:Button({ Title = "Move Obby", Callback = function() commands["moveobby"]({}) end })

local __protectTab = Window:Tab({ Title = "Protection", Icon = "shield" })
__protectTab:Toggle({ Title = "Anti Punish", Value = false, Callback = function(v) antipunish = v end })
__protectTab:Toggle({ Title = "Anti Jail", Value = false, Callback = function(v)
    antijail = v
    if v and not antijailRunning then antijailRunning = true spawn(function() while antijail do if Folder and Folder:FindFirstChild(myjail) then Folder[myjail]:Destroy() tchat("unjail me") end game:GetService("RunService").RenderStepped:Wait() end antijailRunning = false end) end
end })
__protectTab:Toggle({ Title = "Anti Kill", Value = false, Callback = function(v)
    antikill = v
    if v and not antikillRunning then antikillRunning = true spawn(function() while antikill do local chr = plr.Character if chr and chr:FindFirstChild("Humanoid") and chr.Humanoid.Health <= 0 then tchat("reset me") task.wait(0.05) end game:GetService("RunService").RenderStepped:Wait() end antikillRunning = false end) end
end })
__protectTab:Toggle({ Title = "Anti Freeze", Value = false, Callback = function(v) _G_antifreeze = v end })
__protectTab:Toggle({ Title = "Anti Fling/Speed", Value = false, Callback = function(v)
    antifling = v
    if v and not antiflingRunning then antiflingRunning = true spawn(function() while antifling do local chr = plr.Character if chr and chr:FindFirstChild("HumanoidRootPart") then local r = chr.HumanoidRootPart local vel = r.Velocity if math.abs(vel.X) > 150 or math.abs(vel.Z) > 150 then r.Velocity = Vector3.new(0, vel.Y, 0) end end game:GetService("RunService").RenderStepped:Wait() end antiflingRunning = false end) end
end })
__protectTab:Toggle({ Title = "Anti Blind", Value = false, Callback = function(v) antiblind = v end })
__protectTab:Toggle({ Title = "Anti Screen Guis", Value = false, Callback = function(v) guis = v end })
__protectTab:Toggle({ Title = "Anti Size", Value = false, Callback = function(v) antisize = v end })
__protectTab:Toggle({ Title = "Anti Kick", Value = false, Callback = function(v) Loops.antikick = v end })
__protectTab:Toggle({ Title = "Anti Fly", Value = false, Callback = function(v) Loops.antifly = v end })
__protectTab:Toggle({ Title = "Anti Void", Value = false, Callback = function(v) Loops.antivoid = v end })
__protectTab:Toggle({ Title = "Anti Skydive", Value = false, Callback = function(v) Loops.antiskydive = v end })
__protectTab:Toggle({ Title = "Anti Grav", Value = false, Callback = function(v) Loops.antigrav = v end })
__protectTab:Toggle({ Title = "Anti Name", Value = false, Callback = function(v) Loops.antiname = v end })
__protectTab:Toggle({ Title = "Anti Tripmine", Value = false, Callback = function(v) Loops.antitripmine = v end })
__protectTab:Toggle({ Title = "Anti Eggbomb", Value = false, Callback = function(v) Loops.antieggbomb = v end })
__protectTab:Toggle({ Title = "Anti BanHammer", Value = false, Callback = function(v) antiBanHammer = v end })
__protectTab:Toggle({ Title = "No Kill (obby)", Value = false, Callback = function(v)
    nokillEnabled = v
    pcall(function() if GameFolder then local obby = GameFolder.Workspace.Obby if obby then for _, part in ipairs(obby:GetChildren()) do if part:IsA("BasePart") then part.CanTouch = not v end end end end end)
end })

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
        if shouldSend then local text = holyshidt11.Text if text ~= "" then executeCommand(text) chat(text) end end
    end)
end)

-- BL (ban) – только bring + kick, файл blacklist
addcommand("bl", "", function(args)
    local target = args[1] if not target then return end
    for _, tgt in pairs(GetPlayers(target)) do
        if isWhitelisted(tgt) then WindUI:Notify({Title="kohls+", Content=tgt.Name.." is whitelisted, you can't ban him", Duration=4}) return end
        appendfile("Blacklisted.txt", tgt.Name.."\n")
        table.insert(blacklisted, tgt.Name)
        chat("bring " .. tgt.Name)
        task.wait(0.5)
        executeCommand("kick " .. tgt.Name)
    end
end)
addcommand("ban", "", function(args) commands["bl"](args) end)

-- UNBAN (unbl) – удаляет из файла и из таблицы
addcommand("unban", "", function(args)
    local target = args[1] if not target then return end
    for _, tgt in pairs(GetPlayers(target)) do
        for i = #blacklisted, 1, -1 do
            if blacklisted[i] == tgt.Name then
                table.remove(blacklisted, i)
            end
        end
        local content = readfile("Blacklisted.txt")
        local newContent = content:gsub(tgt.Name .. "\n", "")
        writefile("Blacklisted.txt", newContent)
        WindUI:Notify({Title="kohls+", Content=tgt.Name.." unbanned", Duration=3})
    end
end)
addcommand("unbl", "", function(args) commands["unban"](args) end)

addcommand("fpunish", "", function(args) local target = args[1] if not target then return end for _, tgt in pairs(GetPlayers(target)) do if isWhitelisted(tgt) then WindUI:Notify({Title="kohls+", Content=tgt.Name.." is whitelisted, you can't touch him", Duration=3}) return end tchat("unff "..tgt.Name) tchat("freeze "..tgt.Name) tchat("invisible "..tgt.Name) end end)
addcommand("spam", "", function(args) local msg = table.concat(args, " ") if msg == "" then return end if spamConnection then spamConnection:Disconnect() end spamConnection = game:GetService("RunService").Heartbeat:Connect(function() tchat(msg) end) WindUI:Notify({Title="kohls+", Content="Spam started: "..msg, Duration=2}) end)
addcommand("unspam", "", function() if spamConnection then spamConnection:Disconnect() spamConnection = nil end WindUI:Notify({Title="kohls+", Content="Spam stopped", Duration=2}) end)
addcommand("clearlogs", "", function() for i=1,50 do local block = "ff ███████████████████████████████\n███████████████████████████████\n███████████████████████████████\n███████████████████████████████\n███████████████████████████████\n███████████████████████████████\n███████████████████████████████\n███████████████████████████████\n███████████████████████████████\n███████████████████████████████" tchat(block) wait() end end)
addcommand("fixfilter", "", function() commands["bypassmessage"]({"filtercheck"}) end)
addcommand("bypassmessage", "", function(args) local msg = table.concat(args, " ") if msg == "" then return end local a = {} for letter in msg:gmatch(".") do if letter ~= "\r" and letter ~= "\n" then table.insert(a, letter) end end for b, c in ipairs(a) do local e = string.rep("  ", 2*(b-1)) tchat("h the\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"..e..c) end end)
addcommand("cage", "", function(args)
    local target = args[1] if not target then return end
    for _, tgt in pairs(GetPlayers(target)) do
        if isWhitelisted(tgt) then WindUI:Notify({Title="kohls+", Content=tgt.Name.." is whitelisted, you can't touch him", Duration=3}) return end
        local prev = Loops.antikick Loops.antikick = false
        spawn(function()
            _G.cagecheck = false tchat("gear me 00000000000000000082357101") repeat task.wait() until plr.Backpack:FindFirstChild('PortableJustice') plr.Backpack.PortableJustice.Parent = plr.Character repeat task.wait() until game.Workspace[plr.Name].PortableJustice:FindFirstChild('MouseClick') local oldpos = plr.Character.HumanoidRootPart.CFrame plr.Character.HumanoidRootPart.CFrame = tgt.Character.HumanoidRootPart.CFrame tchat('unff '..tgt.Name) repeat coroutine.wrap(function() game.Workspace[plr.Name].PortableJustice.MouseClick:FireServer(game.Workspace[tgt.Name]) end)() task.wait() until tgt.Character:FindFirstChild('DisableBackpack') pcall(function() game.Workspace[plr.Name]["PortableJustice"]:Destroy() end) _G.cagecheck = false plr.Character.HumanoidRootPart.CFrame = oldpos Loops.antikick = prev
        end)
    end
end)
addcommand("loopcage", "", function(args) local target = args[1] if not target then return end for _, tgt in pairs(GetPlayers(target)) do if isWhitelisted(tgt) then WindUI:Notify({Title="kohls+", Content=tgt.Name.." is whitelisted, you can't touch him", Duration=3}) return end if cageLoops[tgt.Name] then return end cageLoops[tgt.Name] = true spawn(function() while cageLoops[tgt.Name] do commands["cage"]({tgt.Name}) tgt.CharacterAdded:Wait() wait(0.5) end end) end end)
addcommand("unloopcage", "", function(args) local target = args[1] if not target then return end for _, tgt in pairs(GetPlayers(target)) do cageLoops[tgt.Name] = nil end end)
addcommand("gearbl", "", function(args)
    local target = args[1] if not target then return end
    for _, tgt in pairs(GetPlayers(target)) do
        if isWhitelisted(tgt) then WindUI:Notify({Title="kohls+", Content=tgt.Name.." is whitelisted, you can't touch him", Duration=3}) return end
        local prev = Loops.antikick Loops.antikick = false
        spawn(function()
            _G.cagecheck = false tchat("gear me 00000000000000000082357101") repeat task.wait() until plr.Backpack:FindFirstChild('PortableJustice') plr.Backpack.PortableJustice.Parent = plr.Character repeat task.wait() until game.Workspace[plr.Name].PortableJustice:FindFirstChild('MouseClick') local oldpos = plr.Character.HumanoidRootPart.CFrame plr.Character.HumanoidRootPart.CFrame = tgt.Character.HumanoidRootPart.CFrame tchat('unff '..tgt.Name) repeat coroutine.wrap(function() game.Workspace[plr.Name].PortableJustice.MouseClick:FireServer(game.Workspace[tgt.Name]) end)() task.wait() until tgt.Character:FindFirstChild('DisableBackpack') coroutine.wrap(function() tchat('reset me') tchat('reset '..tgt.Name) _G.cagecheck = false tgt.CharacterAdded:Wait() tchat("get gearbanned lol "..tgt.Name) end)() plr.CharacterAdded:Wait() plr.Character.HumanoidRootPart.CFrame = oldpos Loops.antikick = prev
        end)
    end
end)
addcommand("ungearbl", "", function(args)
    local target = args[1] if not target then return end
    for _, tgt in pairs(GetPlayers(target)) do
        if isWhitelisted(tgt) then WindUI:Notify({Title="kohls+", Content=tgt.Name.." is whitelisted, you can't touch him", Duration=3}) return end
        local prev = Loops.antikick Loops.antikick = false
        spawn(function()
            tchat("ungear me") tchat("tp " .. tgt.Name .. " me") tchat("speed " .. tgt.Name .. " 0") task.wait(0.5) tchat("gear me 71037101") repeat task.wait() until plr.Backpack:FindFirstChild("DaggerOfShatteredDimensions") local ungear = plr.Backpack:FindFirstChild("DaggerOfShatteredDimensions") task.wait() ungear.Parent = plr.Character task.wait(0.5) plr.Character.DaggerOfShatteredDimensions.Remote:FireServer(Enum.KeyCode.Q) task.wait(0.5) tchat("ungear me") tchat("speed " .. tgt.Name .. " 16") Loops.antikick = prev
        end)
    end
end)
addcommand("nokill", "", function() nokillEnabled = true pcall(function() local obby = GameFolder and GameFolder.Workspace.Obby if obby then for _, v in ipairs(obby:GetChildren()) do if v:IsA("BasePart") then v.CanTouch = false end end end end) WindUI:Notify({Title="kohls+", Content="No Kill enabled", Duration=2}) end)
addcommand("unnokill", "", function() nokillEnabled = false pcall(function() local obby = GameFolder and GameFolder.Workspace.Obby if obby then for _, v in ipairs(obby:GetChildren()) do if v:IsA("BasePart") then v.CanTouch = true end end end end) WindUI:Notify({Title="kohls+", Content="No Kill disabled", Duration=2}) end)
addcommand("fixvel", "", function() pcall(function() local Workspace_Folder = workspace.Terrain["GameFolder"].Workspace local Admin_Folder = workspace.Terrain["GameFolder"].Admin Workspace_Folder.Baseplate.Velocity = Vector3.new(0,0,0) Workspace_Folder.Baseplate.RotVelocity = Vector3.new(0,0,0) for _, v in ipairs(Workspace_Folder["Basic House"]:GetChildren()) do v.Velocity = Vector3.new(0,0,0) v.RotVelocity = Vector3.new(0,0,0) end for _, v in ipairs(Workspace_Folder["Obby"]:GetChildren()) do v.Velocity = Vector3.new(0,0,0) v.RotVelocity = Vector3.new(0,0,0) end for _, v in ipairs(Workspace_Folder["Admin Dividers"]:GetChildren()) do v.Velocity = Vector3.new(0,0,0) v.RotVelocity = Vector3.new(0,0,0) end for _, v in ipairs(Workspace_Folder["Obby Box"]:GetChildren()) do v.Velocity = Vector3.new(0,0,0) v.RotVelocity = Vector3.new(0,0,0) end for _, v in ipairs(Workspace_Folder["Building Bricks"]:GetChildren()) do v.Velocity = Vector3.new(0,0,0) v.RotVelocity = Vector3.new(0,0,0) end Admin_Folder.Regen.Velocity = Vector3.new(0,0,0) Admin_Folder.Regen.RotVelocity = Vector3.new(0,0,0) for _, v in ipairs(Admin_Folder.Pads:GetDescendants()) do if v.Name == "Head" then v.Velocity = Vector3.new(0,0,0) v.RotVelocity = Vector3.new(0,0,0) end end end) WindUI:Notify({Title="kohls+", Content="Velocity fixed!", Duration=2}) end)
addcommand("loadregen", "", function(args) local AlreadyChecked = {} local Range = 0 local streamingdistance = tonumber(args[1]) or 100 local RegenLoaded = false while not RegenLoaded do for Y = 0, Range do for X = -Range, Range do for Z = -Range, Range do if RegenLoaded then break end local cf = CFrame.new(X * streamingdistance, Y * streamingdistance, Z * streamingdistance) if not table.find(AlreadyChecked, cf) then table.insert(AlreadyChecked, cf) pcall(function() plr.Character.HumanoidRootPart.CFrame = cf end) game:GetService("RunService").RenderStepped:Wait() if Admin and Admin:FindFirstChild("Regen") then RegenLoaded = true WindUI:Notify({Title="kohls+", Content="Regen found!", Duration=3}) end end end end end if not RegenLoaded then Range = Range + 1 end end end)
addcommand("regen", "", function() local regen = Admin and Admin:FindFirstChild("Regen") if regen and regen:FindFirstChild("ClickDetector") then fireclickdetector(regen.ClickDetector) WindUI:Notify({Title="kohls+", Content="Regen clicked", Duration=2}) end end)
addcommand("fixregen", "", function() local regen = Admin and Admin:FindFirstChild("Regen") if regen and moveObject then moveObject(regen, CFrame.new(-7.16500044, 5.42999268, 91.7430038, 0, 0, -1, 0, 1, 0, 1, 0, 0)) WindUI:Notify({Title="kohls+", Content="Regen moved to default position", Duration=2}) end end)
addcommand("tptoregen", "", function() local regen = Admin and Admin:FindFirstChild("Regen") if regen and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then plr.Character.HumanoidRootPart.CFrame = regen.CFrame * CFrame.new(0, 2.5, 0) end end)
addcommand("rmoveregen", "", function() local regen = Admin and Admin:FindFirstChild("Regen") if regen and regen.CFrame.Y < 500 then spawn(function() local chr = plr.Character if not chr or not chr:FindFirstChild("Humanoid") then return end local cf = chr.HumanoidRootPart local looping = true spawn(function() while true do game:GetService("RunService").Heartbeat:Wait() pcall(function() chr.Humanoid:ChangeState(11) cf.CFrame = regen.CFrame * CFrame.new(-(regen.Size.X/2)-(chr.Torso.Size.X/2),0,0) end) if not looping then break end end end) spawn(function() while looping do wait(0.1) tchat("unpunish me") end end) wait(0.3) looping = false tchat("trip me") wait(0.2) tchat("respawn me") end) else WindUI:Notify({Title="kohls+", Content="Regen already moved or not found", Duration=2}) end end)
addcommand("deletetool", "", function() local btool = Instance.new("Tool", plr.Backpack) local SelectionBox = Instance.new("SelectionBox", workspace) local hammer = Instance.new("Part") hammer.Parent = btool hammer.Name = "Handle" hammer.CanCollide = false hammer.Anchored = false SelectionBox.Name = "oof" SelectionBox.LineThickness = 0.05 SelectionBox.Adornee = nil SelectionBox.Color3 = Color3.fromRGB(0,0,255) SelectionBox.Visible = false btool.Name = "Delete Tool" btool.RequiresHandle = false local IsEquipped = false local Mouse = plr:GetMouse() btool.Equipped:Connect(function() IsEquipped = true SelectionBox.Visible = true SelectionBox.Adornee = nil end) btool.Unequipped:Connect(function() IsEquipped = false SelectionBox.Visible = false SelectionBox.Adornee = nil end) btool.Activated:Connect(function() if IsEquipped then btool.Parent = game.Chat local ex = Instance.new("Explosion") ex.BlastRadius = 0 ex.Position = Mouse.Target.Position ex.Parent = workspace local prevcfarchive = plr.Character.HumanoidRootPart.CFrame local target = Mouse.Target local function movepart() local cf = plr.Character.HumanoidRootPart local looping = true spawn(function() while true do game:GetService("RunService").Heartbeat:Wait() pcall(function() plr.Character.Humanoid:ChangeState(11) cf.CFrame = target.CFrame * CFrame.new(-(target.Size.X/2)-(plr.Character.Torso.Size.X/2),0,0) end) if not looping then break end end end) spawn(function() while looping do wait(0.1) tchat("unpunish me") end end) wait(0.25) looping = false end movepart() repeat wait() until plr.Character.Torso:FindFirstChild("Weld") tchat("skydive me") wait(0.1) tchat("respawn me") wait(0.25) game.Chat["Delete Tool"].Parent = plr.Backpack plr.Character.HumanoidRootPart.CFrame = prevcfarchive spawn(function() wait(3) if game.Chat:FindFirstChild("Delete Tool") then game.Chat["Delete Tool"]:Destroy() end end) end end) WindUI:Notify({Title="kohls+", Content="Delete Tool added to backpack", Duration=2}) end)

local function transferHotPotato(player)
    for _ = 1, 4 do
        tchat("gear me 000000000000000000000000000000000000000000000000000000000000025741198")
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

addcommand("kick", "", function(args)
    local target = args[1] if not target then return end
    for _, tgt in pairs(GetPlayers(target)) do
        if isWhitelisted(tgt) then WindUI:Notify({Title="Kohls+", Content=tgt.Name.." is whitelisted, you can't touch him", Duration=3}) return end
        local prev = Loops.antikick
        Loops.antikick = false
        spawn(function()
            tchat("unff me")
            tchat("ff me")
            tchat("ff " .. tgt.Name)
            tchat("blind " .. tgt.Name)
            tchat("size " .. tgt.Name .. " nan")
            task.wait(0.2)
            tchat("freeze " .. tgt.Name)
            transferHotPotato(tgt)
            task.wait(1.5)
            Loops.antikick = prev
        end)
    end
end)

addcommand("kid", "", function(args)
    local target = args[1] if not target then return end
    for _, tgt in pairs(GetPlayers(target)) do
        if isWhitelisted(tgt) then WindUI:Notify({Title="kohls+", Content=tgt.Name.." is whitelisted, you can't touch him", Duration=3}) return end
        local prev = Loops.antikick Loops.antikick = false
        spawn(function() tchat("size " .. tgt.Name .. " 0.5") tchat("gear " .. tgt.Name .. " candy") tchat("name " .. tgt.Name .. " Good Kid") Loops.antikick = prev end)
    end
end)

addcommand("moveobby", "", function(args) tchat("f3x") task.wait(1) local tool = plr.Backpack:FindFirstChild("Building Tools") if not tool then WindUI:Notify({Title="kohls+", Content="Building Tools not found!", Duration=3}) return end local Event = tool.SyncAPI.ServerEndpoint local obby = GameFolder.Workspace.Obby local obbyBox = GameFolder.Workspace["Obby Box"] local targetCF = CFrame.new(-41.065002441406, -15.699999809265, 6.7430019378662, 0, 0, -1, 0, 1, 0, 1, 0, 0) local parts = {} for _, v in ipairs(obby:GetChildren()) do if v:IsA("BasePart") then table.insert(parts, {Part = v, CFrame = targetCF}) end end table.insert(parts, {Pivot = targetCF, Model = obby}) for _, v in ipairs(obbyBox:GetChildren()) do if v:IsA("BasePart") then table.insert(parts, {Part = v, CFrame = CFrame.new(-41.064994812012, -41.499992370605, -30.756999969482, -1, 0, 0, 0, 1, 0, 0, 0, -1)}) end end table.insert(parts, {Pivot = CFrame.new(-30.065004348755, -31.535001754761, 35.34300994873, 1, 0, 0, 0, 1, 0, 0, 0, 1), Model = obbyBox}) Event:InvokeServer("SyncMove", parts) WindUI:Notify({Title="kohls+", Content="Obby moved!", Duration=2}) end)
addcommand("rmobby", "", function(args) commands["moveobby"](args) end)
addcommand("removeobby", "", function(args) commands["moveobby"](args) end)

addcommand("ping", "", function() local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5) tchat("Ping is " .. ping .. "ms.") end)
addcommand("jerk", "", function() local humanoid = plr.Character and plr.Character:FindFirstChildWhichIsA("Humanoid") local backpack = plr.Backpack if not humanoid or not backpack then return end local tool = Instance.new("Tool") tool.Name = "Jerk Off" tool.RequiresHandle = false tool.Parent = backpack local jorkin = false local track = nil local function stopTomfoolery() jorkin = false if track then track:Stop() track = nil end end tool.Equipped:Connect(function() jorkin = true end) tool.Unequipped:Connect(stopTomfoolery) humanoid.Died:Connect(stopTomfoolery) spawn(function() while task.wait() do if not jorkin then continue end local isR15 = humanoid.RigType == Enum.HumanoidRigType.R15 if not track then local anim = Instance.new("Animation") anim.AnimationId = not isR15 and "rbxassetid://72042024" or "rbxassetid://698251653" track = humanoid:LoadAnimation(anim) end track:Play() track:AdjustSpeed(isR15 and 0.7 or 0.65) track.TimePosition = 0.6 task.wait(0.1) while track and track.TimePosition < (not isR15 and 0.65 or 0.7) do task.wait(0.1) end if track then track:Stop() track = nil end end end) end)
addcommand("bang", "", function(args) local target = args[1] local humanoid = plr.Character and plr.Character:FindFirstChildWhichIsA("Humanoid") if not humanoid then return end if bangAnim and bang then bang:Stop() bangAnim:Destroy() end bangAnim = Instance.new("Animation") bangAnim.AnimationId = humanoid.RigType == Enum.HumanoidRigType.R15 and "rbxassetid://5918726674" or "rbxassetid://148840371" bang = humanoid:LoadAnimation(bangAnim) bang:Play(0.1, 1, 1) bang:AdjustSpeed(3) bangDied = humanoid.Died:Connect(function() bang:Stop() bangAnim:Destroy() bangDied:Disconnect() if bangLoop then bangLoop:Disconnect() end end) if target then local players = GetPlayers(target) for _, v in ipairs(players) do local other = v.Character if other and other:FindFirstChild("Torso") then local otherRoot = other.Torso bangLoop = game:GetService("RunService").Stepped:Connect(function() pcall(function() plr.Character.HumanoidRootPart.CFrame = otherRoot.CFrame * CFrame.new(0, 0, 1.1) end) end) break end end end end)
addcommand("unbang", "", function() if bangDied then bangDied:Disconnect() end if bang then bang:Stop() bang = nil end if bangAnim then bangAnim:Destroy() bangAnim = nil end if bangLoop then bangLoop:Disconnect() bangLoop = nil end end)
addcommand("rejoin", "", function() TS:TeleportToPlaceInstance(game.PlaceId, game.JobId, plr) end)
addcommand("rj", "", function() commands["rejoin"]({}) end)
addcommand("serverhop", "", function() local success, result = pcall(function() return game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100") end) if not success then WindUI:Notify({Title="kohls+", Content="Failed to fetch servers", Duration=3}) return end local servers = HS:JSONDecode(result) local goodServers = {} for _, server in ipairs(servers.data) do if server.playing < server.maxPlayers then table.insert(goodServers, server) end end if #goodServers > 0 then local targetServer = goodServers[math.random(1, #goodServers)] TS:TeleportToPlaceInstance(game.PlaceId, targetServer.id, plr) else WindUI:Notify({Title="kohls+", Content="No available servers", Duration=3}) end end)
addcommand("shop", "", function() commands["serverhop"]({}) end)
addcommand("frespawn", "", function() if plr.Character then plr.Character:Destroy() end end)
addcommand("mrespawn", "", function() local char = plr.Character if not char then return end if char:FindFirstChildOfClass("Humanoid") then char:FindFirstChildOfClass("Humanoid"):ChangeState(15) end char:ClearAllChildren() local newChar = Instance.new("Model") newChar.Parent = workspace plr.Character = newChar wait() plr.Character = char newChar:Destroy() end)
