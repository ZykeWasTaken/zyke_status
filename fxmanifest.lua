fx_version "cerulean"
game "gta5"
lua54 "yes"
author "discord.gg/zykeresources"

shared_scripts {
    "@zyke_lib/imports.lua",
    "shared/unlocked/config.lua",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/locked/main.lua",
    "server/unlocked/register_statuses.lua",
    "server/locked/functions.lua",
    "server/locked/eventhandler.lua",
    "server/unlocked/functions.lua",
    "statuses/**/server.lua",

    "server/locked/initialize.lua",
}

client_scripts {
    "client/locked/main.lua",
    "statuses/**/client.lua",
}