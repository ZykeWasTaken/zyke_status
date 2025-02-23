# Important Development Information

## Verification

-   Never trigger the status methods directly, because they lack verification.
-   To avoid double-verifications, we encourage you to run the function dedicated to your action, such as `RemoveFromStatus`, it performs all necessary validation to ensure all values exist and is possible to apply. This function then triggers the method on the status to perform the action. If we had another validation on the method, this would perform the same action twice. To avoid unneccessary baggage, we encourage you to do this propperly.

<!--              -->
<!-- RANOMD NOTES -->
<!--              -->

<!-- Addictions / Nicotine -->

-   Multiple values to track
-   Base addiction value, the more you use the drug, the more addicted you get, this value will gradually go downwards
-   Perhaps some satisfaction value, as long as you are above a specific addiction threshold, you have to keep the satisfaction at a managable level, otherwise you will start to feel effects

-   The `value` key is the satisfaction level, it will stay at 100.0 as long as you are not addicted
-   The `addiction` key will keep track of how addicted to something you are, this is static, and once it hits a threshold it will allow the satisfaction to need to be relieved. The addiction is very hard to grow, but will slowly over time, perhaps exponentially harder? So it is easy to start getting addicted, but the severity of the effects are pretty mild and takes time to build

<!-- NOTES FOR OTHER RESOURCES -->

-   esx_basicneeds
    -   esx_status:onTick causes damage if there is no food

<!-- STUFF -->

-   We run the basic structure, to have a primary, values then all the subvalues
-   Inside of the subvalues we have the key `value`, which is consistent
    -   Past that, the rest is just random metadata we chuck in there
    -   We can have stuff such as last time the player attempted to puke for being too drunk etc
    -   This way, we can also cache how long you have been without a status, such as food, and then make you take damage after some period

<!-- Addictions -->

-   Allow a configuration for two types of addictions.
-   The default addiction type should be persistent through deaths, revives etc, it can not just be cleared.
-   We will have exports available or config settings to clear the addictions when you are revived or such.
-   By default the addictions will not be cleared, otherwise it feels like they're pretty pointless.
-   During revives or such, we will reset the satisfaction level, this means that you are not instantly feeling bad after you are healed, but the actual addiction level is persistent, you would need medications or some sort of reset for that to get fixed.
