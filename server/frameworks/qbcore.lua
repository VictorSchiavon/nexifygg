-- Listeners e helpers exclusivos do QBCore

SetTimeout(800, function() 
    if Nexify.framework ~= 'qbcore' then
        return
    end

    function Nexify.getQBPlayer(source)
        return Nexify.frameworkObject.Functions.GetPlayer(source)
    end
end)