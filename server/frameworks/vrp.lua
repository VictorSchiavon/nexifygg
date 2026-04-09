-- Listeners e helpers exclusivos do vRP

SetTimeout(800, function()
    if Nexify.framework ~= 'vrp' then
        return
    end

    vRP    = exports.vrp:getSharedObject()
    vRPclient = exports.vrp_client:getSharedObject()

    function Nexify.getVRPUserId(source)
        return vRP.getUserId({ source })
    end
end)