local MountyAddOnName, Mounty = ...

MountyData = {}
TLV = {}

local TLV_Profile = {}

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

    if TLV.DebugMode or MountyDebugForce then
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

        if TLV_Profile.Mounts[typ][i] > 0 then

            local mountID = C_MountJournal.GetMountFromSpell(TLV_Profile.Mounts[typ][i])
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
                ids[count] = TLV_Profile.Mounts[typ][i]
            end
        end
    end

    if count > 0 then

        if TLV_Profile.Random then
            picked = math.random(count)
        else
            if TLV_Profile.Iterator[typ] < count then
                TLV_Profile.Iterator[typ] = TLV_Profile.Iterator[typ] + 1
            else
                TLV_Profile.Iterator[typ] = 1
            end
            picked = TLV_Profile.Iterator[typ]
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
            if TLV_Profile.Hello ~= "" then
                SendChatMessage(TLV_Profile.Hello)
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
        local taximode = TLV_Profile.TaxiMode
        local together = TLV_Profile.Together
        local showoff = TLV_Profile.ShowOff

        Mounty:Debug("Magic key")

        if together and not alone then
            flyable = false
        end

        local category

        if Mounty:Durability() < TLV_Profile.DurabilityMin then

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
            if TLV_Profile.Mounts[typ][i] == spellID then
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
            while (index > 1 and TLV_Profile.Mounts[typ][index - 1] == 0) do
                index = index - 1
            end

            Mounty:Debug("Mount saved: " .. infoType .. " " .. typ .. " " .. index .. " " .. mountID .. " " .. spellID)
            TLV_Profile.Mounts[typ][index] = spellID
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
        TLV_Profile.Mounts[typ][i] = TLV_Profile.Mounts[typ][i + 1]
    end
    TLV_Profile.Mounts[typ][MountyMounts] = 0

    Mounty:OptionsRenderButtons()

    GameTooltip:Hide()
end

function Mounty:Tooltip(calling)

    local typ = calling.MountyTyp
    local index = calling.MountyIndex

    local spellID = TLV_Profile.Mounts[typ][index]

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
    MountyOptionsFrame:SetHeight(580)
    MountyOptionsFrame:SetPoint("CENTER")

    MountyOptionsFrame:SetFrameStrata("MEDIUM")
    --    MountyOptionsFrame.Bg:SetFrameStrata("HIGH")

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
    --    MountyOptionsFrame_QuickStart.Bg:SetFrameStrata("MEDIUM")

    temp = MountyOptionsFrame_QuickStart:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    temp:SetPoint("TOP", 0, -6)
    temp:SetText(L["Quick start"])

    temp = MountyOptionsFrame_QuickStart:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    temp:SetPoint("TOPLEFT", 32, -32)
    temp:SetJustifyH("LEFT")
    temp:SetText(L["Quick start full"])

    if (not TLV.QuickStart) then
        MountyOptionsFrame_QuickStart:Hide()
    end

    -- Random checkbox

    top = -40

    MountyOptionsFrame_Random = CreateFrame("CheckButton", "MountyOptionsFrame_Random", MountyOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyOptionsFrame_Random:SetPoint("TOPLEFT", 16, top)
    MountyOptionsFrame_RandomText:SetText(L["Random"])
    MountyOptionsFrame_Random:SetScript("OnClick", function(calling)
        TLV_Profile.Random = not TLV_Profile.Random
        calling:SetChecked(TLV_Profile.Random)
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
    MountyOptionsFrame_ShowOffText:SetText(L["Look at me!"])
    MountyOptionsFrame_ShowOff:SetScript("OnClick", function(calling)
        TLV_Profile.ShowOff = not TLV_Profile.ShowOff
        calling:SetChecked(TLV_Profile.ShowOff)
    end)

    -- Together checkbox

    top = top - control_top_delta_small

    MountyOptionsFrame_Together = CreateFrame("CheckButton", "MountyOptionsFrame_Together", MountyOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyOptionsFrame_Together:SetPoint("TOPLEFT", 16, top)
    MountyOptionsFrame_TogetherText:SetText(L["Stay together"])
    MountyOptionsFrame_Together:SetScript("OnClick", function(calling)
        TLV_Profile.Together = not TLV_Profile.Together
        calling:SetChecked(TLV_Profile.Together)
    end)

    -- TaxiMode checkbox

    top = top - control_top_delta_small

    MountyOptionsFrame_TaxiMode = CreateFrame("CheckButton", "MountyOptionsFrame_TaxiMode", MountyOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyOptionsFrame_TaxiMode:SetPoint("TOPLEFT", 16, top)
    MountyOptionsFrame_TaxiModeText:SetText(L["Taxi mode"])
    MountyOptionsFrame_TaxiMode:SetScript("OnClick", function(calling)
        TLV_Profile.TaxiMode = not TLV_Profile.TaxiMode
        calling:SetChecked(TLV_Profile.TaxiMode)
    end)

    -- Taxi!

    top = top - control_top_delta - 10

    MountyOptionsFrame_Hello = CreateFrame("EditBox", "MountyOptionsFrame_Hello", MountyOptionsFrame, "InputBoxTemplate")
    MountyOptionsFrame_Hello:SetWidth(335)
    MountyOptionsFrame_Hello:SetHeight(16)
    MountyOptionsFrame_Hello:SetPoint("TOPLEFT", 25, top)
    MountyOptionsFrame_Hello:SetAutoFocus(false)
    MountyOptionsFrame_Hello:CreateFontString("MountyOptionsFrame_HelloLabel", "BACKGROUND", "GameFontNormalSmall")
    MountyOptionsFrame_HelloLabel:SetPoint("BOTTOMLEFT", MountyOptionsFrame_Hello, "TOPLEFT", 0, 4)
    MountyOptionsFrame_HelloLabel:SetText(L["Hello"])
    MountyOptionsFrame_Hello:SetScript("OnEnterPressed", function(calling)
        TLV_Profile.Hello = calling:GetText()
        calling:ClearFocus()
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
        MountyOptionsFrame_DurabilityMinText:SetFormattedText(L["Summon if durability"], math.floor(value + 0.5))
        TLV_Profile.DurabilityMin = math.floor(value + 0.5)
    end)

    -- Mounts

    for t = 1, MountyTypes do

        MountyOptionsFrame_Buttons[t] = {}

        top = top - control_top_delta

        temp = MountyOptionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
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

    temp = MountyOptionsFrame:CreateFontString(nil, "BACKGROUND", "GameFontNormalSmall")
    temp:SetPoint("TOPLEFT", 90, top - 3)
    temp:SetText(L["Helptext"])

    -- AutoOpen checkbox

    top = top - control_top_delta_small

    MountyOptionsFrame_AutoOpen = CreateFrame("CheckButton", "MountyOptionsFrame_AutoOpen", MountyOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyOptionsFrame_AutoOpen:SetPoint("TOPLEFT", 16, top)
    MountyOptionsFrame_AutoOpenText:SetText(L["Auto open"])
    MountyOptionsFrame_AutoOpen:SetScript("OnClick", function(calling)
        TLV.AutoOpen = not TLV.AutoOpen
        calling:SetChecked(TLV.AutoOpen)
    end)

    -- DebugMode checkbox

    top = top - control_top_delta_small

    MountyOptionsFrame_DebugMode = CreateFrame("CheckButton", "MountyOptionsFrame_DebugMode", MountyOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyOptionsFrame_DebugMode:SetPoint("TOPLEFT", 16, top)
    MountyOptionsFrame_DebugModeText:SetText(L["Debug mode"])
    MountyOptionsFrame_DebugMode:SetScript("OnClick", function(calling)
        TLV.DebugMode = not TLV.DebugMode
        calling:SetChecked(TLV.DebugMode)
    end)

    -- No Idea what for ..?

    -- MountyOptionsFrame.name = "Mounty"
end

function Mounty:OptionsRender()

    MountyOptionsFrame_Random:SetChecked(TLV_Profile.Random)
    MountyOptionsFrame_Together:SetChecked(TLV_Profile.Together)
    MountyOptionsFrame_ShowOff:SetChecked(TLV_Profile.ShowOff)
    MountyOptionsFrame_TaxiMode:SetChecked(TLV_Profile.TaxiMode)
    MountyOptionsFrame_Hello:SetText(TLV_Profile.Hello)
    MountyOptionsFrame_DurabilityMin:SetValue(TLV_Profile.DurabilityMin)

    MountyOptionsFrame_DebugMode:SetChecked(TLV.DebugMode)
    MountyOptionsFrame_AutoOpen:SetChecked(TLV.AutoOpen)

    Mounty:OptionsRenderButtons()
end

function Mounty:OptionsRenderButtons()

    local icon

    for t = 1, MountyTypes do

        for i = 1, MountyMounts do

            MountyOptionsFrame_Buttons[t][i]:Hide() -- Muss sein, sonst werden die nicht immer neu gezeichnet ?!

            if TLV_Profile.Mounts[t][i] == 0 then
                MountyOptionsFrame_Buttons[t][i]:SetNormalTexture("")
                MountyOptionsFrame_Buttons[t][i]:Disable()
            else
                icon = GetSpellTexture(TLV_Profile.Mounts[t][i])
                MountyOptionsFrame_Buttons[t][i]:SetNormalTexture(icon)
                MountyOptionsFrame_Buttons[t][i]:Enable()
            end

            MountyOptionsFrame_Buttons[t][i]:Show() -- Muss sein, sonst werden die nicht immer neu gezeichnet ?!
        end
    end
end

function Mounty:AddJournalButton()

    local temp = CreateFrame("Button", nil, MountJournal)
    temp:SetFrameStrata("MEDIUM")
    temp:SetPoint("BOTTOMRIGHT", -6, 5)
    temp:SetSize(128, 21)
    temp:SetNormalFontObject(GameFontNormal)
    temp:SetHighlightFontObject(GameFontHighlight)
    temp:SetNormalTexture(130763) -- "Interface\\Buttons\\UI-DialogBox-Button-Up"
    temp:GetNormalTexture():SetTexCoord(0.0, 1.0, 0.0, 0.71875)
    temp:SetPushedTexture(130761) -- "Interface\\Buttons\\UI-DialogBox-Button-Down"
    temp:GetPushedTexture():SetTexCoord(0.0, 1.0, 0.0, 0.71875)
    temp:SetHighlightTexture(130762) -- "Interface\\Buttons\\UI-DialogBox-Button-Highlight"
    temp:GetHighlightTexture():SetTexCoord(0.0, 1.0, 0.0, 0.71875)
    temp:SetText(L["Open Mounty"])
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

function Mounty:DeleteProfile(p)

    if (p > 1) then
        TLV.Profiles[p] = nil
        Mounty:Chat(string.format(L["Deleted profile"], p))
        Mounty:SwitchProfile(1, 0)
    end

end

function Mounty:SwitchProfile(p, pfrom)

    if (pfrom > 0) then

        if TLV.Profiles[pfrom] == nil then

            Mounty:Chat(string.format(L["Empty profile"], pfrom))

        else

            TLV.Profiles[p] = deepTableCopy(TLV.Profiles[pfrom])

            Mounty:Chat(string.format(L["Copied profile"], p, pfrom))

        end
    end

    Mounty:SelectProfile(p)
    Mounty:OptionsRender()

    Mounty:Chat(string.format(L["Switched profile"], p))

end

function Mounty:SelectProfile(p)

    if TLV.Profiles[p] == nil then
        TLV.Profiles[p] = {}
    end

    if TLV.Profiles[p].DebugMode == nil then
        TLV.Profiles[p].DebugMode = false
    end

    if TLV.Profiles[p].AutoOpen == nil then
        TLV.Profiles[p].AutoOpen = true
    end

    if TLV.Profiles[p].TaxiMode == nil then
        TLV.Profiles[p].TaxiMode = false
    end

    if TLV.Profiles[p].DoNotFly == nil then
        TLV.Profiles[p].DoNotFly = false
    end

    if TLV.Profiles[p].Together == nil then
        TLV.Profiles[p].Together = TLV.Profiles[p].DoNotFly -- renamed
    end

    if TLV.Profiles[p].DoNotShowOff == nil then
        TLV.Profiles[p].DoNotShowOff = false
    end

    if TLV.Profiles[p].ShowOff == nil then
        TLV.Profiles[p].ShowOff = not TLV.Profiles[p].DoNotShowOff
    end

    if TLV.Profiles[p].Random == nil then
        TLV.Profiles[p].Random = false
    end

    if TLV.Profiles[p].DurabilityMin == nil then
        TLV.Profiles[p].DurabilityMin = 75
    end

    if TLV.Profiles[p].Hello == nil then
        TLV.Profiles[p].Hello = L["Taxi!"]
    end

    if TLV.Profiles[p].Mounts == nil then
        TLV.Profiles[p].Mounts = {}
    end

    if TLV.Profiles[p].Iterator == nil then
        TLV.Profiles[p].Iterator = {}
    end

    for t = 1, MountyTypes do

        if TLV.Profiles[p].Iterator[t] == nil then
            TLV.Profiles[p].Iterator[t] = 0
        end

        if TLV.Profiles[p].Mounts[t] == nil then
            TLV.Profiles[p].Mounts[t] = {}
        end

        for i = 1, MountyMounts do
            if TLV.Profiles[p].Mounts[t][i] == nil then
                TLV.Profiles[p].Mounts[t][i] = 0
            end
        end
    end

    TLV_Profile = TLV.Profiles[p];

    TLV.SelectedProfile = p

end

function Mounty:Init()

    AddOnTitle = GetAddOnMetadata(MountyAddOnName, "Title")
    AddOnVersion = GetAddOnMetadata(MountyAddOnName, "Version")

    Mounty:Upgrade()

    if TLV.SelectedProfile == nil then
        TLV.SelectedProfile = 1
    end

    if TLV.Profiles == nil then
        TLV.Profiles = {}
    end

    if TLV.DebugMode == nil then
        TLV.DebugMode = false
    end

    if TLV.AutoOpen == nil then
        TLV.AutoOpen = true
    end

    Mounty:SelectProfile(TLV.SelectedProfile)

    -- show quick start?

    if TLV.QuickStart == nil then
        TLV.QuickStart = true
    else
        TLV.QuickStart = true
        for t = 1, MountyTypes do
            if TLV_Profile.Mounts[t][1] ~= 0 then
                TLV.QuickStart = false
            end
        end
    end

    --

    Mounty:InitOptionsFrame()

end

function Mounty:Upgrade()

    -- New category Dragonflight

    if MountyData ~= nil then

        if (MountyData.UpgradeToDragonflight == nil) then
            MountyData.UpgradeToDragonflight = true
            for t = MountyTypes, 4, -1 do
                for i = 1, MountyMounts do
                    TLV_Profile.Mounts[t][i] = TLV.Profiles[p].Mounts[t - 1][i]
                    TLV_Profile.Mounts[t - 1][i] = 0
                end
            end
        end

    end

    -- MountyProfiles

    if TLV.Profiles == nil then

        TLV.Profiles = {}

        if MountyData ~= nil then

            TLV.Profiles[1] = {}

            TLV.Profiles[1].DurabilityMin = MountyData.DurabilityMin
            TLV.Profiles[1].Hello = MountyData.Hello
            TLV.Profiles[1].Iterator = MountyData.Iterator
            TLV.Profiles[1].Mounts = MountyData.Mounts
            TLV.Profiles[1].Random = MountyData.Random
            TLV.Profiles[1].ShowOff = MountyData.ShowOff
            TLV.Profiles[1].TaxiMode = MountyData.TaxiMode
            TLV.Profiles[1].Together = MountyData.Together

            TLV.DebugMode = MountyData.DebugMode
            TLV.AutoOpen = MountyData.AutoOpen

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
    if TLV.AutoOpen then
        MountyOptionsFrame:ClearAllPoints()
        MountyOptionsFrame:SetPoint("TOPLEFT", CollectionsJournal, "TOPRIGHT", 0, 0)
        MountyOptionsFrame:Show()
    end
end, MountyAddOnName)

EventRegistry:RegisterCallback("MountJournal.OnHide", function()
    if TLV.AutoOpen then
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

        local p1 = math.floor(tonumber(arg1) or 0)
        local p2 = math.floor(tonumber(arg2) or 0)

        if arg1 == "" then
            Mounty:Chat(string.format(L["Current profile"], TLV.SelectedProfile))
        elseif p1 > 0 and arg2 == "-" then
            Mounty:DeleteProfile(p1)
        elseif p1 > 0 then
            Mounty:SwitchProfile(p1, p2)
        else
            Mounty:Chat(L["Profile number error"])
        end

    elseif mode == "version" then

        Mounty:Chat("<-- ;)")

    elseif mode == "debug" then

        if arg1 == "on" then

            TLV.DebugMode = true
            Mounty:Chat(L["Debug: "] .. "|cff00f000" .. L["on"] .. "|r.")

        elseif arg1 == "off" then

            TLV.DebugMode = false
            Mounty:Chat(L["Debug: "] .. "|cfff00000" .. L["off"] .. "|r.")
        end

    elseif mode == "auto" then

        if arg1 == "on" then

            TLV.AutoOpen = true
            Mounty:Chat(L["Auto open & close: "] .. "|cff00f000" .. L["on"] .. "|r.")

        elseif arg1 == "off" then

            TLV.AutoOpen = false
            Mounty:Chat(L["Auto open & close: "] .. "|cfff00000" .. L["off"] .. "|r.")
        end

    elseif mode == "together" then

        if arg1 == "on" then

            TLV_Profile.Together = true
            Mounty:Chat(L["Together mode: "] .. "|cff00f000" .. L["on"] .. "|r.")

        elseif arg1 == "off" then

            TLV_Profile.Together = false
            Mounty:Chat(L["Together mode: "] .. "|cfff00000" .. L["off"] .. "|r.")

        end

    elseif mode == "showoff" then

        if arg1 == "on" then

            TLV_Profile.ShowOff = true
            Mounty:Chat(L["Show off mode: "] .. "|cff00f000" .. L["on"] .. "|r.")

        elseif arg1 == "off" then

            TLV_Profile.ShowOff = false
            Mounty:Chat(L["Show off mode: "] .. "|cfff00000" .. L["off"] .. "|r.")

        end

    elseif mode == "random" then

        if arg1 == "on" then

            TLV_Profile.Random = true
            Mounty:Chat(L["Random: "] .. "|cff00f000" .. L["on"] .. "|r.")

        elseif arg1 == "off" then

            TLV_Profile.Random = false
            Mounty:Chat(L["Random: "] .. "|cfff00000" .. L["off"] .. "|r.")

        end

    elseif mode == "taxi" then

        if arg1 == "on" then

            TLV_Profile.TaxiMode = true
            Mounty:Chat(L["Taxi mode: "] .. "|cff00f000" .. L["on"] .. "|r.")

        elseif arg1 == "off" then

            TLV_Profile.TaxiMode = false
            Mounty:Chat(L["taxi: "] .. "|cfff00000" .. L["off"] .. "|r.")

        end

    elseif mode ~= "" and mode ~= nil then

        Mounty:Mount(mode)

    else

        MountyOptionsFrame:Show();
    end
end
