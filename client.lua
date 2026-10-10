--[[
    Lado cliente: abre e fecha a janela da loja e leva as escolhas do jogador
    ate o servidor. Nada aqui conhece o token da loja.
]]

local aberta = false

local function fechar()
    if not aberta then return end
    aberta = false
    SetNuiFocus(false, false)
    SendNUIMessage({ acao = 'fechar' })
end

local function abrir()
    if aberta then return end
    TriggerServerEvent('nexify-loja:abrir')
end

local function aviso(texto)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(texto)
    EndTextCommandThefeedPostTicker(false, true)
end

RegisterNetEvent('nexify-loja:catalogo', function(dados)
    aberta = true
    SetNuiFocus(true, true)
    SendNUIMessage({ acao = 'abrir', dados = dados })
end)

RegisterNetEvent('nexify-loja:pagamento', function(dados)
    SendNUIMessage({ acao = 'pagamento', dados = dados })
end)

RegisterNetEvent('nexify-loja:pedido', function(dados)
    SendNUIMessage({ acao = 'pedido', dados = dados })
    if dados.situacao == 'aprovado' then
        aviso('~g~Pagamento aprovado!~s~ Sua compra ja esta a caminho.')
    end
end)

RegisterNetEvent('nexify-loja:erro', function(mensagem)
    SendNUIMessage({ acao = 'erro', mensagem = mensagem })
    if not aberta then
        aviso('~r~Loja:~s~ ' .. tostring(mensagem))
    end
end)

RegisterNUICallback('fechar', function(_, responder)
    fechar()
    responder({ ok = true })
end)

RegisterNUICallback('comprar', function(dados, responder)
    TriggerServerEvent('nexify-loja:comprar', dados.carrinho, dados.cupom)
    responder({ ok = true })
end)

RegisterNUICallback('consultar', function(dados, responder)
    TriggerServerEvent('nexify-loja:consultar', dados.referencia)
    responder({ ok = true })
end)

-- Loja no jogo desligada: o resource fica so com a entrega, sem comando,
-- sem tecla e sem janela.
if not Config.lojaNoJogo then
    return
end

RegisterCommand(Config.comando, function()
    abrir()
end, false)

-- Fecha com ESC mesmo que a janela trave por algum motivo.
CreateThread(function()
    while true do
        if aberta then
            if IsControlJustReleased(0, 322) then fechar() end
            Wait(0)
        else
            Wait(500)
        end
    end
end)

if Config.tecla and Config.tecla ~= '' then
    RegisterKeyMapping(Config.comando, 'Abrir a loja', 'keyboard', Config.tecla)
end
