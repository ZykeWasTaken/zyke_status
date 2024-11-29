---@class PlayerStatus
---@field value number @0-100

---@class StatusType
---@field multi? boolean @Supports multiple instances of the same status type, ex. addiction to multiple substances
---@field values table<StatusName, PlayerStatus>

---@class ServerCache
---@field statuses table<PlayerId, table<StatusName, StatusType>>
---@field existingStatuses table<StatusName, true>

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
---@alias StatusName string