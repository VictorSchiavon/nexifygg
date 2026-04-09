-- Listeners e helpers exclusivos do QBox (qbx_core)

SetTimeout(800, function() 
    if Nexify.framework ~= 'qbox' then
        return
    end

    function Nexify.getQBoxPlayer(source)
        return Nexify.frameworkObject.Functions.GetPlayer(source)
    end
end)