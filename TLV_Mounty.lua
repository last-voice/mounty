local MountyAddOnName, Mounty = ...

MountyData = {}

-- debugging https://www.wowace.com/projects/rarity/pages/faq/how-to-enable-and-disable-script-errors-lua-errors

local Mounty = Mounty
local L = Mounty.L

local MountyOptionsFrame
local MountyOptionsFrame_DebugMode
local MountyOptionsFrame_AutoOpen
local MountyOptionsFrame_TaxiMode
local MountyOptionsFrame_DoNotFly
local MountyOptionsFrame_Random
local MountyOptionsFrame_DurabilityMin
local MountyOptionsFrame_Hello

local MountyOptionsFrame_Buttons = {}

local MountyGround = 1
local MountyFlying = 2
local MountyWater = 3
local MountyRepair = 4
local MountyTaxi = 5
local MountyShowOff = 6

local MountyTypes = 6
local MountyMounts = 10

local MountyTypesLabel = {
    [1] = L["mode.Ground"],
    [2] = L["mode.Flying"],
    [3] = L["mode.Water"],
    [4] = L["mode.Repair"],
    [5] = L["mode.Taxi"],
    [6] = L["mode.Show off"]
}

local MountyFallback = 0

local MountyDebugForce = false

function Mounty:Chat(msg)

    if DEFAULT_CHAT_FRAME then

        DEFAULT_CHAT_FRAME:AddMessage("|cffa0a0ffMounty|r: " .. msg, 1, 1, 0)
    end
end

function Mounty:Debug(msg)

    if (MountyData.DebugMode or MountyDebugForce) then
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

    if (MountyFallback == MountyGround) then

        Mounty:Debug("Fallback: '" .. L["mode.Random"] .. "'")
        return 0
    end

    if (MountyFallback == MountyFlying or typ == MountyFlying) then

        MountyFallback = MountyGround

        Mounty:Debug("Fallback: '" .. L["mode.Ground"] .. "'")
        return MountyGround
    end

    MountyFallback = MountyFlying

    Mounty:Debug("Fallback: '" .. L["mode.Flying"] .. "'")
    return MountyFlying
end

function Mounty:SelectMountByType(typ, onlyflyable)

    if (typ == 0) then return 0 end

    local ids = {}
    local count = 0
    local usable
    local picked

    for i = 1, MountyMounts do

        if (MountyData.Mounts[typ][i] > 0) then

            local mountID = C_MountJournal.GetMountFromSpell(MountyData.Mounts[typ][i])
            local mname, _, _, _, isUsable = C_MountJournal.GetMountInfoByID(mountID)

            if (onlyflyable) then
                --    if (mountcannotfly_cannot_be_checked_yet) then
                --        isUsable = false
                --    end
            end

            Mounty:Debug("Usable: " .. "[" .. mountID .. "] " .. mname .. " -> " .. tostring(isUsable))

            if (isUsable) then
                count = count + 1
                ids[count] = MountyData.Mounts[typ][i]
            end
        end
    end

    if (count > 0) then

        if MountyData.Random then
            picked = math.random(count)
        else
            if (MountyData.Iterator[typ] < count) then
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

    return Mounty:SelectMountByType(Mounty:Fallback(typ, false))
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

function Mounty:Mount(category)

    local mountID = 0
    local typ = MountyGround
    local spellID = 0
    local onlyflyable = false

    if (category == "fly") then

        typ = MountyFlying

    elseif (category == "water") then

        typ = MountyWater

    elseif (category == "repair") then

        typ = MountyRepair

    elseif (category == "taxi") then

        if not IsMounted() then
            if MountyData.Hello ~= "" then
                SendChatMessage(MountyData.Hello)
            end
        end

        typ = MountyTaxi

    elseif (category == "showoff") then

        typ = MountyShowOff

        if IsFlyableArea() then
            onlyflyable = true
        end


    elseif (category == "random") then

        typ = 0
    end

    Mounty:Debug("Category: " .. category)
    Mounty:Debug("Type: " .. typ)

    if (typ > 0) then

        spellID = Mounty:SelectMountByType(typ, onlyflyable)

        if (spellID > 0) then
            mountID = C_MountJournal.GetMountFromSpell(spellID)
        end
    end

    Mounty:Debug("mountID: " .. mountID)
    Mounty:Debug("spellID: " .. spellID)

    C_MountJournal.SummonByID(mountID)
end

function MountyKeyHandler(keypress)

    if (keypress == nil) then
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

        if (keypress == "magic") then return end
    end

    if keypress == "repair" or keypress == "random" or keypress == "showoff" or keypress == "water" or keypress == "taxi" then

        Mounty:Debug("Dedicated key")

        Mounty:Mount(keypress)

    else

        -- magic

        local resting = IsResting()
        local alone = not IsInGroup()
        local flyable = IsFlyableArea()
        local swimming = IsSwimming()
        local taximode = MountyData.TaxiMode
        local donotfly = MountyData.DoNotFly

        Mounty:Debug("Magic key")

        if (donotfly and not alone) then flyable = false end

        local category

        if (Mounty:Durability() < MountyData.DurabilityMin) then

            category = "repair"

        elseif (not alone and taximode) then

            category = "taxi"

        elseif (resting) then

            category = "showoff"

        elseif (flyable) then

            category = "fly"

        elseif (swimming) then

            category = "water"

        else

            category = "ground"
        end

        Mounty:Mount(category)
    end
end

local function MountySetMount(self, button)

    local typ = self.MountyTyp
    local index = self.MountyIndex

    if (button == "LeftButton") then

        while (index > 1 and MountyData.Mounts[typ][index - 1] == 0) do
            index = index - 1
        end

        local infoType, mountID = GetCursorInfo()

        if (infoType == "mount") then

            ClearCursor()

            local spellID = Mounty:MountSpellID(mountID)

            local already = false

            for i = 1, MountyMounts do
                if (MountyData.Mounts[typ][i] == spellID) then
                    already = true
                end
            end

            if (spellID == 0) then

                Mounty:Debug("Fail: spellID = 0 | " .. infoType .. " " .. typ .. " " .. mountID)

            elseif (already) then

                Mounty:Debug("Fail: Already | " .. infoType .. " " .. typ .. " " .. mountID .. " " .. spellID)

            else

                Mounty:Debug("Mount saved: " .. infoType .. " " .. typ .. " " .. index .. " " .. mountID .. " " .. spellID)
                MountyData.Mounts[typ][index] = spellID
                Mounty:OptionsRenderButtons()
            end
        end

    elseif (button == "RightButton") then

        Mounty:Debug("Mount removed: " .. typ .. " " .. index)

        for i = index, MountyMounts - 1 do
            MountyData.Mounts[typ][i] = MountyData.Mounts[typ][i + 1]
        end
        MountyData.Mounts[typ][MountyMounts] = 0

        Mounty:OptionsRenderButtons()
    end

    GameTooltip:Hide()
end

local function MountyTooltip(self, motion)

    local typ = self.MountyTyp
    local index = self.MountyIndex

    local spellID = MountyData.Mounts[typ][index]

    if (spellID) then

        local mountID = C_MountJournal.GetMountFromSpell(spellID)
        local name = C_MountJournal.GetMountInfoByID(mountID)

        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        GameTooltip:SetText(name)
        GameTooltip:Show()
    end
end

local function MountyInit(self, event)

    Mounty:InitOptionsFrame()



    --    MountyData = {
    --        ["MountGround"] = 0,
    --        ["DurabilityMin"] = 75,
    --        ["DoNotFly"] = false,
    --        ["DebugMode"] = false,
    --        ["MountWater"] = 0,
    --        ["Iterator"] = { 0, 1, 0, 0, 0, 0, },
    --        ["TaxiMode"] = false,
    --        ["Mounts"] = {
    --            { 36702, 48025, 260172, 332256, 0, 0, 0, 0, 0, 0, }, { 88990, 107845, 63956, 126508, 333021, 0, 0, 0, 0, 0, }, { 64731, 0, 0, 0, 0, 0, 0, 0, 0, 0, }, { 122708, 0, 0, 0, 0, 0, 0, 0, 0, 0, }, { 88990, 107845, 63956, 126508, 333021, 0, 0, 0, 0, 0, }, { 88990, 107845, 63956, 126508, 333021, 0, 0, 0, 0, 0, },
    --        },
    --        ["MountTaxi"] = 0,
    --        ["MountRepair"] = 0,
    --        ["MountShowOff"] = 0,
    --        ["MountFlying"] = 0,
    --        ["Hello"] = "Taxi!",
    --        ["Random"] = true,
    --        ["ArmoredMin"] = 75
    --    }

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
            if (MountyData.Mounts[t][i] == nil) then
                MountyData.Mounts[t][i] = 0
            end
        end
    end

    self:UnregisterEvent("ADDON_LOADED")
    self:SetScript("OnEvent", nil)

    MountyInit = nil
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
    MountyOptionsFrame:SetHeight(520)
    MountyOptionsFrame:SetPoint("CENTER")

    MountyOptionsFrame:SetFrameStrata("DIALOG")

    MountyOptionsFrame:EnableMouse(true)
    MountyOptionsFrame:SetMovable(true)
    MountyOptionsFrame:RegisterForDrag("LeftButton")
    MountyOptionsFrame:SetScript("OnDragStart", function(self, button)
        self:StartMoving()
    end)
    MountyOptionsFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)

    -- Title text

    temp = MountyOptionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    temp:SetPoint("TOP", 0, -4)
    temp:SetText(L["Options"])

    -- Random checkbox

    top = -40

    MountyOptionsFrame_Random = CreateFrame("CheckButton", "MountyOptionsFrame_Random", MountyOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyOptionsFrame_Random:SetPoint("TOPLEFT", 16, top)
    MountyOptionsFrame_RandomText:SetText(L["Random"])
    MountyOptionsFrame_Random:SetScript("OnClick", function(self)
        MountyData.Random = not MountyData.Random
        self:SetChecked(MountyData.Random)
    end)

    -- Open Mounts

    temp = CreateFrame("Button", "MountyOptionsFrame_OpenMounts", MountyOptionsFrame)
    temp:SetSize(32, 32)
    temp:SetNormalTexture("Interface\\Icons\\Ability_Mount_RidingHorse")
    temp:SetPoint("TOPRIGHT", -20, top)
    temp:SetScript("OnMouseUp", function(self)
        ToggleCollectionsJournal(1)
    end)

    -- DoNotFly checkbox

    top = top - control_top_delta_small

    MountyOptionsFrame_DoNotFly = CreateFrame("CheckButton", "MountyOptionsFrame_DoNotFly", MountyOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyOptionsFrame_DoNotFly:SetPoint("TOPLEFT", 16, top)
    MountyOptionsFrame_DoNotFlyText:SetText(L["Don't fly (except if taxi)"])
    MountyOptionsFrame_DoNotFly:SetScript("OnClick", function(self)
        MountyData.DoNotFly = not MountyData.DoNotFly
        self:SetChecked(MountyData.DoNotFly)
    end)

    -- TaxiMode checkbox

    top = top - control_top_delta_small

    MountyOptionsFrame_TaxiMode = CreateFrame("CheckButton", "MountyOptionsFrame_TaxiMode", MountyOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyOptionsFrame_TaxiMode:SetPoint("TOPLEFT", 16, top)
    MountyOptionsFrame_TaxiModeText:SetText(L["Taxi mode"])
    MountyOptionsFrame_TaxiMode:SetScript("OnClick", function(self)
        MountyData.TaxiMode = not MountyData.TaxiMode
        self:SetChecked(MountyData.TaxiMode)
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
    MountyOptionsFrame_Hello:SetScript("OnEnterPressed", function(self)
        MountyData.Hello = self:GetText()
        self:ClearFocus()
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
    MountyOptionsFrame_DurabilityMin:SetScript("OnValueChanged", function(self, value)
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
            MountyOptionsFrame_Buttons[t][i]:SetScript("OnMouseUp", MountySetMount)
            MountyOptionsFrame_Buttons[t][i]:SetScript("OnEnter", MountyTooltip)
            MountyOptionsFrame_Buttons[t][i]:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)
        end
    end

    -- Helptext

    top = top - control_top_delta + 8

    temp = MountyOptionsFrame:CreateFontString(nil, "BACKGROUND", "GameFontNormalSmall")
    temp:SetPoint("TOPLEFT", 112, top - 3)
    temp:SetText(L["Helptext"])

    -- AutoOpen checkbox

    top = top - control_top_delta_small

    MountyOptionsFrame_AutoOpen = CreateFrame("CheckButton", "MountyOptionsFrame_AutoOpen", MountyOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyOptionsFrame_AutoOpen:SetPoint("TOPLEFT", 16, top)
    MountyOptionsFrame_AutoOpenText:SetText(L["Auto open"])
    MountyOptionsFrame_AutoOpen:SetScript("OnClick", function(self)
        MountyData.AutoOpen = not MountyData.AutoOpen
        self:SetChecked(MountyData.AutoOpen)
    end)

    -- DebugMode checkbox

    top = top - control_top_delta_small

    MountyOptionsFrame_DebugMode = CreateFrame("CheckButton", "MountyOptionsFrame_DebugMode", MountyOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyOptionsFrame_DebugMode:SetPoint("TOPLEFT", 16, top)
    MountyOptionsFrame_DebugModeText:SetText(L["Debug mode"])
    MountyOptionsFrame_DebugMode:SetScript("OnClick", function(self)
        MountyData.DebugMode = not MountyData.DebugMode
        self:SetChecked(MountyData.DebugMode)
    end)

    -- No Idea what for ..?

    -- MountyOptionsFrame.name = "Mounty"
end

local function MountyOptionsRender()

    MountyOptionsFrame_Random:SetChecked(MountyData.Random)
    MountyOptionsFrame_DoNotFly:SetChecked(MountyData.DoNotFly)
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

            if (MountyData.Mounts[t][i] == 0) then
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
    temp:SetFrameStrata("DIALOG")
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
    temp:SetScript("OnMouseUp", function(self)
        if (MountyOptionsFrame:IsVisible()) then
            MountyOptionsFrame:Hide()
        else
            MountyOptionsFrame:ClearAllPoints()
            MountyOptionsFrame:SetPoint("TOPLEFT", CollectionsJournal, "TOPRIGHT", 0, 0)
            MountyOptionsFrame:Show()
        end
    end)
end

MountyOptionsFrame = CreateFrame("Frame", "MountyOptionsFrame", UIParent, "BasicFrameTemplate")

MountyOptionsFrame:RegisterEvent("ADDON_LOADED")
MountyOptionsFrame:SetScript("OnEvent", MountyInit)
MountyOptionsFrame:SetScript("OnShow", MountyOptionsRender)

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

BINDING_NAME_MOUNTY_MAGIC = L["Summon magic mount"]
BINDING_NAME_MOUNTY_WATER = L["Summon water mount"]
BINDING_NAME_MOUNTY_TAXI = L["Summon taxi mount"]
BINDING_NAME_MOUNTY_REPAIR = L["Summon repair mount"]
BINDING_NAME_MOUNTY_SHOWOFF = L["Summon show off mount"]
BINDING_NAME_MOUNTY_RANDOM = L["Summon random mount"]
BINDING_NAME_MOUNTY_DISMOUNT = L["Force dismount"]

-- /mounty

SLASH_MOUNTY1 = "/mounty"
SlashCmdList["MOUNTY"] = function(message)

    if message == "magic" then

        MountyKeyHandler()

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

    elseif message == "fly on" then

        MountyData.DoNotFly = false
        Mounty:Chat(L["fly mode: "] .. "|cff00f000" .. L["on"] .. "|r.")

    elseif message == "fly off" then

        MountyData.DoNotFly = true
        Mounty:Chat(L["fly mode: "] .. "|cfff00000" .. L["off"] .. "|r.")

    elseif message == "random on" then

        MountyData.Random = false
        Mounty:Chat(L["random: "] .. "|cff00f000" .. L["on"] .. "|r.")

    elseif message == "random off" then

        MountyData.Random = true
        Mounty:Chat(L["random: "] .. "|cfff00000" .. L["off"] .. "|r.")

    elseif message == "taxi on" then

        MountyData.TaxiMode = true
        Mounty:Chat(L["taxi: "] .. "|cff00f000" .. L["on"] .. "|r.")

    elseif message == "taxi off" then

        MountyData.TaxiMode = false
        Mounty:Chat(L["taxi: "] .. "|cfff00000" .. L["off"] .. "|r.")

    elseif message ~= "" and message ~= nil then

        Mounty:Mount(message)

    else

        MountyOptionsFrame:Show();
    end
end
