loadstring(exports.interfacer:extend("Interfacer"))()
Extend("SPlayer")
-- Extend("SDB") --НА ТЕСТОВОМ СЕРВЕРЕ!!!

addEvent("referral_system:activatePromo", true)
addEventHandler("referral_system:activatePromo", resourceRoot, function(promo)
    local player = client
    if not promo or type(promo) ~= "string" then 
        return player:ShowInfo("Неверный формат промокода") 
    end

    local accountID = player:getData("id")
    if not accountID then return end

    DB:queryAsync(function(qH)
        local result = dbPoll(qH, 0)
        if result and result[1] and result[1].used_promo ~= nil then
            return player:ShowInfo("Вы уже активировали промокод ранее!")
        end

        DB:queryAsync(function(qH2)
            local promoData = dbPoll(qH2, 0)
            
            if not promoData or #promoData == 0 then
                return player:ShowInfo("Такого промокода не существует")
            end

            local promoInfo = promoData[1]
            
            if promoInfo.owner_id == accountID then
                return player:ShowInfo("Нельзя активировать собственный код")
            end

            DB:exec("UPDATE accounts SET used_promo = ? WHERE id = ?", promo, accountID)
            
            DB:exec("UPDATE promo_codes SET activations_count = activations_count + 1 WHERE promo_text = ?", promo)

            player:giveMoney(5000) 
            player:ShowInfo("Промокод успешно активирован! +5,000$")
            
            outputChatBox("Вы успешно активировали промокод: " .. promo, player, 0, 255, 0)
            
        end, {}, "SELECT * FROM promo_codes WHERE promo_text = ? LIMIT 1", promo)

    end, {}, "SELECT used_promo FROM accounts WHERE id = ? LIMIT 1", accountID)
end, false)

addCommandHandler("promo", function(player)
    local ui_test = true -- FALSE НА ТЕСТОВОМ СЕРВЕРЕ!!!
    if not ui_test then
        local accountID = player:getData("id")
        if not accountID then return end

        DB:queryAsync(function(query, player)
            if not isElement(player) then return dbFree(query) end

            local data = dbPoll(query, 0)
            triggerClientEvent(player, "referral_system:onClientUICreate", resourceRoot, "promo_menu", data[1] or {})
        end, { player }, "SELECT * FROM promo_codes WHERE player_id = ?", accountID)
    else
        local promoDataSample = {
            creation_data = 1739386620, --date
            money_earned = 0, --int
            promo_text = "CHLENPIZDA", --string
            activations_count = 0 --int
        }
        triggerClientEvent(player, "referral_system:onClientUICreate", resourceRoot, "promo_menu", promoDataSample)
    end
end, false, false)