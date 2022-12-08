local _, Mounty = ...

local L = Mounty.L

function Mounty:Upgrade()

    -- MountyData > _Data

    if MountyData ~= nil then

        if MountyData.UpgradeToDragonflight == nil then

            MountyData.UpgradeToDragonflight = true

            if MountyData.Mounts ~= nil then
                for t = 7, 4, -1 do
                    for i = 1, 10 do
                        MountyData.Mounts[t][i] = MountyData.Mounts[t - 1][i]
                        MountyData.Mounts[t - 1][i] = 0
                    end
                end
            end

        end

        _Data.Profiles = {}

        _Data.Profiles[Mounty:ProfileNameDefault()] = {
            DurabilityMin = MountyData.DurabilityMin,
            Hello = MountyData.Hello,
            Iterator = MountyData.Iterator,
            Mounts = MountyData.Mounts,
            Random = MountyData.Random,
            ShowOff = MountyData.ShowOff,
            TaxiMode = MountyData.TaxiMode,
            Together = MountyData.Together
        }

        _Data.DebugMode = MountyData.DebugMode
        _Data.AutoOpen = MountyData.AutoOpen

        -- MountyData no more

        MountyData = nil

    end

    -- _Data > _DataCharacter, _DataAccount

    if _Data ~= nil then

        _DataCharacter = {}

        if _DataAccount == nil then -- attention, if multiple chars upddgrade!

            _DataAccount = {}

            _DataAccount.AutoOpen = _Data.Autoopen
            _DataAccount.DebugMode = _Data.DebugMode

            _DataAccount.QuickStart = _Data.QuickStart

            Mounty:Alert (L["changelog.Account"])

        end

        _DataCharacter.ShareProfiles = false
        _DataCharacter.CurrentProfile = _Data.CurrentProfile

        _DataCharacter.Profiles = TLV:TableDuplicate(_Data.Profiles)

        _Data = nil

    end

end
