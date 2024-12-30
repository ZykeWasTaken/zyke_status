fx_version "cerulean"
game "gta5"
lua54 "yes"
author "discord.gg/zykeresources"

shared_scripts {
    "@zyke_lib/imports.lua",
    "shared/config.lua",
    "shared/functions.lua",

    "statuses/**/config.lua",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/main.lua",
    "server/initialize.lua",

    "server/register_statuses.lua",
    "server/functions.lua",

    "statuses/**/core/server.lua",
    "statuses/**/effects/server.lua",

    "server/eventhandler.lua",

    "dev/server.lua",
}

client_scripts {
    "client/main.lua",
    "client/queue.lua",

    "client/functions.lua",
    "client/eventhandler.lua",

    "statuses/**/core/client.lua",
    "statuses/**/effects/client.lua",

    "effects/*.lua",
    "dev/client.lua",
}