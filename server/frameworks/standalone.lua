-- Handlers de fallback para servidores sem framework

SetTimeout(800, function()
    if Nexify.framework ~= 'standalone' then
        return
    end

    -- Esses eventos são disparados pelos handlers quando framework = standalone.
    -- O dono do servidor pode customizar a lógica aqui conforme sua necessidade.

    AddEventHandler('nexify:standalone:addMoney', function(source, moneyType, amount, deliveryId)
        print(string.format('^3[Nexify Standalone]^0 addMoney: player=%s type=%s amount=%s delivery=%s',
            source, moneyType, amount, deliveryId))
        -- Implemente sua lógica customizada aqui
    end)

    AddEventHandler('nexify:standalone:addItem', function(source, item, count, deliveryId)
        print(string.format('^3[Nexify Standalone]^0 addItem: player=%s item=%s count=%s delivery=%s',
            source, item, count, deliveryId))
        -- Implemente sua lógica customizada aqui
    end)

    AddEventHandler('nexify:standalone:removeItem', function(source, item, count, deliveryId)
        print(string.format('^3[Nexify Standalone]^0 removeItem: player=%s item=%s count=%s delivery=%s',
            source, item, count, deliveryId))
        -- Implemente sua lógica customizada aqui
    end)

    AddEventHandler('nexify:standalone:addVehicle', function(source, model, deliveryId)
        print(string.format('^3[Nexify Standalone]^0 addVehicle: player=%s model=%s delivery=%s',
            source, model, deliveryId))
        -- Implemente sua lógica customizada aqui
    end)

    AddEventHandler('nexify:standalone:addCarTemporary', function(source, model, days, deliveryId)
        print(string.format('^3[Nexify Standalone]^0 addCarTemporary: player=%s model=%s days =%s delivery=%s',
            source, model, days, deliveryId))
        -- Implemente sua lógica customizada aqui
    end)

    AddEventHandler('nexify:standalone:removeCar', function(source, model, deliveryId)
        print(string.format('^3[Nexify Standalone]^0 removeCar: player=%s model=%s delivery=%s',
            source, model, deliveryId))
        -- Implemente sua lógica customizada aqui
    end)

    AddEventHandler('nexify:standalone:addHouse', function(source, house, deliveryId)
        print(string.format('^3[Nexify Standalone]^0 addHouse: player=%s house=%s delivery=%s',
            source, house, deliveryId))
        -- Implemente sua lógica customizada aqui
    end)

    AddEventHandler('nexify:standalone:addHouseTemporary', function(source, house, days, deliveryId)
        print(string.format('^3[Nexify Standalone]^0 addHouseTemporary: player=%s house=%s days =%s delivery=%s',
            source, house, days, deliveryId))
        -- Implemente sua lógica customizada aqui
    end)

    AddEventHandler('nexify:standalone:removeHouse', function(source, house, deliveryId)
        print(string.format('^3[Nexify Standalone]^0 removeHouse: player=%s house=%s delivery=%s',
            source, house, deliveryId))
        -- Implemente sua lógica customizada aqui
    end)
end)