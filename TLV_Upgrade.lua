local _, Mounty = ...

local L = Mounty.L

function Mounty:Upgrade()

    local alert = ""

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

            Profiles = TLV:TableDuplicate(_Data.Profiles)
        }

        _Data = nil

    end

    -- 110

    if _DataAccount ~= nil then

        if _DataAccount.UpgradeTo110 == nil then

            -- Upgrade to 110

            _DataAccount.UpgradeTo110 = true

            Mounty:Alert(L["upgrade"])

        end

    end

end
