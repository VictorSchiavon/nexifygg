fx_version 'cerulean'
game 'gta5'
name 'nexify'
author 'Koytz'
version '1.0.0'

server_scripts {
    --"@vrp/lib/Utils.lua",         -- ⚠️ Remova os traços se sua framework for Creative
    --"@vrp/lib/utils.lua",         -- ⚠️ Remova os traços se sua framework for vRP

    'main.js',
    'server/main.lua',
    'server/handlers.lua',
    'server/frameworks/*.lua',
    'server/config.lua'
}

dependencies {
    '/server:7290',
    '/onesync',
}