if EUI_CLIENT_BLOCKED then return end -- pre-12.1 client failsafe (EllesmereUI_ClientGate.lua)
--------------------------------------------------------------------------------
-- Restore deprecated global aliases that Forever dropped while retail still
-- ships them. Every assignment is `if not _G.Foo` plus a C_* probe, so this
-- is a no-op on Standard 12.1 and only fills holes where the alias is gone.
--
-- GetItemIcon maps to C_Item.GetItemIconByID (itemID/itemInfo), not
-- C_Item.GetItemIcon (ItemLocation). GetSpecializationMasterySpells is a
-- thin wrapper: the C_* form returns a number[] table, the old global
-- returned two number values.
--------------------------------------------------------------------------------

local function alias(globalName, ns, method)
    if _G[globalName] then return end
    local fn = ns and ns[method]
    if type(fn) == "function" then
        _G[globalName] = fn
    end
end

local CSI = _G.C_SpecializationInfo
alias("GetSpecialization", CSI, "GetSpecialization")
alias("GetSpecializationInfo", CSI, "GetSpecializationInfo")
alias("GetNumSpecializationsForClassID", CSI, "GetNumSpecializationsForClassID")

if not _G.GetSpecializationMasterySpells
    and CSI and type(CSI.GetSpecializationMasterySpells) == "function" then
    _G.GetSpecializationMasterySpells = function(...)
        local ids = CSI.GetSpecializationMasterySpells(...)
        if type(ids) == "table" then
            return ids[1], ids[2]
        end
        return ids
    end
end

local Item = _G.C_Item
alias("GetItemInfo", Item, "GetItemInfo")
alias("GetItemInfoInstant", Item, "GetItemInfoInstant")
alias("GetItemQualityColor", Item, "GetItemQualityColor")
alias("GetItemIcon", Item, "GetItemIconByID")
alias("GetItemCooldown", Item, "GetItemCooldown")
alias("GetItemCount", Item, "GetItemCount")
alias("GetDetailedItemLevelInfo", Item, "GetDetailedItemLevelInfo")
alias("GetItemSpell", Item, "GetItemSpell")
alias("IsEquippableItem", Item, "IsEquippableItem")

local CIS = _G.C_ItemSocketInfo
alias("GetNumSockets", CIS, "GetNumSockets")
alias("CloseSocketInfo", CIS, "CloseSocketInfo")

-- Forever identification for the rest of the suite. Forever is Mainline at
-- tocversion 16001 (retail 12.x is 120000+); nothing else distinguishes them
-- from Lua yet, so the interface number is the switch.
local ifaceVersion = select(4, GetBuildInfo())
EUI_IS_FOREVER = type(ifaceVersion) == "number" and ifaceVersion < 100000

-- LibSpecialization (external, cannot be patched in-tree) routes an
-- "Unknown specId" through geterrorhandler() for spec IDs missing from its
-- tables. Forever's classes carry new spec IDs, so every login and spec
-- change would raise an error that means nothing here. Drop only that
-- message, only on Forever; the lib still returns nil for the spec, which
-- the callers already handle.
if EUI_IS_FOREVER then
    local origHandler = geterrorhandler()
    seterrorhandler(function(msg, ...)
        if type(msg) == "string" and msg:find("^LibSpecialization: Unknown specId") then
            return
        end
        return origHandler(msg, ...)
    end)
end
