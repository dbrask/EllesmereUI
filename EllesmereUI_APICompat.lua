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
