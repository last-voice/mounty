local Mounty_Name, Mounty = ...

local L = Mounty.L
local TLVlib = Mounty.TLVlib

function Mounty:Upgrade()

    -- ALERT -- ALERT -- ALERT -- ALERT -- ALERT -- ALERT -- ALERT --

    if _Mounty_A ~= nil then

        local version = _Mounty_A.Version or "00000000"

        if string.len(version) ~= 8 then
            version = "00000000"
        end

        local alert_if_lower = "02070800"

        if version < alert_if_lower then

            _Mounty_A.Version = alert_if_lower

            TLVlib:Alert(L["upgrade.popup"])

        end

    end

end
