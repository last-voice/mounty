local Mounty_Name, Mounty = ...

local L = Mounty.L
local TLVlib = Mounty.TLVlib

function Mounty:Upgrade()

    -- MountyData > _Data

    if MountyData ~= nil then

        if MountyData.UpgradeToDragonflight == nil then

            -- Upgrade to Dragonflight

            MountyData.UpgradeToDragonflight = true

            MountyData.Mounts[7] = {}

            if MountyData.Mounts ~= nil then
                for t = 7, 4, -1 do
                    for i = 1, 10 do
                        MountyData.Mounts[t][i] = MountyData.Mounts[t - 1][i]
                        MountyData.Mounts[t - 1][i] = 0
                    end
                end
            end

        end

        -- MountyData > _Data

        _Data = {

            Profiles = {
                ["Mounty"] = {
                    DurabilityMin = MountyData.DurabilityMin,
                    Hello = MountyData.Hello,
                    Iterator = MountyData.Iterator,
                    Mounts = MountyData.Mounts,
                    Random = MountyData.Random,
                    ShowOff = MountyData.ShowOff,
                    TaxiMode = MountyData.TaxiMode,
                    Together = MountyData.DoNotFly
                }
            },

            DebugMode = MountyData.DebugMode,
            AutoOpen = MountyData.AutoOpen

        }

        -- MountyData no more

        MountyData = nil

    end

    -- _Data > _DataCharacter, _DataAccount

    if _Data ~= nil then


        if _DataAccount == nil then
            -- attention, if multiple chars upddgrade!

            _DataAccount = {

                AutoOpen = _Data.Autoopen,
                DebugMode = _Data.DebugMode,

                QuickStart = _Data.QuickStart
            }

        end

        _DataCharacter = {

            ShareProfiles = false,
            CurrentProfile = _Data.CurrentProfile,

            Profiles = TLVlib:TableDuplicate(_Data.Profiles)
        }

        _Data = nil

    end

    if _DataAccount ~= nil then
        -- do not use generic names for SavedVariables !!!
        _Mounty_A = TLVlib:TableDuplicate(_DataAccount)
        _DataAccount = nil
    end

    if _DataCharacter ~= nil then
        -- do not use generic names for SavedVariables !!!
        _Mounty_C = TLVlib:TableDuplicate(_DataCharacter)
        _DataCharacter = nil
    end

    -- ALERT -- ALERT -- ALERT -- ALERT -- ALERT -- ALERT -- ALERT --

    -- Double Click

    if _Mounty_A ~= nil then

        -- Upgrade to 110 -- Zombie
        _Mounty_A.UpgradeTo110 = nil

        local version = _Mounty_A.Version or ""

        local alert_if_lower = "v020706"

        if version < alert_if_lower then

            _Mounty_A.Version = alert_if_lower

            TLVlib:Alert(L["upgrade.popup"])

        end

    end

end
