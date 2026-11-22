fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Arena'
description 'Neon lobby menu with a live player-ped preview'
version '1.0.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
    'html/assets/neon-city.jpg',
    'html/assets/neon-city-stage.png'
}

shared_script 'config.lua'
client_script 'client.lua'
