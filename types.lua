---@class PlayerStatus
---@field value number @0-100

---@class AddictionStatus
---@field value number @100-0, satisfaction
---@field addiction number @0-100

-- For the ease of structuring, fetching and modifying values, the non-multi statuses will be added in values: [status].values[status]
-- For multi values, only the subvalues will exist in values
---@class PlayerStatuses
---@field values table<StatusName, PlayerStatus | AddictionStatus>

---@class ExistingStatus
---@field multi? boolean @Supports multiple instances of the same status type, ex. addiction to multiple substances
---@field baseValues table
---@field onTick? function
---@field onAdd function
---@field onRemove function
---@field onSet? function @Only used for backwards compatibility with some base values, we use onReset or onAdd/onRemove
---@field onReset function
---@field onSoftReset? function @Soft resets that are not complete, for example, addiciton resets satisfaction level but remains addiction

---@class DirectEffectInput : DirectEffect
---@field name QueueKey

---@class DirectEffect
---@field value number | integer | string | boolean
---@field duration number -- Seconds

---@class ServerCache
---@field statuses table<PlayerId, table<StatusName, PlayerStatuses>>
---@field existingStatuses table<StatusName, ExistingStatus>
---@field directEffects table<PlayerId, table<QueueKey, DirectEffect[]>>

---@class ClientCache
---@field statuses table<StatusName, PlayerStatuses> | nil @nil when unloaded
---@field directEffects table<QueueKey, integer | number | string | boolean> | nil @nil when unloaded

---@alias PlayerId integer
---@alias Character table
---@alias CharacterIdentifier string
---@alias Vector3Table {x: number, y: number, z: number}
---@alias Vehicle integer
---@alias Prop integer
---@alias Ped integer
---@alias Blip integer
---@alias Distance number
---@alias ScaleformHandle integer
---@alias NetId integer
---@alias Plate string
---@alias FailReason string
---@alias Success boolean
---@alias StatusName string @Deprecated
---@alias SubStatusName string @Deprecated
---@alias PrimaryName string
---@alias SecondaryName string
---@alias StatusNames {[1]: PrimaryName, [2]?: SecondaryName} @Defaults 2nd idx to primary if nil
---@alias OsTime integer
---@alias OsClock number