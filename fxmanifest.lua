fx_version "cerulean"
game "gta5"
lua54 "yes"
author "discord.gg/zykeresources"
version "0.3.0"

files {
    "locales/*.lua",

    -- Loader recognition
    "client/**/*",
    "shared/**/*",
    "dev/client/**/*",
    "effect_manager/**/*",
    "statuses/**/*",
    "shortcuts/**/*",
    "compatibility/**/*",
}

shared_script "@zyke_lib/imports.lua"

loader {
    "server:@oxmysql/lib/MySQL.lua",

    -- Shared files
    "shared/config.lua",
    "shared/functions.lua",

    -- Server only
    "server/database.lua",
    "server/main.lua",

    -- Statuses, we register these early because they have no dependencies except the Cache existing
    "server/register_statuses.lua",
    "shared:statuses/addiction/config.lua",
    "statuses/addiction/client.lua",
    "statuses/addiction/server.lua",

    "shared:statuses/caffeine/config.lua",
    "statuses/caffeine/server.lua",

    "shared:statuses/drunk/config.lua",
    "statuses/drunk/server.lua",

    "shared:statuses/high/config.lua",
    "statuses/high/server.lua",

    "shared:statuses/hunger/config.lua",
    "statuses/hunger/server.lua",

    "shared:statuses/stress/config.lua",
    "statuses/stress/server.lua",

    "shared:statuses/thirst/config.lua",
    "statuses/thirst/server.lua",

    "server/functions.lua",

    "server/events.lua",

    "server/direct_effects/functions.lua",
    "server/direct_effects/events.lua",

    "dev/server/main.lua",
    "shortcuts/server.lua",
    "compatibility/server.lua",

    "server/commands/heal.lua",

    "server/initialize.lua",

    -- Client only
    "client/main.lua",

    "client/functions.lua",
    "client/events.lua",

    "client:effect_manager/queue.lua",
    "client:effect_manager/main.lua",
    "client:effect_manager/effects/screenEffect.lua",
    "client:effect_manager/effects/movementSpeed.lua",
    "client:effect_manager/effects/walkingStyle.lua",
    "client:effect_manager/effects/blurryVision.lua",
    "client:effect_manager/effects/cameraShaking.lua",
    "client:effect_manager/effects/strength.lua",
    "client:effect_manager/effects/blockJumping.lua",
    "client:effect_manager/effects/blockSprinting.lua",
    "client:effect_manager/effects/stumble.lua",

    "client/small_resources/driving.lua",
    "client/small_resources/shooting.lua",
    "client/small_resources/stat_decimals.lua",

    "dev/client/hud.lua",
    "shortcuts/client.lua",
    "compatibility/client.lua",
}

provides {
    "esx_status"
}

dependency "zyke_lib"