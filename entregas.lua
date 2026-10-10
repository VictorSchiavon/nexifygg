--[[
    Entregas por framework -- o que fazer com cada compra aprovada.

    O entrega.lua recebe a compra da Nexify e dispara um evento por comando do
    produto, por exemplo "fivemarket:addMoney". Quem transforma esse evento em
    dinheiro, item, VIP ou veiculo na sua base e ESTE arquivo.

    ESTE ARQUIVO E ABERTO DE PROPOSITO: ajuste a logica a vontade conforme a sua
    base. O resto do resource (server.lua, entrega.lua, adaptadores.lua) vem
    ofuscado e nao precisa ser tocado.

    O que ja vem pronto:
      - ESX, QBCore e Qbox: dinheiro, item e veiculo.
      - Standalone (sem framework): dispara "nexify:standalone:*" para voce
        tratar do seu jeito.
      - vRP / Creative: os blocos estao aqui como referencia. Como este resource
        NAO carrega a lib da vRP de proposito (senao quebraria servidores sem
        vRP), para usar vRP/Creative preencha o AJUSTE abaixo e garanta acesso
        ao objeto da sua base.
      - Grupos, casas e remocoes: deixados como ponto de partida -- preencha com
        a funcao da sua base onde estiver indicado.

    A confirmacao da entrega com a Nexify e feita sozinha pelo entrega.lua. Aqui
    voce so executa; nao precisa avisar a Nexify de nada.
]]

Nexify = Nexify or {}
Nexify.framework = nil        -- 'esx' | 'qbcore' | 'qbox' | 'creative' | 'vrp' | nil (standalone)
Nexify.frameworkObject = nil  -- o objeto da base (ESX, QBCore, ...)

------------------------------------------------------------------ AJUSTE (vRP)

-- Deixe false para a deteccao automatica (ESX/QBCore/Qbox) trabalhar.
-- Marque true e preencha se a sua base for vRP ou um fork (Creative e afins).
local VRP_MANUAL = {
    ativo = false,
    -- 'vrp' para vRP padrao, 'creative' para forks estilo Creative.
    tipo = 'vrp',
    -- Como este arquivo chega ao objeto vRP. Ex.: module("vrp","lib/Proxy") no
    -- topo do arquivo, ou um export da sua base. Devolva o objeto aqui.
    obter = function()
        -- return Proxy.getInterface("vRP")
        return nil
    end,
}

----------------------------------------------------------------- DETECCAO

CreateThread(function()
    -- Da tempo das bases subirem antes de perguntar.
    Wait(2000)

    if VRP_MANUAL.ativo then
        Nexify.framework = VRP_MANUAL.tipo
        local ok, obj = pcall(VRP_MANUAL.obter)
        Nexify.frameworkObject = ok and obj or nil
        vRP = Nexify.frameworkObject or vRP
    elseif GetResourceState('es_extended') == 'started' then
        local ok, obj = pcall(function() return exports['es_extended']:getSharedObject() end)
        if ok and obj then Nexify.framework, Nexify.frameworkObject = 'esx', obj end
    elseif GetResourceState('qbx_core') == 'started' then
        Nexify.framework, Nexify.frameworkObject = 'qbox', exports.qbx_core
    elseif GetResourceState('qb-core') == 'started' then
        local ok, obj = pcall(function() return exports['qb-core']:GetCoreObject() end)
        if ok and obj then Nexify.framework, Nexify.frameworkObject = 'qbcore', obj end
    end

    if Config.mostrarEntregaNoConsole then
        print(('[nexify-loja] Entregas: base reconhecida = %s'):format(Nexify.framework or 'standalone (eventos nexify:standalone:*)'))
    end
end)

----------------------------------------------------------------- FERRAMENTAS

-- Acha o jogador online dono deste identificador. O "buyer" e o mesmo
-- identificador que o adaptadores.lua usou na compra; so e possivel entregar
-- se o jogador estiver online.
local function resolverSource(buyer)
    buyer = tostring(buyer)

    -- Barato primeiro: identificador nativo (steam/license/discord).
    for _, pid in ipairs(GetPlayers()) do
        local src = tonumber(pid)
        if src then
            for _, ident in ipairs(GetPlayerIdentifiers(src)) do
                if ident == buyer then return src end
            end
        end
    end

    -- Caro depois: a mesma identificacao da base que gerou o comprador.
    if Nexify.Identificar then
        for _, pid in ipairs(GetPlayers()) do
            local src = tonumber(pid)
            if src then
                local ok, id = pcall(Nexify.Identificar, src)
                if ok and id and tostring(id) == buyer then return src end
            end
        end
    end

    return nil
end

local function logEntrega(tipo, buyer, ok, extra)
    if not Config.mostrarEntregaNoConsole then return end
    print(('[nexify-loja] %s para "%s": %s%s'):format(
        tipo, tostring(buyer),
        ok and 'OK' or 'nao entregue',
        extra and (' (' .. extra .. ')') or ''
    ))
end

-- Executa a entrega protegida: erro na API da base vira log, nunca derruba o
-- resource nem trava a fila. Devolve true so quando executou de fato.
local function executar(tipo, buyer, fn)
    local ok, erro = pcall(fn)
    if ok then
        logEntrega(tipo, buyer, true)
        return true
    end
    logEntrega(tipo, buyer, false, tostring(erro))
    return false
end

-- "item:3" -> "item", 3   |   "item" -> "item", 1
local function separar(valor, padrao)
    local chave, resto = valor, padrao
    if type(valor) == 'string' and valor:find(':') then
        chave = valor:match('(.-):(.*)')
        resto = tonumber(valor:match('.-:(.*)')) or padrao
    end
    return chave, resto
end

----------------------------------------------------------------- ADDMONEY

AddEventHandler('fivemarket:addMoney', function(buyer, command_value)
    local source = resolverSource(buyer)
    if not source then return logEntrega('addMoney', buyer, false, 'jogador offline') end

    local moneyType, amount = 'cash', tonumber(command_value)
    if type(command_value) == 'string' and command_value:find(':') then
        moneyType = command_value:match('(.-):(.*)')
        amount    = tonumber(command_value:match('.-:(.*)'))
    end
    if not amount or amount <= 0 then return logEntrega('addMoney', buyer, false, 'valor invalido') end

    if Nexify.framework == 'esx' then
        executar('addMoney', buyer, function()
            local xPlayer = Nexify.frameworkObject.GetPlayerFromId(source)
            xPlayer.addMoney(amount)
        end)

    elseif Nexify.framework == 'qbcore' or Nexify.framework == 'qbox' then
        executar('addMoney', buyer, function()
            local Player = Nexify.frameworkObject.Functions.GetPlayer(source)
            Player.Functions.AddMoney(moneyType, amount)
        end)

    elseif Nexify.framework == 'creative' then
        executar('addMoney', buyer, function()
            vRP.GiveBank(tonumber(buyer), amount, false)
        end)

    elseif Nexify.framework == 'vrp' then
        executar('addMoney', buyer, function()
            local user_id = vRP.getUserId(source)
            vRP.giveWallet({ user_id, amount })
        end)

    else
        TriggerEvent('nexify:standalone:addMoney', source, moneyType, amount)
        logEntrega('addMoney', buyer, true, 'standalone')
    end
end)

----------------------------------------------------------------- ADDITEM

AddEventHandler('fivemarket:addItem', function(buyer, command_value)
    local source = resolverSource(buyer)
    if not source then return logEntrega('addItem', buyer, false, 'jogador offline') end

    local item, count = separar(command_value, 1)

    if Nexify.framework == 'esx' then
        executar('addItem', buyer, function()
            local xPlayer = Nexify.frameworkObject.GetPlayerFromId(source)
            xPlayer.addInventoryItem(item, count)
        end)

    elseif Nexify.framework == 'qbcore' or Nexify.framework == 'qbox' then
        executar('addItem', buyer, function()
            local Player = Nexify.frameworkObject.Functions.GetPlayer(source)
            Player.Functions.AddItem(item, count)
        end)

    elseif Nexify.framework == 'creative' then
        executar('addItem', buyer, function()
            vRP.GenerateItem(tonumber(buyer), item, count, true)
        end)

    elseif Nexify.framework == 'vrp' then
        executar('addItem', buyer, function()
            vRPclient.giveInventoryItem({ source, item, count })
        end)

    else
        TriggerEvent('nexify:standalone:addItem', source, item, count)
        logEntrega('addItem', buyer, true, 'standalone')
    end
end)

----------------------------------------------------------------- ADDVEHICLE

AddEventHandler('fivemarket:addVehicle', function(buyer, command_value)
    local source = resolverSource(buyer)
    if not source then return logEntrega('addVehicle', buyer, false, 'jogador offline') end

    local model = tostring(command_value):lower()

    if Nexify.framework == 'esx' then
        executar('addVehicle', buyer, function()
            local xPlayer = Nexify.frameworkObject.GetPlayerFromId(source)
            local identifier = xPlayer.getIdentifier()
            MySQL.insert('INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (?, ?, ?)', {
                identifier,
                'NXF' .. math.random(10000, 99999),
                json.encode({ model = model })
            })
        end)

    elseif Nexify.framework == 'qbcore' or Nexify.framework == 'qbox' then
        executar('addVehicle', buyer, function()
            local Player = Nexify.frameworkObject.Functions.GetPlayer(source)
            local plate = Nexify.frameworkObject.Functions.GeneratePlate()
            Player.Functions.AddItem('vehicle_keys', 1, { plate = plate })
            MySQL.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, plate) VALUES (?, ?, ?, ?)', {
                Player.PlayerData.license,
                Player.PlayerData.citizenid,
                model,
                plate
            })
        end)

    elseif Nexify.framework == 'creative' then
        executar('addVehicle', buyer, function()
            local passport = tonumber(buyer)
            local plate    = vRP.GeneratePlate()
            MySQL.insert('INSERT INTO vehicles (passport, plate, vehicle) VALUES (?, ?, ?)', {
                passport,
                plate,
                json.encode({ model = model })
            })
        end)

    else
        TriggerEvent('nexify:standalone:addVehicle', source, model)
        logEntrega('addVehicle', buyer, true, 'standalone')
    end
end)

----------------------------------------------------------------- ADDGROUP (VIP)

AddEventHandler('fivemarket:addGroup', function(buyer, command_value)
    local source = resolverSource(buyer)
    if not source then return logEntrega('addGroup', buyer, false, 'jogador offline') end

    if Nexify.framework == 'creative' then
        executar('addGroup', buyer, function()
            -- Level nil = maximo da hierarquia definido nos Groups
            vRP.SetPermission(tonumber(buyer), command_value, nil, nil)
        end)

    elseif Nexify.framework == 'esx' or Nexify.framework == 'qbcore'
        or Nexify.framework == 'qbox' or Nexify.framework == 'vrp' then
        -- PREENCHA: adicione aqui a funcao da sua base que da o grupo/VIP.
        -- ESX:    local xPlayer = Nexify.frameworkObject.GetPlayerFromId(source); xPlayer.setGroup(command_value)
        -- QB/Qbox: local Player = Nexify.frameworkObject.Functions.GetPlayer(source); Player.Functions.SetPermission(command_value, 4) (ajuste)
        -- vRP:    vRP.addUserGroup({ vRP.getUserId(source), command_value })
        logEntrega('addGroup', buyer, false, 'preencha a logica de VIP no entregas.lua')

    else
        -- Standalone: ACE permissions nativas do FiveM.
        executar('addGroup', buyer, function()
            ExecuteCommand(('add_principal identifier.%s %s'):format(tostring(buyer), command_value))
        end)
    end
end)

----------------------------------------------------------------- REMGROUP

AddEventHandler('fivemarket:removeGroup', function(buyer, command_value)
    local source = resolverSource(buyer)
    if not source then return logEntrega('removeGroup', buyer, false, 'jogador offline') end

    if Nexify.framework == 'creative' then
        executar('removeGroup', buyer, function()
            vRP.RemovePermission(tonumber(buyer), command_value)
        end)

    elseif Nexify.framework == 'esx' or Nexify.framework == 'qbcore'
        or Nexify.framework == 'qbox' or Nexify.framework == 'vrp' then
        -- PREENCHA: funcao da sua base que remove o grupo/VIP.
        logEntrega('removeGroup', buyer, false, 'preencha a logica no entregas.lua')

    else
        executar('removeGroup', buyer, function()
            ExecuteCommand(('rem_principal identifier.%s %s'):format(tostring(buyer), command_value))
        end)
    end
end)

--------------------------------------------------- STUBS (preencha se usar)

-- Os eventos abaixo chegam prontos, mas a acao na base fica por sua conta --
-- cada servidor remove item, entrega casa ou carro temporario de um jeito.
-- Preencha o corpo e troque o logEntrega(false) por executar(...).

AddEventHandler('fivemarket:removeItem', function(buyer, command_value)
    local source = resolverSource(buyer)
    if not source then return logEntrega('removeItem', buyer, false, 'jogador offline') end
    local item, count = separar(command_value, 1)
    -- PREENCHA: remova o item na sua base (item, count).
    if Nexify.framework == nil then
        TriggerEvent('nexify:standalone:removeItem', source, item, count)
        return logEntrega('removeItem', buyer, true, 'standalone')
    end
    logEntrega('removeItem', buyer, false, 'preencha a logica no entregas.lua')
end)

AddEventHandler('fivemarket:addCarTemporary', function(buyer, command_value)
    local source = resolverSource(buyer)
    if not source then return logEntrega('addCarTemporary', buyer, false, 'jogador offline') end
    local model, days = separar(command_value, 1)
    if Nexify.framework == nil then
        TriggerEvent('nexify:standalone:addCarTemporary', source, model, days)
        return logEntrega('addCarTemporary', buyer, true, 'standalone')
    end
    -- PREENCHA: entregue o veiculo temporario (model, days) na sua base.
    logEntrega('addCarTemporary', buyer, false, 'preencha a logica no entregas.lua')
end)

AddEventHandler('fivemarket:removeCar', function(buyer, command_value)
    local source = resolverSource(buyer)
    if not source then return logEntrega('removeCar', buyer, false, 'jogador offline') end
    local model = tostring(command_value):lower()
    if Nexify.framework == nil then
        TriggerEvent('nexify:standalone:removeCar', source, model)
        return logEntrega('removeCar', buyer, true, 'standalone')
    end
    -- PREENCHA: remova o veiculo (model) na sua base.
    logEntrega('removeCar', buyer, false, 'preencha a logica no entregas.lua')
end)

AddEventHandler('fivemarket:addHouse', function(buyer, command_value)
    local source = resolverSource(buyer)
    if not source then return logEntrega('addHouse', buyer, false, 'jogador offline') end
    local house = tonumber(command_value)
    if Nexify.framework == nil then
        TriggerEvent('nexify:standalone:addHouse', source, house)
        return logEntrega('addHouse', buyer, true, 'standalone')
    end
    -- PREENCHA: entregue a casa (house) na sua base.
    logEntrega('addHouse', buyer, false, 'preencha a logica no entregas.lua')
end)

AddEventHandler('fivemarket:addHouseTemporary', function(buyer, command_value)
    local source = resolverSource(buyer)
    if not source then return logEntrega('addHouseTemporary', buyer, false, 'jogador offline') end
    local house, days = separar(command_value, 1)
    if Nexify.framework == nil then
        TriggerEvent('nexify:standalone:addHouseTemporary', source, house, days)
        return logEntrega('addHouseTemporary', buyer, true, 'standalone')
    end
    -- PREENCHA: entregue a casa temporaria (house, days) na sua base.
    logEntrega('addHouseTemporary', buyer, false, 'preencha a logica no entregas.lua')
end)

AddEventHandler('fivemarket:removeHouse', function(buyer, command_value)
    local source = resolverSource(buyer)
    if not source then return logEntrega('removeHouse', buyer, false, 'jogador offline') end
    local house = tonumber(command_value)
    if Nexify.framework == nil then
        TriggerEvent('nexify:standalone:removeHouse', source, house)
        return logEntrega('removeHouse', buyer, true, 'standalone')
    end
    -- PREENCHA: remova a casa (house) na sua base.
    logEntrega('removeHouse', buyer, false, 'preencha a logica no entregas.lua')
end)
