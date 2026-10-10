fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'nexify-loja'
description 'Loja da Nexify aberta dentro do jogo'
author 'Nexify'
version '1.0.0'

shared_script 'config.lua'
client_script 'client.lua'

-- adaptadores.lua vem antes: e ele quem sabe achar a base do servidor.
server_scripts {
    'adaptadores.lua',
    'server.lua',
    'entrega.lua'
}

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/style.css',
    'ui/app.js'
}
