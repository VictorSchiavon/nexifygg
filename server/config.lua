-- ⚠️ PT-BR: Você pode adicionar, ajustar, mudar ou incrementar a lógica de acordo seu desejo ou framework
-- ⚠️ EN: You can add, adjust, change, or enhance the logic as you wish or framework

------------------------------------------------------------------------------------------------
-- ADDMONEY
------------------------------------------------------------------------------------------------

AddEventHandler('fivemarket:addMoney', function(buyer, command_value, deliveryId)
    local source = resolveSource(buyer)

    if not source then 
        return logDelivery('addMoney', buyer, false, deliveryId) 
    end

    local moneyType, amount = 'cash', tonumber(command_value)

    if type(command_value) == 'string' and command_value:find(':') then
        moneyType = command_value:match('(.-):(.*)')
        amount    = tonumber(command_value:match('.-:(.*)'))
    end

    if not amount or amount <= 0 then
        return logDelivery('addMoney', buyer, false, deliveryId)
    end

    if Nexify.framework == 'esx' then
        local xPlayer = Nexify.frameworkObject.GetPlayerFromId(source)

        if xPlayer then
            xPlayer.addMoney(amount)
            logDelivery('addMoney', buyer, true, deliveryId)
        end

    elseif Nexify.framework == 'qbcore' or Nexify.framework == 'qbox' then
        local Player = Nexify.frameworkObject.Functions.GetPlayer(source)

        if Player then
            Player.Functions.AddMoney(moneyType, amount)
            logDelivery('addMoney', buyer, true, deliveryId)
        end

    elseif Nexify.framework == 'creative' then
        local passport = tonumber(buyer)

        vRP.GiveBank(passport, amount, false)
        logDelivery('addMoney', buyer, true, deliveryId)

    elseif Nexify.framework == 'vrp' then
        local user_id = vRP.getUserId(source)

        if user_id then
            vRP.giveWallet({ user_id, amount })
            logDelivery('addMoney', buyer, true, deliveryId)
        end
    else
        -- STANDALONE
        TriggerEvent('nexify:standalone:addMoney', source, moneyType, amount, deliveryId)
    end
end)

------------------------------------------------------------------------------------------------
-- ADDITEM
------------------------------------------------------------------------------------------------

AddEventHandler('fivemarket:addItem', function(buyer, command_value, deliveryId)
    local source = resolveSource(buyer)

    if not source then
        return logDelivery('addItem', buyer, false, deliveryId)
    end

    local item, count = command_value, 1

    if type(command_value) == 'string' and command_value:find(':') then
        item  = command_value:match('(.-):(.*)')
        count = tonumber(command_value:match('.-:(.*)')) or 1
    end

    if Nexify.framework == 'esx' then
        local xPlayer = Nexify.frameworkObject.GetPlayerFromId(source)

        if xPlayer then
            xPlayer.addInventoryItem(item, count)
            logDelivery('addItem', buyer, true, deliveryId)
        end

    elseif Nexify.framework == 'qbcore' or Nexify.framework == 'qbox' then
        local Player = Nexify.frameworkObject.Functions.GetPlayer(source)

        if Player then
            Player.Functions.AddItem(item, count)
            TriggerClientEvent('inventory:client:ItemBox', source, Nexify.frameworkObject.Shared.Items[item], 'add', count)
            logDelivery('addItem', buyer, true, deliveryId)
        end

    elseif Nexify.framework == 'creative' then
        local passport = tonumber(buyer)

        vRP.GenerateItem(passport, item, count, true)
        logDelivery('addItem', buyer, true, deliveryId)

    elseif Nexify.framework == 'vrp' then
        local user_id = vRP.getUserId(source)

        if user_id then
            vRPclient.giveInventoryItem({ source, item, count })
            logDelivery('addItem', buyer, true, deliveryId)
        end

    else
        -- STANDALONE
        TriggerEvent('nexify:standalone:addItem', source, item, count, deliveryId)
    end
end)

------------------------------------------------------------------------------------------------
-- REMOVEITEM
------------------------------------------------------------------------------------------------

AddEventHandler('fivemarket:removeItem', function(buyer, command_value, deliveryId)
    local source = resolveSource(buyer)

    if not source then
        return logDelivery('addItem', buyer, false, deliveryId)
    end

    local item, count = command_value, 1

    if type(command_value) == 'string' and command_value:find(':') then
        item  = command_value:match('(.-):(.*)')
        count = tonumber(command_value:match('.-:(.*)')) or 1
    end

    if Nexify.framework == 'esx' then
        local xPlayer = Nexify.frameworkObject.GetPlayerFromId(source)

        if xPlayer then
            -- adicione sua lógica ou função de remoção de item na framework ESX (parâmetros: item, count)
            -- Add your item removal logic or function to the ESX framework (parameters: item, count)
            logDelivery('removeItem', buyer, true, deliveryId)
        end

    elseif Nexify.framework == 'qbcore' or Nexify.framework == 'qbox' then
        local Player = Nexify.frameworkObject.Functions.GetPlayer(source)

        if Player then
            -- adicione sua lógica ou função de remoção de item na framework QBOX/QBCORE (parâmetros: item, count)
            -- Add your item removal logic or function to the QBOX/QBCORE framework (parameters: item, count)
            logDelivery('removeItem', buyer, true, deliveryId)
        end

    elseif Nexify.framework == 'creative' then
        local passport = tonumber(buyer)

        vRP.RemoveItem(passport, item, count, true)
        logDelivery('removeItem', buyer, true, deliveryId)

    elseif Nexify.framework == 'vrp' then
        local user_id = vRP.getUserId(source)

        if user_id then
            -- adicione sua lógica ou função de remoção de item na framework vRP (parâmetros: item, count)
            -- Add your item removal logic or function to the vRP framework (parameters: item, count)
            logDelivery('removeItem', buyer, true, deliveryId)
        end
    else
        -- STANDALONE
        TriggerEvent('nexify:standalone:removeItem', source, item, count, deliveryId)
    end
end)

------------------------------------------------------------------------------------------------
-- ADDVEHICLE
------------------------------------------------------------------------------------------------

AddEventHandler('fivemarket:addVehicle', function(buyer, command_value, deliveryId)
    local source = resolveSource(buyer)

    if not source then 
        return logDelivery('addVehicle', buyer, false, deliveryId) 
    end

    local model = tostring(command_value):lower()

    if Nexify.framework == 'esx' then
        local xPlayer = Nexify.frameworkObject.GetPlayerFromId(source)

        if xPlayer then
            local identifier = xPlayer.getIdentifier()

            MySQL.insert('INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (?, ?, ?)', {
                identifier,
                'NXF' .. math.random(10000, 99999),
                json.encode({ model = model })
            })

            logDelivery('addVehicle', buyer, true, deliveryId)
        end

    elseif Nexify.framework == 'qbcore' or Nexify.framework == 'qbox' then
        local Player = Nexify.frameworkObject.Functions.GetPlayer(source)

        if Player then
            local plate = Nexify.frameworkObject.Functions.GeneratePlate()

            Player.Functions.AddItem('vehicle_keys', 1, { plate = plate })
            MySQL.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, plate) VALUES (?, ?, ?, ?)', {
                Player.PlayerData.license,
                Player.PlayerData.citizenid,
                model,
                plate
            })

            logDelivery('addVehicle', buyer, true, deliveryId)
        end

    elseif Nexify.framework == 'creative' then
        local passport  = tonumber(buyer)
        local plate     = vRP.GeneratePlate()
        local license   = vRP.License(passport)

        MySQL.insert('INSERT INTO vehicles (passport, plate, vehicle) VALUES (?, ?, ?)', {
            passport,
            plate,
            json.encode({ model = model })
        })

        logDelivery('addVehicle', buyer, true, deliveryId)

    else
        -- vRP comum e standalone: fallback para evento customizável
        TriggerEvent('nexify:standalone:addVehicle', source, model, deliveryId)
    end
end)

------------------------------------------------------------------------------------------------
-- ADDVEHICLETEMP
------------------------------------------------------------------------------------------------

AddEventHandler('fivemarket:addCarTemporary', function(buyer, command_value, deliveryId)
    local source = resolveSource(buyer)

    if not source then 
        return logDelivery('addCarTemporary', buyer, false, deliveryId) 
    end

    local model, days = command_value, 1

    if type(command_value) == 'string' and command_value:find(':') then
        model  = command_value:match('(.-):(.*)')
        days = tonumber(command_value:match('.-:(.*)')) or 1
    end

    if Nexify.framework == 'esx' then
        local xPlayer = Nexify.frameworkObject.GetPlayerFromId(source)

        if xPlayer then
            local identifier = xPlayer.getIdentifier()

            -- adicione sua lógica ou função de adição de veículo temporário na framework ESX (parâmetros: model, days)
            -- add your logic or function for adding temporary vehicles to the ESX framework. (parameters: model, days)
            logDelivery('addCarTemporary', buyer, true, deliveryId)
        end

    elseif Nexify.framework == 'qbcore' or Nexify.framework == 'qbox' then
        local Player = Nexify.frameworkObject.Functions.GetPlayer(source)

        if Player then
            local plate = Nexify.frameworkObject.Functions.GeneratePlate()

            -- adicione sua lógica ou função de adição de veículo temporário na framework QBCORE/QBOX (parâmetros: model, days)
            -- add your logic or function for adding temporary vehicles to the QBCORE/QBOX framework. (parameters: model, days)
            logDelivery('addCarTemporary', buyer, true, deliveryId)
        end

    elseif Nexify.framework == 'creative' then
        local passport  = tonumber(buyer)
        local plate     = vRP.GeneratePlate()
        local license   = vRP.License(passport)

        -- adicione sua lógica ou função de adição de veículo temporário na framework ESX (parâmetros: model, days)
        -- add your logic or function for adding temporary vehicles to the ESX framework. (parameters: model, days)
        logDelivery('addCarTemporary', buyer, true, deliveryId)
    else
        -- vRP comum e standalone: fallback para evento customizável
        TriggerEvent('nexify:standalone:addCarTemporary', source, model, days, deliveryId)
    end
end)

------------------------------------------------------------------------------------------------
-- REMOVECAR
------------------------------------------------------------------------------------------------

AddEventHandler('fivemarket:removeCar', function(buyer, command_value, deliveryId)
    local source = resolveSource(buyer)

    if not source then 
        return logDelivery('removeCar', buyer, false, deliveryId) 
    end

    local model = tostring(command_value):lower()

    if Nexify.framework == 'esx' then
        local xPlayer = Nexify.frameworkObject.GetPlayerFromId(source)

        if xPlayer then
            -- adicione sua lógica ou função de remoção de veículo na framework ESX (parâmetro: model)
            -- Add your vehicle removal logic or function to the ESX framework (parameter: model)
            logDelivery('removeCar', buyer, true, deliveryId)
        end

    elseif Nexify.framework == 'qbcore' or Nexify.framework == 'qbox' then
        local Player = Nexify.frameworkObject.Functions.GetPlayer(source)

        if Player then
            -- adicione sua lógica ou função de remoção de veículo na framework QBCORE e QBOX (parâmetro: model)
            -- Add your vehicle removal logic or function to the QBCORE and QBOX framework (parameter: model)
            logDelivery('removeCar', buyer, true, deliveryId)
        end

    elseif Nexify.framework == 'creative' then
        -- adicione sua lógica ou função de remoção de veículo na framework Creative (parâmetro: model)
        -- Add your vehicle removal logic or function to the Creative framework (parameter: model)
        logDelivery('removeCar', buyer, true, deliveryId)

    else
        -- vRP comum e standalone: fallback para evento customizável
        TriggerEvent('nexify:standalone:removeCar', source, model, deliveryId)
    end
end)

------------------------------------------------------------------------------------------------
-- ADDGROUP
------------------------------------------------------------------------------------------------

AddEventHandler('fivemarket:addGroup', function(buyer, command_value, deliveryId)
    local source = resolveSource(buyer)

    if not source then
        return logDelivery('addGroup', buyer, false, deliveryId) 
    end

    if Nexify.framework == 'esx' then
        local xPlayer = Nexify.frameworkObject.GetPlayerFromId(source)

        if xPlayer then
            -- adicione sua lógica ou função que adicione um grupo ou permissão a um jogador na framework ESX (parâmetro: command_value)
            -- Add your logic or function that adds a group or permission to a player in the ESX framework (parameter: command_value)
            logDelivery('addGroup', buyer, true, deliveryId)
        end

    elseif Nexify.framework == 'qbcore' or Nexify.framework == 'qbox' then
        local Player = Nexify.frameworkObject.Functions.GetPlayer(source)

        if Player then
            -- adicione sua lógica ou função que adicione um grupo ou permissão a um jogador na framework QB CORE / QBOX (parâmetro: command_value)
            -- Add your logic or function that adds a group or permission to a player in the QB CORE / QBOX framework (parameter: command_value)
            logDelivery('addGroup', buyer, true, deliveryId)
        end

    elseif Nexify.framework == 'creative' then
        local passport = tonumber(buyer)

        if passport then
            -- SetPermission(Passport, Permission, Level, Mode)
            -- Level nil = máximo da hierarquia definido nos Groups
            vRP.SetPermission(passport, command_value, nil, nil)
            logDelivery('addGroup', buyer, true, deliveryId)
        end
    elseif Nexify.framework == 'vrp' then
        local user_id = vRP.getUserId(source)

        if user_id then
            -- adicione sua lógica ou função que adicione um grupo ou permissão a um jogador na framework QB CORE / QBOX (parâmetro: command_value)
            -- Add your logic or function that adds a group or permission to a player in the QB CORE / QBOX framework (parameter: command_value)
            logDelivery('addGroup', buyer, true, deliveryId)
        end
    else
        -- Ace permissions nativas do FiveM
        ExecuteCommand(string.format('add_principal identifier.%s %s', tostring(buyer), command_value))
        logDelivery('addGroup', buyer, true, deliveryId)
    end
end)

------------------------------------------------------------------------------------------------
-- REMGROUP
------------------------------------------------------------------------------------------------

AddEventHandler('fivemarket:removeGroup', function(buyer, command_value, deliveryId)
    local source = resolveSource(buyer)

    if not source then
        return logDelivery('removeGroup', buyer, false, deliveryId) 
    end

    if Nexify.framework == 'esx' then
        local xPlayer = Nexify.frameworkObject.GetPlayerFromId(source)

        if xPlayer then
            -- adicione sua lógica ou função que remove um grupo ou permissão a um jogador na framework ESX (parâmetro: command_value)
            -- Add your logic or function that removes a group or permission from a player in the ESX framework (parameter: command_value)
            logDelivery('removeGroup', buyer, true, deliveryId)
        end

    elseif Nexify.framework == 'qbcore' or Nexify.framework == 'qbox' then
        local Player = Nexify.frameworkObject.Functions.GetPlayer(source)

        if Player then
            -- adicione sua lógica ou função que remove um grupo ou permissão a um jogador na framework QB CORE / QBOX (parâmetro: command_value)
            -- Add your logic or function that removes a group or permission from a player in the QB CORE / QBOX framework (parameter: command_value)
            logDelivery('removeGroup', buyer, true, deliveryId)
        end

    elseif Nexify.framework == 'creative' then
        local passport = tonumber(buyer)

        if passport then
            vRP.RemovePermission(passport, command_value)
            logDelivery('removeGroup', buyer, true, deliveryId)
        end
    elseif Nexify.framework == 'vrp' then
        local user_id = vRP.getUserId(source)

        if user_id then
            -- adicione sua lógica ou função que remove um grupo ou permissão a um jogador na framework QB CORE / QBOX (parâmetro: command_value)
            -- Add your logic or function that removes a group or permission from a player in the vRP framework (parameter: command_value)
            logDelivery('removeGroup', buyer, true, deliveryId)
        end
    else
        -- Ace permissions nativas do FiveM
        ExecuteCommand(string.format('rem_principal identifier.%s %s', tostring(buyer), command_value))
        logDelivery('removeGroup', buyer, true, deliveryId)
    end
end)

------------------------------------------------------------------------------------------------
-- ADDHOUSE
------------------------------------------------------------------------------------------------

AddEventHandler('fivemarket:addHouse', function(buyer, command_value, deliveryId)
    local source = resolveSource(buyer)

    if not source then 
        return logDelivery('addHouse', buyer, false, deliveryId) 
    end

    local house = tonumber(command_value)

    if Nexify.framework == 'esx' then
        local xPlayer = Nexify.frameworkObject.GetPlayerFromId(source)

        if xPlayer then
            -- adicione sua lógica ou função que dê uma casa a um jogador na framework ESX (parâmetro: house)
            -- Add your logic or function that assigns a house to a player in the ESX framework (parameter: house)
            logDelivery('addHouse', buyer, true, deliveryId)
        end

    elseif Nexify.framework == 'qbcore' or Nexify.framework == 'qbox' then
        local Player = Nexify.frameworkObject.Functions.GetPlayer(source)

        if Player then
            -- adicione sua lógica ou função que dê uma casa a um jogador na framework QBCORE/QBOX (parâmetro: house)
            -- Add your logic or function that assigns a house to a player in the QBCORE/QBOX framework (parameter: house)
            logDelivery('addHouse', buyer, true, deliveryId)
        end

    elseif Nexify.framework == 'creative' then
        -- adicione sua lógica ou função que dê uma casa a um jogador na framework Creative (parâmetro: house)
        -- Add your logic or function that assigns a house to a player in the Creative framework (parameter: house)
        logDelivery('addHouse', buyer, true, deliveryId)

    elseif Nexify.framework == 'vrp' then
        local user_id = vRP.getUserId(source)

        if user_id then
            -- adicione sua lógica ou função que dê uma casa a um jogador na framework Creative (parâmetro: house)
            -- Add your logic or function that assigns a house to a player in the Creative framework (parameter: house)
            logDelivery('addHouse', buyer, true, deliveryId)
        end
    else
        -- STANDALONE
        TriggerEvent('nexify:standalone:addHouse', source, house, deliveryId)
    end
end)

------------------------------------------------------------------------------------------------
-- ADDHOUSETEMP
------------------------------------------------------------------------------------------------

AddEventHandler('fivemarket:addHouseTemporary', function(buyer, command_value, deliveryId)
    local source = resolveSource(buyer)

    if not source then 
        return logDelivery('addHouseTemporary', buyer, false, deliveryId) 
    end

    local house, days = command_value, 1

    if type(command_value) == 'string' and command_value:find(':') then
        house = tonumber(command_value:match('(.-):(.*)'))
        days = tonumber(command_value:match('.-:(.*)')) or 1
    end

    if Nexify.framework == 'esx' then
        local xPlayer = Nexify.frameworkObject.GetPlayerFromId(source)

        if xPlayer then
            -- adicione sua lógica ou função de adição de casa temporário na framework ESX (parâmetros: house, days)
            -- add your logic or function for adding temporary houses to the ESX framework. (parameters: house, days)
            logDelivery('addHouseTemporary', buyer, true, deliveryId)
        end

    elseif Nexify.framework == 'qbcore' or Nexify.framework == 'qbox' then
        local Player = Nexify.frameworkObject.Functions.GetPlayer(source)

        if Player then
            -- adicione sua lógica ou função de adição de casa temporário na framework QBCORE/QBOX (parâmetros: house, days)
            -- add your logic or function for adding temporary houses to the QBCORE/QBOX framework. (parameters: house, days)
            logDelivery('addHouseTemporary', buyer, true, deliveryId)
        end

    elseif Nexify.framework == 'creative' then
        -- adicione sua lógica ou função de adição de casa temporário na framework ESX (parâmetros: house, days)
        -- add your logic or function for adding temporary houses to the ESX framework. (parameters: house, days)
        logDelivery('addHouseTemporary', buyer, true, deliveryId)
    else
        -- vRP comum e standalone: fallback para evento customizável
        TriggerEvent('nexify:standalone:addHouseTemporary', source, house, days, deliveryId)
    end
end)

------------------------------------------------------------------------------------------------
-- REMHOUSE
------------------------------------------------------------------------------------------------

AddEventHandler('fivemarket:removeHouse', function(buyer, command_value, deliveryId)
    local source = resolveSource(buyer)

    if not source then 
        return logDelivery('removeHouse', buyer, false, deliveryId) 
    end

    local house = tonumber(command_value)

    if Nexify.framework == 'esx' then
        local xPlayer = Nexify.frameworkObject.GetPlayerFromId(source)

        if xPlayer then
            -- adicione sua lógica ou função de remoção de casas na framework ESX (parâmetro: house)
            -- Add your house removal logic or function to the ESX framework (parameter: house)
            logDelivery('removeHouse', buyer, true, deliveryId)
        end

    elseif Nexify.framework == 'qbcore' or Nexify.framework == 'qbox' then
        local Player = Nexify.frameworkObject.Functions.GetPlayer(source)

        if Player then
            -- adicione sua lógica ou função de remoção de casas na framework QBCORE e QBOX (parâmetro: house)
            -- Add your house removal logic or function to the QBCORE and QBOX framework (parameter: house)
            logDelivery('removeHouse', buyer, true, deliveryId)
        end

    elseif Nexify.framework == 'creative' then
        -- adicione sua lógica ou função de remoção de casas na framework Creative (parâmetro: house)
        -- Add your house removal logic or function to the Creative framework (parameter: house)
        logDelivery('removeHouse', buyer, true, deliveryId)

    else
        -- vRP comum e standalone: fallback para evento customizável
        TriggerEvent('nexify:standalone:removeHouse', source, house, deliveryId)
    end
end)