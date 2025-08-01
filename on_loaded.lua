-- รอจนกว่าเกมจะโหลดเสร็จ
if not game:IsLoaded() then
    game.Loaded:Wait()
end
repeat task.wait() until game.Players.LocalPlayer:FindFirstChild("PlayerGui")
--repeat wait(1) until game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Main")

-- รอจนกว่าจะมี LocalPlayer
local Players = game:GetService("Players")
repeat wait() until Players.LocalPlayer

-------------------------------------------------------------------------
local playerName = game.Players.LocalPlayer.Name
local player = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")

if syn and syn.websocket then
    WebSocket = syn.websocket

elseif Krnl then
    print("รอ Krnl.WebSocket...")
    repeat task.wait() until Krnl.WebSocket
    WebSocket = Krnl.WebSocket
    
elseif WebSocket then
    WebSocket = WebSocket
else
    print("ไม่มี WebSocket ใดๆ เลย")
end

if not WebSocket then
    warn("[Client] ไม่รองรับ WebSocket ใน exploit นี้")
    return
end

--local ws = WebSocket.connect("ws://127.0.0.1:8765")
_G.ws = WebSocket.connect("ws://127.0.0.1:8765")
if not _G.ws then
    warn("[Client] ไม่สามารถเชื่อมต่อ WebSocket ได้")
    return
end

-- สร้างข้อมูลแบบ form-urlencoded
--local playerName = game.Players.LocalPlayer.Name
--local jobId = game.JobId or "unknown"
--local message = playerName .. "|" .. jobId

local function getMessage()
    local playerName = game.Players.LocalPlayer.Name
    local jobId = game.JobId or "unknown"
    return playerName .. "|" .. jobId
end

-- รอรับข้อมูลตอบกลับอย่างต่อเนื่อง
_G.ws.OnMessage:Connect(function(msg)
    -- รับข้อมูล แต่ไม่ทำอะไร
end)

-- จัดการเมื่อการเชื่อมต่อถูกปิด
_G.ws.OnClose:Connect(function()
    warn("[Client] การเชื่อมต่อถูกปิด")
end)


local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local currentPlaceId = game.PlaceId
local currentJobId = game.JobId -- JobId ของเซิร์ฟเวอร์นี้

local function teleportSameJob()
    local success, errorMessage = pcall(function()
        TeleportService:TeleportToPlaceInstance(currentPlaceId, currentJobId, player)
    end)

    --if success then
    --    print("Teleport ไปยัง Job เดิมสำเร็จ!")
    --else
    --    warn("Teleport ล้มเหลว: " .. tostring(errorMessage))
    --    game:Shutdown()
    --end
end

local GuiService = game:GetService("GuiService")

local function testkick()
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer

    -- Kick the local player with a message
    player:Kick("You have been kicked from the game.")
end


local function checkdiscon()
    local errorCode = GuiService:GetErrorCode()
    local errorValue = errorCode.Value
    local errorName = errorCode.Name
    print(errorCode)
    print(errorValue)
    print(errorName)

    if (
        (string.find(errorName, "Disconnect") or
        string.find(errorName, "Shutdown") or
        string.find(errorName, "End") or
        string.find(errorName, "auth"))
        and not string.find(errorName, "Request")
    ) 
    or errorValue == 285 
    or errorValue == 1 then
        _G.ws:Close() -- ปิดการเชื่อมต่อ WebSocket
        if errorValue ~= 279 then
            testkick()
        end
        wait(4)
        teleportSameJob() -- เทเลพอร์ตไปยัง server เดิม
        return true
    end
    return false
end

-- เชื่อมต่อเหตุการณ์ ErrorMessageChanged
GuiService.ErrorMessageChanged:Connect(function()
    checkdiscon()
end)


if not game:IsLoaded() then game.Loaded:Wait(20) end
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function showMessage(message, duration)
    local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
    local textLabel = Instance.new("TextLabel", screenGui)
    
    textLabel.Size = UDim2.new(0.5, 0, 0.1, 0)
    textLabel.Position = UDim2.new(0.25, 0, 0.4, 0)
    textLabel.Text = message
    textLabel.TextScaled = true
    textLabel.BackgroundTransparency = 0.5
    textLabel.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    textLabel.TextColor3 = Color3.new(0, 0, 0)
    textLabel.Font = Enum.Font.SourceSansBold
    
    task.wait(duration)
    screenGui:Destroy()
end

local function addHalfPlayersAsFriends()
    local allPlayers = Players:GetPlayers()
    local totalPlayers = #allPlayers
    
    if totalPlayers > 1 then
        local halfCount = math.floor(totalPlayers / 1)
        local count = 0
        
        for _, player in ipairs(allPlayers) do
            if player ~= LocalPlayer then
                LocalPlayer:RequestFriendship(player)
                count += 1
                showMessage("Sent friend request to " .. count .. " players.", 1)
                if count >= halfCount then
                    break
                end
            end
        end
        
        showMessage("Add friends Sent Amount : " .. count .. " Players.", 3)
    else
        showMessage("Not enough players to add friends.", 3)
    end
end


local message = getMessage()
-- ส่งข้อมูล
_G.ws:Send(message)

local LogsCheck = HorstConfig["EnableLog"]
local HorstWhitescreen = HorstConfig["Whitescreen"]
local addfriends = HorstConfig["EnableAddFriends"]
---- Lock Fps
local lockEnabled = HorstConfig["LockFps"]["EnableLockFps"]
local fpsAmount = HorstConfig["LockFps"]["LockFpsAmount"]

if lockEnabled and lockEnabled == true then
    setfpscap(tonumber(fpsAmount)) -- หรือ math.floor(fpsAmount) ก็ได้
end

if HorstWhitescreen and HorstWhitescreen == true then
    game:GetService("RunService"):Set3dRenderingEnabled(false)
end

local PlaceId = tostring(game.PlaceId)
local hasLoadedScript = false  -- ใช้ตรวจสอบว่าโหลด script ไปแล้วหรือยัง

task.spawn(function()
    local timer_xyz = 0

    while true do
        -- ส่งข้อความ keep alive และเช็คการตัดการเชื่อมต่อ
        pcall(function()
            _G.ws:Send("keep alive")
            checkdiscon()
        end)

        -- ตรวจสอบเงื่อนไขทุก 14 รอบ (70 วินาที)
        if LogsCheck == true and  hasLoadedScript == false then
            if PlaceId == "2753915549" or PlaceId == "4442272183" or PlaceId == "7449423635" then
                hasLoadedScript = true
                task.spawn(function()
                    print("Sending bloxfruits 2")
                    pcall(function()
                        loadstring(game:HttpGet("https://raw.githubusercontent.com/HorstSpaceX/last_update/refs/heads/main/BF.lua"))()
                    end)
                end)
            elseif PlaceId == "126884695634066" then
                hasLoadedScript = true
                print("Sending Garden")
                task.spawn(function()
                    pcall(function()
                        loadstring(game:HttpGet("https://raw.githubusercontent.com/HorstSpaceX/last_update/refs/heads/main/GAG.lua"))()
                    end)
                end)
            elseif PlaceId == "17687504411" then
                hasLoadedScript = true
                print("Sending ASDT")
                task.spawn(function()
                    pcall(function()
                        loadstring(game:HttpGet("https://raw.githubusercontent.com/HorstSpaceX/last_update/refs/heads/main/ASDT.lua"))()
                    end)
                end)
            elseif PlaceId == "104715542330896" or PlaceId == "97556409405464" then
                hasLoadedScript = true
                print("Sending BS")
                task.spawn(function()
                    pcall(function()
                        loadstring(game:HttpGet("https://raw.githubusercontent.com/HorstSpaceX/last_update/refs/heads/main/BS.lua"))()
                    end)
                end)

            elseif PlaceId == "16732694052" then
                hasLoadedScript = true
                print("Sending FS")
                task.spawn(function()
                    pcall(function()
                        loadstring(game:HttpGet("https://raw.githubusercontent.com/HorstSpaceX/last_update/refs/heads/main/Fisch.lua"))()
                    end)
                end)
            else
                print("Not Found PlaceId")
            end
        end
        if timer_xyz >= 14 then -- Add friends every 70secs
            if addfriends and addfriends == true then
                addHalfPlayersAsFriends()
            end
            timer_xyz = 0
        end

        task.wait(5)
        timer_xyz = timer_xyz + 1
    end
end)
