fx_version "cerulean"
game "gta5"
lua54 "yes"
author "discord.gg/zykeresources"
version "0.1.5"

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
    "server/database.lua",
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

    "effect_manager/queue.lua",
    "effect_manager/main.lua",
    "effect_manager/effects/screenEffect.lua",
    "effect_manager/effects/movementSpeed.lua",
    "effect_manager/effects/walkingStyle.lua",
    "effect_manager/effects/blurryVision.lua",
    "effect_manager/effects/cameraShaking.lua",

    "client/small_resources/driving.lua",

    "dev/client.lua",
    "dev/hud.lua",
    "shortcuts/client.lua",
    "compatibility/client.lua",
}

provides {
    "esx_status"
}

dependencies {
    "zyke_lib"
}