-- Listeners e helpers exclusivos do ESX

SetTimeout(800, function() 
    if Nexify.framework ~= 'esx' then
        return 
    end

    -- Fallback: busca por license caso o buyer seja um identifier puro
    function Nexify.getESXPlayer(identifier)
        local xPlayer = Nexify.frameworkObject.GetPlayerFromIdentifier(tostring(identifier))
        return xPlayer
    end
end)