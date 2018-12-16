-- Configuration settings
local g_config = {
    admins = {"Junny1992#0000"},
    spawnX = 250,
    spawnY = 250,
    toysAreas = {
        {x1 = 0, y1 = 0, x2 = 800, y2 = 600}
    },
    packingAreas = {
        {x1 = 0, y1 = 0, x2 = 800, y2 = 600}
    },
    dropOffAreas = {
        {x1 = 0, y1 = 0, x2 = 800, y2 = 600}
    },
    minigameChars = {"q","r","t","y","u","i","o","p","f","g","h","j","k","l","z","x","c","v","b","n","m","1","2","3","4","5","6","7","8","9","0"}
}

-- Local globals
local g_players = {}
local g_lastTick = 0
local g_timers = {}
local g_gameState = 0
local g_textAreaIds = {
    countdown = 1,
    inventory = 2,
    toast = 3
}

-- Utilities
local function isAdministrator(playerName)
    for _, adminName in ipairs(g_config.admins)
    do
        if adminName == playerName then
            return true
        end
    end
    return false
end

local function addTimer(callback, startDelay, loop, ...)
    if callback == nil then
        print ("Warning: null callback in addTimer")
        return
    end
    local timer = {
        callback = callback,
        startDelay = startDelay,
        loop = loop,
        args = ...,
        createdTime = g_lastTick,
        expired = false
    }
    table.insert(g_timers, timer)
    return #g_timers
end

local function showToast(text, duration, playerName)
    ui.addTextArea(g_textAreaIds.toast, text, playerName, 300, 250, 200, 30, 0x324650, 0x000000, 0.7, true)
    addTimer(function()
        ui.removeTextArea(g_textAreaIds.toast, playerName)
    end, duration, false)
end

-- Script core logic
local function init()
    tfm.exec.setUIMapName("Greenwolves - Natale 2018")
    tfm.exec.setUIShamanName("Biscuitfioc#0000")
    tfm.exec.disableAutoShaman(true)
    tfm.exec.disableAutoNewGame(true)
    tfm.exec.disableAutoScore(true)
    tfm.exec.disableAutoTimeLeft(true)
    tfm.exec.disableAfkDeath(true)

    for playerName, _ in pairs(tfm.get.room.playerList)
    do
        eventNewPlayer(playerName)
    end

    print("Script initialized!")
end

local function addPlayer(playerName)
    local player = {
        name = playerName,
        carrying = 0
    }
    g_players[playerName] = player
    system.bindKeyboard(playerName, 32, true, true)
    ui.addTextArea(g_textAreaIds.inventory, "", playerName, 5, 28, 200, 30, 0x324650, 0x000000, 1, true)
end

local function removePlayer(playerName)
    local player = g_players[playerName]
    if (player) then
        ui.removeTextArea(g_textAreaIds.inventory, playerName)
        system.bindKeyboard(playerName, 32, true, false)
        g_players[playerName] = nil
    end
end

local function resetPlayer(playerName)
    local player = g_players[playerName]
    if player then
        removePlayer(playerName)
        eventNewPlayer(playerName)
        tfm.exec.killPlayer(playerName)
    end
end

local function startGame()
    g_gameState = 2
    for playerName, player in pairs(g_players) do
        eventPlayerRespawn(playerName)
    end
    tfm.exec.setGameTime(300)
end

local function endGame()

    resetGame()
end

local function resetGame()
    tfm.exec.addShamanObject(61, 400, 350, 0, 0, 0, false)
    g_gameState = 0
    for _, id in pairs(g_textAreaIds) do
        ui.removeTextArea(id, nil)
    end
end

local function startCountdown()
    g_gameState = 1
    local headerText = "<VP><p align=\"center\"><B>Siete pronti?</B>\n\n<CH>"
    local textAreaId = g_textAreaIds.countdown;
    ui.addTextArea(textAreaId, headerText, nil, 300, 270, 200, 60, 0x324650, 0x000000, 1, true)
    local function countdown(secondsLeft)
        if (secondsLeft > 0) then
            ui.updateTextArea(textAreaId, headerText .. secondsLeft, nil)
            addTimer(countdown, 1000, false, secondsLeft - 1)
        else
            ui.updateTextArea(textAreaId, headerText .. "VIA!!!", nil)
            addTimer(function()
                ui.removeTextArea(textAreaId, nil)
            end, 1000, false)
            startGame()
        end
    end
    countdown(3)
end

local function startMinigame(playerName)

end

-- Game delegates
local lastColor = 0x00
function eventChatCommand(playerName, message)
    if isAdministrator(playerName) then
        if message == "start" then
            startCountdown(5)
        elseif message == "win" then
            tfm.exec.newGame("@7450641")
        elseif message == "biscuitfioc" then
            addTimer(function()
                for i=125,1200,50
                do
                    tfm.exec.addShamanObject(6,i,25,0,0,0,false)
                end
            end, 3000, true)
        elseif message == "ares" then
            tfm.exec.changePlayerSize("Junny1992", 0.1)
            tfm.exec.setVampirePlayer("Junny1992", false)
            addTimer(function()
                tfm.exec.setNameColor("Junny1992", lastColor)
                lastColor = (lastColor + 0x1) % 0xFFFFFF
            end, 500, true)
        elseif message == "reset" then
            resetGame()
        elseif message == "exit" then
            system.exit()
        end
    end
    if message == "reset" then
        resetPlayer(playerName)
    elseif message == "electraloves" then
        tfm.exec.newGame("#0")
    elseif message == "test" then
        print(tfm.get.room.playerList["Junny1992#0000"].tribeName)
        tfm.exec.playEmote("Ruka#0823", 3, nil)
    elseif message == "tiny" then
        tfm.exec.changePlayerSize(playerName, 0.1)
    elseif message == "normal" then
        tfm.exec.changePlayerSize(playerName, 1)
    elseif message == "giant" then
        tfm.exec.changePlayerSize(playerName, 5)
    elseif message == "vampireon" then
        tfm.exec.setVampirePlayer(playerName, true)
    elseif message == "vampireoff" then
        tfm.exec.setVampirePlayer(playerName, false)
    end
end

function eventKeyboard(playerName, keyCode, down, xPlayerPosition, yPlayerPosition)
    if keyCode == 32 and down == true then
        local player = g_players[playerName]
        if player then
            if player.carrying == 0 then
                for _, toysArea in ipairs(g_config.toysAreas) do
                    if toysArea.x1 < xPlayerPosition and xPlayerPosition < toysArea.x2 and toysArea.y1 < yPlayerPosition and yPlayerPosition < toysArea.y2 then
                        player.carrying = 1
                        print(playerName .. " ha raccolto un giocattolo")
                        ui.updateTextArea(g_textAreaIds.inventory, "Trasporti un giocattolo!", playerName)
                        break
                    end
                end
            elseif player.carrying == 1 then
                for _, packingArea in ipairs(g_config.packingAreas) do
                    if packingArea.x1 < xPlayerPosition and xPlayerPosition < packingArea.x2 and packingArea.y1 < yPlayerPosition and yPlayerPosition < packingArea.y2 then
                        player.carrying = 2
                        tfm.exec.giveCheese(playerName)
                        print(playerName .. " ha impacchettato il regalo")
                        ui.updateTextArea(g_textAreaIds.inventory, "Trasporti un regalo!", playerName)
                        break
                    end
                end
            elseif player.carrying == 2 then
                for _, dropOffArea in ipairs(g_config.dropOffAreas) do
                    if dropOffArea.x1 < xPlayerPosition and xPlayerPosition < dropOffArea.x2 and dropOffArea.y1 < yPlayerPosition and yPlayerPosition < dropOffArea.y2 then
                        player.carrying = 0
                        tfm.exec.removeCheese(playerName)
                        tfm.exec.setPlayerScore(playerName, 1, true)
                        print(playerName .. " ha consegnato il regalo")
                        ui.updateTextArea(g_textAreaIds.inventory, "", playerName)
                        showToast("Regalo consegnato!", 3000, playerName)
                        break
                    end
                end
            end
        end
    end
end

function eventNewPlayer(playerName)
    if isAdministrator(playerName) then
        tfm.exec.setNameColor(playerName, 0x009DFF)
    else
        addPlayer(playerName)
    end
end

function eventPlayerDied(playerName)
    tfm.exec.respawnPlayer(playerName)
end

function eventPlayerRespawn(playerName)
    if g_gameState > 0 then
        tfm.exec.movePlayer(playerName, g_config.spawnX, g_config.spawnY, false, 0, 0, false)
    end
end

function eventNewGame()
    resetGame()
end

function eventLoop(currentTime, timeRemaining)
    g_lastTick = currentTime

    --
    if g_gameState == 2 and timeRemaining <= 0 then
        endGame()
    end
    
    -- Timers handling
    for i=1, #g_timers
    do
        local timer = g_timers[i]
        timer.expired = (currentTime - timer.createdTime - timer.startDelay >= 0)
        if timer.expired then
            timer.callback(timer.args)
            if timer.loop then
                timer.createdTime = currentTime
                timer.expired = false
            end
        end
    end

    for i=#g_timers,1,-1 do
        if g_timers[i].expired then
            table.remove(g_timers, i)
        end
    end
end

init()
