-- Listeners e helpers exclusivos da Creative (testado na versão Enhanced)
-- adapte se necessário

SetTimeout(800, function()
    if Nexify.framework ~= 'creative' then
        return
    end

    local Tunnel = module("vrp","lib/Tunnel")
    local Proxy = module("vrp","lib/Proxy")
    vRP = Proxy.getInterface("vRP")

    if type(vRP) ~= 'table' then
        print('^1[Nexify]^0 Creative: global vRP não encontrado. Verifique se a resource vrp está iniciada antes do nexify.')
        return
    end

    function Nexify.creativeSource(passport)
        return vRP.Source(tonumber(passport))
    end

    function Nexify.creativePassport(source)
        return vRP.Passport(source)
    end
end)