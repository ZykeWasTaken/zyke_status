[![ko-fi banner2](https://github.com/user-attachments/assets/42eff455-5757-4888-ad88-d61893edcc33)](https://ko-fi.com/zykeresources)

# [> Download](https://github.com/ZykeWasTaken/zyke_status/releases/latest)

# Information

This resource is a work-in-progress status system meant to elevate how your character processes hunger, thirst, stress, addictions, highs and much more. It also has a versatile and dynamic effect system to queue and stack effects to prevent interruptions when using different resources requiring different effects.

Full backwards compatibility will be available (and is already partially available) for ESX & QBCore to avoid having to change other resources to fit our needs.

The idea of this resource was manifested by our current developments for zyke_consumables. We needed an alternative that could handle all the statuses and effects we would like to have, along with a queue system to not fight what should be active between consumables and our smoking resource.

## Setup

We have a first iteration of an installation guide available in our documentation, found [here](https://docs.zykeresources.com/free-resources/status/setup). If there is anything missing, or it doesn't work properly, don't hesitate to contact us on Discord and we will swiftly resolve it.

## Links

-   [Discord](https://discord.gg/zykeresources)
-   [Documentation](https://docs.zykeresources.com/free-resources/status)
-   [Store](https://store.zykeresources.com)

# Planned TODO

## Easier Development

-   All sorts of re-structuring and additions of functions/exports will be made to allow for easier development for everyone that is interested in interacting with our resource.

## More Statuses

-   Anxiety, pains and whatnot that is suggested or thought of will be added in the near future.

## Severity For Queues

-   Stack all the active for a queued key, and alter the severity based on the total value. If your screen is slightly blurred because of 3 different effects, it should be combining all values for a final effect multiplier. Really only relevant for number values queued.
