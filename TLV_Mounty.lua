local MountyAddOnName, Mounty = ...

MountyData = {}

-- debugging https://www.wowace.com/projects/rarity/pages/faq/how-to-enable-and-disable-script-errors-lua-errors

local Mounty = Mounty
local L = Mounty.L

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

local MountyDebugForce = false

function Mounty:Chat(msg)

    if DEFAULT_CHAT_FRAME then

        DEFAULT_CHAT_FRAME:AddMessage("|cffa0a0ffMounty|r: " .. msg, 1, 1, 0)
    end
end

function Mounty:Debug(msg)

    if MountyData.DebugMode or MountyDebugForce then
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

    if typ == 0 then return 0 end

    local ids = {}
    local count = 0
    local usable
    local picked

    for i = 1, MountyMounts do

        if MountyData.Mounts[typ][i] > 0 then

            local mountID = C_MountJournal.GetMountFromSpell(MountyData.Mounts[typ][i])
            local mname, _, _, _, isUsable = C_MountJournal.GetMountInfoByID(mountID)

            if only_flyable_showoffs then
                local _, _, _, _, mountTypeID = C_MountJournal.GetMountInfoExtraByID(mountID)

                if mountTypeID ~= 248 then -- 248 = mostly flyable
                    isUsable = false
                end
            end

            Mounty:Debug("Usable: " .. "[" .. mountID .. "] " .. mname .. " -> " .. tostring(isUsable))

            if isUsable then
                count = count + 1
                ids[count] = MountyData.Mounts[typ][i]
            end
        end
    end

    if count > 0 then

        if MountyData.Random then
            picked = math.random(count)
        else
            if MountyData.Iterator[typ] < count then
                MountyData.Iterator[typ] = MountyData.Iterator[typ] + 1
            else
                MountyData.Iterator[typ] = 1
            end
            picked = MountyData.Iterator[typ]
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

    return Mounty:IsInDragonflight() and C_Spell.DoesSpellExist(376777) -- dragon riding has been learned
    -- return Mounty:IsInDragonflight() and IsPlayerSpell(376777) -- dragon riding has been learned
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
            if MountyData.Hello ~= "" then
                SendChatMessage(MountyData.Hello)
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

        if keypress == "magic" then return end
    end

    if keypress == "ground" or keypress == "repair" or keypress == "random" or keypress == "showoff" or keypress == "water" or keypress == "taxi" then

        Mounty:Debug("Dedicated key")

        Mounty:Mount(keypress)

    else

        -- magic

        local resting = IsResting()
        local dragonflight = Mounty:UserCanDragonflyHere()
        local alone = not IsInGroup()
        local flyable = Mounty:UserCanFlyHere()
        local swimming = IsSwimming()
        local taximode = MountyData.TaxiMode
        local together = MountyData.Together
        local showoff = MountyData.ShowOff

        Mounty:Debug("Magic key")

        if together and not alone then flyable = false end

        local category

        if Mounty:Durability() < MountyData.DurabilityMin then

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
            if MountyData.Mounts[typ][i] == spellID then
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
            while (index > 1 and MountyData.Mounts[typ][index - 1] == 0) do
                index = index - 1
            end

            Mounty:Debug("Mount saved: " .. infoType .. " " .. typ .. " " .. index .. " " .. mountID .. " " .. spellID)
            MountyData.Mounts[typ][index] = spellID
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
        MountyData.Mounts[typ][i] = MountyData.Mounts[typ][i + 1]
    end
    MountyData.Mounts[typ][MountyMounts] = 0

    Mounty:OptionsRenderButtons()

    GameTooltip:Hide()
end

function Mounty:Tooltip(calling)

    local typ = calling.MountyTyp
    local index = calling.MountyIndex

    local spellID = MountyData.Mounts[typ][index]

    if spellID then
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        GameTooltip:SetHyperlink("spell:" .. spellID)
        GameTooltip:Show()
    end
end

function Mounty:InitOptionsFrame()

    local top
    local temp
    local spellID
    local infoType
    local mountID
    local icon

    local control_top_delta = 40
    local control_top_delta_small = 20

    -- Mounty options

    MountyOptionsFrame:Hide()
    MountyOptionsFrame:SetWidth(480)
    MountyOptionsFrame:SetHeight(580)
    MountyOptionsFrame:SetPoint("CENTER")

    MountyOptionsFrame:SetFrameStrata("HIGH")
    MountyOptionsFrame.Bg:SetFrameStrata ("MEDIUM")

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

    temp = MountyOptionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    temp:SetPoint("TOP", 0, -4)
    temp:SetText(L["Options"])

    -- Quickstart

    MountyOptionsFrame_QuickStart = CreateFrame("Frame", nil, MountyOptionsFrame, "SettingsFrameTemplate")
    MountyOptionsFrame_QuickStart:SetWidth(480)
    MountyOptionsFrame_QuickStart:SetHeight(90)
    MountyOptionsFrame_QuickStart:SetPoint("BOTTOM", 0, -90)
    MountyOptionsFrame_QuickStart:SetFrameStrata("HIGH")
    MountyOptionsFrame_QuickStart.Bg:SetFrameStrata ("MEDIUM")

    temp = MountyOptionsFrame_QuickStart:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    temp:SetPoint("TOP", 0, -4)
    temp:SetText(L["Quick start"])

    temp = MountyOptionsFrame_QuickStart:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    temp:SetPoint("TOPLEFT", 32, -32)
    temp:SetJustifyH("LEFT")
    temp:SetText(L["Quick start full"])

    if (not MountyData.QuickStart) then
        MountyOptionsFrame_QuickStart:Hide()
    end

    -- Random checkbox

    top = -40

    MountyOptionsFrame_Random = CreateFrame("CheckButton", "MountyOptionsFrame_Random", MountyOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyOptionsFrame_Random:SetPoint("TOPLEFT", 16, top)
    MountyOptionsFrame_RandomText:SetText(L["Random"])
    MountyOptionsFrame_Random:SetScript("OnClick", function(calling)
        MountyData.Random = not MountyData.Random
        calling:SetChecked(MountyData.Random)
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
        MountyData.ShowOff = not MountyData.ShowOff
        calling:SetChecked(MountyData.ShowOff)
    end)

    -- Together checkbox

    top = top - control_top_delta_small

    MountyOptionsFrame_Together = CreateFrame("CheckButton", "MountyOptionsFrame_Together", MountyOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyOptionsFrame_Together:SetPoint("TOPLEFT", 16, top)
    MountyOptionsFrame_TogetherText:SetText(L["Stay together"])
    MountyOptionsFrame_Together:SetScript("OnClick", function(calling)
        MountyData.Together = not MountyData.Together
        calling:SetChecked(MountyData.Together)
    end)

    -- TaxiMode checkbox

    top = top - control_top_delta_small

    MountyOptionsFrame_TaxiMode = CreateFrame("CheckButton", "MountyOptionsFrame_TaxiMode", MountyOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyOptionsFrame_TaxiMode:SetPoint("TOPLEFT", 16, top)
    MountyOptionsFrame_TaxiModeText:SetText(L["Taxi mode"])
    MountyOptionsFrame_TaxiMode:SetScript("OnClick", function(calling)
        MountyData.TaxiMode = not MountyData.TaxiMode
        calling:SetChecked(MountyData.TaxiMode)
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
    MountyOptionsFrame_HelloLabel:SetText(L["How to call a passenger"])
    MountyOptionsFrame_Hello:SetScript("OnEnterPressed", function(calling)
        MountyData.Hello = calling:GetText()
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
        MountyOptionsFrame_DurabilityMinText:SetFormattedText(L["Summon repair mount if durability is less than %d%%."], math.floor(value + 0.5))
        MountyData.DurabilityMin = math.floor(value + 0.5)
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
        MountyData.AutoOpen = not MountyData.AutoOpen
        calling:SetChecked(MountyData.AutoOpen)
    end)

    -- DebugMode checkbox

    top = top - control_top_delta_small

    MountyOptionsFrame_DebugMode = CreateFrame("CheckButton", "MountyOptionsFrame_DebugMode", MountyOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyOptionsFrame_DebugMode:SetPoint("TOPLEFT", 16, top)
    MountyOptionsFrame_DebugModeText:SetText(L["Debug mode"])
    MountyOptionsFrame_DebugMode:SetScript("OnClick", function(calling)
        MountyData.DebugMode = not MountyData.DebugMode
        calling:SetChecked(MountyData.DebugMode)
    end)

    -- No Idea what for ..?

    -- MountyOptionsFrame.name = "Mounty"
end

function Mounty:OptionsRender()

    MountyOptionsFrame_Random:SetChecked(MountyData.Random)
    MountyOptionsFrame_Together:SetChecked(MountyData.Together)
    MountyOptionsFrame_ShowOff:SetChecked(MountyData.ShowOff)
    MountyOptionsFrame_TaxiMode:SetChecked(MountyData.TaxiMode)
    MountyOptionsFrame_Hello:SetText(MountyData.Hello)
    MountyOptionsFrame_DurabilityMin:SetValue(MountyData.DurabilityMin)
    MountyOptionsFrame_DebugMode:SetChecked(MountyData.DebugMode)
    MountyOptionsFrame_AutoOpen:SetChecked(MountyData.AutoOpen)

    Mounty:OptionsRenderButtons()
end

function Mounty:OptionsRenderButtons()

    local spellID
    local icon

    for t = 1, MountyTypes do

        for i = 1, MountyMounts do

            MountyOptionsFrame_Buttons[t][i]:Hide() -- Muss sein, sonst werden die nicht immer neu gezeichnet ?!

            if MountyData.Mounts[t][i] == 0 then
                MountyOptionsFrame_Buttons[t][i]:SetNormalTexture("")
                MountyOptionsFrame_Buttons[t][i]:Disable()
            else
                icon = GetSpellTexture(MountyData.Mounts[t][i])
                MountyOptionsFrame_Buttons[t][i]:SetNormalTexture(icon)
                MountyOptionsFrame_Buttons[t][i]:Enable()
            end

            MountyOptionsFrame_Buttons[t][i]:Show() -- Muss sein, sonst werden die nicht immer neu gezeichnet ?!
        end
    end
end

function Mounty:AddJournalButton()

    local temp = CreateFrame("Button", nil, MountJournal)
    temp:SetFrameStrata("HIGH")
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
    temp:SetScript("OnMouseUp", function(calling)
        if MountyOptionsFrame:IsVisible() then
            MountyOptionsFrame:Hide()
        else
            MountyOptionsFrame:ClearAllPoints()
            MountyOptionsFrame:SetPoint("TOPLEFT", CollectionsJournal, "TOPRIGHT", 0, 0)
            MountyOptionsFrame:Show()
        end
    end)
end

function Mounty.Init(calling, event)

    if MountyData.DebugMode == nil then
        MountyData.DebugMode = false
    end

    if MountyData.AutoOpen == nil then
        MountyData.AutoOpen = true
    end

    if MountyData.TaxiMode == nil then
        MountyData.TaxiMode = false
    end

    if MountyData.DoNotFly == nil then
        MountyData.DoNotFly = false
    end

    if MountyData.Together == nil then
        MountyData.Together = MountyData.DoNotFly -- renamed
    end

    if MountyData.DoNotShowOff == nil then
        MountyData.DoNotShowOff = false
    end

    if MountyData.ShowOff == nil then
        MountyData.ShowOff = not MountyData.DoNotShowOff
    end

    if MountyData.Random == nil then
        MountyData.Random = false
    end

    if MountyData.DurabilityMin == nil then
        MountyData.DurabilityMin = 75
    end

    if MountyData.Hello == nil then
        MountyData.Hello = L["Taxi!"]
    end

    if MountyData.Mounts == nil then
        MountyData.Mounts = {}
    end

    if MountyData.Iterator == nil then
        MountyData.Iterator = {}
    end

    for t = 1, MountyTypes do

        if MountyData.Iterator[t] == nil then
            MountyData.Iterator[t] = 0
        end

        if MountyData.Mounts[t] == nil then
            MountyData.Mounts[t] = {}
        end

        for i = 1, MountyMounts do
            if MountyData.Mounts[t][i] == nil then
                MountyData.Mounts[t][i] = 0
            end
        end
    end

    if (MountyData.UpgradeToDragonflight == nil) then
        MountyData.UpgradeToDragonflight = true
        for t = MountyTypes, 4, -1 do
            for i = 1, MountyMounts do
                MountyData.Mounts[t][i] = MountyData.Mounts[t - 1][i]
                MountyData.Mounts[t - 1][i] = 0
            end
        end
    end

    if MountyData.QuickStart == nil then
        MountyData.QuickStart = true
    else
        MountyData.QuickStart = true
        for t = 1, MountyTypes do
            if MountyData.Mounts[t][1] ~= 0 then
                MountyData.QuickStart = false
            end
        end
    end

    Mounty:InitOptionsFrame()

    calling:UnregisterEvent("ADDON_LOADED")
    calling:SetScript("OnEvent", nil)
end

function MountyKeyHandler(keypress)
    Mounty:KeyHandler(keypress)
end

MountyOptionsFrame = CreateFrame("Frame", "MountyOptionsFrame", UIParent, "SettingsFrameTemplate")

MountyOptionsFrame:RegisterEvent("ADDON_LOADED")
MountyOptionsFrame:SetScript("OnEvent", Mounty.Init)
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
    if MountyData.AutoOpen then
        MountyOptionsFrame:ClearAllPoints()
        MountyOptionsFrame:SetPoint("TOPLEFT", CollectionsJournal, "TOPRIGHT", 0, 0)
        MountyOptionsFrame:Show()
    end
end, MountyAddOnName)

EventRegistry:RegisterCallback("MountJournal.OnHide", function()
    if MountyData.AutoOpen then
        MountyOptionsFrame:Hide()
    end
end, MountyAddOnName)

-- /mounty

SLASH_MOUNTY1 = "/mounty"
SlashCmdList["MOUNTY"] = function(message)

    if message == "magic" then

        Mounty:KeyHandler()

    elseif message == "debug on" then

        MountyData.DebugMode = true
        Mounty:Chat(L["Debug: "] .. "|cff00f000" .. L["on"] .. "|r.")

    elseif message == "debug off" then

        MountyData.DebugMode = false
        Mounty:Chat(L["Debug: "] .. "|cfff00000" .. L["off"] .. "|r.")

    elseif message == "auto on" then

        MountyData.AutoOpen = true
        Mounty:Chat(L["Auto open & close: "] .. "|cff00f000" .. L["on"] .. "|r.")

    elseif message == "auto off" then

        MountyData.AutoOpen = false
        Mounty:Chat(L["Auto open & close: "] .. "|cfff00000" .. L["off"] .. "|r.")

    elseif message == "together on" then

        MountyData.Together = true
        Mounty:Chat(L["Together mode: "] .. "|cff00f000" .. L["on"] .. "|r.")

    elseif message == "together off" then

        MountyData.Together = false
        Mounty:Chat(L["Together mode: "] .. "|cfff00000" .. L["off"] .. "|r.")

    elseif message == "showoff on" then

        MountyData.ShowOff = true
        Mounty:Chat(L["Show off mode: "] .. "|cff00f000" .. L["on"] .. "|r.")

    elseif message == "showoff off" then

        MountyData.ShowOff = false
        Mounty:Chat(L["Show off mode: "] .. "|cfff00000" .. L["off"] .. "|r.")

    elseif message == "random on" then

        MountyData.Random = true
        Mounty:Chat(L["Random: "] .. "|cff00f000" .. L["on"] .. "|r.")

    elseif message == "random off" then

        MountyData.Random = false
        Mounty:Chat(L["Random: "] .. "|cfff00000" .. L["off"] .. "|r.")

    elseif message == "taxi on" then

        MountyData.TaxiMode = true
        Mounty:Chat(L["Taxi mode: "] .. "|cff00f000" .. L["on"] .. "|r.")

    elseif message == "taxi off" then

        MountyData.TaxiMode = false
        Mounty:Chat(L["taxi: "] .. "|cfff00000" .. L["off"] .. "|r.")

    elseif message ~= "" and message ~= nil then

        Mounty:Mount(message)

    else

        MountyOptionsFrame:Show();
    end
end
