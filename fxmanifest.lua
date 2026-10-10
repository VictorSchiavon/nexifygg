fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'nexify-loja'
description 'Loja da Nexify aberta dentro do jogo'
author 'Nexify'
version '1.0.0'

shared_script 'config.lua'
client_script 'client.lua'

-- Ordem importa: adaptadores.lua sabe achar a base (Nexify.Identificar) e o
-- entregas.lua registra o que fazer com cada compra -- ambos antes do
-- entrega.lua, que e quem dispara as entregas.
server_scripts {
    'adaptadores.lua',
    'entregas.lua',
    'server.lua',
    'entrega.lua'
}

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/style.css',
    'ui/app.js'
}
