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
