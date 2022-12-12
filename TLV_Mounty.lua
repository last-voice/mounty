local MountyAddOnName, Mounty = ...

local _Profiles = {}
local _Profile = {}

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
local MountyOptionsFrame_JournalButton
local MountyOptionsFrame_Buttons = {}

local MountyQuickStartFrame

local MountyExpandedFrame
local MountyExpandedFrame_Title
local MountyExpandedFrame_Buttons = {}

local MountyCategories = 7
local MountyMounts = 10
local MountyMountsExpanded = 110

local MountyGround = 1
local MountyFlying = 2
local MountDragonflight = 3
local MountyWater = 4
local MountyRepair = 5
local MountyTaxi = 6
local MountyShowOff = 7

local MountyCategoriesLabel = {
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

function Mounty:Alert(msg)

    TLV:Alert("|cffa0a0ff" .. Mounty.AddOnTitle .. " " .. Mounty.AddOnVersion .. "|r\n\n" .. msg)

end

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

function Mounty:Fallback(category)

    MountyFallbackAlready[category] = true

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

function Mounty:SelectMountByCategory(category, only_flyable_showoffs)

    if category == 0 then
        return 0
    end

    local ids = {}
    local count = 0
    local picked

    for i = 1, MountyMountsExpanded do

        if _Profile.Mounts[category][i] > 0 then

            local mountID = C_MountJournal.GetMountFromSpell(_Profile.Mounts[category][i])
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
                ids[count] = _Profile.Mounts[category][i]
            end
        end
    end

    if count > 0 then

        if _Profile.Random then
            picked = math.random(count)
        else
            if _Profile.Iterator[category] < count then
                _Profile.Iterator[category] = _Profile.Iterator[category] + 1
            else
                _Profile.Iterator[category] = 1
            end
            picked = _Profile.Iterator[category]
        end

        Mounty:Debug("Selected: " .. picked .. " of " .. count)

        return ids[picked]
    end

    Mounty:Debug("No mount found in category.")

    return Mounty:SelectMountByCategory(Mounty:Fallback(category), false)
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

function Mounty:Mount(mode)

    local mountID = 0
    local spellID = 0
    local only_flyable_showoffs = false

    local category = MountyGround

    if mode == "dragonflight" then

        category = MountDragonflight

    elseif mode == "fly" then

        category = MountyFlying

    elseif mode == "water" then

        category = MountyWater

    elseif mode == "repair" then

        category = MountyRepair

    elseif mode == "taxi" then

        if IsInGroup() and not IsMounted() then
            if _Profile.Hello ~= "" then
                SendChatMessage(_Profile.Hello)
            end
        end

        category = MountyTaxi

    elseif mode == "showoff" then

        category = MountyShowOff

        if Mounty:UserCanFlyHere() then
            only_flyable_showoffs = true
        end


    elseif mode == "random" then

        category = 0
    end

    Mounty:Debug("Mode: " .. mode)
    Mounty:Debug("Category: " .. category)

    if category > 0 then

        MountyFallbackAlready = {} -- Muss wieder auf leer gesetzt werden

        if Mounty:UserCanFlyHere() then
            MountyFallbackQueue = { MountyFlying, MountyGround }
        else
            MountyFallbackQueue = { MountyGround, MountyFlying }
        end

        spellID = Mounty:SelectMountByCategory(category, only_flyable_showoffs)

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

        if not alone and together then
            flyable = false
        end

        local mode

        if Mounty:Durability() < _Profile.DurabilityMin then

            mode = "repair"

        elseif not alone and taximode then

            mode = "taxi"

        elseif dragonflight then

            mode = "dragonflight"

        elseif resting and showoff then

            mode = "showoff"

        elseif flyable then

            mode = "fly"

        elseif swimming then

            mode = "water"

        else

            mode = "ground"
        end

        Mounty:Mount(mode)
    end
end

function Mounty:AddMount(calling, expanded)

    local infoType, mountID = GetCursorInfo()

    local category = calling.MountyCategory or 0
    local index = calling.MountyIndex

    if expanded then
        category = Mounty:ValidCategory(MountyExpandedFrame.MountyCategory)
    end

    if not category then
        return
    end

    if infoType == "mount" then

        ClearCursor()

        local spellID = Mounty:MountSpellID(mountID)

        if spellID == 0 then

            Mounty:Debug("Fail: spellID = 0 | " .. infoType .. " " .. category .. " " .. mountID)

        elseif Mounty:AlreadyInCategory(category, spellID) then

            Mounty:Alert(L["options.Already"])

            Mounty:Debug("Fail: Already | " .. infoType .. " " .. category .. " " .. mountID .. " " .. spellID)

        else

            if index < MountyMounts then

                -- find the first empty slot
                while (index > 1 and _Profile.Mounts[category][index - 1] == 0) do
                    index = index - 1
                end

            end

            Mounty:Debug("Mount saved: " .. infoType .. " " .. category .. " " .. index .. " " .. mountID .. " " .. spellID)
            _Profile.Mounts[category][index] = spellID
            Mounty:OptionsRenderButtons()
        end

        GameTooltip:Hide()

    end

end

function Mounty:RemoveMount(calling, expanded)

    local category = calling.MountyCategory or 0
    local index = calling.MountyIndex

    if expanded then
        category = Mounty:ValidCategory(MountyExpandedFrame.MountyCategory)
    end

    if not category then
        return
    end

    Mounty:Debug("Mount removed: " .. category .. " " .. index)

    if index < MountyMounts then

        for i = index, MountyMounts - 1 do
            _Profile.Mounts[category][i] = _Profile.Mounts[category][i + 1]
        end

        _Profile.Mounts[category][MountyMounts] = 0

    else

        _Profile.Mounts[category][index] = 0

    end

    Mounty:OptionsRenderButtons()

    GameTooltip:Hide()

end

function Mounty:AlreadyInCategory (category, spellID)

    for i = 1, MountyMountsExpanded do
        if _Profile.Mounts[category][i] == spellID then
            return true
        end
    end

    return false

end

function Mounty:Tooltip(calling, expanded)

    local category = calling.MountyCategory or 0
    local index = calling.MountyIndex

    if expanded then
        category = Mounty:ValidCategory(MountyExpandedFrame.MountyCategory)
    end

    if not category then
        return
    end

    local spellID = _Profile.Mounts[category][index]

    if spellID then
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        GameTooltip:SetHyperlink("spell:" .. spellID)
        GameTooltip:Show()
    end
end

function Mounty:SettingsFrameTemplateSetBg (SettingsFrameTemplateFrame)

    -- To modify the template SettingsFrameTemplate as needed

    SettingsFrameTemplateFrame.Bg.TopSection:SetColorTexture(0, 0, 0, 0.9)

    SettingsFrameTemplateFrame.Bg.BottomEdge:SetColorTexture(0, 0, 0, 0.9)

    SettingsFrameTemplateFrame.Bg.BottomLeft:SetColorTexture(0, 0, 0, 0.9)
    SettingsFrameTemplateFrame.Bg.BottomLeft:SetVertexColor(1, 1, 1, 1)

    SettingsFrameTemplateFrame.Bg.BottomRight:SetColorTexture(0, 0, 0, 0.9)
    SettingsFrameTemplateFrame.Bg.BottomRight:SetVertexColor(1, 1, 1, 1)

end

function Mounty:InitFrameOptions()

    local top
    local temp

    local delta = 10

    MountyOptionsFrame:Hide()
    MountyOptionsFrame:SetWidth(500)
    MountyOptionsFrame:SetHeight(660)
    MountyOptionsFrame:SetPoint("CENTER")

    MountyOptionsFrame:SetFrameStrata("HIGH")

    Mounty:SettingsFrameTemplateSetBg(MountyOptionsFrame)

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

    top = -20

    -- Mounts

    for category = 1, MountyCategories do

        MountyOptionsFrame_Buttons[category] = {}

        top = top - delta * 4

        temp = MountyOptionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        temp:SetPoint("TOPLEFT", 16, top - 10)
        temp:SetText(MountyCategoriesLabel[category])

        for i = 1, MountyMounts do

            MountyOptionsFrame_Buttons[category][i] = CreateFrame("Button", nil, MountyOptionsFrame)
            MountyOptionsFrame_Buttons[category][i].MountyCategory = category
            MountyOptionsFrame_Buttons[category][i].MountyIndex = i
            MountyOptionsFrame_Buttons[category][i]:SetSize(32, 32)
            MountyOptionsFrame_Buttons[category][i]:SetDisabledTexture("Interface\\Buttons\\UI-EmptySlot")
            MountyOptionsFrame_Buttons[category][i]:GetDisabledTexture():SetTexCoord(0.15, 0.85, 0.15, 0.85)
            MountyOptionsFrame_Buttons[category][i]:SetHighlightTexture("Interface\\Buttons\\UI-StopButton")
            MountyOptionsFrame_Buttons[category][i]:SetPoint("TOPLEFT", 48 + i * 38, top)
            MountyOptionsFrame_Buttons[category][i]:SetScript("OnMouseUp", function(calling, button)
                if button == "LeftButton" then
                    Mounty:AddMount(calling, false)
                elseif button == "RightButton" then
                    Mounty:RemoveMount(calling, false)
                end
            end)
            MountyOptionsFrame_Buttons[category][i]:SetScript("OnEnter", function(calling)
                Mounty:Tooltip(calling, false)
            end)
            MountyOptionsFrame_Buttons[category][i]:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)
        end

        temp = TLV:Button(MountyOptionsFrame, "TOPLEFT", 466, top, 24, 32, "+")
        temp.MountyCategory = category
        temp:SetScript("OnClick", function(calling)

            MountyExpandedFrame_Title:SetText("+ " .. MountyCategoriesLabel[calling.MountyCategory])
            MountyExpandedFrame.MountyCategory = calling.MountyCategory
            MountyExpandedFrame:Show()
            Mounty:OptionsRenderExpandedButtons()

        end)

    end

    -- Helptext

    top = top - delta * 3

    temp = MountyOptionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    temp:SetPoint("TOPLEFT", 90, top - 3)
    temp:SetText(L["options.Helptext"])

    -- Random checkbox

    top = top - delta * 2

    MountyOptionsFrame_Random = CreateFrame("CheckButton", "MountyOptionsFrame_Random", MountyOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyOptionsFrame_Random:SetPoint("TOPLEFT", 16, top)
    MountyOptionsFrame_RandomText:SetText(L["options.Random"])
    MountyOptionsFrame_Random:SetScript("OnClick", function(calling)
        _Profile.Random = not _Profile.Random
        calling:SetChecked(_Profile.Random)
    end)

    -- ShowOff checkbox

    top = top - delta * 2

    MountyOptionsFrame_ShowOff = CreateFrame("CheckButton", "MountyOptionsFrame_ShowOff", MountyOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyOptionsFrame_ShowOff:SetPoint("TOPLEFT", 16, top)
    MountyOptionsFrame_ShowOffText:SetText(L["options.Look"])
    MountyOptionsFrame_ShowOff:SetScript("OnClick", function(calling)
        _Profile.ShowOff = not _Profile.ShowOff
        calling:SetChecked(_Profile.ShowOff)
    end)

    -- Together checkbox

    top = top - delta * 2

    MountyOptionsFrame_Together = CreateFrame("CheckButton", "MountyOptionsFrame_Together", MountyOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyOptionsFrame_Together:SetPoint("TOPLEFT", 16, top)
    MountyOptionsFrame_TogetherText:SetText(L["options.Stay"])
    MountyOptionsFrame_Together:SetScript("OnClick", function(calling)
        _Profile.Together = not _Profile.Together
        calling:SetChecked(_Profile.Together)
    end)

    -- TaxiMode checkbox

    top = top - delta * 2

    MountyOptionsFrame_TaxiMode = CreateFrame("CheckButton", "MountyOptionsFrame_TaxiMode", MountyOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyOptionsFrame_TaxiMode:SetPoint("TOPLEFT", 16, top)
    MountyOptionsFrame_TaxiModeText:SetText(L["options.Taxi"])
    MountyOptionsFrame_TaxiMode:SetScript("OnClick", function(calling)
        _Profile.TaxiMode = not _Profile.TaxiMode
        --        calling:SetChecked(_Profile.TaxiMode)
        Mounty:OptionsRender()
    end)

    -- Taxi!

    top = top - delta * 5

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

    temp = TLV:Button(MountyOptionsFrame, "TOPLEFT", 360, top + 3, 32, 21, L["button.OK"])
    temp:SetScript("OnClick", function()
        _Profile.Hello = MountyOptionsFrame_Hello:GetText()
        MountyOptionsFrame_Hello:ClearFocus()
    end)

    -- Durability slider

    top = top - delta * 4

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

    -- Current profile

    top = top - delta * 5

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
            info.checked = profile == _DataCharacter.CurrentProfile
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

    -- Profile buttons 1

    temp = TLV:Button(MountyOptionsFrame, "TOPLEFT", 270, top + 3, 50, 21, L["button.Add"])
    temp:SetScript("OnClick", function()
        Mounty:NewProfile(MountyOptionsFrame_Profile:GetText())
    end)

    temp = TLV:Button(MountyOptionsFrame, "TOPLEFT", 318, top + 3, 50, 21, L["button.Duplicate"])
    temp:SetScript("OnClick", function()
        Mounty:DuplicateProfile(_DataCharacter.CurrentProfile, MountyOptionsFrame_Profile:GetText())
    end)

    temp = TLV:Button(MountyOptionsFrame, "TOPLEFT", 366, top + 3, 50, 21, L["button.Edit"])
    temp:SetScript("OnClick", function()
        Mounty:DuplicateProfile(_DataCharacter.CurrentProfile, MountyOptionsFrame_Profile:GetText(), true)
    end)

    temp = TLV:Button(MountyOptionsFrame, "TOPLEFT", 414, top + 3, 50, 21, L["button.Delete"])
    temp:SetScript("OnClick", function()
        Mounty:DeleteProfile(_DataCharacter.CurrentProfile)
    end)

    -- Share profiles checkbox

    top = top - delta * 2

    MountyOptionsFrame_ShareProfiles = CreateFrame("CheckButton", "MountyOptionsFrame_ShareProfiles", MountyOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyOptionsFrame_ShareProfiles:SetPoint("TOPLEFT", 16, top)
    MountyOptionsFrame_ShareProfilesText:SetText(L["options.ShareProfiles"])
    MountyOptionsFrame_ShareProfiles:SetScript("OnClick", function()
        _DataCharacter.ShareProfiles = not _DataCharacter.ShareProfiles
        _DataCharacter.CurrentProfile = nil
        Mounty:InitSavedVariables()
        Mounty:OptionsRender()

    end)

    -- Profile buttons 2

    temp = TLV:Button(MountyOptionsFrame, "TOPLEFT", 270, top, 98, 21, L["button.CopyC2A"])
    temp:SetScript("OnClick", function()
        Mounty:CopyProfiles("c>a")
    end)

    temp = TLV:Button(MountyOptionsFrame, "TOPLEFT", 366, top, 98, 21, L["button.CopyA2C"])
    temp:SetScript("OnClick", function()
        Mounty:CopyProfiles("a>c")
    end)

    -- Auto open checkbox

    top = top - delta * 3

    MountyOptionsFrame_AutoOpen = CreateFrame("CheckButton", "MountyOptionsFrame_AutoOpen", MountyOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyOptionsFrame_AutoOpen:SetPoint("TOPLEFT", 16, top)
    MountyOptionsFrame_AutoOpenText:SetText(L["options.Autoopen"])
    MountyOptionsFrame_AutoOpen:SetScript("OnClick", function(calling)
        _DataAccount.AutoOpen = not _DataAccount.AutoOpen
        --        calling:SetChecked(_DataAccount.AutoOpen)
        Mounty:OptionsRender()
    end)

    -- DebugMode checkbox

    top = top - delta * 2

    MountyOptionsFrame_DebugMode = CreateFrame("CheckButton", "MountyOptionsFrame_DebugMode", MountyOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyOptionsFrame_DebugMode:SetPoint("TOPLEFT", 16, top)
    MountyOptionsFrame_DebugModeText:SetText(L["options.Debug"])
    MountyOptionsFrame_DebugMode:SetScript("OnClick", function(calling)
        _DataAccount.DebugMode = not _DataAccount.DebugMode
        calling:SetChecked(_DataAccount.DebugMode)
    end)

    -- Open Mounts

    MountyOptionsFrame_JournalButton = TLV:Button(MountyOptionsFrame, "TOPLEFT", 270, top, 98, 21, L["button.Journal"])
    MountyOptionsFrame_JournalButton:SetScript("OnClick", function()
        ToggleCollectionsJournal(1)
    end)

    --    if (_DataAccount.AutoOpen) then
    --        MountyOptionsFrame_JournalButton:Hide()
    --    end

    -- Open Quick start

    temp = TLV:Button(MountyOptionsFrame, "TOPLEFT", 366, top, 98, 21, L["button.Help"])
    temp:SetScript("OnClick", function()
        if MountyQuickStartFrame:IsVisible() then
            MountyQuickStartFrame:Hide()
        else
            MountyQuickStartFrame:Show()
        end
    end)


end

function Mounty:InitFrameQuickStart()

    MountyQuickStartFrame = CreateFrame("Frame", "MountyQuickStartFrame", MountyOptionsFrame, "SettingsFrameTemplate")
    MountyQuickStartFrame:SetWidth(490)
    MountyQuickStartFrame:SetHeight(150)
    MountyQuickStartFrame:SetPoint("CENTER", 0, 0)
    MountyQuickStartFrame:SetFrameStrata("DIALOG")

    Mounty:SettingsFrameTemplateSetBg(MountyQuickStartFrame)

    temp = MountyQuickStartFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    temp:SetPoint("TOP", 0, -6)
    temp:SetText(L["quick.title"])

    temp = MountyQuickStartFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    temp:SetPoint("TOP", 0, -32)
    temp:SetJustifyH("LEFT")
    temp:SetText(L["quick.text"])

    temp = CreateFrame("EditBox", nil, MountyQuickStartFrame, "InputBoxTemplate")
    temp:SetWidth(400)
    temp:SetHeight(16)
    temp:SetPoint("TOP", 0, -120)
    temp:SetAutoFocus(false)
    temp:SetText(L["readme.URL"])

    if not _DataAccount.QuickStart then
        MountyQuickStartFrame:Hide()
    end

end

function Mounty:InitFrameExpanded()

    local temp

    MountyExpandedFrame = CreateFrame("Frame", "MountyExpandedFrame", MountyOptionsFrame, "SettingsFrameTemplate")
    MountyExpandedFrame:SetWidth(288)
    MountyExpandedFrame:SetHeight(360)
    MountyExpandedFrame:SetPoint("TOPRIGHT", 288, -200)
    MountyExpandedFrame:SetFrameStrata("HIGH")

    Mounty:SettingsFrameTemplateSetBg(MountyExpandedFrame)

    MountyExpandedFrame:EnableMouse(true)
    MountyExpandedFrame:SetMovable(true)
    MountyExpandedFrame:RegisterForDrag("LeftButton")
    MountyExpandedFrame:SetScript("OnDragStart", function(calling)
        calling:StartMoving()
    end)
    MountyExpandedFrame:SetScript("OnDragStop", function(calling)
        calling:StopMovingOrSizing()
    end)

    MountyExpandedFrame_Title = MountyExpandedFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    MountyExpandedFrame_Title:SetPoint("TOP", 0, -6)
    MountyExpandedFrame_Title:SetText("TITLE to be replaced")

    MountyExpandedFrame.MountyCategory = MountyGround -- safety 1st

    -- Mounts 10 x 10

    local top = -12

    local index = MountyMounts

    for y = 1, 10 do

        y = y -- use

        top = top - 26

        for x = 1, 10 do

            index = index + 1

            MountyExpandedFrame_Buttons[index] = CreateFrame("Button", nil, MountyExpandedFrame)
            MountyExpandedFrame_Buttons[index].MountyIndex = index
            MountyExpandedFrame_Buttons[index]:SetSize(24, 24)
            MountyExpandedFrame_Buttons[index]:SetDisabledTexture("Interface\\Buttons\\UI-EmptySlot")
            MountyExpandedFrame_Buttons[index]:GetDisabledTexture():SetTexCoord(0.15, 0.85, 0.15, 0.85)
            MountyExpandedFrame_Buttons[index]:SetHighlightTexture("Interface\\Buttons\\UI-StopButton")
            MountyExpandedFrame_Buttons[index]:SetPoint("TOPLEFT", 18 + (x - 1) * 26, top)
            MountyExpandedFrame_Buttons[index]:SetScript("OnMouseUp", function(calling, button)
                if button == "LeftButton" then
                    Mounty:AddMount(calling, true)
                elseif button == "RightButton" then
                    Mounty:RemoveMount(calling, true)
                end
            end)
            MountyExpandedFrame_Buttons[index]:SetScript("OnEnter", function(calling)
                Mounty:Tooltip(calling, true)
            end)
            MountyExpandedFrame_Buttons[index]:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

        end

    end

    top = top - 32

    temp = TLV:Button(MountyExpandedFrame, "TOPLEFT", 18, top, 192, 21, L["expanded.Add"])
    temp:SetScript("OnClick", function()
        Mounty:AddMountsFromJournalToCategory()
    end)

    temp = TLV:Button(MountyExpandedFrame, "TOPLEFT", 216, top, 60, 21, L["expanded.Refresh"])
    temp:SetScript("OnClick", function()
        Mounty:RefreshCategory()
    end)

    top = top - 24

    temp = TLV:Button(MountyExpandedFrame, "TOPLEFT", 216, top, 60, 21, L["expanded.Clear"])
    temp:SetScript("OnClick", function()
        Mounty:ClearCategory()
    end)

    MountyExpandedFrame:Hide()

end

function Mounty:AddMountsFromJournalToCategory()

    StaticPopupDialogs["Mounty_AddMountsFromJournal"] = {
        text = L["expanded.add-journal-confirm"],
        button1 = YES,
        button2 = NO,
        sound = IG_MAINMENU_OPEN,
        timeout = 20,
        whileDead = true,
        hideOnEscape = true,
        OnAccept = function()

            local category

            local empty

            category = Mounty:ValidCategory(MountyExpandedFrame.MountyCategory)

            if not category then
                return
            end

            Mounty:ReorderCategory(category)

            -- find 1st empty slot

            empty = 0

            for i = 1, MountyMountsExpanded do
                if empty == 0 and _Profile.Mounts[category][i] == 0 then
                    empty = i
                end
            end

            if empty == 0 then
                return
            end

            local added = 0

            for i = 1, C_MountJournal.GetNumDisplayedMounts() do

                local mountID = C_MountJournal.GetDisplayedMountID(i)

                if empty <= MountyMountsExpanded then

                    if _Profile.Mounts[category][empty] == 0 then

                        if not Mounty:AlreadyInCategory(category, spellID) then

                            local _, spellID, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID);

                            if isCollected and hideOnChar ~= true then

                                _Profile.Mounts[category][empty] = spellID
                                added = added + 1
                                empty = empty + 1

                            end
                        end

                    end

                end

            end

            Mounty:OptionsRenderButtons()

            Mounty:Debug("Added " .. added .. " new mounts to the current category.")

        end
    }

    -- https://wowpedia.fandom.com/wiki/Creating_simple_pop-up_dialog_boxes

    StaticPopup_Show("Mounty_AddMountsFromJournal")

end

function Mounty:RefreshCategory()

    StaticPopupDialogs["Mounty_RefreshExpanded"] = {
        text = L["expanded.refresh-confirm"],
        button1 = YES,
        button2 = NO,
        sound = IG_MAINMENU_OPEN,
        timeout = 20,
        whileDead = true,
        hideOnEscape = true,
        OnAccept = function()

            local category = Mounty:ValidCategory(MountyExpandedFrame.MountyCategory)

            if not category then
                return
            end

            Mounty:ReorderCategory(category)

            Mounty:OptionsRenderButtons()

        end
    }

    -- https://wowpedia.fandom.com/wiki/Creating_simple_pop-up_dialog_boxes

    StaticPopup_Show("Mounty_RefreshExpanded")

end

function Mounty:ClearCategory()

    StaticPopupDialogs["Mounty_ClearExpanded"] = {
        text = L["expanded.clear-confirm"],
        button1 = YES,
        button2 = NO,
        sound = IG_MAINMENU_OPEN,
        timeout = 20,
        whileDead = true,
        hideOnEscape = true,
        OnAccept = function()

            local category = Mounty:ValidCategory(MountyExpandedFrame.MountyCategory)

            if not category then
                return
            end

            for i = 1, MountyMountsExpanded do
                _Profile.Mounts[category][i] = 0
            end

            Mounty:OptionsRenderButtons()

        end
    }

    -- https://wowpedia.fandom.com/wiki/Creating_simple_pop-up_dialog_boxes

    StaticPopup_Show("Mounty_ClearExpanded")

end

function Mounty:ReorderCategory (category)

    local j

    for i = 1, MountyMountsExpanded - 1 do

        if _Profile.Mounts[category][i] == 0 then

            j = i + 1

            while (j < MountyMountsExpanded and _Profile.Mounts[category][j] == 0) do
                j = j + 1
            end

            if _Profile.Mounts[category][j] > 0 then
                _Profile.Mounts[category][i] = _Profile.Mounts[category][j]
                _Profile.Mounts[category][j] = 0
            end

        end

    end

end

function Mounty:ValidCategory (category)

    if category == nil then
        return false
    end

    if category < 1 or category > MountyCategories then
        return false
    end

    return category

end

function Mounty:InitFrames()

    Mounty:InitFrameOptions()
    Mounty:InitFrameQuickStart()
    Mounty:InitFrameExpanded()

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

    if (_Profile.TaxiMode) then
        MountyOptionsFrame_Together:Disable()
        MountyOptionsFrame_Together:SetAlpha(0.4)
    else
        MountyOptionsFrame_Together:Enable()
        MountyOptionsFrame_Together:SetAlpha(1)
    end

    if (_DataAccount.AutoOpen) then
        MountyOptionsFrame_JournalButton:Hide()
    else
        MountyOptionsFrame_JournalButton:Show()
    end

    Mounty:OptionsRenderButtons()

end

function Mounty:OptionsRenderButtons()

    local icon

    for category = 1, MountyCategories do

        for i = 1, MountyMounts do

            MountyOptionsFrame_Buttons[category][i]:Hide() -- Muss sein, sonst werden die nicht immer neu gezeichnet ?!

            if _Profile.Mounts[category][i] == 0 then
                MountyOptionsFrame_Buttons[category][i]:SetNormalTexture("")
                MountyOptionsFrame_Buttons[category][i]:Disable()
            else
                icon = GetSpellTexture(_Profile.Mounts[category][i])
                MountyOptionsFrame_Buttons[category][i]:SetNormalTexture(icon)
                MountyOptionsFrame_Buttons[category][i]:Enable()
            end

            MountyOptionsFrame_Buttons[category][i]:Show() -- Muss sein, sonst werden die nicht immer neu gezeichnet ?!
        end

    end

    Mounty:OptionsRenderExpandedButtons()

end

function Mounty:OptionsRenderExpandedButtons()

    if not MountyExpandedFrame:IsVisible() then
        return
    end

    local icon

    local category = Mounty:ValidCategory(MountyExpandedFrame.MountyCategory)

    if not category then
        return
    end

    for i = MountyMounts + 1, MountyMountsExpanded do

        MountyExpandedFrame_Buttons[i]:Hide() -- Muss sein, sonst werden die nicht immer neu gezeichnet ?!

        if _Profile.Mounts[category][i] == 0 then
            MountyExpandedFrame_Buttons[i]:SetNormalTexture("")
            MountyExpandedFrame_Buttons[i]:Disable()
        else
            icon = GetSpellTexture(_Profile.Mounts[category][i])
            MountyExpandedFrame_Buttons[i]:SetNormalTexture(icon)
            MountyExpandedFrame_Buttons[i]:Enable()
        end

        MountyExpandedFrame_Buttons[i]:Show() -- Muss sein, sonst werden die nicht immer neu gezeichnet ?!

    end

end

function Mounty:AddJournalButton()

    local temp = TLV:Button(MountJournal, "BOTTOMRIGHT", -6, 3, 128, 21, L["Mount journal - Open Mounty"])
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

    local profiles = Mounty:ProfilesSorted()

    local default = profiles[1]

    if _Profiles[default] == nil then
        default = UnitName("player")
    end

    if not Mounty:ProfileCheckName(default) then
        default = "Mounty"
    end

    return default

end

function Mounty:ProfileCheckName (p, alert)

    local err = ""

    if p == nil or p == "" then
        err = "profile.empty"
    elseif p ~= string.match(p, "[a-zA-Z0-9_]+") then
        err = "profile.error"
    end

    if err ~= "" and alert then
        Mounty:Alert(L[err])
    end

    return err == ""

end

function Mounty:DeleteProfile(p)

    if not Mounty:ProfileCheckName(p, true) then
        return
    end

    if _Profiles[p] == nil then

        Mounty:Alert(string.format(L["profile.none"], p))
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

    local popup = StaticPopup_Show("Mounty_Delete_Profile", p) -- Ersetzt automatisch %s in L["profile.delete-confirm"] durch p
    if popup then
        popup.data = p -- setzt data im Objekt auf p
    end

end

function Mounty:NewProfile (p)

    if not Mounty:ProfileCheckName(p, true) then
        return
    end

    if _Profiles[p] ~= nil then
        Mounty:Alert(string.format(L["profile.already"], p))
        return
    end

    Mounty:SwitchProfile(p)

end

function Mounty:DuplicateProfile (p_from, p, rename)

    if not Mounty:ProfileCheckName(p, true) then
        return
    end

    if _Profiles[p] ~= nil then
        Mounty:Alert(string.format(L["profile.already"], p))
        return
    end

    if not Mounty:ProfileCheckName(p_from, true) then
        return
    end

    if _Profiles[p_from] == nil then

        Mounty:Alert(string.format(L["profile.none"], p_from))
        return

    end

    _Profiles[p] = TLV:TableDuplicate(_Profiles[p_from])

    if rename then
        _Profiles[p_from] = nil
    end

    Mounty:SwitchProfile(p)

end

function Mounty:SwitchProfile(p)

    if p == "" then
        Mounty:Alert(string.format(L["profile.empty"], p))
        return
    end

    if not Mounty:ProfileCheckName(p, true) then
        return
    end

    Mounty:SelectProfile(p)

    if MountyOptionsFrame:IsVisible() then
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

    for category = 1, MountyCategories do

        if _Profiles[p].Iterator[category] == nil then
            _Profiles[p].Iterator[category] = 0
        end

        if _Profiles[p].Mounts[category] == nil then
            _Profiles[p].Mounts[category] = {}
        end

        for i = 1, MountyMountsExpanded do
            if _Profiles[p].Mounts[category][i] == nil then
                _Profiles[p].Mounts[category][i] = 0
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

    if joined then
        profiles = table.concat(profiles, " ")
    end

    return profiles

end

function Mounty:CopyProfiles(mode)

    StaticPopupDialogs["Mounty_Copy_Profiles"] = {
        text = L["profile.copy-confirm"],
        button1 = YES,
        button2 = NO,
        sound = IG_MAINMENU_OPEN,
        timeout = 20,
        whileDead = true,
        hideOnEscape = true,
        OnAccept = function(_, data)

            local Profiles_Src
            local Profiles_Dst

            if data == "c>a" then
                Profiles_Src = _DataCharacter.Profiles
                Profiles_Dst = _DataAccount.Profiles
            else
                Profiles_Src = _DataAccount.Profiles
                Profiles_Dst = _DataCharacter.Profiles
            end

            for k, _ in pairs(Profiles_Src) do

                local i = 1
                local dk = k

                while (Profiles_Dst[dk] ~= nil) do
                    dk = string.format("%s_%d", k, i)
                    i = i + 1
                end

                Profiles_Dst[dk] = TLV:TableDuplicate(Profiles_Src[k])

            end

        end
    }

    -- https://wowpedia.fandom.com/wiki/Creating_simple_pop-up_dialog_boxes

    local popup = StaticPopup_Show("Mounty_Copy_Profiles", L["profile.copy-" .. mode])
    if popup then
        popup.data = mode -- setzt data im Objekt auf mode
    end

end

function Mounty:InitSavedVariables()

    if _DataAccount == nil then
        _DataAccount = {}
    end

    if _DataCharacter == nil then
        _DataCharacter = {}
    end

    if _DataCharacter.ShareProfiles == nil then
        _DataCharacter.ShareProfiles = false
    end

    if _DataCharacter.Profiles == nil then
        _DataCharacter.Profiles = {}
    end

    if _DataAccount.Profiles == nil then
        _DataAccount.Profiles = {}
    end

    if _DataCharacter.ShareProfiles then
        _Profiles = _DataAccount.Profiles -- Pointer per Reference!
    else
        _Profiles = _DataCharacter.Profiles -- Pointer per Reference!
    end

    if _Profiles == nil then
        _Profiles = {}
    end

    if _DataCharacter.CurrentProfile == nil then

        local profiles = Mounty:ProfilesSorted()

        _DataCharacter.CurrentProfile = profiles[1]

        if _Profiles[_DataCharacter.CurrentProfile] == nil then
            _DataCharacter.CurrentProfile = Mounty:ProfileNameDefault()

        end

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
        for category = 1, MountyCategories do
            if _Profile.Mounts[category][1] ~= 0 then
                _DataAccount.QuickStart = false
            end
        end
    end

end

function Mounty:Init()

    Mounty.AddOnTitle = GetAddOnMetadata(MountyAddOnName, "Title")
    Mounty.AddOnVersion = GetAddOnMetadata(MountyAddOnName, "Version")

    Mounty:Upgrade()

    Mounty:InitSavedVariables()

    Mounty:InitFrames()

end

function Mounty:OnEvent (event, arg1)

    if event == "ADDON_LOADED" and arg1 == MountyAddOnName then

        Mounty:Init()

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
            if p1 == _DataCharacter.CurrentProfile then
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

    elseif mode == "dbg" then

        --    TLV:TableDebug(MountyQuickStartFrame)

    elseif mode ~= "" and mode ~= nil then

        Mounty:Mount(mode)

    else

        MountyOptionsFrame:Show();

    end

end
