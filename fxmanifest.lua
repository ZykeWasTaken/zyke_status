fx_version "cerulean"
game "gta5"
lua54 "yes"
author "discord.gg/zykeresources"
version "0.1.1"

files {
    "locales/*.lua",
}

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

    "statuses/**/server.lua",

    "server/events.lua",

    "dev/server.lua",
    "shortcuts/server.lua",
    "compatibility/server.lua",
    "server/commands.lua",
}

client_scripts {
    "client/main.lua",

    "client/functions.lua",
    "client/events.lua",

    "statuses/**/client.lua",

    "effects/queue.lua",
    "effects/main.lua",
    "effects/screenEffect.lua",
    "effects/movementSpeed.lua",
    "effects/walkingStyle.lua",
    "effects/blurryVision.lua",
    "effects/cameraShaking.lua",

    "dev/client.lua",
    "dev/hud.lua",
    "shortcuts/client.lua",
    "compatibility/client.lua",
}

provides {
    "esx_status"
}