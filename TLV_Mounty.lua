local MountyAddOnName, Mounty = ...

local TLV = TLV

local L = Mounty.L

local MountyOptionsFrame
local MountyOptionsFrame_DebugMode
local MountyOptionsFrame_ShareProfiles
local MountyOptionsFrame_AutoOpen
local MountyOptionsFrame_TaxiMode
local MountyOptionsFrame_Together
local MountyOptionsFrame_ShowOff
local MountyOptionsFrame_Random
local MountyOptionsFrame_DurabilityMin
local MountyOptionsFrame_Hello
local MountyOptionsFrame_Profile
local MountyOptionsFrame_ProfileDropdown
local MountyOptionsFrame_QuickStart

local MountyOptionsFrame_Buttons = {}

local MountyTypes = 7
local MountyMounts = 10

local MountyGround = 1
local MountyFlying = 2
local MountDragonflight = 3
local MountyWater = 4
local MountyRepair = 5
local MountyTaxi = 6
local MountyShowOff = 7

local MountyTypesLabel = {
    [1] = L["mode.Ground"],
    [2] = L["mode.Flying"],
    [3] = L["mode.Dragonflight"],
    [4] = L["mode.Water"],
    [5] = L["mode.Repair"],
    [6] = L["mode.Taxi"],
    [7] = L["mode.Show off"]
}

local MountyFallbackQueue = {}
local MountyFallbackAlready = {}

Mounty.AddOnTitle = nil
Mounty.AddOnVersion = nil

Mounty.MountyTestDragon = nil

Mounty.MountyDebugForce = false

function Mounty:Chat(msg)

    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cffa0a0ff" .. Mounty.AddOnTitle .. " " .. Mounty.AddOnVersion .. "|r: " .. msg, 1, 1, 0)
    end

end

function Mounty:Debug(msg)

    if _DataAccount.DebugMode or Mounty.MountyDebugForce then
        Mounty:Chat(msg)
    end
end

function Mounty:Durability()

    local curTotal = 0
    local maxTotal = 0

    for slot = 1, 20 do
        local curSlot, maxSlot = GetInventoryItemDurability(slot)
        if maxSlot then
            curTotal = curTotal + curSlot
            maxTotal = maxTotal + maxSlot
        end
    end

    local durability = math.floor((100 * curTotal / maxTotal) + 0.5)

    Mounty:Debug("Durability: |cffa0a0ff" .. durability .. "%|r")

    return durability
end

function Mounty:Fallback(typ)

    MountyFallbackAlready[typ] = true

    local FallbackTo = 0

    if not MountyFallbackAlready[MountyFallbackQueue[1]] then

        FallbackTo = MountyFallbackQueue[1]

    elseif not MountyFallbackAlready[MountyFallbackQueue[2]] then

        FallbackTo = MountyFallbackQueue[2]
    end

    if FallbackTo == MountyFlying then

        Mounty:Debug("Fallback: '" .. L["mode.Flying"] .. "'")
        return MountyFlying

    elseif FallbackTo == MountyGround then

        Mounty:Debug("Fallback: '" .. L["mode.Ground"] .. "'")
        return MountyGround
    end

    Mounty:Debug("Fallback: '" .. L["mode.Random"] .. "'")
    return 0
end

function Mounty:SelectMountByType(typ, only_flyable_showoffs)

    if typ == 0 then
        return 0
    end

    local ids = {}
    local count = 0
    local picked

    for i = 1, MountyMounts do

        if _Profile.Mounts[typ][i] > 0 then

            local mountID = C_MountJournal.GetMountFromSpell(_Profile.Mounts[typ][i])
            local mname, _, _, _, usable = C_MountJournal.GetMountInfoByID(mountID)

            if only_flyable_showoffs then
                local _, _, _, _, mountTypeID = C_MountJournal.GetMountInfoExtraByID(mountID)

                if mountTypeID ~= 248 then
                    -- 248 = mostly flyable
                    usable = false
                end
            end

            Mounty:Debug("Usable: " .. "[" .. mountID .. "] " .. mname .. " -> " .. tostring(usable))

            if usable then
                count = count + 1
                ids[count] = _Profile.Mounts[typ][i]
            end
        end
    end

    if count > 0 then

        if _Profile.Random then
            picked = math.random(count)
        else
            if _Profile.Iterator[typ] < count then
                _Profile.Iterator[typ] = _Profile.Iterator[typ] + 1
            else
                _Profile.Iterator[typ] = 1
            end
            picked = _Profile.Iterator[typ]
        end

        Mounty:Debug("Selected: " .. picked .. " of " .. count)

        return ids[picked]
    end

    Mounty:Debug("No mount found in category.")

    return Mounty:SelectMountByType(Mounty:Fallback(typ), false)
end

function Mounty:MountSpellID(mountID)

    local _, spellID = C_MountJournal.GetMountInfoByID(mountID)

    return spellID
end

function Mounty:MountUsableBySpellID(spellID)

    local mountID = C_MountJournal.GetMountFromSpell(spellID)
    local _, _, icon = C_MountJournal.GetMountInfoByID(mountID)

    return icon
end

function Mounty:UserCanFlyHere()

    return IsFlyableArea() and (C_Spell.DoesSpellExist(34090) or C_Spell.DoesSpellExist(90265)) -- riding has been learned
    --    return IsFlyableArea() and (IsPlayerSpell(34090) or IsPlayerSpell(90265)) -- riding has been learned
end

function Mounty:IsInDragonflight()

    local mapID = C_Map.GetBestMapForUnit("player");

    local map_info = C_Map.GetMapInfo(mapID)

    while (map_info and map_info.mapType > 2) do

        if map_info.parentMapID == 0 then
            return false
        end

        map_info = C_Map.GetMapInfo(map_info.parentMapID)
    end

    return (map_info and map_info.mapID == 1978) -- Dragonflight
end

function Mounty:UserCanDragonflyHere()
    -- Not used, using Mounty:DragonCanFlyHere instead
    return Mounty:IsInDragonflight() and C_Spell.DoesSpellExist(376777) -- dragon riding has been learned
    -- return Mounty:IsInDragonflight() and IsPlayerSpell(376777) -- dragon riding has been learned
end

function Mounty:DragonsCanFlyHere()

    if Mounty.MountyTestDragon == nil then

        Mounty.MountyTestDragon = 0

        for _, v in ipairs(C_MountJournal.GetCollectedDragonridingMounts()) do
            local name, spellID, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(v)
            if isCollected then
                Mounty.MountyTestDragon = spellID
                Mounty:Debug("Test dragon found: " .. name .. " [" .. spellID .. "]")
            end
        end
    end

    if Mounty.MountyTestDragon == 0 then
        return false
    end

    return (IsUsableSpell(Mounty.MountyTestDragon))
end

function Mounty:Mount(category)

    local mountID = 0
    local spellID = 0
    local only_flyable_showoffs = false

    local typ = MountyGround

    if category == "dragonflight" then

        typ = MountDragonflight

    elseif category == "fly" then

        typ = MountyFlying

    elseif category == "water" then

        typ = MountyWater

    elseif category == "repair" then

        typ = MountyRepair

    elseif category == "taxi" then

        if IsInGroup() and not IsMounted() then
            if _Profile.Hello ~= "" then
                SendChatMessage(_Profile.Hello)
            end
        end

        typ = MountyTaxi

    elseif category == "showoff" then

        typ = MountyShowOff

        if Mounty:UserCanFlyHere() then
            only_flyable_showoffs = true
        end


    elseif category == "random" then

        typ = 0
    end

    Mounty:Debug("Category: " .. category)
    Mounty:Debug("Type: " .. typ)

    if typ > 0 then

        MountyFallbackAlready = {} -- Muss wieder auf leer gesetzt werden

        if Mounty:UserCanFlyHere() then
            MountyFallbackQueue = { MountyFlying, MountyGround }
        else
            MountyFallbackQueue = { MountyGround, MountyFlying }
        end

        spellID = Mounty:SelectMountByType(typ, only_flyable_showoffs)

        if spellID > 0 then
            mountID = C_MountJournal.GetMountFromSpell(spellID)
        end
    end

    Mounty:Debug("mountID: " .. mountID)
    Mounty:Debug("spellID: " .. spellID)

    C_MountJournal.SummonByID(mountID)
end

function Mounty:KeyHandler(keypress)

    if keypress == nil then
        keypress = "magic"
    end

    Mounty:Debug("--- --- --- --- --- --- ---")
    Mounty:Debug("Key pressed: " .. keypress)

    if keypress == "forceoff" then

        if IsMounted() then
            Dismount()
        end

        return

    elseif IsMounted() then

        if IsFlying() then
            Mounty:Debug("You are mounted and flying.")
            return
        end

        Dismount()

        if keypress == "magic" then
            return
        end
    end

    if keypress == "ground" or keypress == "repair" or keypress == "random" or keypress == "showoff" or keypress == "water" or keypress == "taxi" then

        Mounty:Debug("Dedicated key")

        Mounty:Mount(keypress)

    else

        -- magic

        local resting = IsResting()
        local dragonflight = Mounty:DragonsCanFlyHere()
        local alone = not IsInGroup()
        local flyable = Mounty:UserCanFlyHere()
        local swimming = IsSwimming()
        local taximode = _Profile.TaxiMode
        local together = _Profile.Together
        local showoff = _Profile.ShowOff

        Mounty:Debug("Magic key")

        if together and not alone then
            flyable = false
        end

        local category

        if Mounty:Durability() < _Profile.DurabilityMin then

            category = "repair"

        elseif not alone and taximode then

            category = "taxi"

        elseif resting and showoff then

            category = "showoff"

        elseif dragonflight then

            category = "dragonflight"

        elseif flyable then

            category = "fly"

        elseif swimming then

            category = "water"

        else

            category = "ground"
        end

        Mounty:Mount(category)
    end
end

function Mounty:AddMount(target)

    local infoType, mountID = GetCursorInfo()

    if infoType == "mount" then

        ClearCursor()

        local typ = target.MountyTyp

        local spellID = Mounty:MountSpellID(mountID)

        local already = false

        for i = 1, MountyMounts do
            if _Profile.Mounts[typ][i] == spellID then
                already = true
            end
        end

        if spellID == 0 then

            Mounty:Debug("Fail: spellID = 0 | " .. infoType .. " " .. typ .. " " .. mountID)

        elseif already then

            Mounty:Debug("Fail: Already | " .. infoType .. " " .. typ .. " " .. mountID .. " " .. spellID)

        else

            local index = target.MountyIndex

            -- find the first empty slot
            while (index > 1 and _Profile.Mounts[typ][index - 1] == 0) do
                index = index - 1
            end

            Mounty:Debug("Mount saved: " .. infoType .. " " .. typ .. " " .. index .. " " .. mountID .. " " .. spellID)
            _Profile.Mounts[typ][index] = spellID
            Mounty:OptionsRenderButtons()
        end

        GameTooltip:Hide()
    end
end

function Mounty:RemoveMount(target)

    local typ = target.MountyTyp
    local index = target.MountyIndex

    Mounty:Debug("Mount removed: " .. typ .. " " .. index)

    for i = index, MountyMounts - 1 do
        _Profile.Mounts[typ][i] = _Profile.Mounts[typ][i + 1]
    end
    _Profile.Mounts[typ][MountyMounts] = 0

    Mounty:OptionsRenderButtons()

    GameTooltip:Hide()
end

function Mounty:Tooltip(calling)

    local typ = calling.MountyTyp
    local index = calling.MountyIndex

    local spellID = _Profile.Mounts[typ][index]

    if spellID then
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        GameTooltip:SetHyperlink("spell:" .. spellID)
        GameTooltip:Show()
    end
end

function Mounty:InitOptionsFrame()

    local top
    local temp

    local control_top_delta = 40
    local control_top_delta_small = 20

    MountyOptionsFrame:Hide()
    MountyOptionsFrame:SetWidth(480)
    MountyOptionsFrame:SetHeight(640)
    MountyOptionsFrame:SetPoint("CENTER")

    MountyOptionsFrame:SetFrameStrata("MEDIUM")
    MountyOptionsFrame.Bg:SetFrameStrata("LOW")

    MountyOptionsFrame:EnableMouse(true)
    MountyOptionsFrame:SetMovable(true)
    MountyOptionsFrame:RegisterForDrag("LeftButton")
    MountyOptionsFrame:SetScript("OnDragStart", function(calling)
        calling:StartMoving()
    end)
    MountyOptionsFrame:SetScript("OnDragStop", function(calling)
        calling:StopMovingOrSizing()
    end)

    -- Title text
    temp = MountyOptionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    temp:SetPoint("TOP", 0, -6)
    temp:SetText(Mounty.AddOnTitle .. " " .. Mounty.AddOnVersion)

    -- Quickstart

    MountyOptionsFrame_QuickStart = CreateFrame("Frame", nil, MountyOptionsFrame, "SettingsFrameTemplate")
    MountyOptionsFrame_QuickStart:SetWidth(480)
    MountyOptionsFrame_QuickStart:SetHeight(90)
    MountyOptionsFrame_QuickStart:SetPoint("BOTTOM", 0, -90)
    MountyOptionsFrame_QuickStart:SetFrameStrata("MEDIUM")
    MountyOptionsFrame.Bg:SetFrameStrata("LOW")

    temp = MountyOptionsFrame_QuickStart:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    temp:SetPoint("TOP", 0, -6)
    temp:SetText(L["quick.title"])

    temp = MountyOptionsFrame_QuickStart:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    temp:SetPoint("TOPLEFT", 32, -32)
    temp:SetJustifyH("LEFT")
    temp:SetText(L["quick.text"])

    if not _DataAccount.QuickStart then
        MountyOptionsFrame_QuickStart:Hide()
    end

    -- Random checkbox

    top = -40

    MountyOptionsFrame_Random = CreateFrame("CheckButton", "MountyOptionsFrame_Random", MountyOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyOptionsFrame_Random:SetPoint("TOPLEFT", 16, top)
    MountyOptionsFrame_RandomText:SetText(L["options.Random"])
    MountyOptionsFrame_Random:SetScript("OnClick", function(calling)
        _Profile.Random = not _Profile.Random
        calling:SetChecked(_Profile.Random)
    end)

    -- Open Mounts

    temp = CreateFrame("Button", "MountyOptionsFrame_OpenMounts", MountyOptionsFrame)
    temp:SetSize(32, 32)
    temp:SetNormalTexture("Interface\\Icons\\Ability_Mount_RidingHorse")
    temp:SetPoint("TOPRIGHT", -20, top)
    temp:SetScript("OnClick", function()
        ToggleCollectionsJournal(1)
    end)

    -- Open Quick start

    temp = CreateFrame("Button", "MountyOptionsFrame_OpenMounts", MountyOptionsFrame)
    temp:SetSize(32, 32)
    temp:SetNormalTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    temp:SetPoint("TOPRIGHT", -20, top - 40)
    temp:SetScript("OnClick", function()
        if MountyOptionsFrame_QuickStart:IsVisible() then
            MountyOptionsFrame_QuickStart:Hide()
        else
            MountyOptionsFrame_QuickStart:Show()
        end
    end)

    -- ShowOff checkbox

    top = top - control_top_delta_small

    MountyOptionsFrame_ShowOff = CreateFrame("CheckButton", "MountyOptionsFrame_ShowOff", MountyOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyOptionsFrame_ShowOff:SetPoint("TOPLEFT", 16, top)
    MountyOptionsFrame_ShowOffText:SetText(L["options.Look"])
    MountyOptionsFrame_ShowOff:SetScript("OnClick", function(calling)
        _Profile.ShowOff = not _Profile.ShowOff
        calling:SetChecked(_Profile.ShowOff)
    end)

    -- Together checkbox

    top = top - control_top_delta_small

    MountyOptionsFrame_Together = CreateFrame("CheckButton", "MountyOptionsFrame_Together", MountyOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyOptionsFrame_Together:SetPoint("TOPLEFT", 16, top)
    MountyOptionsFrame_TogetherText:SetText(L["options.Stay"])
    MountyOptionsFrame_Together:SetScript("OnClick", function(calling)
        _Profile.Together = not _Profile.Together
        calling:SetChecked(_Profile.Together)
    end)

    -- TaxiMode checkbox

    top = top - control_top_delta_small

    MountyOptionsFrame_TaxiMode = CreateFrame("CheckButton", "MountyOptionsFrame_TaxiMode", MountyOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyOptionsFrame_TaxiMode:SetPoint("TOPLEFT", 16, top)
    MountyOptionsFrame_TaxiModeText:SetText(L["options.Taxi"])
    MountyOptionsFrame_TaxiMode:SetScript("OnClick", function(calling)
        _Profile.TaxiMode = not _Profile.TaxiMode
        calling:SetChecked(_Profile.TaxiMode)
    end)

    -- Taxi!

    top = top - control_top_delta - 10

    MountyOptionsFrame_Hello = CreateFrame("EditBox", "MountyOptionsFrame_Hello", MountyOptionsFrame, "InputBoxTemplate")
    MountyOptionsFrame_Hello:SetWidth(335)
    MountyOptionsFrame_Hello:SetHeight(16)
    MountyOptionsFrame_Hello:SetPoint("TOPLEFT", 25, top)
    MountyOptionsFrame_Hello:SetAutoFocus(false)
    MountyOptionsFrame_Hello:CreateFontString("MountyOptionsFrame_HelloLabel", "OVERLAY", "GameFontNormalSmall")
    MountyOptionsFrame_HelloLabel:SetPoint("BOTTOMLEFT", MountyOptionsFrame_Hello, "TOPLEFT", 0, 4)
    MountyOptionsFrame_HelloLabel:SetText(L["options.Hello"])
    MountyOptionsFrame_Hello:SetScript("OnEnterPressed", function(calling)
        _Profile.Hello = calling:GetText()
        calling:ClearFocus()
    end)
    MountyOptionsFrame_Hello:SetScript("OnEscapePressed", function(calling)
        calling:SetText(_Profile.Hello)
    end)

    temp = TLV:Button(MountyOptionsFrame, "TOPLEFT", 360, top + 3, 32, L["button.OK"])
    temp:SetScript("OnClick", function()
        _Profile.Hello = MountyOptionsFrame_Hello:GetText()
        MountyOptionsFrame_Hello:ClearFocus()
    end)

    -- Durability slider

    top = top - control_top_delta

    MountyOptionsFrame_DurabilityMin = CreateFrame("Slider", "MountyOptionsFrame_DurabilityMin", MountyOptionsFrame, "OptionsSliderTemplate")
    MountyOptionsFrame_DurabilityMin:SetWidth(335)
    MountyOptionsFrame_DurabilityMin:SetHeight(16)
    MountyOptionsFrame_DurabilityMin:SetPoint("TOPLEFT", 25, top)
    MountyOptionsFrame_DurabilityMinLow:SetText("50%")
    MountyOptionsFrame_DurabilityMinHigh:SetText("100%")
    MountyOptionsFrame_DurabilityMin:SetMinMaxValues(50, 100)
    MountyOptionsFrame_DurabilityMin:SetValueStep(1)
    MountyOptionsFrame_DurabilityMin:SetScript("OnValueChanged", function(_, value)
        MountyOptionsFrame_DurabilityMinText:SetFormattedText(L["options.Durability"], math.floor(value + 0.5))
        _Profile.DurabilityMin = math.floor(value + 0.5)
    end)

    -- Mounts

    for t = 1, MountyTypes do

        MountyOptionsFrame_Buttons[t] = {}

        top = top - control_top_delta

        temp = MountyOptionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        temp:SetPoint("TOPLEFT", 16, top - 10)
        temp:SetText(MountyTypesLabel[t])

        for i = 1, MountyMounts do

            MountyOptionsFrame_Buttons[t][i] = CreateFrame("Button", "MountyOptionsFrame_Buttons_t" .. t .. "_i" .. i, MountyOptionsFrame)
            MountyOptionsFrame_Buttons[t][i].MountyTyp = t
            MountyOptionsFrame_Buttons[t][i].MountyIndex = i
            MountyOptionsFrame_Buttons[t][i]:SetSize(32, 32)
            MountyOptionsFrame_Buttons[t][i]:SetDisabledTexture("Interface\\Buttons\\UI-EmptySlot")
            MountyOptionsFrame_Buttons[t][i]:GetDisabledTexture():SetTexCoord(0.15, 0.85, 0.15, 0.85)
            MountyOptionsFrame_Buttons[t][i]:SetHighlightTexture("Interface\\Buttons\\UI-StopButton")
            MountyOptionsFrame_Buttons[t][i]:SetPoint("TOPLEFT", 48 + i * 38, top)
            MountyOptionsFrame_Buttons[t][i]:SetScript("OnMouseUp", function(calling, button)
                if button == "LeftButton" then
                    Mounty:AddMount(calling)
                elseif button == "RightButton" then
                    Mounty:RemoveMount(calling)
                end
            end)
            MountyOptionsFrame_Buttons[t][i]:SetScript("OnEnter", function(calling)
                Mounty:Tooltip(calling)
            end)
            MountyOptionsFrame_Buttons[t][i]:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)
        end
    end

    -- Helptext

    top = top - control_top_delta + 8

    temp = MountyOptionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    temp:SetPoint("TOPLEFT", 90, top - 3)
    temp:SetText(L["options.Helptext"])

    -- Current profile

    top = top - control_top_delta

    MountyOptionsFrame_ProfileDropdown = CreateFrame("FRAME", "MountyOptionsFrame_ProfileDropdown", MountyOptionsFrame, "UIDropDownMenuTemplate")
    MountyOptionsFrame_ProfileDropdown:SetPoint("TOPLEFT", 0, top + 6);
    MountyOptionsFrame_ProfileDropdown:CreateFontString("MountyOptionsFrame_ProfileDropdownLabel", "OVERLAY", "GameFontNormalSmall")
    MountyOptionsFrame_ProfileDropdownLabel:SetPoint("BOTTOMLEFT", MountyOptionsFrame_ProfileDropdown, "TOPLEFT", 16, -2)
    MountyOptionsFrame_ProfileDropdownLabel:SetText(L["options.Profile"])
    UIDropDownMenu_SetWidth(MountyOptionsFrame_ProfileDropdown, 120)
    UIDropDownMenu_SetText(MountyOptionsFrame_ProfileDropdown, _DataCharacter.CurrentProfile)
    UIDropDownMenu_JustifyText(MountyOptionsFrame_ProfileDropdown, "LEFT")
    UIDropDownMenu_Initialize(MountyOptionsFrame_ProfileDropdown, function()

        local info = UIDropDownMenu_CreateInfo()

        for _, profile in ipairs(Mounty:ProfilesSorted()) do

            info.text = profile
            info.func = function(p)
                Mounty:SwitchProfile(p.value)
            end

            UIDropDownMenu_AddButton(info)

        end

    end)

    MountyOptionsFrame_Profile = CreateFrame("EditBox", "MountyOptionsFrame_Profile", MountyOptionsFrame, "InputBoxTemplate")
    MountyOptionsFrame_Profile:SetWidth(100)
    MountyOptionsFrame_Profile:SetHeight(16)
    MountyOptionsFrame_Profile:SetPoint("TOPLEFT", 170, top)
    MountyOptionsFrame_Profile:SetAutoFocus(false)
    MountyOptionsFrame_Profile:SetScript("OnEnterPressed", function(calling)
        calling:ClearFocus()
        Mounty:NewProfile(calling:GetText())
    end)

    temp = TLV:Button(MountyOptionsFrame, "TOPLEFT", 270, top + 3, 50, L["button.Add"])
    temp:SetScript("OnClick", function()
        Mounty:NewProfile(MountyOptionsFrame_Profile:GetText())
    end)

    temp = TLV:Button(MountyOptionsFrame, "TOPLEFT", 318, top + 3, 50, L["button.Copy"])
    temp:SetScript("OnClick", function()
        Mounty:CopyProfile(_DataCharacter.CurrentProfile, MountyOptionsFrame_Profile:GetText())
    end)

    temp = TLV:Button(MountyOptionsFrame, "TOPLEFT", 366, top + 3, 50, L["button.Edit"])
    temp:SetScript("OnClick", function()
        Mounty:CopyProfile(_DataCharacter.CurrentProfile, MountyOptionsFrame_Profile:GetText(), true)
    end)

    temp = TLV:Button(MountyOptionsFrame, "TOPLEFT", 414, top + 3, 50, L["button.Delete"])
    temp:SetScript("OnClick", function()
        Mounty:DeleteProfile(_DataCharacter.CurrentProfile)
    end)

    -- Share profiles checkbox

    top = top - control_top_delta_small

    MountyOptionsFrame_ShareProfiles = CreateFrame("CheckButton", "MountyOptionsFrame_ShareProfiles", MountyOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyOptionsFrame_ShareProfiles:SetPoint("TOPLEFT", 16, top)
    MountyOptionsFrame_ShareProfilesText:SetText(L["options.ShareProfiles"])
    MountyOptionsFrame_ShareProfiles:SetScript("OnClick", function(calling)
        _DataCharacter.ShareProfiles = not _DataCharacter.ShareProfiles
        _DataCharacter.CurrentProfile = nil
        Mounty:Init()
        Mounty:OptionsRender()

    end)

    -- Auto open checkbox

    top = top - control_top_delta_small - 4

    MountyOptionsFrame_AutoOpen = CreateFrame("CheckButton", "MountyOptionsFrame_AutoOpen", MountyOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyOptionsFrame_AutoOpen:SetPoint("TOPLEFT", 16, top)
    MountyOptionsFrame_AutoOpenText:SetText(L["options.Autoopen"])
    MountyOptionsFrame_AutoOpen:SetScript("OnClick", function(calling)
        _DataAccount.AutoOpen = not _DataAccount.AutoOpen
        calling:SetChecked(_DataAccount.AutoOpen)
    end)

    -- DebugMode checkbox

    top = top - control_top_delta_small

    MountyOptionsFrame_DebugMode = CreateFrame("CheckButton", "MountyOptionsFrame_DebugMode", MountyOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyOptionsFrame_DebugMode:SetPoint("TOPLEFT", 16, top)
    MountyOptionsFrame_DebugModeText:SetText(L["options.Debug"])
    MountyOptionsFrame_DebugMode:SetScript("OnClick", function(calling)
        _DataAccount.DebugMode = not _DataAccount.DebugMode
        calling:SetChecked(_DataAccount.DebugMode)
    end)

end

function Mounty:OptionsRender()

    MountyOptionsFrame_Random:SetChecked(_Profile.Random)
    MountyOptionsFrame_Together:SetChecked(_Profile.Together)
    MountyOptionsFrame_ShowOff:SetChecked(_Profile.ShowOff)
    MountyOptionsFrame_TaxiMode:SetChecked(_Profile.TaxiMode)
    MountyOptionsFrame_Hello:SetText(_Profile.Hello)
    MountyOptionsFrame_DurabilityMin:SetValue(_Profile.DurabilityMin)

    MountyOptionsFrame_ShareProfiles:SetChecked(_DataCharacter.ShareProfiles)

    MountyOptionsFrame_DebugMode:SetChecked(_DataAccount.DebugMode)
    MountyOptionsFrame_AutoOpen:SetChecked(_DataAccount.AutoOpen)

    MountyOptionsFrame_Profile:SetText("")

    UIDropDownMenu_SetText(MountyOptionsFrame_ProfileDropdown, _DataCharacter.CurrentProfile)

    Mounty:OptionsRenderButtons()

end

function Mounty:OptionsRenderButtons()

    local icon

    for t = 1, MountyTypes do

        for i = 1, MountyMounts do

            MountyOptionsFrame_Buttons[t][i]:Hide() -- Muss sein, sonst werden die nicht immer neu gezeichnet ?!

            if _Profile.Mounts[t][i] == 0 then
                MountyOptionsFrame_Buttons[t][i]:SetNormalTexture("")
                MountyOptionsFrame_Buttons[t][i]:Disable()
            else
                icon = GetSpellTexture(_Profile.Mounts[t][i])
                MountyOptionsFrame_Buttons[t][i]:SetNormalTexture(icon)
                MountyOptionsFrame_Buttons[t][i]:Enable()
            end

            MountyOptionsFrame_Buttons[t][i]:Show() -- Muss sein, sonst werden die nicht immer neu gezeichnet ?!
        end
    end

end

function Mounty:AddJournalButton()

    local temp = TLV:Button(MountJournal, "BOTTOMRIGHT", -6, 3, 128, L["Mount journal - Open Mounty"])

    temp:SetScript("OnClick", function()
        if MountyOptionsFrame:IsVisible() then
            MountyOptionsFrame:Hide()
        else
            MountyOptionsFrame:ClearAllPoints()
            MountyOptionsFrame:SetPoint("TOPLEFT", CollectionsJournal, "TOPRIGHT", 0, 0)
            MountyOptionsFrame:Show()
        end
    end)

end

function Mounty:ProfileNameDefault ()

    local default = UnitName("player")

    if not Mounty:ProfileCheckName(default) then
        default = "Mounty"
    end

    return default

end

function Mounty:ProfileCheckName (p, alert)

    local err = ""

    if p == nil or p == "" then
        err = "profile.empty"
    elseif p ~= string.match(p, "[a-zA-Z0-9]+") then
        err = "profile.error"
    end

    if err ~= "" and alert then
        TLV:Alert(L[err])
    end

    return err == ""

end

function Mounty:DeleteProfile(p)

    if not Mounty:ProfileCheckName(p, true) then
        return
    end

    if _Profiles[p] == nil then

        TLV:Alert(string.format(L["profile.none"], p))
        return

    end

    StaticPopupDialogs["Mounty_Delete_Profile"] = {
        text = L["profile.delete-confirm"],
        button1 = YES,
        button2 = NO,
        sound = IG_MAINMENU_OPEN,
        timeout = 20,
        whileDead = true,
        hideOnEscape = true,
        OnAccept = function(_, data)
            _Profiles[data] = nil
            Mounty:SwitchProfile(Mounty:ProfileNameDefault())
        end
    }

    -- https://wowpedia.fandom.com/wiki/Creating_simple_pop-up_dialog_boxes

    popup = StaticPopup_Show("Mounty_Delete_Profile", p) -- Ersetzt automatisch %s in L["profile.delete-confirm"] durch p
    if (popup) then
        popup.data = p -- setzt data im Objekt auf p
    end

end

function Mounty:NewProfile (p)

    if not Mounty:ProfileCheckName(p, true) then
        return
    end

    if (_Profiles[p] ~= nil) then
        TLV:Alert(string.format(L["profile.already"], p))
        return
    end

    Mounty:SwitchProfile(p)

end

function Mounty:CopyProfile (p_from, p, rename)

    if not Mounty:ProfileCheckName(p, true) then
        return
    end

    if (_Profiles[p] ~= nil) then
        TLV:Alert(string.format(L["profile.already"], p))
        return
    end

    if not Mounty:ProfileCheckName(p_from, true) then
        return
    end

    if _Profiles[p_from] == nil then

        TLV:Alert(string.format(L["profile.none"], p_from))
        return

    end

    _Profiles[p] = TLV:TableCopy(_Profiles[p_from])

    if (rename) then
        _Profiles[p_from] = nil
    end

    Mounty:SwitchProfile(p)

end

function Mounty:SwitchProfile(p)

    if p == "" then
        TLV:Alert(string.format(L["profile.empty"], p))
        return
    end

    if not Mounty:ProfileCheckName(p, true) then
        return
    end

    Mounty:SelectProfile(p)

    if (MountyOptionsFrame:IsVisible()) then
        Mounty:OptionsRender()
    end

end

function Mounty:SelectProfile(p)

    if not Mounty:ProfileCheckName(p) then
        return
    end

    if _Profiles[p] == nil then
        _Profiles[p] = {}
    end

    if _Profiles[p].TaxiMode == nil then
        _Profiles[p].TaxiMode = false
    end

    if _Profiles[p].DoNotFly == nil then
        _Profiles[p].DoNotFly = false
    end

    if _Profiles[p].Together == nil then
        _Profiles[p].Together = _Profiles[p].DoNotFly -- renamed
    end

    if _Profiles[p].DoNotShowOff == nil then
        _Profiles[p].DoNotShowOff = false
    end

    if _Profiles[p].ShowOff == nil then
        _Profiles[p].ShowOff = not _Profiles[p].DoNotShowOff
    end

    if _Profiles[p].Random == nil then
        _Profiles[p].Random = false
    end

    if _Profiles[p].DurabilityMin == nil then
        _Profiles[p].DurabilityMin = 75
    end

    if _Profiles[p].Hello == nil then
        _Profiles[p].Hello = L["options.Hello-Default"]
    end

    if _Profiles[p].Mounts == nil then
        _Profiles[p].Mounts = {}
    end

    if _Profiles[p].Iterator == nil then
        _Profiles[p].Iterator = {}
    end

    for t = 1, MountyTypes do

        if _Profiles[p].Iterator[t] == nil then
            _Profiles[p].Iterator[t] = 0
        end

        if _Profiles[p].Mounts[t] == nil then
            _Profiles[p].Mounts[t] = {}
        end

        for i = 1, MountyMounts do
            if _Profiles[p].Mounts[t][i] == nil then
                _Profiles[p].Mounts[t][i] = 0
            end
        end
    end

    _DataCharacter.CurrentProfile = p

    _Profile = _Profiles[p];

end

function Mounty:ProfilesSorted (joined)

    local profiles = {}

    for k, _ in pairs(_Profiles) do

        table.insert(profiles, k)

    end

    table.sort(profiles)

    if (joined) then
        profiles = table.concat(profiles, " ")
    end

    return profiles

end

function Mounty:Init()

    Mounty.AddOnTitle = GetAddOnMetadata(MountyAddOnName, "Title")
    Mounty.AddOnVersion = GetAddOnMetadata(MountyAddOnName, "Version")

    if _DataCharacter.ShareProfiles == nil then
        _DataCharacter.ShareProfiles = false
    end

    if _DataCharacter.CurrentProfile == nil then
        _DataCharacter.CurrentProfile = Mounty:ProfileNameDefault()
    end

    if (_DataCharacter.Profiles == nil) then
        _DataCharacter.Profiles = {}
    end

    if (_DataAccount.Profiles == nil) then
        _DataAccount.Profiles = {}
    end

    if (_DataCharacter.ShareProfiles) then
        _Profiles = _DataAccount.Profiles -- Pointer per Reference!
    else
        _Profiles = _DataCharacter.Profiles -- Pointer per Reference!
    end

    if _Profiles == nil then
        _Profiles = {}
    end

    if _DataAccount.DebugMode == nil then
        _DataAccount.DebugMode = false
    end

    if _DataAccount.AutoOpen == nil then
        _DataAccount.AutoOpen = true
    end

    Mounty:SelectProfile(_DataCharacter.CurrentProfile)

    -- show quick start?

    if _DataAccount.QuickStart == nil then
        _DataAccount.QuickStart = true
    else
        _DataAccount.QuickStart = true
        for t = 1, MountyTypes do
            if _Profile.Mounts[t][1] ~= 0 then
                _DataAccount.QuickStart = false
            end
        end
    end

end

function Mounty:OnEvent (event, arg1)

    if event == "ADDON_LOADED" and arg1 == MountyAddOnName then

        Mounty:Upgrade()

        Mounty:Init()

        Mounty:InitOptionsFrame()

        self:UnregisterEvent("ADDON_LOADED")

    end

end

function Mounty:OnShow ()

    Mounty:OptionsRender()

end

function Mounty:OnHide ()

end

function MountyKeyHandler(keypress)
    Mounty:KeyHandler(keypress)
end

MountyOptionsFrame = CreateFrame("Frame", "MountyOptionsFrame", UIParent, "SettingsFrameTemplate")

MountyOptionsFrame:RegisterEvent("ADDON_LOADED")
MountyOptionsFrame:RegisterEvent("PLAYER_LOGOUT")

MountyOptionsFrame:SetScript("OnEvent", Mounty.OnEvent)
MountyOptionsFrame:SetScript("OnShow", Mounty.OnShow)
MountyOptionsFrame:SetScript("OnHide", Mounty.OnHide)

tinsert(UISpecialFrames, "MountyOptionsFrame");

EventRegistry:RegisterCallback("MountJournal.OnShow", function()
    if CollectionsJournal.selectedTab == COLLECTIONS_JOURNAL_TAB_INDEX_MOUNTS and not Mounty.MountyJournalButtonAdded then
        EventRegistry:UnregisterCallback("MountJournal.OnShow", MountyAddOnName .. 'Button')
        Mounty:AddJournalButton()
        Mounty.MountyJournalButtonAdded = true
    end
end, MountyAddOnName .. 'Button')

EventRegistry:RegisterCallback("MountJournal.OnShow", function()
    if _DataAccount.AutoOpen then
        MountyOptionsFrame:ClearAllPoints()
        MountyOptionsFrame:SetPoint("TOPLEFT", CollectionsJournal, "TOPRIGHT", 0, 0)
        MountyOptionsFrame:Show()
    end
end, MountyAddOnName)

EventRegistry:RegisterCallback("MountJournal.OnHide", function()
    if _DataAccount.AutoOpen then
        MountyOptionsFrame:Hide()
    end
end, MountyAddOnName)

-- /mounty

SLASH_MOUNTY1 = "/mounty"
SlashCmdList["MOUNTY"] = function(message)

    message = message or ""

    local mode, arg1 = string.split(" ", message, 2)

    mode = string.lower(mode or "")
    arg1 = arg1 or ""

    if mode == "magic" then

        Mounty:KeyHandler()

    elseif mode == "profile" then

        if arg1 == "" then
            Mounty:Chat(string.format(L["profile.current"], _DataCharacter.CurrentProfile))
        else
            Mounty:SwitchProfile(p1)
            if (p1 == _DataCharacter.CurrentProfile) then
                Mounty:Chat(string.format(L["profile.switched"], p))
            end
        end

    elseif mode == "version" then

        Mounty:Chat("<-- ;)")

    elseif mode == "debug" then

        if arg1 == "on" then

            _DataAccount.DebugMode = true
            Mounty:Chat(L["chat.Debug"] .. "|cff00f000" .. L["on"] .. "|r.")

        elseif arg1 == "off" then

            _DataAccount.DebugMode = false
            Mounty:Chat(L["chat.Debug"] .. "|cfff00000" .. L["off"] .. "|r.")
        end

    elseif mode == "auto" then

        if arg1 == "on" then

            _DataAccount.AutoOpen = true
            Mounty:Chat(L["chat.Autoopen"] .. "|cff00f000" .. L["on"] .. "|r.")

        elseif arg1 == "off" then

            _DataAccount.AutoOpen = false
            Mounty:Chat(L["chat.Autoopen"] .. "|cfff00000" .. L["off"] .. "|r.")
        end

    elseif mode == "together" then

        if arg1 == "on" then

            _Profile.Together = true
            Mounty:Chat(L["chat.Together"] .. "|cff00f000" .. L["on"] .. "|r.")

        elseif arg1 == "off" then

            _Profile.Together = false
            Mounty:Chat(L["chat.Together"] .. "|cfff00000" .. L["off"] .. "|r.")

        end

    elseif mode == "showoff" then

        if arg1 == "on" then

            _Profile.ShowOff = true
            Mounty:Chat(L["chat.Showoff"] .. "|cff00f000" .. L["on"] .. "|r.")

        elseif arg1 == "off" then

            _Profile.ShowOff = false
            Mounty:Chat(L["chat.Showoff"] .. "|cfff00000" .. L["off"] .. "|r.")

        end

    elseif mode == "random" then

        if arg1 == "on" then

            _Profile.Random = true
            Mounty:Chat(L["chat.Random"] .. "|cff00f000" .. L["on"] .. "|r.")

        elseif arg1 == "off" then

            _Profile.Random = false
            Mounty:Chat(L["chat.Random"] .. "|cfff00000" .. L["off"] .. "|r.")

        end

    elseif mode == "taxi" then

        if arg1 == "on" then

            _Profile.TaxiMode = true
            Mounty:Chat(L["chat.Taxi"] .. "|cff00f000" .. L["on"] .. "|r.")

        elseif arg1 == "off" then

            _Profile.TaxiMode = false
            Mounty:Chat(L["chat.Taxi"] .. "|cfff00000" .. L["off"] .. "|r.")

        end

    elseif mode ~= "" and mode ~= nil then

        Mounty:Mount(mode)

    else

        MountyOptionsFrame:Show();

    end

end
