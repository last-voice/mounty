local Mounty_Name, Mounty = ...

local L = Mounty.L
local TLVlib = Mounty.TLVlib

function Mounty:Upgrade()

    -- ALERT -- ALERT -- ALERT -- ALERT -- ALERT -- ALERT -- ALERT --

    if _Mounty_A ~= nil then

        local version = _Mounty_A.Version or ""

        local alert_if_lower = "v0207"

        if version < alert_if_lower then

            _Mounty_A.Version = alert_if_lower

            TLVlib:Alert(L["upgrade.popup"])

        end

    end

end
