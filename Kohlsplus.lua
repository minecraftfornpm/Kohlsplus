local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
local _G = getfenv() or _ENV or {}
local __game = game
local __players = __game:GetService("Players")
local __player = __players.LocalPlayer
local __replicated = __game:GetService("ReplicatedStorage")
local __sayRequest = __replicated:WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest")
local __http = game:GetService("HttpService")
local __runService = game:GetService("RunService")
local __textChatService = game:GetService("TextChatService")

local function __send(msg)
    __sayRequest:FireServer(msg, "System")
end

local function __sendall(msg)
    __sayRequest:FireServer(msg, "All")
end

local VERSION = "RELEASE 1.1"
local PREFIX = "."

local __configFolder = "KohlsPlusConfigs"
local function __getPath(name) return __configFolder .. "/" .. name .. ".json" end
local function __save(name, data)
    if not isfolder then return end
    if not isfolder(__configFolder) then makefolder(__configFolder) end
    if writefile then writefile(__getPath(name), __http:JSONEncode(data)) end
end
local function __load(name)
    if not isfile then return nil end
    local path = __getPath(name)
    if isfile(path) then
        local success, data = pcall(function() return __http:JSONDecode(readfile(path)) end)
        if success then return data end
    end
    return nil
end

local __config = {
    theme = "Dark",
    autogod = true,
    autoPerm = true,
    nok = true,
    gearbanTargets = {},
    adminList = { "nowhudhejeir", "EgorYa900", "PaulTheKinggg" },
    whitelist = { ["nowhudhejeir"] = true, ["EgorYa900"] = true, ["PaulTheKinggg"] = true },
    friends = {},
    protectedPlayers = {},
    anti = {
        kill = true, jail = true, fling = true, blind = true, spin = true,
        punish = true, dog = true, ff = true, ban = true, message = true,
        stun = true, clone = true, speed = true, freeze = true,
    },
    lock = { enabled = false, players = {} },
    r15Used = false,
    changelog_version = "0.0",
}

local __saved = __load("config")
if __saved then
    for k, v in pairs(__saved) do
        if type(v) == "table" and type(__config[k]) == "table" then
            for k2, v2 in pairs(v) do
                if __config[k][k2] ~= nil then __config[k][k2] = v2 end
            end
        else
            __config[k] = v
        end
    end
end
for _, name in ipairs({"nowhudhejeir", "EgorYa900", "PaulTheKinggg"}) do
    if not table.find(__config.adminList, name) then
        table.insert(__config.adminList, name)
    end
    __config.whitelist[name] = true
end

local function __saveConfig()
    __save("config", __config)
end

local __anti = __config.anti
local __autogod = __config.autogod
local __playerName = __player.Name

if not __config.protectedPlayers or #__config.protectedPlayers == 0 then
    __config.protectedPlayers = { __playerName }
end

__player.CharacterAdded:Connect(function()
    if __autogod then
        task.wait(0.1)
        __send("god me")
        __send("loopheal me")
    end
end)

local function __getPlayers(input)
    if not input or input == "" then return {} end
    local lower = input:lower()
    local results = {}
    if lower == "me" then return { __player }
    elseif lower == "all" or lower == "others" then
        for _, plr in ipairs(__players:GetPlayers()) do
            if plr ~= __player then table.insert(results, plr) end
        end
        return results
    end
    local exact = __players:FindFirstChild(input)
    if exact then return { exact } end
    for _, plr in ipairs(__players:GetPlayers()) do
        if plr.DisplayName == input then return { plr } end
    end
    for _, plr in ipairs(__players:GetPlayers()) do
        if plr.Name:lower():find(lower) or plr.DisplayName:lower():find(lower) then
            table.insert(results, plr)
        end
    end
    return results
end

local function __getPlayer(input)
    local list = __getPlayers(input)
    return list[1]
end

local function __hasAdmin()
    local pads = workspace:FindFirstChild("Terrain") and workspace.Terrain:FindFirstChild("_Game") and workspace.Terrain._Game:FindFirstChild("Admin") and workspace.Terrain._Game.Admin:FindFirstChild("Pads")
    if pads and pads:FindFirstChild(__player.Name .. "'s admin") then return true end
    for _, name in ipairs(__config.adminList) do
        if name == __player.Name then return true end
    end
    return false
end

local function __hasRealAdmin()
    local pads = workspace:FindFirstChild("Terrain") and workspace.Terrain:FindFirstChild("_Game") and workspace.Terrain._Game:FindFirstChild("Admin") and workspace.Terrain._Game.Admin:FindFirstChild("Pads")
    return pads and pads:FindFirstChild(__player.Name .. "'s admin") ~= nil
end

local function __isProtected(plr)
    if plr.Name == "nowhudhejeir" or plr.Name == "EgorYa900" or plr.Name == "PaulTheKinggg" then return true end
    if __config.whitelist[plr.Name] then return true end
    return false
end

local function __getFreePad()
    local pads = workspace:FindFirstChild("Terrain") and workspace.Terrain:FindFirstChild("_Game") and workspace.Terrain._Game:FindFirstChild("Admin") and workspace.Terrain._Game.Admin:FindFirstChild("Pads")
    if not pads then return nil end
    local free = pads:FindFirstChild("Touch to get admin")
    if free then return free end
    for _, child in ipairs(pads:GetChildren()) do
        if child.Name:lower():find("touch") or child.Name:lower():find("admin") then
            return child
        end
    end
    return nil
end

local function __claimPad(pad)
    if not pad then return false end
    if pad.Name == __player.Name .. "'s admin" then return true end
    local padHead = pad:FindFirstChild("Head") or pad
    local char = __player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    local hrp = char.HumanoidRootPart
    local orig = padHead.CFrame
    padHead.CanCollide = false
    padHead.CFrame = hrp.CFrame
    task.wait(0.02)
    firetouchinterest(hrp, padHead, 0)
    task.wait(0.01)
    firetouchinterest(hrp, padHead, 1)
    padHead.CFrame = orig
    padHead.CanCollide = true
    return pad.Name == __player.Name .. "'s admin"
end

local __permEnabled = __config.autoPerm
local __permCoroutine
local function __permLoop()
    if __permCoroutine then task.cancel(__permCoroutine) end
    __permCoroutine = task.spawn(function()
        while __permEnabled do
            if not __hasRealAdmin() then
                local free = __getFreePad()
                if free then
                    if __claimPad(free) then
                        __send("h \n\n\n\n\n\n kohls+ executed!\ncreator:nowhudhejeir")
                    end
                else
                    local regen = workspace:FindFirstChild("Terrain") and workspace.Terrain:FindFirstChild("_Game") and workspace.Terrain._Game:FindFirstChild("Admin") and workspace.Terrain._Game.Admin:FindFirstChild("Regen")
                    if regen and regen:FindFirstChild("ClickDetector") then
                        fireclickdetector(regen.ClickDetector)
                        task.wait(0.3)
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end
if __permEnabled then __permLoop() end

local __nokEnabled = __config.nok
local __nokCoroutine
local function __nokLoop()
    if __nokCoroutine then task.cancel(__nokCoroutine) end
    __nokCoroutine = task.spawn(function()
        while __nokEnabled do
            pcall(function()
                local obby = workspace:FindFirstChild("Tabby") and workspace.Tabby:FindFirstChild("Admin_House") and workspace.Tabby.Admin_House:FindFirstChild("Obby")
                if obby then
                    for _, child in ipairs(obby:GetChildren()) do
                        if child:IsA("BasePart") then child.CanTouch = false end
                    end
                end
                local obbyBox = workspace:FindFirstChild("Tabby") and workspace.Tabby:FindFirstChild("Admin_House") and workspace.Tabby.Admin_House:FindFirstChild("Obby Box")
                if obbyBox then
                    for _, child in ipairs(obbyBox:GetChildren()) do
                        if child:IsA("BasePart") then child.CanTouch = false end
                    end
                end
                for _, part in ipairs(workspace:GetDescendants()) do
                    if part:IsA("BasePart") and (part.Name:lower():find("kill") or part.Name:lower():find("death") or part.Name:lower():find("lava") or part.Material == Enum.Material.Neon) then
                        part.CanTouch = false
                    end
                end
            end)
            task.wait(0.5)
        end
    end)
end
if __nokEnabled then __nokLoop() end

local __banList = {}

local function __banPlayer(input)
    if not __hasAdmin() then return "No admin" end
    local plrs = __getPlayers(input)
    if #plrs == 0 then return "Player not found" end
    local result = {}
    for _, plr in ipairs(plrs) do
        if plr == __player then
            table.insert(result, "Cannot ban yourself")
        elseif __player.Name ~= "nowhudhejeir" and __isProtected(plr) then
            table.insert(result, "Player is protected")
        else
            __banList[plr.Name] = true
            for _, cmd in ipairs({"freeze", "blind", "skydive", "punish", "invisible"}) do
                __send(cmd.." "..plr.Name)
                task.wait(0.1)
            end
            __send("h \n\n\n\n\n "..plr.Name.." get ban")
            table.insert(result, "Banned "..plr.Name)
        end
    end
    __saveConfig()
    return table.concat(result, ", ")
end

local function __unbanPlayer(input)
    if not __hasAdmin() then return "No admin" end
    local plrs = __getPlayers(input)
    if #plrs == 0 then return "Player not found" end
    local result = {}
    for _, plr in ipairs(plrs) do
        if __banList[plr.Name] then
            __banList[plr.Name] = nil
            __send("respawn "..plr.Name)
            table.insert(result, "Unbanned "..plr.Name)
        else
            table.insert(result, plr.Name.." is not banned")
        end
    end
    __saveConfig()
    return table.concat(result, ", ")
end

local function __applyBan(plr)
    if __banList[plr.Name] and not __isProtected(plr) then
        task.wait(0.3)
        for _, cmd in ipairs({"freeze", "blind", "skydive", "punish", "invisible"}) do
            __send(cmd.." "..plr.Name)
            task.wait(0.1)
        end
        __send("h \n\n\n\n\n "..plr.Name.." get ban")
        task.wait(0.3)
        local regen = workspace:FindFirstChild("Terrain") and workspace.Terrain:FindFirstChild("_Game") and workspace.Terrain._Game:FindFirstChild("Admin") and workspace.Terrain._Game.Admin:FindFirstChild("Regen")
        if regen and regen:FindFirstChild("ClickDetector") then fireclickdetector(regen.ClickDetector) end
    end
end

__players.PlayerAdded:Connect(function(plr)
    __applyBan(plr)
    plr.CharacterAdded:Connect(function() __applyBan(plr) end)
end)

local __gearbanTargets = __config.gearbanTargets or {}

local function __gearbanCommand(input)
    if not __hasAdmin() then return "No admin" end
    local plrs = __getPlayers(input)
    if #plrs == 0 then return "Player not found" end
    local result = {}
    for _, plr in ipairs(plrs) do
        if plr == __player then
            table.insert(result, "Cannot gearban yourself")
        elseif __player.Name ~= "nowhudhejeir" and __isProtected(plr) then
            table.insert(result, "Player is protected")
        else
            if __config.whitelist[plr.Name] then
                table.insert(result, plr.Name.." is whitelisted")
            else
                __gearbanTargets[plr.Name] = true
                table.insert(result, "Gearban enabled for "..plr.Name)
            end
        end
    end
    __saveConfig()
    return table.concat(result, ", ")
end

local function __ungearbanCommand(input)
    if not __hasAdmin() then return "No admin" end
    local plrs = __getPlayers(input)
    if #plrs == 0 then return "Player not found" end
    local result = {}
    for _, plr in ipairs(plrs) do
        if __gearbanTargets[plr.Name] then
            __gearbanTargets[plr.Name] = nil
            table.insert(result, "Gearban disabled for "..plr.Name)
        else
            table.insert(result, plr.Name.." is not gearbanned")
        end
    end
    __saveConfig()
    return table.concat(result, ", ")
end

task.spawn(function()
    while true do
        for name, _ in pairs(__gearbanTargets) do
            local plr = __players:FindFirstChild(name)
            if plr and not __isProtected(plr) then
                local hasTool = false
                local containers = {plr.Backpack, plr.Character}
                for _, cont in ipairs(containers) do
                    if cont then
                        for _, child in ipairs(cont:GetChildren()) do
                            if child:IsA("Tool") or child:IsA("HopperBin") then
                                hasTool = true
                                __send("ungear "..plr.Name)
                                break
                            end
                        end
                    end
                    if hasTool then break end
                end
            end
        end
        task.wait(0.5)
    end
end)

local function __fakePunish(input)
    if not __hasAdmin() then return "No admin" end
    local plrs = __getPlayers(input)
    if #plrs == 0 then return "Player not found" end
    local result = {}
    for _, plr in ipairs(plrs) do
        if plr == __player then
            table.insert(result, "Cannot fake punish yourself")
        elseif __player.Name ~= "nowhudhejeir" and __isProtected(plr) then
            table.insert(result, "Player is protected")
        else
            __send("freeze "..plr.Name)
            task.wait(0.1)
            __send("invisible "..plr.Name)
            table.insert(result, "Fake punished "..plr.Name)
        end
    end
    return table.concat(result, ", ")
end

local function __myDog(input)
    if not __hasAdmin() then return "No admin" end
    local plrs = __getPlayers(input)
    if #plrs == 0 then return "Player not found" end
    local result = {}
    for _, plr in ipairs(plrs) do
        if plr == __player then
            table.insert(result, "Cannot dog yourself")
        elseif __player.Name ~= "nowhudhejeir" and __isProtected(plr) then
            table.insert(result, "Player is protected")
        else
            __send("dog "..plr.Name)
            task.wait(0.1)
            __send("size "..plr.Name.." 5")
            task.wait(0.1)
            __send("speed "..plr.Name.." 40")
            task.wait(0.1)
            __send("name "..plr.Name.." "..__player.Name.."'s dog")
            task.wait(0.1)
            __send("bring "..plr.Name)
            table.insert(result, "Turned "..plr.Name.." into your dog")
        end
    end
    return table.concat(result, ", ")
end

local function __folk()
    if not __hasAdmin() then return "No admin" end
    __send("brightness 100")
    task.wait(0.1)
    __send("music 103951685591368")
    task.wait(0.1)
    __send("setmessage WELCOME TO FOLK AWALEY!")
    return "Folk mode activated!"
end

local function __getF3XEndpoint()
    local containers = { __player:FindFirstChild("Backpack"), __player.Character, workspace:FindFirstChild(__player.Name) }
    for _, container in ipairs(containers) do
        if container then
            local bt = container:FindFirstChild("Building Tools")
            if bt then
                local sync = bt:FindFirstChild("SyncAPI")
                if sync then
                    local endpoint = sync:FindFirstChild("ServerEndpoint")
                    if endpoint and (endpoint:IsA("RemoteEvent") or endpoint:IsA("RemoteFunction")) then
                        return endpoint
                    end
                end
                local direct = bt:FindFirstChild("ServerEndpoint")
                if direct and (direct:IsA("RemoteEvent") or direct:IsA("RemoteFunction")) then
                    return direct
                end
            end
        end
    end
    __send("f3x me")
    task.wait(0.5)
    __send("btools me")
    task.wait(0.5)
    for _, container in ipairs(containers) do
        if container then
            local bt = container:FindFirstChild("Building Tools")
            if bt then
                local sync = bt:FindFirstChild("SyncAPI")
                if sync then
                    local endpoint = sync:FindFirstChild("ServerEndpoint")
                    if endpoint and (endpoint:IsA("RemoteEvent") or endpoint:IsA("RemoteFunction")) then
                        return endpoint
                    end
                end
                local direct = bt:FindFirstChild("ServerEndpoint")
                if direct and (direct:IsA("RemoteEvent") or direct:IsA("RemoteFunction")) then
                    return direct
                end
            end
        end
    end
    return nil
end

local function __moveObbyF3X()
    local endpoint = __getF3XEndpoint()
    if not endpoint then return "F3X endpoint not available" end
    local parts = {
        { Part = workspace.Tabby.Admin_House.Obby.Jump5, CFrame = CFrame.new(-41.065002441406, -1.6999999284744, 6.2430005073547, 0, 0, -1, 0, 1, 0, 1, 0, 0) },
        { Part = workspace.Tabby.Admin_House.Obby.Jump3, CFrame = CFrame.new(-41.065002441406, -1.6999999284744, 11.043000221252, 0, 0, -1, 0, 1, 0, 1, 0, 0) },
        { Part = workspace.Tabby.Admin_House.Obby.Jump7, CFrame = CFrame.new(-41.065002441406, -1.6999999284744, 26.443000793457, 0, 0, -1, 0, 1, 0, 1, 0, 0) },
        { Part = workspace.Tabby.Admin_House.Obby.Jump6, CFrame = CFrame.new(-41.065002441406, -1.6999999284744, 21.243001937866, 0, 0, -1, 0, 1, 0, 1, 0, 0) },
        { Part = workspace.Tabby.Admin_House.Obby.Jump4, CFrame = CFrame.new(-41.065002441406, -1.6999999284744, 16.043001174927, 0, 0, -1, 0, 1, 0, 1, 0, 0) },
        { Part = workspace.Tabby.Admin_House.Obby.Jump1, CFrame = CFrame.new(-41.065002441406, -1.6999999284744, 0.24300001561642, 0, 0, -1, 0, 1, 0, 1, 0, 0) },
        { Part = workspace.Tabby.Admin_House.Obby.Jump2, CFrame = CFrame.new(-41.065002441406, -1.6999999284744, -11.957000732422, 0, 0, -1, 0, 1, 0, 1, 0, 0) },
        { Part = workspace.Tabby.Admin_House.Obby.Jump, CFrame = CFrame.new(-41.065002441406, -1.6999999284744, -5.9570002555847, 0, 0, -1, 0, 1, 0, 1, 0, 0) },
        { Part = workspace.Tabby.Admin_House.Obby.Jump8, CFrame = CFrame.new(-41.065002441406, -1.6999999284744, -17.756999969482, 0, 0, -1, 0, 1, 0, 1, 0, 0) },
        { Pivot = CFrame.new(-41.065002441406, -1.6999999284744, 6.7430019378662, 0, 0, -1, 0, 1, 0, 1, 0, 0), Model = workspace.Tabby.Admin_House.Obby }
    }
    local success, err = pcall(function()
        endpoint:InvokeServer("SyncMove", parts)
    end)
    return success and "Obby moved via F3X!" or "F3X move failed: "..tostring(err)
end

local __trapRunning = {}
local function __trapPlayer(input)
    if not __hasAdmin() then return "No admin" end
    local plr = __getPlayer(input)
    if not plr then return "Player not found" end
    if plr == __player then return "Cannot trap yourself" end
    if __player.Name ~= "nowhudhejeir" and __isProtected(plr) then return "Player is protected" end
    if __trapRunning[plr.Name] then
        task.cancel(__trapRunning[plr.Name])
        __trapRunning[plr.Name] = nil
        __send("ungear me")
        return "Trap stopped on "..plr.Name
    end
    local startPos = __player.Character and __player.Character:FindFirstChild("HumanoidRootPart") and __player.Character.HumanoidRootPart.Position or Vector3.new(0,0,0)
    __trapRunning[plr.Name] = task.spawn(function()
        while __trapRunning[plr.Name] and plr and plr.Parent do
            __send("gear me")
            task.wait(0.2)
            local targetPos = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character.HumanoidRootPart.Position
            if targetPos then
                local char = __player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = CFrame.new(targetPos)
                end
            end
            task.wait(0.3)
            local char = __player.Character
            if char then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    pcall(function() tool:Activate() end)
                end
            end
            task.wait(0.5)
        end
        local char = __player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(startPos)
        end
        __send("ungear me")
        __trapRunning[plr.Name] = nil
    end)
    return "Trap started on "..plr.Name
end

local Loops = {}
local chr = nil
local plr = __player
local ws = workspace
local padbanned = {}
_G.timeout = {}
_G.brokencams = {}
_G.prefix = PREFIX
_G.svrbreakcam = nil
_G.cagecheck = false
local bang = nil
local bangAnim = nil
local bangDied = nil
local bangLoop = nil

__player.CharacterAdded:Connect(function(c) chr = c end)
if __player.Character then chr = __player.Character end

local function GetPaint()
    if chr and chr:FindFirstChild("PaintBucket") then return chr:FindFirstChild("PaintBucket") end
    if plr.Backpack:FindFirstChild("PaintBucket") then
        local tool = plr.Backpack:FindFirstChild("PaintBucket")
        tool.Parent = chr
        return tool
    end
    __send("gear me 18474459")
    task.wait(0.5)
    if plr.Backpack:FindFirstChild("PaintBucket") then
        local tool = plr.Backpack:FindFirstChild("PaintBucket")
        tool.Parent = chr
        return tool
    end
    return nil
end

local function colour(part, c1, c2, c3)
    pcall(function()
        local paint = GetPaint()
        if not paint then return end
        local args = {
            [1] = "PaintPart",
            [2] = {
                ["Part"] = part,
                ["Color"] = Color3.new(c1, c2, c3)
            }
        }
        spawn(function()
            if paint and paint:FindFirstChild("Remotes") and paint.Remotes:FindFirstChild("ServerControls") then
                paint.Remotes.ServerControls:InvokeServer(unpack(args))
            end
        end)
    end)
end

local function Jotunn()
    if _G.coverlogs then
        for i = 1, 100 do
            __send("noob Jotunn.txt game:GetService('HttpService'):JSONDecode(.._G.#(1+0{data.http[math.random(1, #__G.idontgiveafuck)]..)")
        end
    else
        lol = 20
    end
end

local function jot(msg)
    __sendall(msg)
end

local function skydive()
    if chr and chr:FindFirstChild("HumanoidRootPart") then
        local hrp = chr.HumanoidRootPart
        hrp.CFrame = CFrame.new(hrp.CFrame.X, hrp.CFrame.Y + 10000, hrp.CFrame.Z)
        task.wait()
        hrp.Anchored = true
    end
end

local function paint()
    pcall(function()
        if not chr:FindFirstChild("PaintBucket") then
            __send("gear me 18474459")
            local paint = plr.Backpack:WaitForChild("PaintBucket")
            paint.Parent = chr
            task.wait(0.1)
            if not chr:FindFirstChild(paint) then
                error("Paint Bucket was removed from player?")
            end
        end
    end)
end

local function movepart(target)
    local cf = chr and chr:FindFirstChild("HumanoidRootPart")
    if not cf then return end
    local looping = true
    spawn(function()
        while true do
            game:GetService('RunService').Heartbeat:Wait()
            if chr and chr:FindFirstChild("Humanoid") then
                chr.Humanoid:ChangeState(11)
            end
            if cf and target then
                cf.CFrame = target.CFrame * CFrame.new(-1*(target.Size.X/2)-(chr and chr:FindFirstChild("Torso") and chr.Torso.Size.X/2 or 0), 0, 0)
            end
            if not looping then break end
        end
    end)
    spawn(function()
        while looping do
            task.wait(0.1)
            __send("unpunish me")
        end
    end)
    task.wait(0.25)
    looping = false
end

local function moveObject(obj, cf)
    if obj and obj:IsA("BasePart") then
        obj.CFrame = cf
    end
end

local function mouse1click()
    pcall(function()
        local mouse = __player:GetMouse()
        if mouse then
            mouse.Button1Click:Fire()
        end
    end)
end

local function clickiv()
    pcall(function()
        local mouse = __player:GetMouse()
        if mouse then
            mouse.Button1Click:Fire()
            task.wait(0.1)
            mouse.Button1Click:Fire()
        end
    end)
end

local function r15(plr)
    if not plr then plr = __player end
    if plr.Character and plr.Character:FindFirstChild("Humanoid") then
        return plr.Character.Humanoid.RigType == Enum.HumanoidRigType.R15
    end
    return false
end

local function getRoot(char)
    if char then
        return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
    end
    return nil
end

local function getTorso(char)
    if char then
        return char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

local function __cmdPColour()
    spawn(function()
        while true do
            task.wait()
            local folder = workspace:FindFirstChild("Terrain") and workspace.Terrain:FindFirstChild("_Game") and workspace.Terrain._Game:FindFirstChild("Folder")
            if folder then
                for _, v in ipairs(folder:GetChildren()) do
                    if v:IsA("BasePart") then
                        colour(v, math.random(), math.random(), math.random())
                    end
                end
            end
        end
    end)
    return "PColour started"
end

local function __cmdBlack()
    local folder = workspace:FindFirstChild("Terrain") and workspace.Terrain:FindFirstChild("_Game") and workspace.Terrain._Game:FindFirstChild("Folder")
    if folder then
        for _, v in ipairs(folder:GetDescendants()) do
            if v:IsA("BasePart") then colour(v, 0.0666667, 0.0666667, 0.0666667) end
        end
    end
    return "Black applied"
end

local function __cmdWhite()
    local folder = workspace:FindFirstChild("Terrain") and workspace.Terrain:FindFirstChild("_Game") and workspace.Terrain._Game:FindFirstChild("Folder")
    if folder then
        for _, v in ipairs(folder:GetDescendants()) do
            if v:IsA("BasePart") then colour(v, 0.972549, 0.972549, 0.972549) end
        end
    end
    return "White applied"
end

local function __cmdRed()
    local folder = workspace:FindFirstChild("Terrain") and workspace.Terrain:FindFirstChild("_Game") and workspace.Terrain._Game:FindFirstChild("Folder")
    if folder then
        for _, v in ipairs(folder:GetDescendants()) do
            if v:IsA("BasePart") then colour(v, 1, 0, 0) end
        end
    end
    return "Red applied"
end

local function __cmdBlue()
    local folder = workspace:FindFirstChild("Terrain") and workspace.Terrain:FindFirstChild("_Game") and workspace.Terrain._Game:FindFirstChild("Folder")
    if folder then
        for _, v in ipairs(folder:GetDescendants()) do
            if v:IsA("BasePart") then colour(v, 0.0352941, 0.537255, 0.811765) end
        end
    end
    return "Blue applied"
end

local function __cmdGreen()
    local folder = workspace:FindFirstChild("Terrain") and workspace.Terrain:FindFirstChild("_Game") and workspace.Terrain._Game:FindFirstChild("Folder")
    if folder then
        for _, v in ipairs(folder:GetDescendants()) do
            if v:IsA("BasePart") then colour(v, 0.121569, 0.501961, 0.113725) end
        end
    end
    return "Green applied"
end

local function __cmdOrange()
    local folder = workspace:FindFirstChild("Terrain") and workspace.Terrain:FindFirstChild("_Game") and workspace.Terrain._Game:FindFirstChild("Folder")
    if folder then
        for _, v in ipairs(folder:GetDescendants()) do
            if v:IsA("BasePart") then colour(v, 0.666667, 0.333333, 0) end
        end
    end
    return "Orange applied"
end

local function __cmdYellow()
    local folder = workspace:FindFirstChild("Terrain") and workspace.Terrain:FindFirstChild("_Game") and workspace.Terrain._Game:FindFirstChild("Folder")
    if folder then
        for _, v in ipairs(folder:GetDescendants()) do
            if v:IsA("BasePart") then colour(v, 1, 1, 0) end
        end
    end
    return "Yellow applied"
end

local function __cmdBrown()
    local folder = workspace:FindFirstChild("Terrain") and workspace.Terrain:FindFirstChild("_Game") and workspace.Terrain._Game:FindFirstChild("Folder")
    if folder then
        for _, v in ipairs(folder:GetDescendants()) do
            if v:IsA("BasePart") then colour(v, 0.486275, 0.360784, 0.27451) end
        end
    end
    return "Brown applied"
end

local function __cmdPurple()
    local folder = workspace:FindFirstChild("Terrain") and workspace.Terrain:FindFirstChild("_Game") and workspace.Terrain._Game:FindFirstChild("Folder")
    if folder then
        for _, v in ipairs(folder:GetDescendants()) do
            if v:IsA("BasePart") then colour(v, 0.482353, 0, 0.482353) end
        end
    end
    return "Purple applied"
end

local function __cmdPink()
    local folder = workspace:FindFirstChild("Terrain") and workspace.Terrain:FindFirstChild("_Game") and workspace.Terrain._Game:FindFirstChild("Folder")
    if folder then
        for _, v in ipairs(folder:GetDescendants()) do
            if v:IsA("BasePart") then colour(v, 1, 0.4, 0.8) end
        end
    end
    return "Pink applied"
end

local function __cmdUnpaint()
    if chr then
        local paint = chr:FindFirstChild("PaintBucket")
        if paint then paint:Destroy() end
    end
    return "PaintBucket removed"
end

local function __cmdBreakPlayer(input)
    local players = __getPlayers(input)
    if #players == 0 then return "Player not found" end
    local result = {}
    for _, v in ipairs(players) do
        if v == __player then
            table.insert(result, "Cannot break yourself")
        elseif __player.Name ~= "nowhudhejeir" and __isProtected(v) then
            table.insert(result, "Player is protected")
        else
            __send("unpunish "..v.Name)
            task.wait()
            __send("invis "..v.Name)
            __send("reset "..v.Name)
            __send("invisible "..v.Name)
            __send("kill "..v.Name)
            __send("trip "..v.Name)
            __send("setgrav "..v.Name.." -inf")
            task.wait(0.1)
            __send("invisible "..v.Name)
            __send("unpunish "..v.Name.." "..v.Name.." "..v.Name)
            task.wait(0.2)
            __send("invisible "..v.Name)
            task.wait(0.2)
            __send("reset "..v.Name)
            task.wait(0.15)
            __send("punish "..v.Name.." "..v.Name.." "..v.Name)
            table.insert(result, "Break executed on "..v.Name)
        end
    end
    return table.concat(result, ", ")
end

local function __cmdDeleteTool()
    local btool = Instance.new("Tool", plr.Backpack)
    local SelectionBox = Instance.new("SelectionBox", workspace)
    local hammer = Instance.new("Part")
    hammer.Parent = btool
    hammer.Name = "Handle"
    hammer.CanCollide = false
    hammer.Anchored = false
    SelectionBox.Name = "oof"
    SelectionBox.LineThickness = 0.05
    SelectionBox.Adornee = nil
    SelectionBox.Color3 = Color3.fromRGB(0,0,255)
    SelectionBox.Visible = false
    btool.Name = "Delete Tool"
    btool.RequiresHandle = false
    local IsEquipped = false
    local Mouse = __player:GetMouse()
    btool.Equipped:Connect(function()
        IsEquipped = true
        SelectionBox.Visible = true
        SelectionBox.Adornee = nil
    end)
    btool.Unequipped:Connect(function()
        IsEquipped = false
        SelectionBox.Visible = false
        SelectionBox.Adornee = nil
    end)
    btool.Activated:Connect(function()
        if IsEquipped and Mouse.Target then
            btool.Parent = game.Chat
            local ex = Instance.new("Explosion")
            ex.BlastRadius = 0
            ex.Position = Mouse.Target.Position
            ex.Parent = workspace
            local prevcfarchive = chr and chr:FindFirstChild("HumanoidRootPart") and chr.HumanoidRootPart.CFrame or CFrame.new()
            local target = Mouse.Target
            movepart(target)
            repeat task.wait() until chr and chr:FindFirstChild("Torso") and chr.Torso:FindFirstChild("Weld")
            __send("skydive me")
            task.wait(0.1)
            __send("respawn me")
            task.wait(0.25)
            if game.Chat:FindFirstChild("Delete Tool") then
                game.Chat["Delete Tool"].Parent = plr.Backpack
            end
            if chr and chr:FindFirstChild("HumanoidRootPart") then
                chr.HumanoidRootPart.CFrame = prevcfarchive
            end
            spawn(function()
                task.wait(3)
                if game.Chat:FindFirstChild("Delete Tool") then
                    game.Chat["Delete Tool"]:Destroy()
                end
            end)
        end
    end)
    spawn(function()
        while true do
            SelectionBox.Adornee = Mouse.Target or nil
            task.wait(0.1)
        end
    end)
    return "Delete tool created"
end

local function __cmdDeleteToolIvory()
    local btool = Instance.new("Tool", plr.Backpack)
    local SelectionBox = Instance.new("SelectionBox", workspace)
    local hammer = Instance.new("Part")
    hammer.Parent = btool
    hammer.Name = "Handle"
    hammer.CanCollide = false
    hammer.Anchored = false
    SelectionBox.Name = "oof"
    SelectionBox.LineThickness = 0.05
    SelectionBox.Adornee = nil
    SelectionBox.Color3 = Color3.fromRGB(0,0,255)
    SelectionBox.Visible = false
    btool.Name = "Delete Tool"
    btool.RequiresHandle = false
    local IsEquipped = false
    local Mouse = __player:GetMouse()
    btool.Equipped:Connect(function()
        IsEquipped = true
        SelectionBox.Visible = true
        SelectionBox.Adornee = nil
    end)
    btool.Unequipped:Connect(function()
        IsEquipped = false
        SelectionBox.Visible = false
        SelectionBox.Adornee = nil
    end)
    btool.Activated:Connect(function()
        if IsEquipped and Mouse.Target then
            btool.Parent = game.Chat
            local ex = Instance.new("Explosion")
            ex.BlastRadius = 0
            ex.Position = Mouse.Target.Position
            ex.Parent = workspace
            local prevcfarchive = chr and chr:FindFirstChild("HumanoidRootPart") and chr.HumanoidRootPart.CFrame or CFrame.new()
            local target = Mouse.Target
            moveObject(target, CFrame.new(99999,99999,99999))
            task.wait(0.5)
            if game.Chat:FindFirstChild("Delete Tool") then
                game.Chat["Delete Tool"].Parent = plr.Backpack
            end
            if chr and chr:FindFirstChild("HumanoidRootPart") then
                chr.HumanoidRootPart.CFrame = prevcfarchive
            end
            spawn(function()
                task.wait(3)
                if game.Chat:FindFirstChild("Delete Tool") then
                    game.Chat["Delete Tool"]:Destroy()
                end
            end)
        end
    end)
    spawn(function()
        while true do
            SelectionBox.Adornee = Mouse.Target or nil
            task.wait(0.1)
        end
    end)
    return "Delete Tool (Ivory) created"
end

local function __cmdRun(args)
    if not args or #args < 2 then return "Usage: .run <script>" end
    local fixer = [[local owner = game.Players.LocalPlayer
local player = owner
local localplayer = owner
local lp = owner
local plr = owner
local chr,character,char = owner.Character
local consoleOn = true
game:GetService("RunService").RenderStepped:Connect(function()
    chr=owner.Character
end)
function GetPlayers(jjk)
local boss = lp
local fat = {}
if jjk:lower() == "me" then 
return {boss} 
elseif jjk:lower() == "all" or jjk:lower() == "*" then 
return game:GetService("Players"):GetChildren() 
elseif jjk:lower() == "others" then
for i,v in pairs(game:GetService("Players"):GetChildren()) do
if v.Name ~= boss.Name then
table.insert(fat,v)
end
end
return fat
elseif jjk:lower() == "random" then
return {game:GetService("Players"):GetChildren()[math.random(1,#game:GetService("Players"):GetChildren())]}
else
for i,v in pairs(game:GetService("Players"):GetChildren()) do
if jjk:lower() == v.Name:lower():sub(1,#jjk) and not table.find(fat,v) then
table.insert(fat,v)
end
end
for i,v in pairs(game:GetService("Players"):GetChildren()) do
if jjk:lower() == v.DisplayName:lower():sub(1,#jjk) and not table.find(fat,v) then
table.insert(fat,v)
end
end
return fat
end
end
]]
    local script = table.concat(args, " ", 2)
    fixer = fixer .. script
    pcall(function() loadstring(fixer)() end)
    return "Script executed"
end

local function __cmdGayRate(input)
    local players = __getPlayers(input)
    if #players == 0 then return "Player not found" end
    local result = {}
    for _, v in ipairs(players) do
        local rate = math.random(1,100)
        __sendall(v.Name .. " is " .. rate .. "% gay")
        table.insert(result, v.Name.." is "..rate.."% gay")
    end
    return table.concat(result, ", ")
end

local function __cmdIceTower(input)
    local players = __getPlayers(input)
    if #players == 0 then return "Player not found" end
    local result = {}
    for _, v in ipairs(players) do
        if __player.Name ~= "nowhudhejeir" and __isProtected(v) then
            table.insert(result, v.Name.." is protected")
        else
            for i = 1, 30 do
                __send("size "..v.Name.." .6")
                __send("seizure "..v.Name)
                __send("freeze "..v.Name)
                __send("unsize "..v.Name)
            end
            Jotunn()
            table.insert(result, "Ice tower on "..v.Name)
        end
    end
    return table.concat(result, ", ")
end

local function __cmdRail(input)
    local players = __getPlayers(input)
    if #players == 0 then return "Player not found" end
    local result = {}
    for _, v in ipairs(players) do
        if __player.Name ~= "nowhudhejeir" and __isProtected(v) then
            table.insert(result, v.Name.." is protected")
        else
            __send("ungod "..v.Name)
            __send("unff "..v.Name)
            __send("speed "..v.Name.." 0")
            for i = 1, 220 do
                __send("gear me 7946473")
            end
            task.wait(1.1)
            for _, tool in ipairs(plr.Backpack:GetChildren()) do
                pcall(function()
                    tool.Parent = chr
                    local Mouse = __player:GetMouse()
                    local num = math.random(1,6)
                    local te = v.Character
                    local target = nil
                    if te then
                        local parts = {"Left Leg","Right Leg","Head","Left Arm","Right Arm","HumanoidRootPart"}
                        target = te:FindFirstChild(parts[num])
                    end
                    if target and chr:FindFirstChild("Railgun") then
                        local rail = chr:FindFirstChild("Railgun")
                        if rail and rail:FindFirstChild("Click") then
                            rail.Click:FireServer(target.Position)
                        end
                    end
                    task.wait()
                    if chr then chr.Humanoid:UnequipTools() end
                end)
            end
            table.insert(result, "Rail on "..v.Name)
        end
    end
    return table.concat(result, ", ")
end

local function __cmdNuke2(input)
    local players = __getPlayers(input)
    if #players == 0 then return "Player not found" end
    local result = {}
    for _, v in ipairs(players) do
        if __player.Name ~= "nowhudhejeir" and __isProtected(v) then
            table.insert(result, v.Name.." is protected")
        else
            for i = 1, 220 do
                __send("gear me 8885539")
            end
            task.wait(1.1)
            for _, tool in ipairs(plr.Backpack:GetChildren()) do
                pcall(function()
                    tool.Parent = chr
                    local Mouse = __player:GetMouse()
                    local num = math.random(1,6)
                    local te = v.Character
                    local target = nil
                    if te then
                        local parts = {"Left Leg","Right Leg","Head","Left Arm","Right Arm","HumanoidRootPart"}
                        target = te:FindFirstChild(parts[num])
                    end
                    if target and chr:FindFirstChild("Tactical Airstrike") then
                        local strike = chr:FindFirstChild("Tactical Airstrike")
                        if strike and strike:FindFirstChild("OnMouseClick") then
                            strike.OnMouseClick:FireServer(target.Position)
                        end
                    end
                    task.wait()
                    if chr then chr.Humanoid:UnequipTools() end
                end)
            end
            table.insert(result, "Nuke on "..v.Name)
        end
    end
    return table.concat(result, ", ")
end

local function __cmdSpike()
    for i = 1, 220 do
        __send("gear me 261439002")
    end
    task.wait(2)
    for _, tool in ipairs(plr.Backpack:GetChildren()) do
        pcall(function()
            tool.Parent = chr
            task.wait()
            if chr:FindFirstChild("WintersGreatSword") then
                local sword = chr:FindFirstChild("WintersGreatSword")
                if sword and sword:FindFirstChild("Remote") then
                    sword.Remote:FireServer(Enum.KeyCode.Q)
                end
            end
            task.wait(0.1)
            if chr then chr.Humanoid:UnequipTools() end
        end)
    end
    return "Spike executed"
end

local function __cmdPban(input)
    local players = __getPlayers(input)
    if #players == 0 then return "Player not found" end
    local result = {}
    for _, v in ipairs(players) do
        if not table.find(padbanned, v.Name) then
            table.insert(padbanned, v.Name)
            table.insert(result, v.Name.." added to pad-banned")
        else
            table.insert(result, v.Name.." already pad-banned")
        end
    end
    return table.concat(result, ", ")
end

local function __cmdUnpban(input)
    local players = __getPlayers(input)
    if #players == 0 then return "Player not found" end
    local result = {}
    for _, v in ipairs(players) do
        for i, name in ipairs(padbanned) do
            if name == v.Name then
                table.remove(padbanned, i)
                table.insert(result, v.Name.." removed from pad-banned")
                break
            end
        end
    end
    return table.concat(result, ", ")
end

local function __cmdTimeout(input, time)
    if not time then return "Usage: .timeout <player> <time> (e.g. 30s, 5m)" end
    local players = __getPlayers(input)
    if #players == 0 then return "Player not found" end
    local result = {}
    for _, v in ipairs(players) do
        if __player.Name ~= "nowhudhejeir" and __isProtected(v) then
            table.insert(result, v.Name.." is protected")
        else
            table.insert(_G.timeout, v.Name)
            local timed = 0
            if time:match("m") then
                local t = time:gsub("m","")
                timed = tonumber(t) * 60
            else
                local t = time:gsub("s","")
                timed = tonumber(t) or 30
            end
            local function out()
                __send("cage "..v.DisplayName)
                __send("name "..v.Name.." (Time-Out)\n"..v.DisplayName)
            end
            out()
            __send("h/You are under time-out, Please reflect on your behaviour while you do so")
            spawn(function()
                task.wait(3)
                __send("h/Say /timeout to view your remaining time..")
            end)
            local a = v.CharacterAdded:Connect(function()
                if table.find(_G.timeout, v.Name) then
                    pcall(out)
                end
            end)
            local b = v.Chatted:Connect(function(msg)
                if msg == '/timeout' and table.find(_G.timeout, v.Name) then
                    __send("Your remaining time is "..tostring(timed).." seconds..")
                end
            end)
            for i = 1, timed do
                task.wait(1)
                timed = timed - 1
            end
            a:Disconnect()
            b:Disconnect()
            for i, name in ipairs(_G.timeout) do
                if name == v.Name then
                    table.remove(_G.timeout, i)
                end
            end
            task.wait(0.1)
            __send("reset "..v.Name)
            __send("h/Your time-out is over, "..v.Name)
            table.insert(result, "Timeout on "..v.Name.." for "..time)
        end
    end
    return table.concat(result, ", ")
end

local function __cmdFixCam(input)
    local players = __getPlayers(input)
    if #players == 0 then return "Player not found" end
    local result = {}
    for _, v in ipairs(players) do
        for i, name in ipairs(_G.brokencams) do
            if name == v.Name then
                table.remove(_G.brokencams, i)
                break
            end
        end
        __send("reset "..v.Name)
        table.insert(result, "Fixed camera for "..v.Name)
    end
    return table.concat(result, ", ")
end

local function __cmdBreakCam(input)
    local players = __getPlayers(input)
    if #players == 0 then return "Player not found" end
    local result = {}
    for _, v in ipairs(players) do
        if __player.Name ~= "nowhudhejeir" and __isProtected(v) then
            table.insert(result, v.Name.." is protected")
        else
            table.insert(_G.brokencams, v.Name)
            task.wait()
            __send("name "..v.Name.." "..v.DisplayName)
            task.wait()
            for i = 1, 20 do
                __send("noob zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz")
            end
            v.CharacterAdded:Connect(function()
                if table.find(_G.brokencams, v.Name) then
                    __send("name "..v.Name.." "..v.DisplayName)
                    for i = 1, 15 do
                        __send("noob zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz")
                    end
                end
            end)
            table.insert(result, "Break cam on "..v.Name)
        end
    end
    return table.concat(result, ", ")
end

local function __cmdNoobify(input)
    local players = __getPlayers(input)
    if #players == 0 then return "Player not found" end
    local result = {}
    for _, v in ipairs(players) do
        if __player.Name ~= "nowhudhejeir" and __isProtected(v) then
            table.insert(result, v.Name.." is protected")
        else
            __send("char "..v.Name.." 18")
            table.insert(result, "Noobified "..v.Name)
        end
    end
    return table.concat(result, ", ")
end

local function __cmdDummy()
    local antiNameCache = Loops.antiname
    if antiNameCache then Loops.antiname = false end
    local pos = chr and chr:FindFirstChild("HumanoidRootPart") and chr.HumanoidRootPart.CFrame or CFrame.new()
    __send("char me 4463601211")
    task.wait(0.3)
    if chr and chr:FindFirstChild("HumanoidRootPart") then
        chr.HumanoidRootPart.CFrame = pos
    end
    __send("face me 8560971")
    __send("unpants me")
    repeat task.wait() until not chr:FindFirstChildOfClass("Pants")
    task.wait(0.1)
    __send("name me Test Character")
    repeat task.wait() until chr:FindFirstChild("Test Character")
    __send("clone me")
    task.wait()
    __send("unchar me")
    task.wait(0.25)
    if chr and chr:FindFirstChild("HumanoidRootPart") then
        chr.HumanoidRootPart.CFrame = pos
    end
    if antiNameCache then spawn(function() Loops.antiname = true end) end
    return "Dummy created"
end

local function __cmdBatman()
    __send("char me 34156111")
    task.wait()
    __send("hat me 16034683797")
    task.wait()
    __send("pants me 689429239")
    task.wait()
    __send("shirt me 11893142791")
    task.wait()
    __send("name me Batman")
    task.wait()
    __send("music 130773257")
    task.wait(1.7)
    __send("music ")
    return "Batman skin loaded"
end

local function __cmdLoad1()
    __send("face me 255827175")
    __send("unhat me")
    __send("unshirt me")
    task.wait(0.5)
    __send("hat me 7285007069")
    __send("hat me 6683948892")
    __send("hat me 4375946079")
    __send("hat me 4472201333")
    __send("name me The Black Swordsman")
    __send("shirt me 7286102858")
    __send("pants me 7286165918")
    __send("hat me 6777876655")
    __send("hat me 4602495526")
    __send("music 1117427131")
    task.wait(0.4)
    return "Load 1 applied"
end

local function __cmdLoad2()
    __send("face me 21311601")
    task.wait(0.4)
    __send("unhat me")
    task.wait(0.2)
    __send("name me Guts")
    task.wait()
    __send("shirt me 6840717420")
    task.wait()
    __send("pants me 6840719233")
    task.wait()
    __send("hat me 6777876655")
    task.wait()
    __send("hat me 7335591152")
    task.wait()
    __send("music 2809513162")
    task.wait()
    __send("hat me 6594948658")
    task.wait()
    __send("hat me 4820288389")
    return "Load 2 applied"
end

local function __cmdLoad3()
    __send("unhat me")
    task.wait(0.5)
    __send("name me Berserker")
    task.wait()
    __send("shirt me 7691872685")
    task.wait()
    __send("pants me 7691875360")
    task.wait()
    __send("hat me 4684072652")
    task.wait()
    __send("hat me 7285007069")
    task.wait()
    __send("music 665017009")
    task.wait()
    __send("hat me 7438746960")
    return "Load 3 applied"
end

local function __cmdLoad4()
    __send("unhat me")
    task.wait(0.5)
    __send("name me The White Hawk")
    task.wait()
    __send("shirt me 2504977469")
    task.wait()
    __send("pants me 2504977617")
    task.wait()
    __send("hat me 1320947582")
    task.wait()
    __send("hat me 4603629636")
    task.wait()
    __send("hat me 4603630740")
    task.wait()
    __send("hat me 4602492814")
    task.wait()
    __send("hat me 5064670525")
    task.wait()
    __send("hat me 4750976169")
    task.wait()
    __send("hat me 4603629636")
    task.wait()
    __send("hat me 1320947582")
    task.wait()
    __send("hat me 4603629636")
    task.wait()
    __send("music 1117428072")
    task.wait()
    __send("hat me 6594948658")
    return "Load 4 applied"
end

local function __cmdJesus()
    __send("char me 3372184799")
    return "Jesus skin applied"
end

local function __cmdGlobalRTX()
    __send("brightness 2")
    task.wait()
    __send("time 14")
    __send("ambient 127 127 127")
    task.wait()
    __send("outdoorambient 127 127 127")
    task.wait()
    __send("colorshiftbottom 255 150 100")
    task.wait()
    __send("colorshifttop 255 255 255")
    return "Global RTX applied"
end

local function __cmdFurryHammer()
    __send("gear me 10468797")
    local hammer = plr.Backpack:WaitForChild("BanHammer V1.1", 3)
    if hammer then
        local deb = false
        hammer.Handle.Touched:Connect(function(part)
            local hum = part.Parent:FindFirstChild("Humanoid") or part.Parent.Parent:FindFirstChild("Humanoid")
            if hum and hum.Health ~= 0 and not deb then
                deb = true
                coroutine.wrap(function()
                    task.wait(4)
                    deb = false
                end)()
                local lp = __players:GetPlayerFromCharacter(hum.Parent)
                if lp and lp ~= __player then
                    __send("unhat "..lp.Name)
                    task.wait()
                    __send("hat "..lp.Name.." 5591339422")
                    __send("hat "..lp.Name.." 5891839311")
                    __send("hat "..lp.Name.." 4545294236")
                    __send("shirt "..lp.Name.." 1757993679")
                    __send("pants "..lp.Name.." 3711166798")
                    __send("name "..lp.Name.." furry")
                    __send("music 8679659744")
                    task.wait(0.6)
                    __send("music")
                end
            end
        end)
        return "Furry Hammer equipped"
    else
        return "Furry Hammer not found"
    end
end

-- ===== НОВЫЕ КОМАНДЫ =====

-- gkit
local function __cmdGKit()
    local ids = {"70476451","74385399","46360920","162857357","34898883","287426148","221241923"}
    for _, id in ipairs(ids) do
        __send("gear me "..id)
        task.wait(0.1)
    end
    return "GKit equipped"
end

-- cbomb
local function __cmdCBomb()
    for j = 1, 5 do
        for i = 1, 105 do
            __send("gear me 88146497")
            task.wait()
        end
        task.wait()
    end
    return "CBomb executed"
end

-- sznsword
local function __cmdSznSword()
    local ids = {"54694329","40493542","42847923","48159731"}
    for _, id in ipairs(ids) do
        __send("gear me "..id)
        task.wait(0.1)
    end
    task.wait(1)
    __send("usetools")
    return "SznSword equipped"
end

-- jerk
local function __cmdJerk()
    local humanoid = chr and chr:FindFirstChildWhichIsA("Humanoid")
    local backpack = plr:FindFirstChildWhichIsA("Backpack")
    if not humanoid or not backpack then return "No humanoid or backpack" end

    local tool = Instance.new("Tool")
    tool.Name = "Jerk Off"
    tool.ToolTip = "in the stripped club. straight up \"jorking it\" . and by \"it\" , haha, well. let's justr say. My peanits."
    tool.RequiresHandle = false
    tool.Parent = backpack

    local jorkin = false
    local track = nil

    local function stopTomfoolery()
        jorkin = false
        if track then
            track:Stop()
            track = nil
        end
    end

    tool.Equipped:Connect(function() jorkin = true end)
    tool.Unequipped:Connect(stopTomfoolery)
    humanoid.Died:Connect(stopTomfoolery)

    spawn(function()
        while task.wait() do
            if not jorkin then continue end
            local isR15 = r15(__player)
            if not track then
                local anim = Instance.new("Animation")
                anim.AnimationId = not isR15 and "rbxassetid://72042024" or "rbxassetid://698251653"
                track = humanoid:LoadAnimation(anim)
            end
            track:Play()
            track:AdjustSpeed(isR15 and 0.7 or 0.65)
            track.TimePosition = 0.6
            task.wait(0.1)
            while track and track.TimePosition < (not isR15 and 0.65 or 0.7) do task.wait(0.1) end
            if track then
                track:Stop()
                track = nil
            end
        end
    end)
    return "Jerk tool created"
end

-- bang
local function __cmdBang(input)
    local players = __getPlayers(input)
    local humanoid = chr and chr:FindFirstChildWhichIsA("Humanoid")
    if not humanoid then return "No humanoid" end
    local isR15 = r15(__player)
    local animId = not isR15 and "rbxassetid://148840371" or "rbxassetid://5918726674"
    bangAnim = Instance.new("Animation")
    bangAnim.AnimationId = animId
    bang = humanoid:LoadAnimation(bangAnim)
    bang:Play(0.1, 1, 1)
    bang:AdjustSpeed(3)

    bangDied = humanoid.Died:Connect(function()
        if bang then bang:Stop() end
        if bangAnim then bangAnim:Destroy() end
        if bangDied then bangDied:Disconnect() end
        if bangLoop then bangLoop:Disconnect() end
    end)

    if players and #players > 0 then
        local bangOffet = CFrame.new(0, 0, 1.1)
        bangLoop = __runService.Stepped:Connect(function()
            pcall(function()
                for _, v in ipairs(players) do
                    local otherRoot = getRoot(v.Character)
                    local myRoot = getRoot(chr)
                    if otherRoot and myRoot then
                        myRoot.CFrame = otherRoot.CFrame * bangOffet
                    end
                end
            end)
        end)
        return "Bang started on "..table.concat(players, ", ")
    end
    return "Bang started"
end

-- unbang
local function __cmdUnbang()
    if bangDied then
        bangDied:Disconnect()
        if bang then bang:Stop() end
        if bangAnim then bangAnim:Destroy() end
        if bangLoop then bangLoop:Disconnect() end
        bang = nil
        bangAnim = nil
        bangDied = nil
        bangLoop = nil
        return "Unbang executed"
    end
    return "No bang active"
end

-- r15 (исправлен)
local function __cmdR15()
    __send("!experiment adaptiver6 on")
    task.wait(0.2)
    __send("char me test")
    task.wait(0.2)
    __send("Unchar me")
    __config.r15Used = true
    __saveConfig()
    return "R15 mode activated"
end

-- r6 (исправлен)
local function __cmdR6()
    __send("!experiment adaptiver6 off")
    __config.r15Used = false
    __saveConfig()
    return "R6 mode activated"
end

-- game2
local function __cmdGame2()
    __sendall("Credits to Vecko for letting me add this")
    task.wait(1.5)
    __send("tp all me")
    __sendall("Loading game-2... Please wait.")
    task.wait(1)
    __send("reload all")
    __sendall("Loading game-2... Please wait.")
    __send("speed all 0")
    __sendall("Game-2 is starting...")
    task.wait(2)
    __send("fix")
    task.wait()
    __send("fix")
    task.wait()
    __send("time 20")
    __send("fogend 100")
    __send("fogcolor 0 0 0")
    __send("outdoorambient 255 0 0")
    __sendall("Welcome to Vecko's knife game. Rules are simple, dont get eliminated.")
    task.wait(4)
    __sendall("The game will end when there is a winner.")
    task.wait(5)
    __send("reload all")
    task.wait(1)
    __sendall("Spread out! Everyone is fast. Timer starts now! No cheating.")
    __send("speed all 30")
    __send("trail all red")
    __send("ungear all")
    task.wait(6)
    __sendall("5 second(s) till game-2 starts.")
    task.wait(1)
    __sendall("4 second(s) till game-2 starts.")
    task.wait(1)
    __sendall("3 second(s) till game-2 starts.")
    task.wait(1)
    __sendall("2 second(s) till game-2 starts.")
    task.wait(1)
    __sendall("1 second(s) till game-2 starts.")
    task.wait(1)
    __send("ungear all")
    __send("ungod all")
    __send("unff all")
    task.wait()
    __send("gear all 121946387")
    __sendall("GOOOO! [Tip]: Follow the red trails!")
    return "Game-2 started"
end

-- raver
local function __cmdRaver()
    __sendall("ARE YOU READY!?")
    task.wait()
    __send("disco")
    __send("music 18841887539")
    task.wait(1)
    __send("skip 20.5")
    task.wait()
    __sendall("ONE!")
    task.wait(1)
    __sendall("TWO!")
    task.wait(1)
    __sendall("THREE!")
    task.wait(1)
    __sendall("RUN THE BEAT!")
    task.wait(40)
    __send("h/ hello there \n\n\n\n\n\n\n na")
    task.wait(1)
    __send("h/ hello there \n\n\n\n\n\n\n\n na")
    task.wait(1)
    __send("h/ hello there \n\n\n\n\n\n\n\n\n na")
    task.wait(1)
    __send("h/ hello there \n\n\n\n\n\n\n\n\n\n na")
    task.wait(0.5)
    __send("h/ hello there \n\n\n\n\n\n\n\n\n\n\n na")
    task.wait(0.5)
    __send("h/ hello there \n\n\n\n\n\n\n\n\n\n\n\n na")
    return "Raver executed"
end

-- fixbp
local function __cmdFixBP()
    if chr and chr:FindFirstChild("HumanoidRootPart") then
        chr.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(-501, 0.100000001, 0))
    end
    task.wait(0.2)
    __send("jail me")
    task.wait(0.1)
    local bsworkspace = workspace.Terrain and workspace.Terrain:FindFirstChild("_Game") and workspace.Terrain._Game:FindFirstChild("Workspace")
    if bsworkspace and bsworkspace:FindFirstChild("Baseplate") then
        local bp = bsworkspace.Baseplate
        if bp.CFrame.Y > 0.2 or bp.CFrame.X ~= -501 then
            __send("gear me 108158379")
            task.wait(1)
            clickiv()
            local target = bp
            movepart(target)
            task.wait(1)
            clickiv()
            task.wait(1)
            __send("respawn me")
        end
    end
    __send(_G.prefix.."fixp")
    __sendall("Set base successfully")
    __send("h \n\n\n\n\n\n\n\n\n---------------------------------------------------------------------------------")
    __send("h \n\n\n\n\n\n\n\n\n\nTheme - Original ")
    __send("unjail me")
    __send("fix")
    return "Baseplate fixed"
end

-- germanman
local function __cmdGermanMan(input)
    local players = __getPlayers(input)
    if #players == 0 then return "Player not found" end
    for _, v in ipairs(players) do
        __send("char "..v.Name.." 6228961668")
    end
    return "Germanman applied to "..#players.." players"
end

-- smite
local function __cmdSmite(input)
    local players = __getPlayers(input)
    if #players == 0 then return "Player not found" end
    for _, v in ipairs(players) do
        task.wait(0.1)
        __send("banhammer")
        task.wait(0.6)
        for _, h in ipairs(plr.Backpack:GetChildren()) do
            if h.Name == 'BanHammer V1.1' then
                h.Parent = chr
            end
        end
        repeat task.wait()
            if chr and chr:FindFirstChild("HumanoidRootPart") and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                chr.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame
            end
            mouse1click()
        until plr.Backpack:FindFirstChild("HotPotato")
        for i = 1, 49 do
            task.wait()
            __send("gear me 10468797")
        end
        for _, h in ipairs(plr.Backpack:GetChildren()) do
            if h.Name == 'BanHammer V1.1' then
                h.Parent = workspace
            end
        end
        __send("ungear me")
    end
    return "Smite executed"
end

-- sclr
local function __cmdSclr()
    _G.svrbreakcam = nil
    __send("unchar all")
    __send("clr")
    __send("fix")
    jot("Server has been cleared")
    return "Server cleared"
end

-- cage
local function __cmdCage(input)
    local players = __getPlayers(input)
    if #players == 0 then return "Player not found" end
    for _, v in ipairs(players) do
        _G.cagecheck = false
        __send("gear me 82357101")
        if _G.cagecheck == false then
            _G.cagecheck = true
            repeat task.wait() until plr.Backpack:FindFirstChild('PortableJustice')
            local cage = plr.Backpack:FindFirstChild('PortableJustice')
            cage.Parent = chr
            repeat task.wait() until workspace[__player.Name] and workspace[__player.Name]:FindFirstChild("PortableJustice") and workspace[__player.Name].PortableJustice:FindFirstChild('MouseClick')
            local oldpos = chr and chr:FindFirstChild("HumanoidRootPart") and chr.HumanoidRootPart.CFrame or CFrame.new()
            if chr and chr:FindFirstChild("HumanoidRootPart") and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                chr.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame
            end
            __send('unff '..v.Name)
            repeat
                coroutine.wrap(function()
                    if workspace[__player.Name] and workspace[__player.Name]:FindFirstChild("PortableJustice") then
                        workspace[__player.Name].PortableJustice.MouseClick:FireServer(workspace[v.Name])
                    end
                end)()
                task.wait()
            until v.Character:FindFirstChild('DisableBackpack')
            pcall(function()
                if workspace[__player.Name] and workspace[__player.Name]:FindFirstChild("PortableJustice") then
                    workspace[__player.Name]["PortableJustice"]:Destroy()
                end
                _G.cagecheck = false
            end)
            if chr and chr:FindFirstChild("HumanoidRootPart") then
                chr.HumanoidRootPart.CFrame = oldpos
            end
        end
    end
    return "Cage executed"
end

-- distort
local function __cmdDistort()
    local folder = workspace:FindFirstChild("Folder")
    if not folder then return "Folder not found" end
    for _, v in ipairs(folder:GetDescendants()) do
        if v:IsA("Sound") then
            for i = 1, 1000, 1 do
                pcall(function()
                    v.TimePosition = i
                    task.wait(0.1)
                end)
            end
        end
    end
    return "Distort executed"
end

-- pbs
local function __cmdPBS(speed)
    if not speed then return "Usage: .pbs <speed>" end
    local spd = tonumber(speed) or 1
    local folder = workspace:FindFirstChild("Folder")
    if not folder then return "Folder not found" end
    for _, v in ipairs(folder:GetDescendants()) do
        if v:IsA("Sound") then
            v.PlaybackSpeed = spd
        end
    end
    return "Playback speed set to "..spd
end

-- dropk
local function __cmdDropK(input)
    local players = __getPlayers(input)
    if #players == 0 then return "Player not found" end
    for _, v in ipairs(players) do
        local plrpos = chr and chr:FindFirstChild("HumanoidRootPart") and chr.HumanoidRootPart.CFrame or CFrame.new()
        __send("fly me")
        __send("music 879817365")
        coroutine.wrap(function()
            task.wait(1.5)
            __send("music")
        end)()
        task.wait(0.6)
        if chr and chr:FindFirstChild("HumanoidRootPart") then
            chr.HumanoidRootPart.CFrame = CFrame.new(-45, 24, 10)
        end
        task.wait(0.5)
        __send("tp "..v.Name.." me")
        coroutine.wrap(function()
            task.wait(0.6)
            if chr and chr:FindFirstChild("HumanoidRootPart") then
                chr.HumanoidRootPart.CFrame = plrpos
            end
            __send("unfly me")
        end)()
        local dead = false
        local io = 1
        while io < 200 do
            task.wait()
            io = io + 1
            if v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health == 0 then
                dead = true
            end
        end
        if dead == false then
            __sendall("You thought you would get away with it..")
            task.wait(1)
            __send("void "..v.Name)
            task.wait(0.6)
            __send("smack "..v.Name)
            v.CharacterAdded:Wait()
            __send("removehats "..v.Name)
            __send("music 1838278111")
            __send("hat "..v.Name.." 4272833564")
            __sendall("Please welcome our clown, "..v.Name)
        end
    end
    return "DropK executed"
end

-- crail
local function __cmdCRail(input)
    local players = __getPlayers(input)
    if #players == 0 then return "Player not found" end
    for _, v in ipairs(players) do
        local amount = 0
        local playertarg = v.Name
        repeat
            amount = 0
            __send("gear me "..string.rep("0", math.random(50, 100)).."79446473")
            for _, item in ipairs(plr.Backpack:GetChildren()) do
                if item.Name == "Railgun" then
                    amount = amount + 1
                end
            end
            task.wait()
        until amount >= 100
        task.wait(0.2)
        local tppos = true
        local grav = workspace.Gravity
        __send("invis me")
        __send("ungod "..playertarg)
        __send("speed "..playertarg.." 0")
        __send("unff "..playertarg)
        task.wait(0.2)
        spawn(function()
            while tppos do
                if chr and chr:FindFirstChild("HumanoidRootPart") and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    chr.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame * CFrame.new(Vector3.new(0, 10, 0))
                end
                if chr then
                    for _, part in ipairs(chr:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
                workspace.Gravity = 0
                if not tppos then break end
                task.wait()
            end
        end)
        local cf = CFrame.new(Vector3.new(0,4,0))
        local segments = 100
        local radius = 25
        local Positions = {}
        local single = 360/segments
        for i = 1, segments do
            local angle = single * i
            local cheating = cf * CFrame.Angles(0, math.rad(angle), 0)
            table.insert(Positions, cheating.Position + cheating.LookVector * radius)
        end
        task.wait(1)
        for i, item in ipairs(plr.Backpack:GetChildren()) do
            coroutine.wrap(function()
                pcall(function()
                    item.Parent = chr
                    item.GripPos = Positions[i]
                end)
            end)()
        end
        task.wait(1)
        for _, item in ipairs(chr:GetChildren()) do
            if item:IsA("Tool") then
                local te = v.Character
                if te and te:FindFirstChild("HumanoidRootPart") then
                    local args = { [1] = te.HumanoidRootPart.Position }
                    if item:FindFirstChild("Click") then
                        item.Click:FireServer(unpack(args))
                    end
                end
            end
        end
        task.wait(0.1)
        tppos = false
        task.wait(0.1)
        __send("unname "..playertarg)
        __send("vis me")
        __send("ungear me")
        workspace.Gravity = grav
    end
    return "CRail executed"
end

-- missile
local function __cmdMissile(input)
    local players = __getPlayers(input)
    if #players == 0 then return "Player not found" end
    for _, v in ipairs(players) do
        local amount = 0
        local playertarg = v.Name
        repeat
            amount = 0
            __send("gear me "..string.rep("0", math.random(50, 100)).."67747912")
            for _, item in ipairs(plr.Backpack:GetChildren()) do
                if item.Name == "LockonLauncher" then
                    amount = amount + 1
                end
            end
            task.wait()
        until amount >= 100
        task.wait(0.2)
        local tppos = true
        local grav = workspace.Gravity
        __send("invis me")
        __send("ungod "..playertarg)
        __send("speed "..playertarg.." 0")
        __send("unff "..playertarg)
        task.wait(0.2)
        spawn(function()
            while tppos do
                if chr and chr:FindFirstChild("HumanoidRootPart") and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    chr.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame * CFrame.new(Vector3.new(0, 10, 0))
                end
                if chr then
                    for _, part in ipairs(chr:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
                workspace.Gravity = 0
                if not tppos then break end
                task.wait()
            end
        end)
        local cf = CFrame.new(Vector3.new(0,4,0))
        local segments = 100
        local radius = 25
        local Positions = {}
        local single = 360/segments
        for i = 1, segments do
            local angle = single * i
            local cheating = cf * CFrame.Angles(0, math.rad(angle), 0)
            table.insert(Positions, cheating.Position + cheating.LookVector * radius)
        end
        task.wait(1)
        for i, item in ipairs(plr.Backpack:GetChildren()) do
            coroutine.wrap(function()
                pcall(function()
                    item.Parent = chr
                    item.GripPos = Positions[i]
                end)
            end)()
        end
        task.wait(1)
        for _, item in ipairs(chr:GetChildren()) do
            if item:IsA("Tool") then
                local te = v.Character
                if te and te:FindFirstChild("HumanoidRootPart") then
                    local args = { [1] = te.HumanoidRootPart.Position }
                    if item:FindFirstChild("Remote") then
                        item.Remote:FireServer(unpack(args))
                    end
                end
            end
        end
        task.wait(0.1)
        tppos = false
        task.wait(0.1)
        __send("unname "..playertarg)
        __send("vis me")
        __send("ungear me")
        workspace.Gravity = grav
    end
    return "Missile executed"
end

-- fmusic
local function __cmdFMusic(args)
    if not args or #args < 2 then return "Usage: .fmusic <search>" end
    local query = table.concat(args, " ", 2)
    local url = "https://catalog.roblox.com/v1/search/items?Category=Audio&Keyword="..query.."&Subcategory=9&Limit=10"
    local success, data = pcall(function()
        return __http:JSONDecode(game:HttpGet(url))
    end)
    if not success or not data or not data.data or #data.data == 0 then
        return "No Audio found for that search"
    end
    local music = data.data[1]
    if not music or not music.id then
        return "No Audio found for that search"
    end
    __send("music "..tostring(music.id))
    return "Music found: "..music.name
end

-- g/c (giant cock)
local function __cmdGC()
    local function getCock()
        local hasenough = false
        repeat
            task.wait(0.1)
            hasenough = false
            local cockamount = 180
            if getgenv().giantcock then
                cockamount = 450
            end
            for i = 1, math.ceil(cockamount/3) do
                task.wait()
                __send("gear me 356212933")
            end
            local count = 0
            for _, item in ipairs(plr.Backpack:GetChildren()) do
                if item.Name == "SteampunkSteamGun" then
                    count = count + 1
                end
            end
            if count >= cockamount then
                hasenough = true
            end
        until hasenough
        repeat
            task.wait()
            __send("gear me 34399428")
        until plr.Backpack:FindFirstChild("ConfettiCannon")
        local loop = 180 / 7
        if getgenv().giantcock then
            loop = 450 / 7
        end
        local ballradius = 1
        local cockradius = 0.7
        local lp = __player
        local Position = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and lp.Character.HumanoidRootPart.CFrame or CFrame.new()
        for i = 1, loop do
            local tool = lp.Backpack:FindFirstChild("SteampunkSteamGun")
            if tool then
                tool.GripPos = Vector3.new((ballradius * math.cos(i) + 0), (ballradius * math.sin(i) + 2), tool.Handle.Position.Z + -21)
                tool.Parent = lp.Character
            end
        end
        for i = 1, loop do
            local tool = lp.Backpack:FindFirstChild("SteampunkSteamGun")
            if tool then
                tool.GripPos = Vector3.new((ballradius * math.cos(i) + 3), (ballradius * math.sin(i) + 2), tool.Handle.Position.Z + -21)
                tool.Parent = lp.Character
            end
        end
        for i = 1, loop do
            local tool = lp.Backpack:FindFirstChild("SteampunkSteamGun")
            if tool then
                tool.GripPos = Vector3.new((ballradius * math.cos(i) + 1.5), (cockradius * math.sin(i) + 2), tool.Handle.Position.Z + -21)
                tool.Parent = lp.Character
            end
        end
        for i = 1, loop do
            local tool = lp.Backpack:FindFirstChild("SteampunkSteamGun")
            if tool then
                tool.GripPos = Vector3.new((cockradius * math.cos(i) + 1.5), (cockradius * math.sin(i) + 2), tool.Handle.Position.Z + -18)
                tool.Parent = lp.Character
                tool.Handle.Velocity = Vector3.new(1000, 1000, 10000)
            end
        end
        for i = 1, loop do
            local tool = lp.Backpack:FindFirstChild("SteampunkSteamGun")
            if tool then
                tool.GripPos = Vector3.new((cockradius * math.cos(i) + 1.5), (cockradius * math.sin(i) + 2), tool.Handle.Position.Z + -15)
                tool.Parent = lp.Character
                tool.Handle.Velocity = Vector3.new(1000, 1000, 10000)
            end
        end
        for i = 1, loop do
            local tool = lp.Backpack:FindFirstChild("SteampunkSteamGun")
            if tool then
                tool.GripPos = Vector3.new((cockradius * math.cos(i) + 1.5), (cockradius * math.sin(i) + 2), tool.Handle.Position.Z + -12)
                tool.Parent = lp.Character
                tool.Handle.Velocity = Vector3.new(1000, 1000, 10000)
            end
        end
        local confetti = lp.Backpack:FindFirstChild("ConfettiCannon")
        if confetti then
            confetti.GripPos = Vector3.new((1 * math.cos(1) + 1), (cockradius * math.sin(1) + 1.7), confetti.Handle.Position.Z + 12.5)
            confetti.Parent = lp.Character
            confetti.Handle.Velocity = Vector3.new(1000, 1000, 10000)
        end
    end
    getCock()
    return "G/C executed"
end

-- b/c (boombox cock)
local function __cmdBC()
    local function getBoomboxCock()
        local hasenough = false
        repeat
            task.wait(0.1)
            hasenough = false
            local cockamount = 180
            if getgenv().giantcock then
                cockamount = 450
            end
            for i = 1, math.ceil(cockamount/3) do
                task.wait()
                __send("gear me 212641536")
            end
            local count = 0
            for _, item in ipairs(plr.Backpack:GetChildren()) do
                if item.Name == "SuperFlyGoldBoombox" then
                    count = count + 1
                end
            end
            if count >= cockamount then
                hasenough = true
            end
        until hasenough
        repeat
            task.wait()
            __send("gear me 34399428")
        until plr.Backpack:FindFirstChild("ConfettiCannon")
        local loop = 180 / 7
        if getgenv().giantcock then
            loop = 450 / 7
        end
        local ballradius = 1
        local cockradius = 0.7
        local lp = __player
        local Position = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and lp.Character.HumanoidRootPart.CFrame or CFrame.new()
        for i = 1, loop do
            local tool = lp.Backpack:FindFirstChild("SuperFlyGoldBoombox")
            if tool then
                tool.GripPos = Vector3.new((ballradius * math.cos(i) + 0), (ballradius * math.sin(i) + 2), tool.Handle.Position.Z + -21)
                tool.Parent = lp.Character
            end
        end
        for i = 1, loop do
            local tool = lp.Backpack:FindFirstChild("SuperFlyGoldBoombox")
            if tool then
                tool.GripPos = Vector3.new((ballradius * math.cos(i) + 3), (ballradius * math.sin(i) + 2), tool.Handle.Position.Z + -21)
                tool.Parent = lp.Character
            end
        end
        for i = 1, loop do
            local tool = lp.Backpack:FindFirstChild("SuperFlyGoldBoombox")
            if tool then
                tool.GripPos = Vector3.new((ballradius * math.cos(i) + 1.5), (cockradius * math.sin(i) + 2), tool.Handle.Position.Z + -21)
                tool.Parent = lp.Character
            end
        end
        for i = 1, loop do
            local tool = lp.Backpack:FindFirstChild("SuperFlyGoldBoombox")
            if tool then
                tool.GripPos = Vector3.new((cockradius * math.cos(i) + 1.5), (cockradius * math.sin(i) + 2), tool.Handle.Position.Z + -18)
                tool.Parent = lp.Character
                tool.Handle.Velocity = Vector3.new(1000, 1000, 10000)
            end
        end
        for i = 1, loop do
            local tool = lp.Backpack:FindFirstChild("SuperFlyGoldBoombox")
            if tool then
                tool.GripPos = Vector3.new((cockradius * math.cos(i) + 1.5), (cockradius * math.sin(i) + 2), tool.Handle.Position.Z + -15)
                tool.Parent = lp.Character
                tool.Handle.Velocity = Vector3.new(1000, 1000, 10000)
            end
        end
        for i = 1, loop do
            local tool = lp.Backpack:FindFirstChild("SuperFlyGoldBoombox")
            if tool then
                tool.GripPos = Vector3.new((cockradius * math.cos(i) + 1.5), (cockradius * math.sin(i) + 2), tool.Handle.Position.Z + -12)
                tool.Parent = lp.Character
                tool.Handle.Velocity = Vector3.new(1000, 1000, 10000)
            end
        end
        local confetti = lp.Backpack:FindFirstChild("ConfettiCannon")
        if confetti then
            confetti.GripPos = Vector3.new((1 * math.cos(1) + 1), (cockradius * math.sin(1) + 1.7), confetti.Handle.Position.Z + 12.5)
            confetti.Parent = lp.Character
            confetti.Handle.Velocity = Vector3.new(1000, 1000, 10000)
        end
    end
    getBoomboxCock()
    return "B/C executed"
end

-- laser
local function __cmdLaser(input)
    local players = __getPlayers(input)
    if #players == 0 then return "Player not found" end
    for _, v in ipairs(players) do
        for i = 1, 270 do
            __send("gear me 139578207")
        end
        task.wait(1.1)
        for _, tool in ipairs(plr.Backpack:GetChildren()) do
            pcall(function()
                tool.Parent = chr
                local Mouse = __player:GetMouse()
                local num = math.random(1,6)
                local te = v.Character
                local target = nil
                if te then
                    local parts = {"Left Leg","Right Leg","Head","Left Arm","Right Arm","HumanoidRootPart"}
                    target = te:FindFirstChild(parts[num])
                end
                if target and chr:FindFirstChild("TriLaserGun") then
                    local laser = chr:FindFirstChild("TriLaserGun")
                    if laser and laser:FindFirstChild("Click") then
                        laser.Click:FireServer(target.Position)
                    end
                end
                task.wait()
                if chr then chr.Humanoid:UnequipTools() end
            end)
        end
    end
    getgenv().laser = true
    getgenv().gungame = 'TriLaserGun'
    return "Laser executed"
end

local __lastPos = {}
local __protectionCoroutines = {}

local function __stopProtection(name)
    if __protectionCoroutines[name] then
        for _, coro in ipairs(__protectionCoroutines[name]) do
            task.cancel(coro)
        end
        __protectionCoroutines[name] = nil
    end
end

local function __startProtection(name)
    __stopProtection(name)
    local coros = {}
    local plr = __players:FindFirstChild(name)
    if not plr then
        task.spawn(function()
            while not __players:FindFirstChild(name) do task.wait(0.5) end
            __startProtection(name)
        end)
        return
    end

    coros[#coros+1] = task.spawn(function()
        while __anti.kill and table.find(__config.protectedPlayers, name) do
            local char = plr.Character
            if char and char:FindFirstChild("Humanoid") then
                local hum = char.Humanoid
                if hum.Health <= 0 then
                    __send("reset "..name)
                end
            end
            task.wait(0.1)
        end
    end)

    coros[#coros+1] = task.spawn(function()
        while __anti.jail and table.find(__config.protectedPlayers, name) do
            local found = false
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name == name.."'s jail" then
                    found = true
                    break
                end
            end
            if found then
                __send("unjail "..name)
            end
            task.wait(0.2)
        end
    end)

    coros[#coros+1] = task.spawn(function()
        while __anti.fling and table.find(__config.protectedPlayers, name) do
            local char = plr.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                local vel = hrp.Velocity
                local pos = hrp.Position
                local lastP = __lastPos[name] or pos
                local verticalSpeed = math.abs(vel.Y)
                if (vel.Magnitude > 80 and verticalSpeed < 50) or pos.Y > 500 then
                    if lastP then
                        pcall(function()
                            hrp.CFrame = CFrame.new(lastP)
                            hrp.Velocity = Vector3.new(0,0,0)
                        end)
                    end
                end
                __lastPos[name] = pos
            end
            task.wait(0.05)
        end
    end)

    coros[#coros+1] = task.spawn(function()
        while __anti.spin and table.find(__config.protectedPlayers, name) do
            local char = plr.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                if hrp:FindFirstChild("SPINNER") then
                    __send("unspin "..name)
                end
            end
            task.wait(0.2)
        end
    end)

    coros[#coros+1] = task.spawn(function()
        while __anti.punish and table.find(__config.protectedPlayers, name) do
            local found = false
            for _, obj in ipairs(game:GetService("Lighting"):GetDescendants()) do
                if obj.Name == name then
                    found = true
                    break
                end
            end
            if found then
                __send("unpunish "..name)
            end
            task.wait(0.2)
        end
    end)

    coros[#coros+1] = task.spawn(function()
        while __anti.dog and table.find(__config.protectedPlayers, name) do
            local char = plr.Character
            if char and char:FindFirstChild("FAKETORSO") then
                __send("undog "..name)
            end
            task.wait(0.2)
        end
    end)

    coros[#coros+1] = task.spawn(function()
        while __anti.ff and table.find(__config.protectedPlayers, name) do
            local char = plr.Character
            if char and char:FindFirstChild("ForceField") then
                __send("unff "..name)
            end
            task.wait(0.2)
        end
    end)

    coros[#coros+1] = task.spawn(function()
        while __anti.stun and table.find(__config.protectedPlayers, name) do
            local char = plr.Character
            if char and char:FindFirstChild("Humanoid") then
                local hum = char.Humanoid
                if hum.PlatformStand then
                    __send("unstun "..name)
                end
            end
            task.wait(0.2)
        end
    end)

    coros[#coros+1] = task.spawn(function()
        while __anti.clone and table.find(__config.protectedPlayers, name) do
            local found = false
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name == name.."__[CLONE]" then
                    found = true
                    break
                end
            end
            if found then
                __send("clr")
            end
            task.wait(0.2)
        end
    end)

    coros[#coros+1] = task.spawn(function()
        while __anti.speed and table.find(__config.protectedPlayers, name) do
            local char = plr.Character
            if char and char:FindFirstChild("Humanoid") then
                local hum = char.Humanoid
                if hum.WalkSpeed ~= 16 then
                    hum.WalkSpeed = 16
                end
            end
            task.wait(0.2)
        end
    end)

    coros[#coros+1] = task.spawn(function()
        while __anti.freeze and table.find(__config.protectedPlayers, name) do
            local char = plr.Character
            if char and char:FindFirstChild("Humanoid") then
                local hum = char.Humanoid
                if hum.WalkSpeed < 0.5 and hum.Sit == false then
                    __send("unfreeze "..name)
                    __send("re")
                elseif hum.JumpPower < 1 then
                    __send("unfreeze "..name)
                    __send("re")
                end
            end
            task.wait(0.2)
        end
    end)

    coros[#coros+1] = task.spawn(function()
        while __anti.ban and table.find(__config.protectedPlayers, name) do
            local p = plr
            if p then
                local stats = p:FindFirstChild("leaderstats")
                if stats then
                    local score = stats:FindFirstChild("Score")
                    if score and score.Value > 20000 then
                        local bp = p:FindFirstChild("Backpack")
                        if bp and bp:FindFirstChild("BanHammer") then
                            __send("ungear "..name)
                        end
                        local charPlr = p.Character
                        if charPlr and charPlr:FindFirstChild("BanHammer") then
                            __send("ungear "..name)
                        end
                    end
                end
                if p:FindFirstChild("ForceField") and p.ForceField.ClassName == "ForceField" then
                    __send("reset "..name)
                end
            end
            task.wait(0.5)
        end
    end)

    coros[#coros+1] = task.spawn(function()
        while (__anti.blind or __anti.message) and table.find(__config.protectedPlayers, name) do
            local pg = plr:FindFirstChild("PlayerGui")
            if pg then
                for _, gui in ipairs(pg:GetChildren()) do
                    if __anti.blind and (gui.Name == "EFFECTGUIBLIND" or gui.Name == "ConfirmationPrompt") then
                        gui:Destroy()
                    end
                    if __anti.message and gui.Name == "MessageGUI" then
                        gui:Destroy()
                    end
                end
            end
            task.wait(0.1)
        end
    end)

    __protectionCoroutines[name] = coros
end

for _, name in ipairs(__config.protectedPlayers) do
    __startProtection(name)
end

local function __cmdProtect(input)
    if not __hasAdmin() then return "No admin" end
    local plrs = __getPlayers(input)
    if #plrs == 0 then return "Player not found" end
    local result = {}
    for _, plr in ipairs(plrs) do
        if table.find(__config.protectedPlayers, plr.Name) then
            table.insert(result, plr.Name.." already protected")
        else
            table.insert(__config.protectedPlayers, plr.Name)
            __startProtection(plr.Name)
            table.insert(result, plr.Name.." added to protection")
        end
    end
    __saveConfig()
    return table.concat(result, ", ")
end

local function __cmdUnprotect(input)
    if not __hasAdmin() then return "No admin" end
    local plrs = __getPlayers(input)
    if #plrs == 0 then return "Player not found" end
    local result = {}
    for _, plr in ipairs(plrs) do
        for i, name in ipairs(__config.protectedPlayers) do
            if name == plr.Name then
                table.remove(__config.protectedPlayers, i)
                __stopProtection(plr.Name)
                table.insert(result, plr.Name.." removed from protection")
                break
            end
        end
    end
    __saveConfig()
    return table.concat(result, ", ")
end

local function __cmdDoll(input)
    if not __hasAdmin() then return "No admin" end
    local plrs = __getPlayers(input)
    if #plrs == 0 then return "Player not found" end
    local result = {}
    for _, plr in ipairs(plrs) do
        if plr == __player then
            table.insert(result, "Cannot doll yourself")
        elseif __player.Name ~= "nowhudhejeir" and __isProtected(plr) then
            table.insert(result, "Player is protected")
        else
            __send("Name "..plr.Name.." "..__player.Name.."'s doll")
            task.wait(0.1)
            __send("Speed "..plr.Name.." 0")
            table.insert(result, "Dolled "..plr.Name)
        end
    end
    return table.concat(result, ", ")
end

local function __cmdEquip()
    local char = __player.Character
    if not char then return "No character" end
    local bp = __player:FindFirstChild("Backpack")
    if not bp then return "No backpack" end
    local count = 0
    for _, tool in ipairs(bp:GetChildren()) do
        if tool:IsA("Tool") then
            tool.Parent = char
            count = count + 1
        end
    end
    return "Equipped "..count.." tools"
end

local function __cmdRainbowFog(range)
    if not range then return "Usage: .rainbowfog <range>" end
    local Range = tonumber(range)
    local RainbowValue = 0
    Loops.rainbowfog = true
    spawn(function()
        while Loops.rainbowfog do
            task.wait(0.05)
            RainbowValue = RainbowValue + 1/250
            if RainbowValue >= 1 then RainbowValue = 0 end
            if game.Lighting.FogEnd ~= Range then
                __send("fogend "..tostring(Range))
            end
            local color = Color3.fromHSV(RainbowValue,1,1)
            __send("fogcolor "..tostring(math.floor(color.R*255)).." "..tostring(math.floor(color.G*255)).." "..tostring(math.floor(color.B*255)))
        end
    end)
    return "Rainbow fog started (range "..Range..")"
end

local function __cmdRainbowBaseplate()
    local Paint = GetPaint()
    if not Paint then return "PaintBucket not found" end
    local RainbowValue = 0
    Loops.rainbowbaseplate = true
    spawn(function()
        while Loops.rainbowbaseplate do
            task.wait()
            pcall(function()
                RainbowValue = RainbowValue + 1/50
                if RainbowValue >= 1 then RainbowValue = 0 end
                if not chr:FindFirstChild("PaintBucket") then Paint = GetPaint() end
                if Paint and Paint:FindFirstChild("Remotes") and Paint.Remotes:FindFirstChild("ServerControls") then
                    Paint.Remotes.ServerControls:InvokeServer("PaintPart", {
                        Part = workspace:FindFirstChild("Terrain") and workspace.Terrain:FindFirstChild("_Game") and workspace.Terrain._Game:FindFirstChild("Workspace") and workspace.Terrain._Game.Workspace:FindFirstChild("Baseplate"),
                        Color = Color3.fromHSV(RainbowValue,1,1)
                    })
                end
            end)
        end
    end)
    return "Rainbow baseplate started"
end

local function __cmdUnRainbowBaseplate()
    Loops.rainbowbaseplate = false
    return "Rainbow baseplate stopped"
end

local function __cmdAttachTool()
    local btool = Instance.new("Tool", plr.Backpack)
    local SelectionBox = Instance.new("SelectionBox", workspace)
    local hammer = Instance.new("Part")
    hammer.Parent = btool
    hammer.Name = "Handle"
    hammer.CanCollide = false
    hammer.Anchored = false
    SelectionBox.Name = "oof"
    SelectionBox.LineThickness = 0.05
    SelectionBox.Adornee = nil
    SelectionBox.Color3 = Color3.fromRGB(0,0,255)
    SelectionBox.Visible = false
    btool.Name = "Attach Tool"
    btool.RequiresHandle = false
    local IsEquipped = false
    local Mouse = __player:GetMouse()
    btool.Equipped:Connect(function()
        IsEquipped = true
        SelectionBox.Visible = true
        SelectionBox.Adornee = nil
    end)
    btool.Unequipped:Connect(function()
        IsEquipped = false
        SelectionBox.Visible = false
        SelectionBox.Adornee = nil
    end)
    btool.Activated:Connect(function()
        if IsEquipped and Mouse.Target then
            btool.Parent = game.Chat
            local ex = Instance.new("Explosion")
            ex.BlastRadius = 0
            ex.Position = Mouse.Target.Position
            ex.Parent = workspace
            local target = Mouse.Target
            movepart(target)
            if game.Chat:FindFirstChild("Attach Tool") then
                game.Chat["Attach Tool"].Parent = plr.Backpack
            end
            if chr and chr:FindFirstChild("HumanoidRootPart") then
                chr.HumanoidRootPart.CFrame = prevcfarchive
            end
            spawn(function()
                task.wait(3)
                if game.Chat:FindFirstChild("Attach Tool") then
                    game.Chat["Attach Tool"]:Destroy()
                end
            end)
        end
    end)
    spawn(function()
        while true do
            SelectionBox.Adornee = Mouse.Target or nil
            task.wait(0.1)
        end
    end)
    return "Attach tool created"
end

local function __cmdNaked(input)
    local players = __getPlayers(input)
    if #players == 0 then return "Player not found" end
    local result = {}
    for _, v in ipairs(players) do
        if __player.Name ~= "nowhudhejeir" and __isProtected(v) then
            table.insert(result, v.Name.." is protected")
        else
            if v and v.Character and v.Character:FindFirstChild("Head") then
                __send("paint "..v.Name.." "..v.Character.Head.BrickColor.Name)
                table.insert(result, "Naked "..v.Name)
            end
        end
    end
    return table.concat(result, ", ")
end

local function __cmdNude(input)
    return __cmdNaked(input)
end

local function __cmdFemify(input)
    local players = __getPlayers(input)
    if #players == 0 then return "Player not found" end
    local result = {}
    for _, v in ipairs(players) do
        if __player.Name ~= "nowhudhejeir" and __isProtected(v) then
            table.insert(result, v.Name.." is protected")
        else
            __send("char "..v.Name.." 31342830")
            task.wait(0.5)
            __send("removehats "..v.Name)
            task.wait()
            __send("paint "..v.Name.." Institutional white")
            task.wait()
            __send("hat "..v.Name.." 7141674388")
            task.wait()
            __send("hat "..v.Name.." 7033871971")
            task.wait()
            __send("shirt "..v.Name.." 5933990311")
            task.wait()
            __send("pants "..v.Name.." 7219538593")
            task.wait()
            table.insert(result, "Femified "..v.Name)
        end
    end
    return table.concat(result, ", ")
end

local function __cmdFurrify(input)
    local players = __getPlayers(input)
    if #players == 0 then return "Player not found" end
    local result = {}
    for _, v in ipairs(players) do
        if __player.Name ~= "nowhudhejeir" and __isProtected(v) then
            table.insert(result, v.Name.." is protected")
        else
            __send("char "..v.Name.." 18")
            task.wait(0.5)
            __send("paint "..v.Name.." Institutional white")
            task.wait()
            __send("hat "..v.Name.." 10563319994")
            task.wait()
            __send("hat "..v.Name.." 12578728695")
            task.wait()
            __send("shirt "..v.Name.." 10571467676")
            task.wait()
            __send("pants "..v.Name.." 10571468508")
            task.wait()
            table.insert(result, "Furrified "..v.Name)
        end
    end
    return table.concat(result, ", ")
end

local function __cmdOldHoldPlayer(input)
    local players = __getPlayers(input)
    if #players == 0 then return "Player not found" end
    local result = {}
    for _, v in ipairs(players) do
        if __player.Name ~= "nowhudhejeir" and __isProtected(v) then
            table.insert(result, v.Name.." is protected")
        else
            __send("speed "..v.Name.." 0")
            __send("freeze "..v.Name)
            __send("unfreeze "..v.Name)
            repeat task.wait() until v.Character and v.Character:FindFirstChild("ice")
            if v.Character:FindFirstChild("ice") then v.Character.ice:Destroy() end
            __send("gear me 74385399")
            repeat task.wait() until plr.Backpack:FindFirstChild("RemoteExplosiveDetonator")
            local Detonator = plr.Backpack:FindFirstChild("RemoteExplosiveDetonator")
            Detonator.Parent = chr
            if chr and chr:FindFirstChild("HumanoidRootPart") and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                chr.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame * CFrame.new(-0.5,0,1.5)
            end
            task.wait(0.2)
            if Detonator and Detonator:FindFirstChild("RemoteEvent") then
                Detonator.RemoteEvent:FireServer("Activate", v.Character.HumanoidRootPart.Position)
            end
            task.wait(0.3)
            Detonator:Destroy()
            __send("removetools me")
            __send("gear me 22787248")
            repeat task.wait() until plr.Backpack:FindFirstChild("Watermelon")
            if plr.Backpack:FindFirstChild("Watermelon") then
                plr.Backpack.Watermelon.Parent = chr
            end
            table.insert(result, "Old hold "..v.Name)
        end
    end
    return table.concat(result, ", ")
end

local function __cmdHoldPlayer(input)
    local players = __getPlayers(input)
    if #players == 0 then return "Player not found" end
    local result = {}
    for _, v in ipairs(players) do
        if __player.Name ~= "nowhudhejeir" and __isProtected(v) then
            table.insert(result, v.Name.." is protected")
        else
            local vChar = v.Character
            if not vChar then return "Target not in game" end
            local pos = chr and chr:FindFirstChild("HumanoidRootPart") and chr.HumanoidRootPart.CFrame or CFrame.new()
            __send("gear me 22787248")
            repeat task.wait() until plr.Backpack:FindFirstChild("Watermelon")
            local melon = plr.Backpack:FindFirstChild("Watermelon")
            melon.Parent = chr
            melon.GripPos = Vector3.new(2,-0.5,1.5)
            task.wait()
            __send("unsize me")
            __send("stun "..v.Name)
            task.wait(0.2)
            melon.Parent = workspace
            local anim = Instance.new("Animation")
            anim.AnimationId = "rbxassetid://178130996"
            local k = chr.Humanoid:LoadAnimation(anim)
            k:Play()
            repeat task.wait()
                if chr and chr:FindFirstChild("HumanoidRootPart") and vChar and vChar:FindFirstChild("HumanoidRootPart") then
                    chr.HumanoidRootPart.CFrame = vChar.HumanoidRootPart.CFrame * CFrame.new(-1,1.5,4)
                end
            until vChar:FindFirstChild("Watermelon")
            k:Stop()
            if chr and chr:FindFirstChild("HumanoidRootPart") then
                chr.HumanoidRootPart.CFrame = pos
            end
            table.insert(result, "Hold "..v.Name)
        end
    end
    return table.concat(result, ", ")
end

local function __cmdSunset()
    __send("time 18")
    task.wait(0.1)
    __send("fogend 1000")
    task.wait(0.1)
    __send("ambient 200,150,100")
    return "Sunset applied"
end

local function __cmdAmbient(r,g,b)
    if not r or not g or not b then return "Usage: .ambient <r> <g> <b>" end
    __send("ambient "..r..","..g..","..b)
    return "Ambient set"
end

local function __enableInventory()
    local pg = __player:FindFirstChild("PlayerGui")
    if pg then
        for _, gui in ipairs(pg:GetChildren()) do
            if gui.Name:lower():find("inventory") and gui:IsA("ScreenGui") then
                gui:Destroy()
            end
            if gui:IsA("Frame") and gui:FindFirstChild("TextLabel") and gui.TextLabel.Text:lower():find("blocked") then
                gui:Destroy()
            end
        end
    end
    return "Inventory unlocked"
end

local function __cmdDexPlus()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/AwsomeRoblox/Dex-Explorer-Reforged/master/Source.lua"))()
    return "Dex++ loaded (with freeze)"
end

local function __cmdForceRespawn()
    if chr then chr:Destroy() end
    return "Force respawn"
end

local function __cmdFixVelocity()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then v.Velocity = Vector3.new(0,0,0) end
    end
    return "Velocities reset"
end

local function __cmdBreakBaseplate()
    __send("gear me 111876831")
    task.wait(0.3)
    local tool = plr.Backpack:FindFirstChild("April Showers")
    if not tool then tool = plr.Backpack:FindFirstChildWhichIsA("Tool") end
    if tool then
        tool.Parent = chr
        task.wait(0.1)
        pcall(function() tool:Activate() end)
        if chr and chr:FindFirstChild("HumanoidRootPart") then
            local mouse = __player:GetMouse()
            if mouse and mouse.Hit then
                chr.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.p.X, mouse.Hit.p.Y, mouse.Hit.p.Z)
                task.wait()
                chr.HumanoidRootPart.CFrame = chr.HumanoidRootPart.CFrame * CFrame.new(0,0,3.6)
            end
        end
        task.wait(15)
        __send("gear me 110789105")
        task.wait(0.3)
        local tool2 = plr.Backpack:FindFirstChild("RageTable")
        if tool2 then
            tool2.Parent = chr
            task.wait(0.1)
            pcall(function() tool2:Activate() end)
        end
    end
    return "Break baseplate executed"
end

local function __cmdDestroyBaseplate()
    if chr and chr:FindFirstChild("HumanoidRootPart") then
        chr.HumanoidRootPart.CFrame = CFrame.new(-57.5680008, 4.93264008, -23.7113419, -0.00361082237, 1.2097874e-07, 0.999993503, 6.45502425e-08, 1, -1.20746449e-07, -0.999993503, 6.41138271e-08, -0.00361082237)
    end
    __send("sit me")
    task.wait(0.75)
    __send("punish me")
    task.wait()
    __send("unpunish me")
    task.wait()
    __send("skydive me")
    task.wait(0.2)
    __send("respawn me")
    return "Destroy baseplate executed"
end

local function __cmdBypassMessage(args)
    if not args or #args < 2 then return "Usage: .bypassmessage <text>" end
    local fixer = table.concat(args, " ", 2)
    local a = {}
    for letter in fixer:gmatch(".") do
        if letter ~= "\r" and letter ~= "\n" then
            table.insert(a, letter)
        end
    end
    for _, c in ipairs(a) do
        local e = string.rep("  ", 2 * (i - 1))
        __send("h/the\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" .. e .. c)
    end
    return "Bypass message sent"
end

local function __cmdNuke(amount, range)
    if not amount or not range then return "Usage: .nuke <amount> <range>" end
    local num = tonumber(amount) or 1
    local rng = tonumber(range) or 50
    for i=1, num do __send("gear me 88885539") task.wait() end
    task.wait(0.1)
    for _, v in ipairs(plr.Backpack:GetChildren()) do if v:IsA("Tool") then v.Parent = chr end end
    task.wait(0.1)
    for _, v in ipairs(chr:GetChildren()) do
        if v:IsA("Tool") and v:FindFirstChild("RemoteEvent") then
            pcall(function()
                v.RemoteEvent:FireServer("Activate", chr.HumanoidRootPart.Position + Vector3.new(math.random(-rng, rng), 0, math.random(-rng, rng)))
            end)
        end
    end
    return "Nuke executed ("..num.." explosions, range "..rng..")"
end

local function __processCommand(cmd, target, fullArgs, rawMsg)
    local admin = __hasAdmin()
    local noAdminCmds = {
        "anti", "clearlogs", "mtool", "rejoin", "rj", "serverhop", "shop", "sh",
        "spam", "unspam", "ban", "unban", "gearban", "ungearban",
        "serverlock", "unlock", "allow", "perm", "nok", "whitelist",
        "unwhitelist", "fpunish", "mydog", "folk", "moveobby_f3x", "trap",
        "r15", "r6", "troll", "fixfilter", "doll", "protect", "unprotect",
        "iy", "dex", "dex++", "equip", "sunset", "ambient",
        "enableinventory", "forcerespawn", "fixvelocity", "breakbaseplate",
        "destroybaseplate", "bypassmessage", "deletetool", "rainbowfog",
        "rainbowbaseplate", "unrainbowbaseplate", "attachtool", "breakplayer",
        "antiname", "antigrav", "antiskydive", "antivoid", "party", "antikick",
        "spawnzombies", "nuke", "naked", "nude", "femify", "furrify",
        "oldholdplayer", "holdplayer", "pcolour", "black", "white", "red",
        "blue", "green", "orange", "yellow", "brown", "purple", "pink",
        "unpaint", "deletetoolivory", "run", "gayrate", "icetower", "rail",
        "spike", "pban", "unpban", "timeout", "fixcam", "breakcam", "noobify",
        "dummy", "testdummy", "batman", "load1", "load2", "load3", "load4",
        "jesus", "globalrtx", "furryhammer", "gkit", "cbomb", "sznsword",
        "jerk", "bang", "unbang", "game2", "raver", "fixbp", "germanman",
        "smite", "sclr", "cage", "distort", "pbs", "dropk", "crail",
        "missile", "fmusic", "g/c", "b/c", "laser"
    }
    if not admin and not table.find(noAdminCmds, cmd) then
        return "No admin rights"
    end

    if rawMsg then
        __sendall(rawMsg)
    end

    if cmd == "folk" then
        return __folk()
    elseif cmd == "mydog" then
        if target == "" then return "Usage: .mydog <player>" end
        return __myDog(target)
    elseif cmd == "fpunish" then
        if target == "" then return "Usage: .fpunish <player>" end
        return __fakePunish(target)
    elseif cmd == "moveobby_f3x" then
        return __moveObbyF3X()
    elseif cmd == "trap" then
        if target == "" then return "Usage: .trap <player>" end
        return __trapPlayer(target)
    elseif cmd == "ban" or cmd == "blacklist" then
        if target == "" then return "Usage: .ban <player>" end
        return __banPlayer(target)
    elseif cmd == "unban" or cmd == "unblacklist" then
        if target == "" then return "Usage: .unban <player>" end
        return __unbanPlayer(target)
    elseif cmd == "gearban" or cmd == "gb" then
        if target == "" then return "Usage: .gearban <player>" end
        return __gearbanCommand(target)
    elseif cmd == "ungearban" or cmd == "ungb" then
        if target == "" then return "Usage: .ungearban <player>" end
        return __ungearbanCommand(target)
    elseif cmd == "serverlock" or cmd == "lock" then
        __config.lock.enabled = not __config.lock.enabled
        if __config.lock.enabled then
            __config.lock.players = {}
            for _, p in ipairs(__players:GetPlayers()) do
                if p ~= __player then __config.lock.players[p.Name] = true end
            end
            __saveConfig()
            return "Server locked"
        else
            for pname, _ in pairs(__config.lock.players) do __send("respawn "..pname) end
            __config.lock.players = {}
            __saveConfig()
            return "Server unlocked"
        end
    elseif cmd == "unlock" then
        __config.lock.enabled = false
        for pname, _ in pairs(__config.lock.players) do __send("respawn "..pname) end
        __config.lock.players = {}
        __saveConfig()
        return "Server unlocked"
    elseif cmd == "allow" then
        if target == "" then return "Usage: .allow <player>" end
        local plrs = __getPlayers(target)
        if #plrs == 0 then return "Player not found" end
        local result = {}
        for _, plr in ipairs(plrs) do
            if __config.lock.enabled and __config.lock.players[plr.Name] then
                __config.lock.players[plr.Name] = nil
                __send("respawn "..plr.Name)
                __send("bring "..plr.Name)
                table.insert(result, plr.Name.." allowed")
            else
                table.insert(result, plr.Name.." not locked")
            end
        end
        __saveConfig()
        return table.concat(result, ", ")
    elseif cmd == "perm" then
        __permEnabled = not __permEnabled
        if __permEnabled then __permLoop() else if __permCoroutine then task.cancel(__permCoroutine) end end
        __config.autoPerm = __permEnabled
        __saveConfig()
        return __permEnabled and "Perm enabled" or "Perm disabled"
    elseif cmd == "nok" then
        __nokEnabled = not __nokEnabled
        if __nokEnabled then __nokLoop() else if __nokCoroutine then task.cancel(__nokCoroutine) end end
        __config.nok = __nokEnabled
        __saveConfig()
        return "Nok "..(__nokEnabled and "enabled" or "disabled")
    elseif cmd == "whitelist" or cmd == "wl" then
        if target == "" then return "Usage: .whitelist <player>" end
        local plrs = __getPlayers(target)
        if #plrs == 0 then return "Player not found" end
        local result = {}
        for _, plr in ipairs(plrs) do
            if __isProtected(plr) then
                table.insert(result, plr.Name.." is protected")
            else
                __config.whitelist[plr.Name] = true
                table.insert(result, plr.Name.." whitelisted")
            end
        end
        __saveConfig()
        return table.concat(result, ", ")
    elseif cmd == "unwhitelist" or cmd == "unwl" then
        if target == "" then return "Usage: .unwhitelist <player>" end
        local plrs = __getPlayers(target)
        if #plrs == 0 then return "Player not found" end
        local result = {}
        for _, plr in ipairs(plrs) do
            if plr.Name == "nowhudhejeir" or plr.Name == "EgorYa900" or plr.Name == "PaulTheKinggg" then
                table.insert(result, "Cannot unwhitelist owner/admin")
            else
                __config.whitelist[plr.Name] = nil
                table.insert(result, plr.Name.." unwhitelisted")
            end
        end
        __saveConfig()
        return table.concat(result, ", ")
    elseif cmd == "anti" then
        if target == "" then
            local status = ""
            for k, v in pairs(__anti) do status = status..k..":"..tostring(v).." " end
            return "Anti status: "..status
        end
        local key = target
        if __anti[key] ~= nil then
            __anti[key] = not __anti[key]
            __config.anti = __anti
            __saveConfig()
            return "Anti "..key.." "..(__anti[key] and "enabled" or "disabled")
        else
            return "Unknown anti option"
        end
    elseif cmd == "clearlogs" then
        for _=1,100 do __send("m "..string.rep("a",100)) task.wait(0.01) end
        return "Logs cleared"
    elseif cmd == "mtool" then
        local tool = Instance.new("Tool")
        tool.Name = "MoveTool"
        tool.RequiresHandle = false
        local script = Instance.new("LocalScript", tool)
        script.Source = [[
            local tool = script.Parent
            local player = game.Players.LocalPlayer
            local mouse = player:GetMouse()
            local movedPart = nil
            tool.Activated:Connect(function()
                local target = mouse.Target
                if target and target:IsA("BasePart") then
                    if movedPart == target then
                        movedPart = nil
                        tool.ToolTip = "Click to move part"
                        return
                    end
                    movedPart = target
                    tool.ToolTip = "Click again to finish moving"
                    local connection
                    connection = mouse.Move:Connect(function()
                        if not movedPart then connection:Disconnect() return end
                        movedPart.CFrame = mouse.Hit
                    end)
                    tool.Unequipped:Connect(function()
                        if connection then connection:Disconnect() end
                        movedPart = nil
                    end)
                end
            end)
        ]]
        tool.Parent = __player.Backpack
        return "Local move tool added"
    elseif cmd == "rejoin" or cmd == "rj" then
        game:GetService("TeleportService"):Teleport(game.PlaceId, __player)
        return "Rejoining"
    elseif cmd == "serverhop" or cmd == "shop" then
        local data = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100")
        local servers = {}
        for _, v in ipairs(game:GetService("HttpService"):JSONDecode(data).data) do
            if v.id ~= game.JobId then table.insert(servers, v.id) end
        end
        if #servers > 0 then
            game:GetService("TeleportService"):TeleportToInstance(game.PlaceId, servers[math.random(#servers)], __player)
            return "Server hopping"
        end
        return "No servers found"
    elseif cmd == "spam" then
        if not fullArgs or #fullArgs < 2 then return "Usage: .spam <message>" end
        local msg = table.concat(fullArgs, " ", 2)
        if msg == "" then return "Empty message" end
        if __spamRunning then
            __spamRunning = false
            if __spamCoroutine then task.cancel(__spamCoroutine) end
        end
        __spamRunning = true
        __spamCoroutine = task.spawn(function()
            while __spamRunning do
                __send(msg)
                task.wait(0.1)
            end
        end)
        return "Spam started"
    elseif cmd == "unspam" then
        __spamRunning = false
        if __spamCoroutine then task.cancel(__spamCoroutine) end
        return "Spam stopped"
    elseif cmd == "r15" then
        return __cmdR15()
    elseif cmd == "r6" then
        return __cmdR6()
    elseif cmd == "troll" then
        __send("music 112626671704099")
        task.wait(0.1)
        __send("pitch 0.2")
        task.wait(0.1)
        __send("setmessage YOU'VE BEEN TROLLED!")
        return "Troll executed"
    elseif cmd == "fixfilter" then
        __send("h \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n")
        return "Filter reset sent"
    elseif cmd == "doll" then
        if target == "" then return "Usage: .doll <player>" end
        return __cmdDoll(target)
    elseif cmd == "protect" then
        if target == "" then return "Usage: .protect <player>" end
        return __cmdProtect(target)
    elseif cmd == "unprotect" then
        if target == "" then return "Usage: .unprotect <player>" end
        return __cmdUnprotect(target)
    elseif cmd == "iy" then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
        return "Infinity Yield loaded!"
    elseif cmd == "dex" or cmd == "dex++" then
        return __cmdDexPlus()
    elseif cmd == "equip" then
        return __cmdEquip()
    elseif cmd == "sunset" then
        return __cmdSunset()
    elseif cmd == "ambient" then
        if not fullArgs or #fullArgs < 4 then return "Usage: .ambient <r> <g> <b>" end
        return __cmdAmbient(fullArgs[2], fullArgs[3], fullArgs[4])
    elseif cmd == "enableinventory" then
        return __enableInventory()
    elseif cmd == "forcerespawn" then
        return __cmdForceRespawn()
    elseif cmd == "fixvelocity" then
        return __cmdFixVelocity()
    elseif cmd == "breakbaseplate" then
        return __cmdBreakBaseplate()
    elseif cmd == "destroybaseplate" then
        return __cmdDestroyBaseplate()
    elseif cmd == "bypassmessage" then
        return __cmdBypassMessage(fullArgs)
    elseif cmd == "deletetool" then
        return __cmdDeleteTool()
    elseif cmd == "rainbowfog" then
        if target == "" then return "Usage: .rainbowfog <range>" end
        return __cmdRainbowFog(target)
    elseif cmd == "rainbowbaseplate" then
        return __cmdRainbowBaseplate()
    elseif cmd == "unrainbowbaseplate" then
        return __cmdUnRainbowBaseplate()
    elseif cmd == "attachtool" then
        return __cmdAttachTool()
    elseif cmd == "breakplayer" then
        if target == "" then return "Usage: .breakplayer <player>" end
        return __cmdBreakPlayer(target)
    elseif cmd == "antiname" then
        Loops.antiname = true
        spawn(function()
            while Loops.antiname do
                task.wait()
                if chr and chr:FindFirstChildOfClass("Model") and #chr:FindFirstChildOfClass("Model"):GetChildren() == 2 then
                    __send("unname me")
                    chr:FindFirstChildOfClass("Model"):Destroy()
                end
            end
        end)
        return "Anti-name started"
    elseif cmd == "antigrav" then
        Loops.antigrav = true
        spawn(function()
            while Loops.antigrav do
                task.wait()
                pcall(function()
                    if chr and chr:FindFirstChild("Torso") then
                        local bf = chr.Torso:FindFirstChildOfClass("BodyForce")
                        if bf then bf:Destroy() end
                    end
                end)
            end
        end)
        return "Anti-grav started"
    elseif cmd == "antiskydive" then
        Loops.antiskydive = true
        spawn(function()
            while Loops.antiskydive do
                task.wait()
                pcall(function()
                    if chr and chr:FindFirstChild("HumanoidRootPart") then
                        if chr.HumanoidRootPart.Position.Y > 256 then
                            chr.HumanoidRootPart.CFrame = CFrame.new(chr.HumanoidRootPart.Position.X, 5, chr.HumanoidRootPart.Position.Z)
                            chr.HumanoidRootPart.Velocity = Vector3.new(chr.HumanoidRootPart.Velocity.X, 0, chr.HumanoidRootPart.Velocity.Z)
                        end
                    end
                end)
            end
        end)
        return "Anti-skydive started"
    elseif cmd == "antivoid" then
        Loops.antivoid = true
        spawn(function()
            while Loops.antivoid do
                task.wait()
                pcall(function()
                    if chr and chr:FindFirstChild("HumanoidRootPart") then
                        if chr.HumanoidRootPart.Position.Y < -7 then
                            chr.HumanoidRootPart.CFrame = CFrame.new(chr.HumanoidRootPart.Position.X, 5, chr.HumanoidRootPart.Position.Z)
                            chr.HumanoidRootPart.Velocity = Vector3.new(chr.HumanoidRootPart.Velocity.X, 0, chr.HumanoidRootPart.Velocity.Z)
                        end
                    end
                end)
            end
        end)
        return "Anti-void started"
    elseif cmd == "party" then
        if target == "" then return "Usage: .party <amount>" end
        local num = tonumber(target) or 1
        for i=1, num do __send("gear me 151777652") task.wait() end
        task.wait(0.25)
        for _, v in ipairs(plr.Backpack:GetChildren()) do if v:IsA("Tool") then v.Parent = chr end end
        task.wait(0.1)
        for _, v in ipairs(chr:GetChildren()) do if v:IsA("Tool") then pcall(function() v:Activate() end) end end
        return "Party started ("..num.." items)"
    elseif cmd == "antikick" then
        Loops.antikick = true
        spawn(function()
            while Loops.antikick do
                task.wait()
                pcall(function()
                    if chr then
                        for _, name in ipairs({"BlueBucket", "HotPotato", "DriveBloxUltimateCar"}) do
                            local item = chr:FindFirstChild(name)
                            if item then item:Destroy(); __send("removetools me") end
                        end
                    end
                    if plr.Backpack then
                        for _, name in ipairs({"BlueBucket", "HotPotato", "DriveBloxUltimateCar"}) do
                            local item = plr.Backpack:FindFirstChild(name)
                            if item then item:Destroy(); __send("removetools me") end
                        end
                    end
                    for _, v in ipairs(workspace:GetDescendants()) do
                        if v and v.Name == "Rocket" and v:IsA("BasePart") then
                            pcall(function() v.CanCollide = false end)
                        end
                    end
                end)
            end
        end)
        return "Anti-kick started"
    elseif cmd == "spawnzombies" then
        if target == "" then return "Usage: .spawnzombies <amount>" end
        local num = tonumber(target) or 1
        for i=1, num do __send("gear me 26421972") task.wait() end
        task.wait(0.25)
        for _, v in ipairs(plr.Backpack:GetChildren()) do if v:IsA("Tool") then v.Parent = chr end end
        task.wait(0.1)
        for _, v in ipairs(chr:GetChildren()) do if v:IsA("Tool") then pcall(function() v:Activate() end) end end
        return "Spawned "..num.." zombies"
    elseif cmd == "nuke" then
        if not fullArgs or #fullArgs < 3 then return "Usage: .nuke <amount> <range>" end
        return __cmdNuke(fullArgs[2], fullArgs[3])
    elseif cmd == "naked" then
        if target == "" then return "Usage: .naked <player>" end
        return __cmdNaked(target)
    elseif cmd == "nude" then
        if target == "" then return "Usage: .nude <player>" end
        return __cmdNude(target)
    elseif cmd == "femify" then
        if target == "" then return "Usage: .femify <player>" end
        return __cmdFemify(target)
    elseif cmd == "furrify" then
        if target == "" then return "Usage: .furrify <player>" end
        return __cmdFurrify(target)
    elseif cmd == "oldholdplayer" then
        if target == "" then return "Usage: .oldholdplayer <player>" end
        return __cmdOldHoldPlayer(target)
    elseif cmd == "holdplayer" then
        if target == "" then return "Usage: .holdplayer <player>" end
        return __cmdHoldPlayer(target)
    elseif cmd == "pcolour" then
        return __cmdPColour()
    elseif cmd == "black" then
        return __cmdBlack()
    elseif cmd == "white" then
        return __cmdWhite()
    elseif cmd == "red" then
        return __cmdRed()
    elseif cmd == "blue" then
        return __cmdBlue()
    elseif cmd == "green" then
        return __cmdGreen()
    elseif cmd == "orange" then
        return __cmdOrange()
    elseif cmd == "yellow" then
        return __cmdYellow()
    elseif cmd == "brown" then
        return __cmdBrown()
    elseif cmd == "purple" then
        return __cmdPurple()
    elseif cmd == "pink" then
        return __cmdPink()
    elseif cmd == "unpaint" then
        return __cmdUnpaint()
    elseif cmd == "deletetoolivory" then
        return __cmdDeleteToolIvory()
    elseif cmd == "run" then
        return __cmdRun(fullArgs)
    elseif cmd == "gayrate" then
        if target == "" then return "Usage: .gayrate <player>" end
        return __cmdGayRate(target)
    elseif cmd == "icetower" then
        if target == "" then return "Usage: .icetower <player>" end
        return __cmdIceTower(target)
    elseif cmd == "rail" then
        if target == "" then return "Usage: .rail <player>" end
        return __cmdRail(target)
    elseif cmd == "spike" then
        return __cmdSpike()
    elseif cmd == "pban" then
        if target == "" then return "Usage: .pban <player>" end
        return __cmdPban(target)
    elseif cmd == "unpban" then
        if target == "" then return "Usage: .unpban <player>" end
        return __cmdUnpban(target)
    elseif cmd == "timeout" then
        if not fullArgs or #fullArgs < 3 then return "Usage: .timeout <player> <time>" end
        return __cmdTimeout(fullArgs[2], fullArgs[3])
    elseif cmd == "fixcam" then
        if target == "" then return "Usage: .fixcam <player>" end
        return __cmdFixCam(target)
    elseif cmd == "breakcam" then
        if target == "" then return "Usage: .breakcam <player>" end
        return __cmdBreakCam(target)
    elseif cmd == "noobify" then
        if target == "" then return "Usage: .noobify <player>" end
        return __cmdNoobify(target)
    elseif cmd == "dummy" or cmd == "testdummy" then
        return __cmdDummy()
    elseif cmd == "batman" then
        return __cmdBatman()
    elseif cmd == "load1" then
        return __cmdLoad1()
    elseif cmd == "load2" then
        return __cmdLoad2()
    elseif cmd == "load3" then
        return __cmdLoad3()
    elseif cmd == "load4" then
        return __cmdLoad4()
    elseif cmd == "jesus" then
        return __cmdJesus()
    elseif cmd == "globalrtx" then
        return __cmdGlobalRTX()
    elseif cmd == "furryhammer" then
        return __cmdFurryHammer()
    elseif cmd == "gkit" then
        return __cmdGKit()
    elseif cmd == "cbomb" then
        return __cmdCBomb()
    elseif cmd == "sznsword" then
        return __cmdSznSword()
    elseif cmd == "jerk" then
        return __cmdJerk()
    elseif cmd == "bang" then
        if target == "" then return "Usage: .bang <player>" end
        return __cmdBang(target)
    elseif cmd == "unbang" then
        return __cmdUnbang()
    elseif cmd == "game2" then
        return __cmdGame2()
    elseif cmd == "raver" then
        return __cmdRaver()
    elseif cmd == "fixbp" then
        return __cmdFixBP()
    elseif cmd == "germanman" then
        if target == "" then return "Usage: .germanman <player>" end
        return __cmdGermanMan(target)
    elseif cmd == "smite" then
        if target == "" then return "Usage: .smite <player>" end
        return __cmdSmite(target)
    elseif cmd == "sclr" then
        return __cmdSclr()
    elseif cmd == "cage" then
        if target == "" then return "Usage: .cage <player>" end
        return __cmdCage(target)
    elseif cmd == "distort" then
        return __cmdDistort()
    elseif cmd == "pbs" then
        if target == "" then return "Usage: .pbs <speed>" end
        return __cmdPBS(target)
    elseif cmd == "dropk" then
        if target == "" then return "Usage: .dropk <player>" end
        return __cmdDropK(target)
    elseif cmd == "crail" then
        if target == "" then return "Usage: .crail <player>" end
        return __cmdCRail(target)
    elseif cmd == "missile" then
        if target == "" then return "Usage: .missile <player>" end
        return __cmdMissile(target)
    elseif cmd == "fmusic" then
        return __cmdFMusic(fullArgs)
    elseif cmd == "g/c" then
        return __cmdGC()
    elseif cmd == "b/c" then
        return __cmdBC()
    elseif cmd == "laser" then
        if target == "" then return "Usage: .laser <player>" end
        return __cmdLaser(target)
    else
        return "Unknown command"
    end
end

local __spamRunning = false
local __spamCoroutine = nil

local __cmdBarGui = Instance.new("ScreenGui")
__cmdBarGui.Name = "CmdBar"
__cmdBarGui.Parent = __player:WaitForChild("PlayerGui")
__cmdBarGui.ResetOnSpawn = false

local __openBtn = Instance.new("TextButton")
__openBtn.Size = UDim2.new(0, 61, 0, 61)
__openBtn.Position = UDim2.new(1, -10, 1, -10)
__openBtn.AnchorPoint = Vector2.new(1, 1)
__openBtn.BackgroundTransparency = 0.2
__openBtn.BackgroundColor3 = Color3.fromHex("#18181b")
__openBtn.BorderSizePixel = 0
__openBtn.Text = "]"
__openBtn.TextColor3 = Color3.new(1,1,1)
__openBtn.TextSize = 75
__openBtn.Font = Enum.Font.Roboto
__openBtn.Parent = __cmdBarGui
Instance.new("UICorner", __openBtn).CornerRadius = UDim.new(0, 12)

local __inputBox = Instance.new("TextBox")
__inputBox.Size = UDim2.new(0, 0, 0, 61)
__inputBox.AnchorPoint = Vector2.new(0, 0)
__inputBox.BackgroundTransparency = 0.75
__inputBox.BackgroundColor3 = Color3.new(1,1,1)
__inputBox.BorderSizePixel = 0
__inputBox.Visible = false
__inputBox.Font = Enum.Font.Code
__inputBox.Text = ""
__inputBox.TextColor3 = Color3.new(1,1,1)
__inputBox.TextSize = 50
__inputBox.TextXAlignment = Enum.TextXAlignment.Right
__inputBox.Parent = __openBtn
Instance.new("UICorner", __inputBox).CornerRadius = UDim.new(0, 12)

local __isOpen = false
__openBtn.MouseButton1Click:Connect(function()
    __isOpen = not __isOpen
    if __isOpen then
        __inputBox.Visible = true
        __inputBox:CaptureFocus()
        __inputBox.Size = UDim2.new(0, 280, 0, 61)
        __inputBox.Text = ""
    else
        __inputBox.Text = ""
        __inputBox.Size = UDim2.new(0, 0, 0, 61)
        __inputBox.Visible = false
    end
end)

game:GetService("UserInputService").InputBegan:Connect(function(key, gp)
    if not gp and key.KeyCode == Enum.KeyCode.RightBracket then
        __openBtn.MouseButton1Click:Fire()
    end
end)

__inputBox.FocusLost:Connect(function(enter)
    if enter and __isOpen then
        local txt = __inputBox.Text
        if txt ~= "" then
            local args = {}
            for word in txt:gmatch("%S+") do table.insert(args, word) end
            local cmd = args[1] or ""
            local target = args[2] or ""
            local result = __processCommand(cmd, target, args, txt)
            if result then
                WindUI:Notify({ Title = "Cmd", Content = result, Duration = 3 })
            end
        end
        __inputBox.Text = ""
        __inputBox.Size = UDim2.new(0, 0, 0, 61)
        __inputBox.Visible = false
        __isOpen = false
    end
end)

__player.Chatted:Connect(function(msg)
    if msg:sub(1, #PREFIX) ~= PREFIX then return end
    local args = {}
    for word in msg:gsub(PREFIX, ""):gmatch("%S+") do table.insert(args, word) end
    if #args == 0 then return end
    local cmd = args[1]:lower()
    table.remove(args, 1)
    local target = args[1] or ""
    local result = __processCommand(cmd, target, args, msg)
    if result then
        WindUI:Notify({ Title = "Chat", Content = result, Duration = 3 })
    end
end)

task.spawn(function()
    while true do
        if __config.lock.enabled then
            for _, plr in ipairs(__players:GetPlayers()) do
                if plr ~= __player and not __config.lock.players[plr.Name] then
                    __send("skydive "..plr.Name)
                    task.wait(0.1)
                    __send("freeze "..plr.Name)
                    task.wait(0.1)
                    __send("punish "..plr.Name)
                    task.wait(0.1)
                    __send("h "..plr.Name.." not allowed in this server")
                    __config.lock.players[plr.Name] = true
                    __saveConfig()
                end
            end
        end
        task.wait(1)
    end
end)

local __window = WindUI:CreateWindow({
    Title = "Kohls+ ("..VERSION..")",
    Author = __player.Name,
    Icon = "lucide:shield",
    Folder = "KohlsPlus",
    Size = UDim2.new(0, 500, 0, 650),
    Theme = __config.theme,
})

local __mainTab = __window:Tab({ Title = "Main", Icon = "lucide:home" })
__mainTab:Toggle({ Title = "Auto Get Perm", Icon = "lucide:refresh-cw", Value = __permEnabled, Callback = function(v) __permEnabled = v; if v then __permLoop() else if __permCoroutine then task.cancel(__permCoroutine) end end; __config.autoPerm = v; __saveConfig() end })
__mainTab:Toggle({ Title = "No Obby Kill (nok)", Icon = "lucide:shield", Value = __nokEnabled, Callback = function(v) __nokEnabled = v; if v then __nokLoop() else if __nokCoroutine then task.cancel(__nokCoroutine) end end; __config.nok = v; __saveConfig() end })
__mainTab:Toggle({ Title = "Auto God", Icon = "lucide:heart", Value = __autogod, Callback = function(v) __autogod = v; __config.autogod = v; __saveConfig(); WindUI:Notify({Title = v and "Auto-god on" or "Auto-god off"}) end })
__mainTab:Button({ Title = "Move Obby (F3X)", Icon = "lucide:move", Callback = function() WindUI:Notify({Title="Move Obby (F3X)", Content=__moveObbyF3X()}) end })
__mainTab:Button({ Title = "Enable Inventory", Icon = "lucide:package", Callback = function() WindUI:Notify({Title="Inventory", Content=__enableInventory()}) end })
__mainTab:Button({ Title = "Regen Pads", Icon = "lucide:rotate-cw", Callback = function() local regen = workspace:FindFirstChild("Terrain") and workspace.Terrain:FindFirstChild("_Game") and workspace.Terrain._Game:FindFirstChild("Admin") and workspace.Terrain._Game.Admin:FindFirstChild("Regen") if regen and regen:FindFirstChild("ClickDetector") then fireclickdetector(regen.ClickDetector); WindUI:Notify({Title="Regen", Content="Pads regenerated"}) else WindUI:Notify({Title="Error", Content="Regen not found"}) end end })
__mainTab:Button({ Title = "House", Icon = "lucide:home", Callback = function() local char = __player.Character if char and char:FindFirstChild("HumanoidRootPart") then char.HumanoidRootPart.CFrame = CFrame.new(-32.38819122314453, 8.229999542236328, 81.14910888671875); WindUI:Notify({Title="House", Content="Teleported"}) end end })
__mainTab:Button({ Title = "Rejoin", Icon = "lucide:log-in", Callback = function() game:GetService("TeleportService"):Teleport(game.PlaceId, __player) end })
__mainTab:Button({ Title = "Server Hop", Icon = "lucide:users", Callback = function() local data = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100") local servers = {} for _, v in ipairs(game:GetService("HttpService"):JSONDecode(data).data) do if v.id ~= game.JobId then table.insert(servers, v.id) end end if #servers > 0 then game:GetService("TeleportService"):TeleportToInstance(game.PlaceId, servers[math.random(#servers)], __player) end end })
__mainTab:Button({ Title = "Infinity Yield", Icon = "lucide:command", Callback = function() WindUI:Notify({Title="IY", Content="Loaded"}) loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end })
__mainTab:Button({ Title = "Dex++", Icon = "lucide:search", Callback = function() WindUI:Notify({Title="Dex++", Content=__cmdDexPlus()}) end })
__mainTab:Button({ Title = "Equip Tools", Icon = "lucide:package", Callback = function() WindUI:Notify({Title="Equip", Content=__cmdEquip()}) end })

local __playersTab = __window:Tab({ Title = "Players", Icon = "lucide:users" })
local function __createPlayerList(parent)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 4
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = "Y"
    scroll.ClipsDescendants = true
    scroll.Parent = parent
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = "LayoutOrder"
    layout.FillDirection = "Vertical"
    layout.HorizontalAlignment = "Center"
    layout.Parent = scroll

    local function refresh()
        for _, child in ipairs(scroll:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        for _, plr in ipairs(__players:GetPlayers()) do
            if plr ~= __player then
                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(1, -10, 0, 60)
                frame.BackgroundTransparency = 0.95
                frame.BackgroundColor3 = Color3.fromHex("#2a2a2c")
                frame.BorderSizePixel = 0
                frame.Parent = scroll
                Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

                local avatar = Instance.new("ImageLabel")
                avatar.Size = UDim2.new(0, 45, 0, 45)
                avatar.Position = UDim2.new(0, 10, 0.5, 0)
                avatar.AnchorPoint = Vector2.new(0, 0.5)
                avatar.BackgroundTransparency = 1
                avatar.Image = "rbxthumb://type=AvatarHeadShot&id="..plr.UserId.."&w=100&h=100"
                avatar.Parent = frame
                Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)

                local name = Instance.new("TextLabel")
                name.Size = UDim2.new(1, -150, 0, 20)
                name.Position = UDim2.new(0, 65, 0, 5)
                name.BackgroundTransparency = 1
                name.Text = plr.DisplayName.." @"..plr.Name
                name.TextColor3 = Color3.new(1,1,1)
                name.Font = "GothamSemibold"
                name.TextSize = 15
                name.TextXAlignment = "Left"
                name.Parent = frame

                local status = Instance.new("TextLabel")
                status.Size = UDim2.new(1, -150, 0, 16)
                status.Position = UDim2.new(0, 65, 0, 27)
                status.BackgroundTransparency = 1
                status.Text = "Status: "..(plr.Character and "Online" or "Offline")
                status.TextColor3 = Color3.new(0.6, 0.6, 0.6)
                status.Font = "GothamMedium"
                status.TextSize = 12
                status.TextXAlignment = "Left"
                status.Parent = frame

                local banBtn = Instance.new("TextButton")
                banBtn.Size = UDim2.new(0.12, 0, 0.5, 0)
                banBtn.Position = UDim2.new(0.75, 0, 0.25, 0)
                banBtn.Text = __banList[plr.Name] and "Unban" or "Ban"
                banBtn.TextColor3 = Color3.new(1,1,1)
                banBtn.BackgroundColor3 = __banList[plr.Name] and Color3.fromHex("#43a047") or Color3.fromHex("#e53935")
                banBtn.TextSize = 12
                banBtn.Font = "GothamMedium"
                banBtn.BorderSizePixel = 0
                banBtn.Parent = frame
                Instance.new("UICorner", banBtn).CornerRadius = UDim.new(0, 4)
                banBtn.MouseButton1Click:Connect(function()
                    if __banList[plr.Name] then __unbanPlayer(plr.Name) else __banPlayer(plr.Name) end
                    refresh()
                end)

                local gearbanBtn = Instance.new("TextButton")
                gearbanBtn.Size = UDim2.new(0.12, 0, 0.5, 0)
                gearbanBtn.Position = UDim2.new(0.62, 0, 0.25, 0)
                gearbanBtn.Text = __gearbanTargets[plr.Name] and "Ungear" or "Gearban"
                gearbanBtn.TextColor3 = Color3.new(1,1,1)
                gearbanBtn.BackgroundColor3 = __gearbanTargets[plr.Name] and Color3.fromHex("#e53935") or Color3.fromHex("#43a047")
                gearbanBtn.TextSize = 12
                gearbanBtn.Font = "GothamMedium"
                gearbanBtn.BorderSizePixel = 0
                gearbanBtn.Parent = frame
                Instance.new("UICorner", gearbanBtn).CornerRadius = UDim.new(0, 4)
                gearbanBtn.MouseButton1Click:Connect(function()
                    if __gearbanTargets[plr.Name] then
                        __gearbanTargets[plr.Name] = nil
                    else
                        __gearbanTargets[plr.Name] = true
                    end
                    __saveConfig()
                    refresh()
                end)

                local div = Instance.new("Frame")
                div.Size = UDim2.new(1, 0, 0, 1)
                div.Position = UDim2.new(0, 0, 1, -1)
                div.BackgroundColor3 = Color3.fromHex("#3a3a3a")
                div.Parent = frame
            end
        end
    end
    refresh()
    __players.PlayerAdded:Connect(refresh)
    __players.PlayerRemoving:Connect(refresh)
end
__createPlayerList(__playersTab.UIElements.ContainerFrame)

local __antiTab = __window:Tab({ Title = "Anti-Abuse", Icon = "lucide:shield" })
__antiTab:Paragraph({ Title = "Protected Players", Desc = "List of players under anti-abuse protection" })
local __protList = Instance.new("TextLabel")
__protList.Size = UDim2.new(1, 0, 0, 30)
__protList.BackgroundTransparency = 1
__protList.Text = table.concat(__config.protectedPlayers, ", ")
__protList.TextColor3 = Color3.new(1,1,1)
__protList.Font = "GothamMedium"
__protList.TextSize = 14
__protList.Parent = __antiTab.UIElements.ContainerFrame

local __antiKeys = {"kill","jail","fling","blind","spin","punish","dog","ff","ban","message","stun","clone","speed","freeze"}
for _, key in ipairs(__antiKeys) do
    __antiTab:Toggle({ Title = "Anti "..key, Icon = "lucide:shield", Value = __anti[key] or false, Callback = function(v) __anti[key] = v; __config.anti = __anti; __saveConfig() end })
end

local __friendsTab = __window:Tab({ Title = "Friends (Anti-Abuse)", Icon = "lucide:users" })
__friendsTab:Paragraph({ Title = "Friends List", Desc = "Anti-abuse does not affect friends." })
local __friendsContainer = Instance.new("ScrollingFrame")
__friendsContainer.Size = UDim2.new(1, 0, 1, 0)
__friendsContainer.BackgroundTransparency = 1
__friendsContainer.ScrollBarThickness = 4
__friendsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
__friendsContainer.AutomaticCanvasSize = "Y"
__friendsContainer.ClipsDescendants = true
__friendsContainer.Parent = __friendsTab.UIElements.ContainerFrame
local __friendsLayout = Instance.new("UIListLayout")
__friendsLayout.Padding = UDim.new(0, 6)
__friendsLayout.SortOrder = "LayoutOrder"
__friendsLayout.FillDirection = "Vertical"
__friendsLayout.HorizontalAlignment = "Center"
__friendsLayout.Parent = __friendsContainer

local function __refreshFriends()
    for _, child in ipairs(__friendsContainer:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    for _, name in ipairs(__config.friends) do
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 35)
        frame.BackgroundTransparency = 1
        frame.Parent = __friendsContainer
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.new(1,1,1)
        label.Font = "GothamMedium"
        label.TextSize = 16
        label.TextXAlignment = "Left"
        label.Parent = frame
        local removeBtn = Instance.new("TextButton")
        removeBtn.Size = UDim2.new(0.2, 0, 0.8, 0)
        removeBtn.Position = UDim2.new(0.8, 0, 0.1, 0)
        removeBtn.Text = "Remove"
        removeBtn.TextColor3 = Color3.new(1,1,1)
        removeBtn.BackgroundColor3 = Color3.fromHex("#e53935")
        removeBtn.TextSize = 14
        removeBtn.Font = "GothamMedium"
        removeBtn.BorderSizePixel = 0
        removeBtn.Parent = frame
        removeBtn.MouseButton1Click:Connect(function()
            if __hasAdmin() then
                __removeFriend(name)
                __refreshFriends()
            end
        end)
        local div = Instance.new("Frame")
        div.Size = UDim2.new(1, 0, 0, 1)
        div.Position = UDim2.new(0, 0, 1, -1)
        div.BackgroundColor3 = Color3.fromHex("#3a3a3a")
        div.Parent = frame
    end
end
__refreshFriends()
__friendsTab:Button({ Title = "Refresh List", Icon = "lucide:refresh-cw", Callback = __refreshFriends })

local __commandsTab = __window:Tab({ Title = "Commands", Icon = "lucide:terminal" })
__commandsTab:Paragraph({ Title = "Command List", Desc = "Use prefix '"..PREFIX.."' in chat." })
local __cmdList = {
    "folk - activate folk mode",
    "mydog <player> - turn player into your dog",
    "fpunish <player> - freeze + invisible",
    "moveobby_f3x - move obby via F3X",
    "trap <player> - trap player with gear",
    "ban/unban - ban/unban player",
    "gearban/ungearban - gearban control",
    "serverlock/unlock - lock server",
    "allow <player> - allow in locked server",
    "perm - toggle auto-perm",
    "nok - toggle No Obby Kill",
    "whitelist/unwhitelist - immune",
    "anti <name> - toggle anti-abuse",
    "clearlogs - clear logs",
    "mtool - local move tool",
    "rejoin/rj - rejoin",
    "serverhop/shop/sh - hop server",
    "spam/unspam - spam messages",
    "r15 - enable R15 mode",
    "r6 - disable R15",
    "troll - troll effects",
    "fixfilter - reset chat filter",
    "doll <player> - rename and speed 0",
    "protect/unprotect <player> - anti-abuse control",
    "sunset - apply sunset",
    "ambient <r> <g> <b> - set ambient color",
    "enableinventory - unlock inventory",
    "iy - load Infinity Yield",
    "dex++ - load Dex Explorer Reforged",
    "equip - equip all tools",
    "forcerespawn - respawn yourself",
    "fixvelocity - reset all velocities",
    "breakbaseplate - break baseplate",
    "destroybaseplate - destroy baseplate",
    "bypassmessage <text> - send filtered message",
    "deletetool - create delete tool",
    "rainbowfog <range> - rainbow fog",
    "rainbowbaseplate - start rainbow baseplate",
    "unrainbowbaseplate - stop rainbow baseplate",
    "attachtool - create attach tool",
    "breakplayer <player> - break player",
    "antiname - anti-name protection",
    "antigrav - anti-gravity",
    "antiskydive - anti-skydive",
    "antivoid - anti-void",
    "party <amount> - spawn party items",
    "antikick - anti-kick protection",
    "spawnzombies <amount> - spawn zombies",
    "nuke <amount> <range> - nuke",
    "naked <player> - naked player",
    "nude <player> - nude player",
    "femify <player> - femify player",
    "furrify <player> - furrify player",
    "oldholdplayer <player> - old hold player",
    "holdplayer <player> - hold player",
    "pcolour - start rainbow painting",
    "black/white/red/blue/green/orange/yellow/brown/purple/pink - paint all",
    "unpaint - remove paint bucket",
    "deletetoolivory - create ivory delete tool",
    "run <script> - execute lua script",
    "gayrate <player> - get gay rate",
    "icetower <player> - ice tower",
    "rail <player> - railgun spam",
    "spike - spike attack",
    "pban/unpban <player> - pad ban",
    "timeout <player> <time> - timeout player",
    "fixcam <player> - fix broken camera",
    "breakcam <player> - break camera",
    "noobify <player> - noobify player",
    "dummy/testdummy - create dummy",
    "batman - Batman skin",
    "load1/load2/load3/load4 - load skins",
    "jesus - Jesus skin",
    "globalrtx - global RTX settings",
    "furryhammer - Furry Hammer tool",
    "gkit - GKit equipment",
    "cbomb - Cluster bomb",
    "sznsword - Season sword set",
    "jerk - Jerk off animation tool",
    "bang <player> - Bang animation on player",
    "unbang - Stop bang animation",
    "game2 - Start game-2",
    "raver - Raver party",
    "fixbp - Fix baseplate",
    "germanman <player> - German man skin",
    "smite <player> - Smite player",
    "sclr - Clear server",
    "cage <player> - Cage player",
    "distort - Distort sounds",
    "pbs <speed> - Playback speed",
    "dropk <player> - Dropkick player",
    "crail <player> - Crazy rail",
    "missile <player> - Missile attack",
    "fmusic <search> - Find music",
    "g/c - Giant cock (guns)",
    "b/c - Giant cock (boomboxes)",
    "laser <player> - Laser attack"
}
for _, info in ipairs(__cmdList) do
    local c = info:match("^%S+")
    __commandsTab:Paragraph({ Title = PREFIX..c, Desc = info:gsub("^%S+%s*", "") })
end

local __infoTab = __window:Tab({ Title = "Info", Icon = "lucide:info" })
local infoContainer = Instance.new("Frame")
infoContainer.Size = UDim2.new(1, 0, 1, 0)
infoContainer.BackgroundTransparency = 1
infoContainer.Parent = __infoTab.UIElements.ContainerFrame

local avatar = Instance.new("ImageLabel")
avatar.Size = UDim2.new(0, 100, 0, 100)
avatar.Position = UDim2.new(0.5, -50, 0, 20)
avatar.BackgroundTransparency = 1
avatar.Image = "rbxthumb://type=AvatarHeadShot&id="..__player.UserId.."&w=420&h=420"
avatar.Parent = infoContainer
Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)

local displayName = Instance.new("TextLabel")
displayName.Size = UDim2.new(1, 0, 0, 30)
displayName.Position = UDim2.new(0, 0, 0, 130)
displayName.BackgroundTransparency = 1
displayName.Text = __player.DisplayName
displayName.TextColor3 = Color3.new(1,1,1)
displayName.TextSize = 24
displayName.Font = "GothamBold"
displayName.TextXAlignment = "Center"
displayName.Parent = infoContainer

local originalName = Instance.new("TextLabel")
originalName.Size = UDim2.new(1, 0, 0, 20)
originalName.Position = UDim2.new(0, 0, 0, 160)
originalName.BackgroundTransparency = 1
originalName.Text = "@"..__player.Name
originalName.TextColor3 = Color3.new(0.6, 0.6, 0.6)
originalName.TextSize = 16
originalName.Font = "GothamMedium"
originalName.TextXAlignment = "Center"
originalName.Parent = infoContainer

local rank = Instance.new("TextLabel")
rank.Size = UDim2.new(1, 0, 0, 25)
rank.Position = UDim2.new(0, 0, 0, 190)
rank.BackgroundTransparency = 1
local rankText = "User"
if __player.Name == "nowhudhejeir" or __player.Name == "EgorYa900" or __player.Name == "PaulTheKinggg" then rankText = "Owner" end
rank.Text = "Rank: "..rankText
rank.TextColor3 = Color3.new(1,1,1)
rank.TextSize = 18
rank.Font = "GothamMedium"
rank.TextXAlignment = "Center"
rank.Parent = infoContainer

local creator = Instance.new("TextLabel")
creator.Size = UDim2.new(1, 0, 0, 30)
creator.Position = UDim2.new(0, 0, 0, 240)
creator.BackgroundTransparency = 1
creator.Text = "Script created by nowhudhejeir"
creator.TextColor3 = Color3.new(1,1,1)
creator.TextSize = 18
creator.Font = "GothamMedium"
creator.TextXAlignment = "Center"
creator.Parent = infoContainer

local thanks = Instance.new("TextLabel")
thanks.Size = UDim2.new(1, 0, 0, 30)
thanks.Position = UDim2.new(0, 0, 0, 280)
thanks.BackgroundTransparency = 1
thanks.Text = "Special thanks to EgorYa900 for feature ideas"
thanks.TextColor3 = Color3.new(0.7,0.7,0.7)
thanks.TextSize = 16
thanks.Font = "GothamMedium"
thanks.TextXAlignment = "Center"
thanks.Parent = infoContainer

local ver = Instance.new("TextLabel")
ver.Size = UDim2.new(1, 0, 0, 30)
ver.Position = UDim2.new(0, 0, 0, 320)
ver.BackgroundTransparency = 1
ver.Text = "Version "..VERSION
ver.TextColor3 = Color3.new(0.5,0.5,0.5)
ver.TextSize = 14
ver.Font = "GothamMedium"
ver.TextXAlignment = "Center"
ver.Parent = infoContainer

local __settingsTab = __window:Tab({ Title = "Settings", Icon = "lucide:settings" })
__settingsTab:Dropdown({ Title = "Theme", Values = {"Dark","Light","Rose","Plant","Red","Indigo","Sky","Violet","Amber","Emerald","Midnight","Crimson","MonokaiPro","CottonCandy","Mellowsi","Rainbow"}, Value = __config.theme, Callback = function(v) __config.theme = v; __saveConfig(); WindUI:SetTheme(v) end })

if not __load("changelog_version") or __load("changelog_version") ~= VERSION then
    WindUI:Notify({Title="Changelog", Content="RELEASE 1.1: Added all new commands (gkit, cbomb, sznsword, jerk, bang, unbang, game2, raver, fixbp, germanman, smite, sclr, cage, distort, pbs, dropk, crail, missile, fmusic, g/c, b/c, laser). Fixed r15/r6. All features complete.", Duration=15})
    __save("changelog_version", VERSION)
end

__window:Open()
