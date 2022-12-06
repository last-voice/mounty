local MountyAddOnName, Mounty = ...

MountyData = {}
_Data = {}

local _Data_Profile = {}

local TLV = TLV

local L = Mounty.L

local AddOnTitle
local AddOnVersion

local MountyOptionsFrame
local MountyOptionsFrame_DebugMode
local MountyOptionsFrame_AutoOpen
local MountyOptionsFrame_TaxiMode
local MountyOptionsFrame_Together
local MountyOptionsFrame_ShowOff
local MountyOptionsFrame_Random
local MountyOptionsFrame_DurabilityMin
local MountyOptionsFrame_Hello
local MountyOptionsFrame_Profile
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

local MountyTestDragon

local MountyDebugForce = false

function Mounty:Chat(msg)

    if DEFAULT_CHAT_FRAME then

        DEFAULT_CHAT_FRAME:AddMessage("|cffa0a0ff" .. AddOnTitle .. " " .. AddOnVersion .. "|r: " .. msg, 1, 1, 0)
    end
end

function Mounty:Debug(msg)

    if _Data.DebugMode or MountyDebugForce then
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

    if (not MountyFallbackAlready[MountyFallbackQueue[1]]) then

        FallbackTo = MountyFallbackQueue[1]

    elseif (not MountyFallbackAlready[MountyFallbackQueue[2]]) then

        FallbackTo = MountyFallbackQueue[2]
    end

    if (FallbackTo == MountyFlying) then

        Mounty:Debug("Fallback: '" .. L["mode.Flying"] .. "'")
        return MountyFlying

    elseif (FallbackTo == MountyGround) then

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
    local usable
    local picked

    for i = 1, MountyMounts do

        if _Data_Profile.Mounts[typ][i] > 0 then

            local mountID = C_MountJournal.GetMountFromSpell(_Data_Profile.Mounts[typ][i])
            local mname, _, _, _, isUsable = C_MountJournal.GetMountInfoByID(mountID)

            if only_flyable_showoffs then
                local _, _, _, _, mountTypeID = C_MountJournal.GetMountInfoExtraByID(mountID)

                if mountTypeID ~= 248 then
                    -- 248 = mostly flyable
                    isUsable = false
                end
            end

            Mounty:Debug("Usable: " .. "[" .. mountID .. "] " .. mname .. " -> " .. tostring(isUsable))

            if isUsable then
                count = count + 1
                ids[count] = _Data_Profile.Mounts[typ][i]
            end
        end
    end

    if count > 0 then

        if _Data_Profile.Random then
            picked = math.random(count)
        else
            if _Data_Profile.Iterator[typ] < count then
                _Data_Profile.Iterator[typ] = _Data_Profile.Iterator[typ] + 1
            else
                _Data_Profile.Iterator[typ] = 1
            end
            picked = _Data_Profile.Iterator[typ]
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

    if (MountyTestDragon == nil) then

        MountyTestDragon = 0

        for k, v in ipairs(C_MountJournal.GetCollectedDragonridingMounts()) do
            local name, spellID, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(v)
            if (isCollected) then
                MountyTestDragon = spellID
                Mounty:Debug("Test dragon found: " .. name .. " [" .. spellID .. "]")
            end
        end
    end

    if (MountyTestDragon == 0) then
        return false
    end

    return (IsUsableSpell(MountyTestDragon))
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
            if _Data_Profile.Hello ~= "" then
                SendChatMessage(_Data_Profile.Hello)
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

        if (Mounty:UserCanFlyHere()) then
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
        local taximode = _Data_Profile.TaxiMode
        local together = _Data_Profile.Together
        local showoff = _Data_Profile.ShowOff

        Mounty:Debug("Magic key")

        if together and not alone then
            flyable = false
        end

        local category

        if Mounty:Durability() < _Data_Profile.DurabilityMin then

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
            if _Data_Profile.Mounts[typ][i] == spellID then
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
            while (index > 1 and _Data_Profile.Mounts[typ][index - 1] == 0) do
                index = index - 1
            end

            Mounty:Debug("Mount saved: " .. infoType .. " " .. typ .. " " .. index .. " " .. mountID .. " " .. spellID)
            _Data_Profile.Mounts[typ][index] = spellID
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
        _Data_Profile.Mounts[typ][i] = _Data_Profile.Mounts[typ][i + 1]
    end
    _Data_Profile.Mounts[typ][MountyMounts] = 0

    Mounty:OptionsRenderButtons()

    GameTooltip:Hide()
end

function Mounty:Tooltip(calling)

    local typ = calling.MountyTyp
    local index = calling.MountyIndex

    local spellID = _Data_Profile.Mounts[typ][index]

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

    -- Mounty options

    MountyOptionsFrame:Hide()
    MountyOptionsFrame:SetWidth(480)
    MountyOptionsFrame:SetHeight(620)
    MountyOptionsFrame:SetPoint("CENTER")

    MountyOptionsFrame:SetFrameStrata("MEDIUM")

    MountyOptionsFrame:EnableMouse(true)
    MountyOptionsFrame:SetMovable(true)
    MountyOptionsFrame:RegisterForDrag("LeftButton")
    MountyOptionsFrame:SetScript("OnDragStart", function(calling, button)
        calling:StartMoving()
    end)
    MountyOptionsFrame:SetScript("OnDragStop", function(calling)
        calling:StopMovingOrSizing()
    end)

    -- Title text
    temp = MountyOptionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    temp:SetPoint("TOP", 0, -6)
    temp:SetText(AddOnTitle .. " " .. AddOnVersion)

    -- Quickstart

    MountyOptionsFrame_QuickStart = CreateFrame("Frame", nil, MountyOptionsFrame, "SettingsFrameTemplate")
    MountyOptionsFrame_QuickStart:SetWidth(480)
    MountyOptionsFrame_QuickStart:SetHeight(90)
    MountyOptionsFrame_QuickStart:SetPoint("BOTTOM", 0, -90)
    MountyOptionsFrame_QuickStart:SetFrameStrata("MEDIUM")

    temp = MountyOptionsFrame_QuickStart:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    temp:SetPoint("TOP", 0, -6)
    temp:SetText(L["quick.title"])

    temp = MountyOptionsFrame_QuickStart:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    temp:SetPoint("TOPLEFT", 32, -32)
    temp:SetJustifyH("LEFT")
    temp:SetText(L["quick.text"])

    if (not _Data.QuickStart) then
        MountyOptionsFrame_QuickStart:Hide()
    end

    -- Random checkbox

    top = -40

    MountyOptionsFrame_Random = CreateFrame("CheckButton", "MountyOptionsFrame_Random", MountyOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyOptionsFrame_Random:SetPoint("TOPLEFT", 16, top)
    MountyOptionsFrame_RandomText:SetText(L["options.Random"])
    MountyOptionsFrame_Random:SetScript("OnClick", function(calling)
        _Data_Profile.Random = not _Data_Profile.Random
        calling:SetChecked(_Data_Profile.Random)
    end)

    -- Open Mounts

    temp = CreateFrame("Button", "MountyOptionsFrame_OpenMounts", MountyOptionsFrame)
    temp:SetSize(32, 32)
    temp:SetNormalTexture("Interface\\Icons\\Ability_Mount_RidingHorse")
    temp:SetPoint("TOPRIGHT", -20, top)
    temp:SetScript("OnMouseUp", function()
        ToggleCollectionsJournal(1)
    end)

    -- Open Quick start

    temp = CreateFrame("Button", "MountyOptionsFrame_OpenMounts", MountyOptionsFrame)
    temp:SetSize(32, 32)
    temp:SetNormalTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    temp:SetPoint("TOPRIGHT", -20, top - 40)
    temp:SetScript("OnMouseUp", function()
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
        _Data_Profile.ShowOff = not _Data_Profile.ShowOff
        calling:SetChecked(_Data_Profile.ShowOff)
    end)

    -- Together checkbox

    top = top - control_top_delta_small

    MountyOptionsFrame_Together = CreateFrame("CheckButton", "MountyOptionsFrame_Together", MountyOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyOptionsFrame_Together:SetPoint("TOPLEFT", 16, top)
    MountyOptionsFrame_TogetherText:SetText(L["options.Stay"])
    MountyOptionsFrame_Together:SetScript("OnClick", function(calling)
        _Data_Profile.Together = not _Data_Profile.Together
        calling:SetChecked(_Data_Profile.Together)
    end)

    -- TaxiMode checkbox

    top = top - control_top_delta_small

    MountyOptionsFrame_TaxiMode = CreateFrame("CheckButton", "MountyOptionsFrame_TaxiMode", MountyOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyOptionsFrame_TaxiMode:SetPoint("TOPLEFT", 16, top)
    MountyOptionsFrame_TaxiModeText:SetText(L["options.Taxi"])
    MountyOptionsFrame_TaxiMode:SetScript("OnClick", function(calling)
        _Data_Profile.TaxiMode = not _Data_Profile.TaxiMode
        calling:SetChecked(_Data_Profile.TaxiMode)
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
        _Data_Profile.Hello = calling:GetText()
        calling:ClearFocus()
    end)
    MountyOptionsFrame_Hello:SetScript("OnEscapePressed", function(calling)
        calling:SetText(_Data_Profile.Hello)
    end)

    temp = TLV:Button(MountyOptionsFrame, "TOPLEFT", 360, top + 2, 32, "MEDIUM", L["button.OK"])
    temp:SetScript("OnMouseUp", function()
        _Data_Profile.Hello = MountyOptionsFrame_Hello:GetText()
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
    MountyOptionsFrame_DurabilityMin:SetScript("OnValueChanged", function(calling, value)
        MountyOptionsFrame_DurabilityMinText:SetFormattedText(L["options.Durability"], math.floor(value + 0.5))
        _Data_Profile.DurabilityMin = math.floor(value + 0.5)
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

    MountyOptionsFrame_Profile = CreateFrame("EditBox", "MountyOptionsFrame_Profile", MountyOptionsFrame, "InputBoxTemplate")
    MountyOptionsFrame_Profile:SetWidth(140)
    MountyOptionsFrame_Profile:SetHeight(16)
    MountyOptionsFrame_Profile:SetPoint("TOPLEFT", 25, top)
    MountyOptionsFrame_Profile:SetAutoFocus(false)
    MountyOptionsFrame_Profile:CreateFontString("MountyOptionsFrame_ProfileLabel", "OVERLAY", "GameFontNormalSmall")
    MountyOptionsFrame_ProfileLabel:SetPoint("BOTTOMLEFT", MountyOptionsFrame_Profile, "TOPLEFT", 0, 4)
    MountyOptionsFrame_ProfileLabel:SetText(L["options.Profile"])
    MountyOptionsFrame_Profile:SetScript("OnEnterPressed", function(calling)
        calling:ClearFocus()
        local ok = Mounty:ParseProfile(string.split(" ", calling:GetText(), 2))
        if not ok then
            MountyOptionsFrame_Profile:SetText(_Data.Profile)
        end
    end)

    local raid_opts = {
        ['name'] = 'raid',
        ['parent'] = MountyOptionsFrame,
        ['title'] = '',
        ['items'] = { '2', '12', '13' },
        ['defaultVal'] = '',
        ['changeFunc'] = function(dropdown_frame, dropdown_val)
            Mounty:ParseProfile(dropdown_val)
            UIDropDownMenu_SetText(MountyOptionsFrame_ProfileDropdown, "")
        end
    }

    MountyOptionsFrame_ProfileDropdown = TLV:Dropdown(raid_opts)
    MountyOptionsFrame_ProfileDropdown:SetPoint("TOPLEFT", 160, top + 6);

    -- AutoOpen checkbox

    top = top - control_top_delta_small

    MountyOptionsFrame_AutoOpen = CreateFrame("CheckButton", "MountyOptionsFrame_AutoOpen", MountyOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyOptionsFrame_AutoOpen:SetPoint("TOPLEFT", 16, top)
    MountyOptionsFrame_AutoOpenText:SetText(L["options.Autoopen"])
    MountyOptionsFrame_AutoOpen:SetScript("OnClick", function(calling)
        _Data.AutoOpen = not _Data.AutoOpen
        calling:SetChecked(_Data.AutoOpen)
    end)

    -- DebugMode checkbox

    top = top - control_top_delta_small

    MountyOptionsFrame_DebugMode = CreateFrame("CheckButton", "MountyOptionsFrame_DebugMode", MountyOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyOptionsFrame_DebugMode:SetPoint("TOPLEFT", 16, top)
    MountyOptionsFrame_DebugModeText:SetText(L["options.Debug"])
    MountyOptionsFrame_DebugMode:SetScript("OnClick", function(calling)
        _Data.DebugMode = not _Data.DebugMode
        calling:SetChecked(_Data.DebugMode)
    end)

    -- No Idea what for ..?

    -- MountyOptionsFrame.name = "Mounty"

end

function Mounty:OptionsRender()

    MountyOptionsFrame_Random:SetChecked(_Data_Profile.Random)
    MountyOptionsFrame_Together:SetChecked(_Data_Profile.Together)
    MountyOptionsFrame_ShowOff:SetChecked(_Data_Profile.ShowOff)
    MountyOptionsFrame_TaxiMode:SetChecked(_Data_Profile.TaxiMode)
    MountyOptionsFrame_Hello:SetText(_Data_Profile.Hello)
    MountyOptionsFrame_DurabilityMin:SetValue(_Data_Profile.DurabilityMin)

    MountyOptionsFrame_Profile:SetText(_Data.Profile)
    MountyOptionsFrame_DebugMode:SetChecked(_Data.DebugMode)
    MountyOptionsFrame_AutoOpen:SetChecked(_Data.AutoOpen)

    Mounty:OptionsRenderButtons()
end

function Mounty:OptionsRenderButtons()

    local icon

    for t = 1, MountyTypes do

        for i = 1, MountyMounts do

            MountyOptionsFrame_Buttons[t][i]:Hide() -- Muss sein, sonst werden die nicht immer neu gezeichnet ?!

            if _Data_Profile.Mounts[t][i] == 0 then
                MountyOptionsFrame_Buttons[t][i]:SetNormalTexture("")
                MountyOptionsFrame_Buttons[t][i]:Disable()
            else
                icon = GetSpellTexture(_Data_Profile.Mounts[t][i])
                MountyOptionsFrame_Buttons[t][i]:SetNormalTexture(icon)
                MountyOptionsFrame_Buttons[t][i]:Enable()
            end

            MountyOptionsFrame_Buttons[t][i]:Show() -- Muss sein, sonst werden die nicht immer neu gezeichnet ?!
        end
    end
end

function Mounty:AddJournalButton()

    local temp = TLV:Button(MountJournal, "BOTTOMRIGHT", -6, 3, 128, "HIGH", L["Mount journal - Open Mounty"])

    temp:SetScript("OnMouseUp", function()
        if MountyOptionsFrame:IsVisible() then
            MountyOptionsFrame:Hide()
        else
            MountyOptionsFrame:ClearAllPoints()
            MountyOptionsFrame:SetPoint("TOPLEFT", CollectionsJournal, "TOPRIGHT", 0, 0)
            MountyOptionsFrame:Show()
        end
    end)

end

function Mounty:ParseProfile(p1, p2)

    local n1 = math.floor(tonumber(p1) or 0)
    local n2 = math.floor(tonumber(p2) or 0)

    if n1 > 0 and p2 == "-" then
        Mounty:DeleteProfile(n1)
    elseif n1 > 0 then
        Mounty:SwitchProfile(n1, n2)
    else
        Mounty:Chat(L["chat.profile-error"])
        return false
    end

    return true

end

function Mounty:DeleteProfile(p)

    if (p > 1) then
        _Data.Profiles[p] = nil
        Mounty:Chat(string.format(L["chat.profile-deleted"], p))
        Mounty:SwitchProfile(1, 0)
    end

end

function Mounty:SwitchProfile(p, pfrom)

    if (pfrom > 0) then

        if _Data.Profiles[pfrom] == nil then

            Mounty:Chat(string.format(L["chat.profile-empty"], pfrom))

        else

            _Data.Profiles[p] = TLV:TableCopy(_Data.Profiles[pfrom])

            Mounty:Chat(string.format(L["chat.profile-copied"], p, pfrom))

        end
    end

    Mounty:SelectProfile(p)
    Mounty:OptionsRender()

    Mounty:Chat(string.format(L["chat.profile-switched"], p))

end

function Mounty:SelectProfile(p)

    if _Data.Profiles[p] == nil then
        _Data.Profiles[p] = {}
    end

    if _Data.Profiles[p].DebugMode == nil then
        _Data.Profiles[p].DebugMode = false
    end

    if _Data.Profiles[p].AutoOpen == nil then
        _Data.Profiles[p].AutoOpen = true
    end

    if _Data.Profiles[p].TaxiMode == nil then
        _Data.Profiles[p].TaxiMode = false
    end

    if _Data.Profiles[p].DoNotFly == nil then
        _Data.Profiles[p].DoNotFly = false
    end

    if _Data.Profiles[p].Together == nil then
        _Data.Profiles[p].Together = _Data.Profiles[p].DoNotFly -- renamed
    end

    if _Data.Profiles[p].DoNotShowOff == nil then
        _Data.Profiles[p].DoNotShowOff = false
    end

    if _Data.Profiles[p].ShowOff == nil then
        _Data.Profiles[p].ShowOff = not _Data.Profiles[p].DoNotShowOff
    end

    if _Data.Profiles[p].Random == nil then
        _Data.Profiles[p].Random = false
    end

    if _Data.Profiles[p].DurabilityMin == nil then
        _Data.Profiles[p].DurabilityMin = 75
    end

    if _Data.Profiles[p].Hello == nil then
        _Data.Profiles[p].Hello = L["options.Hello-Default"]
    end

    if _Data.Profiles[p].Mounts == nil then
        _Data.Profiles[p].Mounts = {}
    end

    if _Data.Profiles[p].Iterator == nil then
        _Data.Profiles[p].Iterator = {}
    end

    for t = 1, MountyTypes do

        if _Data.Profiles[p].Iterator[t] == nil then
            _Data.Profiles[p].Iterator[t] = 0
        end

        if _Data.Profiles[p].Mounts[t] == nil then
            _Data.Profiles[p].Mounts[t] = {}
        end

        for i = 1, MountyMounts do
            if _Data.Profiles[p].Mounts[t][i] == nil then
                _Data.Profiles[p].Mounts[t][i] = 0
            end
        end
    end

    _Data_Profile = _Data.Profiles[p];

    _Data.Profile = p

end

function Mounty:Init()

    AddOnTitle = GetAddOnMetadata(MountyAddOnName, "Title")
    AddOnVersion = GetAddOnMetadata(MountyAddOnName, "Version")

    Mounty:Upgrade()

    if _Data.Profile == nil then
        _Data.Profile = 1
    end

    if _Data.Profiles == nil then
        _Data.Profiles = {}
    end

    if _Data.DebugMode == nil then
        _Data.DebugMode = false
    end

    if _Data.AutoOpen == nil then
        _Data.AutoOpen = true
    end

    Mounty:SelectProfile(_Data.Profile)

    -- show quick start?

    if _Data.QuickStart == nil then
        _Data.QuickStart = true
    else
        _Data.QuickStart = true
        for t = 1, MountyTypes do
            if _Data_Profile.Mounts[t][1] ~= 0 then
                _Data.QuickStart = false
            end
        end
    end

    --

    Mounty:InitOptionsFrame()

end

function Mounty:Upgrade()

    -- MountyData not deleted yet
    -- New category Dragonflight

    if MountyData ~= nil then
        if MountyData.Mounts ~= nil then

            if (MountyData.UpgradeToDragonflight == nil) then
                MountyData.UpgradeToDragonflight = true
                for t = MountyTypes, 4, -1 do
                    for i = 1, MountyMounts do
                        MountyData.Mounts[t][i] = MountyData.Mounts[t - 1][i]
                        MountyData.Mounts[t - 1][i] = 0
                    end
                end
            end

        end
    end

    -- MountyProfiles

    if _Data.Profiles == nil then

        _Data.Profiles = {}

        if MountyData ~= nil then

            _Data.Profiles[1] = {}

            _Data.Profiles[1].DurabilityMin = MountyData.DurabilityMin
            _Data.Profiles[1].Hello = MountyData.Hello
            _Data.Profiles[1].Iterator = MountyData.Iterator
            _Data.Profiles[1].Mounts = MountyData.Mounts
            _Data.Profiles[1].Random = MountyData.Random
            _Data.Profiles[1].ShowOff = MountyData.ShowOff
            _Data.Profiles[1].TaxiMode = MountyData.TaxiMode
            _Data.Profiles[1].Together = MountyData.Together

            _Data.DebugMode = MountyData.DebugMode
            _Data.AutoOpen = MountyData.AutoOpen

        end

    end

    -- MountyData no more

    if MountyData ~= nil then
        MountyData = nil
    end

end

function Mounty:OnEvent (event, arg1)

    if (event == "ADDON_LOADED" and arg1 == MountyAddOnName) then

        Mounty.Init()
        self:UnregisterEvent("ADDON_LOADED")

    end

end

function MountyKeyHandler(keypress)
    Mounty:KeyHandler(keypress)
end

MountyOptionsFrame = CreateFrame("Frame", "MountyOptionsFrame", UIParent, "SettingsFrameTemplate")

MountyOptionsFrame:RegisterEvent("ADDON_LOADED")
MountyOptionsFrame:RegisterEvent("PLAYER_LOGOUT")

MountyOptionsFrame:SetScript("OnEvent", Mounty.OnEvent)
MountyOptionsFrame:SetScript("OnShow", Mounty.OptionsRender)

tinsert(UISpecialFrames, "MountyOptionsFrame");

EventRegistry:RegisterCallback("MountJournal.OnShow", function()
    if CollectionsJournal.selectedTab == COLLECTIONS_JOURNAL_TAB_INDEX_MOUNTS and not Mounty.MountyJournalButtonAdded then
        EventRegistry:UnregisterCallback("MountJournal.OnShow", MountyAddOnName .. 'Button')
        Mounty:AddJournalButton()
        Mounty.MountyJournalButtonAdded = true
    end
end, MountyAddOnName .. 'Button')

EventRegistry:RegisterCallback("MountJournal.OnShow", function()
    if _Data.AutoOpen then
        MountyOptionsFrame:ClearAllPoints()
        MountyOptionsFrame:SetPoint("TOPLEFT", CollectionsJournal, "TOPRIGHT", 0, 0)
        MountyOptionsFrame:Show()
    end
end, MountyAddOnName)

EventRegistry:RegisterCallback("MountJournal.OnHide", function()
    if _Data.AutoOpen then
        MountyOptionsFrame:Hide()
    end
end, MountyAddOnName)

-- /mounty

SLASH_MOUNTY1 = "/mounty"
SlashCmdList["MOUNTY"] = function(message)

    message = message or ""

    local mode, arg1, arg2 = string.split(" ", message, 3)

    mode = string.lower(mode or "")
    arg1 = string.lower(arg1 or "")
    arg2 = string.lower(arg2 or "")

    if mode == "magic" then

        Mounty:KeyHandler()

    elseif mode == "profile" then

        if arg1 == "" then
            Mounty:Chat(string.format(L["chat.profile-current"], _Data.Profile))
        else
            Mounty:ParseProfile(arg1, arg2)
        end

    elseif mode == "version" then

        Mounty:Chat("<-- ;)")

    elseif mode == "debug" then

        if arg1 == "on" then

            _Data.DebugMode = true
            Mounty:Chat(L["chat.Debug"] .. "|cff00f000" .. L["on"] .. "|r.")

        elseif arg1 == "off" then

            _Data.DebugMode = false
            Mounty:Chat(L["chat.Debug"] .. "|cfff00000" .. L["off"] .. "|r.")
        end

    elseif mode == "auto" then

        if arg1 == "on" then

            _Data.AutoOpen = true
            Mounty:Chat(L["chat.Autoopen"] .. "|cff00f000" .. L["on"] .. "|r.")

        elseif arg1 == "off" then

            _Data.AutoOpen = false
            Mounty:Chat(L["chat.Autoopen"] .. "|cfff00000" .. L["off"] .. "|r.")
        end

    elseif mode == "together" then

        if arg1 == "on" then

            _Data_Profile.Together = true
            Mounty:Chat(L["chat.Together"] .. "|cff00f000" .. L["on"] .. "|r.")

        elseif arg1 == "off" then

            _Data_Profile.Together = false
            Mounty:Chat(L["chat.Together"] .. "|cfff00000" .. L["off"] .. "|r.")

        end

    elseif mode == "showoff" then

        if arg1 == "on" then

            _Data_Profile.ShowOff = true
            Mounty:Chat(L["chat.Showoff"] .. "|cff00f000" .. L["on"] .. "|r.")

        elseif arg1 == "off" then

            _Data_Profile.ShowOff = false
            Mounty:Chat(L["chat.Showoff"] .. "|cfff00000" .. L["off"] .. "|r.")

        end

    elseif mode == "random" then

        if arg1 == "on" then

            _Data_Profile.Random = true
            Mounty:Chat(L["chat.Random"] .. "|cff00f000" .. L["on"] .. "|r.")

        elseif arg1 == "off" then

            _Data_Profile.Random = false
            Mounty:Chat(L["chat.Random"] .. "|cfff00000" .. L["off"] .. "|r.")

        end

    elseif mode == "taxi" then

        if arg1 == "on" then

            _Data_Profile.TaxiMode = true
            Mounty:Chat(L["chat.Taxi"] .. "|cff00f000" .. L["on"] .. "|r.")

        elseif arg1 == "off" then

            _Data_Profile.TaxiMode = false
            Mounty:Chat(L["chat.Taxi"] .. "|cfff00000" .. L["off"] .. "|r.")

        end

    elseif mode ~= "" and mode ~= nil then

        Mounty:Mount(mode)

    else

        MountyOptionsFrame:Show();
    end
end
