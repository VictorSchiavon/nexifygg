Config = {
    -- Token da loja, em Configuracoes > Integracoes no painel da Nexify.
    -- Ele fica so no servidor: o jogador nunca recebe este valor.
    token = 'SEU-TOKEN-DA-LOJA',

    ------------------------------------------------------------------ ENTREGA

    -- Executa no servidor as compras aprovadas, venham do site ou do jogo.
    -- Deixe ligado se este e o unico script da Nexify aqui. Se voce ja usa o
    -- resource "nexify", pode deixar ligado do mesmo jeito: ele se desliga
    -- sozinho ao ver o outro no ar, para nao entregar em dobro.
    entregarNesteServidor = true,

    -- Escreve no console cada entrega executada. Deixe ligado ate a primeira
    -- venda funcionar.
    mostrarEntregaNoConsole = true,

    ------------------------------------------------------------ LOJA NO JOGO

    -- Abre a loja dentro do jogo. Desligue se voce so quer a entrega e
    -- prefere vender apenas pelo site.
    lojaNoJogo = true,

    -- Comando que abre a loja no jogo.
    comando = 'loja',

    -- Tecla para abrir sem digitar o comando. Deixe '' para nao registrar.
    -- Nomes aceitos: https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/
    tecla = 'F6',

    -- Escreve no console o identificador usado em cada compra feita no jogo.
    -- Ligue no primeiro teste, desligue depois.
    mostrarIdentificadorNoConsole = false,

    ---------------------------------------------------------------------------

    -- Endereco da API da Nexify. So mude se o suporte pedir.
    api = 'https://api.nexify.gg'
}

--------------------------------------------------------------- AJUSTE MANUAL

-- A base do seu servidor (vRP, QBCore, ESX, Qbox, ND ou propria) e
-- reconhecida sozinha. Deixe tudo em branco aqui para o automatico trabalhar.
--
-- So mexa se o comando "nexifyid" no console avisar que nao encontrou o
-- identificador do jogador. Preencha UMA das tres formas abaixo.
AjusteManual = {
    -- Sua base entrega o ID por export? exports['recurso']:metodo(source)
    exportRecurso = '',
    exportMetodo = '',

    -- Ou por evento, respondendo numa funcao de retorno?
    -- TriggerEvent('evento', source, function(id) ... end)
    eventoNome = '',
    eventoEspera = 2000,

    -- Ou de um jeito que so voce sabe. Devolva o identificador aqui.
    naMao = nil -- function(source) return exports['meucore']:getUserId(source) end
}
