local config = {
    backToLevel = 8,
    redskull = false, -- need to be without redskull to reset?
    battle = true, -- need to be without battle to reset?
    pz = false, -- need to be in protect zone to reset?
    stages = {
        {resets = 4, level = 350, premium = 330},
        {resets = 9, level = 355, premium = 340},
        {resets = 14, level = 360, premium = 355},
        {resets = 19, level = 365, premium = 360},
        {resets = 24, level = 380, premium = 370},
        {resets = 29, level = 390, premium = 380},
        {resets = 34, level = 410, premium = 400},
        {resets = 39, level = 430, premium = 420},
        {resets = 44, level = 450, premium = 440},
        {resets = 49, level = 480, premium = 470},
        {resets = 54, level = 510, premium = 500},
        {resets = 59, level = 550, premium = 540},
        {resets = 64, level = 590, premium = 580},
        {resets = 69, level = 630, premium = 620},
        {resets = 74, level = 680, premium = 670},
        {resets = 79, level = 730, premium = 720},
        {resets = 84, level = 780, premium = 770},
        {resets = 89, level = 860, premium = 840},
        {resets = 94, level = 930, premium = 910},
        {resets = 2^1024, level = 1010, premium = 990}
    }
}

function onSay(player, words, param)

local exhaustvalue = 78692 -- storage to avoid command spam
local exhausttime = 10 -- seconds before you may request rank again

	local function getExpForLevel(level)
    level = level - 1
    return ((50 * level * level * level) - (150 * level * level) + (400 * level)) / 3
end
   
    if config.redskull and player:getSkull() == 4 then
        player:sendCancelMessage("You need to be without red skull to reset.")
        return false
    elseif config.pz and not getTilePzInfo(player:getPosition()) then
        player:sendCancelMessage("You need to be in protection zone to reset.")
        return false
    elseif config.battle and player:getCondition(CONDITION_INFIGHT) then
        player:sendCancelMessage("Você precisa estar sem battle para resetar.")
		player:setStorageValue(exhaustvalue, os.time() + exhausttime)
        return false
    end

    local resetLevel = 0
    for x, y in ipairs(config.stages) do
        if player:getStorageValue(5123513) <= y.resets then
            resetLevel = player:isPremium() and y.premium or y.level
            break
        end
    end
   
   	if player:getStorageValue(exhaustvalue) >= os.time() then
		player:sendCancelMessage("Você precisa esperar " .. player:getStorageValue(78692) - os.time() .. " segundos para resetar novamente.")
		return false
	end
	
    if getPlayerLevel(player) < resetLevel then
	    player:setStorageValue(exhaustvalue, os.time() + exhausttime)
        player:sendCancelMessage("Você precisa de nível (" .. resetLevel .. ") ou mais para resetar.")
        return false
    end
   
    local playerId = player:getGuid()
    player:setStorageValue(5123513, player:getStorageValue(5123513) + 1)
	player:remove()
    db.query("UPDATE `players` SET `resets`= `resets` + 1 WHERE `players`.`id`= ".. playerId .."")
    db.query("UPDATE `players` SET `level`="..config.backToLevel..",`experience`= 4200 WHERE `players`.`id`= ".. playerId .."")
    return false
end