<!-- Basics -->

-   Lightweight status system to just handle the backend of statuses.
-   Have a base function to create a status to keep track of.
-   A separate file for each status type, where you use the function to inject the base, then all the extra functionality is separated into it's own file.
-   With a lightweight setup to just handle the backend in this fashion, it is easy to configure as needed.
-   Some statuses will only have one value, such as stress, whilst others such as addicition will have sub values to keep track of, for example, addiction to weed, addiction to nicotine etc.

<!-- Backwards Compatibility -->

-   Use the same database structure as ESX & QBCore when saving, but when actually fetchig and using, you can choose between the two. Our new structure will be more optimized most likely, considering ESX is using an array for no reason.
-   By defaut, you will fetch our structure with the exports, but you can optionally select to use the old and compatible code.
-   Make a bunch of shitter events that you can modify anything with. Unfortunately this exists in the old code. This will be a config, and you will have to toggle to have these events enabled, because if you are not trying to make old code compatible without any changes, we don't want to allow people to use them.
-   Match events, exports and use the provide keyword for fxmanifest.

<!-- Addictions / Nicotine -->

-   Multiple values to track
-   Base addiction value, the more you use the drug, the more addicted you get, this value will gradually go downwards
-   Perhaps some satisfaction value, as long as you are above a specific addiciton threshold, you have to keep the satisfaction at a managable level, otherwise you will start to feel effects

-   The `value` key is the satisfaction level, it will stay at 100.0 as long as you are not addicted
-   The `addiciton` key will keep track of how addicted to something you are, this is static, and once it hits a threshold it will allow the satisfaction to need to be relieved. The addiction is very hard to grow, but will slowly over time, perhaps exponentially harder? So it is easy to start getting addicted, but the severity of the effects are pretty mild and takes time to build

<!-- Statuses -->

-   Addiction
-   Stress
-   High
-   Drunk
-   Hunger
-   Thirst

<!-- Queue System For Values -->

-   Have some sort of smarter indicator actually check the values that are in the queue, to grab the most important one, and not just whatever has the most keys. It won't really be viable to do so for strings, but numbers should work decent. These queues would have to be movement speed or something, since other things like poison or food/thirst damage won't make sense to handle in that way.
-   I can also pre-construct a priority list, so that effects & walking styles are prioritized, since I might want to always prioritize some over others. Could make re-do it and go from a list, and if it is not part of a list, just use the highest one in the list. Or use the existing systems, but also check for a priority list. If it is within that priority list, don't care about the key counts.

<!-- Sync multiple values -->

-   Remove sync from each component, have a sync loop running in the background
-   Sync queue function

<!-- NOTES FOR OTHER RESOURCES -->

-   esx_basicneeds
    -   esx_status:onTick causes damage if there is no food

<!-- TODO -->

-   For stuff, such as screen effects or movement styles, recognize if a stronger one is already applied via another resource, and then skip applying something from our side maybe? Or add some toggler, where you can block our resource from applying specific effects, an example wouild be an ambulance script with crutches, we don't want to override that movement style

<!-- STUFF -->

-   We run the basic structure, to have a primary, values then all the subvalues
-   Inside of the subvalues we have the key `value`, which is consistent
    -   Past that, the rest is just random metadata we chuck in there
    -   We can have stuff such as last time the player attempted to puke for being too drunk etc
    -   This way, we can also cache how long you have been without a status, such as food, and then make you take damage after some period

<!-- Effects -->

-   When we attempt to run an effect, we check if it is cached, this way, we can easily override and run completely custom effects without doing a bunch of extra work, other than adding what drug it is, and what the effect will be
-   If there are no cached effects, we cache the default effects and run it
-   Allow multiple effects for a specific status, such as if you are drunk, have different walk styles based on how drunk you are, or the amount of damage you take based on how thirsty you are
-   Allow different settings how you get the current effect based on some critera, such as how long you have been without water, what level of drunk you are (0-100) etc, this allows for a very customizable development and smooth gameplay experience

<!-- QB Compatibility -->

-   Instead of changing a bunch of values, just go into the SetMetaData function and run an event for the setter for us
-   All we have to do is remove some of their stress stuff
-   The drain of hunger/thirst might get messed up because of the setmetadata, unless we can remove something and check if it sent from our resource?

<!-- Basicneeds stuff -->
<!-- CLIENT -->

AddEventHandler('esx:onPlayerSpawn', function(spawn)
if IsDead then
TriggerEvent('esx_basicneeds:resetStatus')
end

    IsDead = false

end)

-   FINISHED
    RegisterNetEvent('esx_basicneeds:healPlayer')
    AddEventHandler('esx_basicneeds:healPlayer', function()
    -- restore hunger & thirst
    TriggerEvent('esx_status:set', 'hunger', 1000000)
    TriggerEvent('esx_status:set', 'thirst', 1000000)

        -- restore hp
        local playerPed = PlayerPedId()
        SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed))

end)

-   FINISHED
    AddEventHandler('esx_basicneeds:resetStatus', function()
    TriggerEvent('esx_status:set', 'hunger', 500000)
    TriggerEvent('esx_status:set', 'thirst', 500000)
    end)

<!-- SERVER -->

-   FINISHED
    ESX.RegisterCommand('heal', 'admin', function(xPlayer, args, showError)
    args.playerId.triggerEvent('esx_basicneeds:healPlayer')
    args.playerId.showNotification('You have been healed.')
    end, true, {help = 'Heal a player, or yourself - restores thirst, hunger and health.', validate = true, arguments = {
    {name = 'playerId', help = 'the player id', type = 'player'}
    }})

-   FINISHED
    AddEventHandler('txAdmin:events:healedPlayer', function(eventData)
    if GetInvokingResource() ~= "monitor" or type(eventData) ~= "table" or type(eventData.id) ~= "number" then
    return
    end

        TriggerClientEvent('esx_basicneeds:healPlayer', eventData.id)

end)

REGISTERING FOOD STUFF FOR EATING

<!-- Addictions -->

-   Allow a configuration for two types of addictions.
-   The default addiciton type should be persistent through deaths, revives etc, it can not just be cleared.
-   We will have exports available or config settings to clear the addictions when you are revived or such.
-   By default the addictions will not be cleared, otherwise it feels like they're pretty pointless.
-   During revives or such, we will reset the satisfaction level, this means that you are not instantly feeling bad after you are healed, but the actual addiction level is persistent, you would need medications or some sort of reset for that to get fixed.
