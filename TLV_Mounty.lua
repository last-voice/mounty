local _, Mounty = ...

MountyData = {}

-- debugging https://www.wowace.com/projects/rarity/pages/faq/how-to-enable-and-disable-script-errors-lua-errors

local Mounty = Mounty
local L = Mounty.L

local MountyOptionsFrame = nil
local MountyOptionsFrame_DebugMode = nil
local MountyOptionsFrame_TaxiMode = nil
local MountyOptionsFrame_DoNotFly = nil
local MountyOptionsFrame_Random = nil
local MountyOptionsFrame_ArmoredMin = nil
local MountyOptionsFrame_Hello = nil

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
    [1] = L["Ground"],
    [2] = L["Flying"],
    [3] = L["Water"],
    [4] = L["Repair"],
    [5] = L["Taxi"],
    [6] = L["Show off"]
}

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

function Mounty:Armored()

    local curTotal = 0
    local maxTotal = 0

    for slot = 1, 20 do
        local curSlot, maxSlot = GetInventoryItemDurability(slot)
        if maxSlot then
            curTotal = curTotal + curSlot
            maxTotal = maxTotal + maxSlot
        end
    end

    local armored = 100 * curTotal / maxTotal

    Mounty:Debug(L["Armor is at"] .. " |cffa0a0ff" .. armored .. "%|r.")

    return armored
end

function Mounty:Fallback(typ)
end

function Mounty:Select(typ)

    local ids = {}
    local count = 0
    local usable
    local picked

    -- try MountyDataGlobal = MountyData

    for i = 1, MountyMounts do

        if (MountyData.Mounts[typ][i] > 0) then

            local mountID = C_MountJournal.GetMountFromSpell(MountyData.Mounts[typ][i])
            local mname, _, _, _, isUsable = C_MountJournal.GetMountInfoByID(mountID)

            Mounty:Debug(L["is usable: "] .. mname .. " -> " .. tostring(isUsable))

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

        Mounty:Debug(L["selected "] .. " " .. picked .. " / " .. count)

        return ids[picked]
    end

    Mounty:Debug(L["random not found!"])
    return 0
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

    if (category == "fly") then

        typ = MountyFlying

    elseif (category == "water") then

        typ = MountyWater

    elseif (category == "repair") then

        typ = MountyRepair

    elseif (category == "taxi") then

        if not IsMounted() then
            SendChatMessage(MountyData.Hello)
        end

        typ = MountyTaxi

    elseif (category == "showoff") then

        typ = MountyShowOff

    elseif (category == "random") then

        typ = 0
    end

    if (typ > 0) then

        spellID = Mounty:Select(typ)

        if (spellID > 0) then
            mountID = C_MountJournal.GetMountFromSpell(spellID)
        end
    end

    Mounty:Debug(L["Category: "] .. category)
    Mounty:Debug(L["Type: "] .. typ)
    Mounty:Debug("spellID = " .. spellID)
    Mounty:Debug("mountID = " .. mountID)

    C_MountJournal.SummonByID(mountID)
end

function MountyKeyHandler(keypress)

    if (keypress == nil) then
        keypress = "auto"
    end

    Mounty:Debug(L["key pressed"])
    Mounty:Debug(L["key: "] .. keypress)

    if keypress == "forceoff" then

        if IsMounted() then
            Dismount()
        end

        return

    elseif IsMounted() then

        Mounty:Debug(L["is mounted"])

        if not IsFlying() then
            Dismount()
        end

        if (keypress == "auto") then return end
    end

    if keypress == "repair" or keypress == "random" or keypress == "showoff" or keypress == "water" or keypress == "taxi" then

        Mounty:Debug(L["special key"])

        Mounty:Mount(keypress)

    else

        -- auto

        local alone = not IsInGroup()
        local flyable = IsFlyableArea()
        local swimming = IsSwimming()
        local taximode = MountyData.TaxiMode
        local donotfly = MountyData.DoNotFly

        Mounty:Debug(L["magic key"])

        if (donotfly) then

            flyable = false
        end

        local category = "ground"

        if (Mounty:Armored() < MountyData.ArmoredMin) then

            category = "repair"

        elseif (alone and flyable) then

            category = "fly"

        elseif (not alone and taximode) then

            category = "taxi"

        elseif (not alone and flyable) then

            category = "fly"

        elseif (not flyable and swimming) then

            category = "water"
        end

        Mounty:Debug(L["category: "] .. category)
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

                Mounty:Debug(L["fail"] .. " (spellID = 0): " .. infoType .. " " .. typ .. " " .. mountID)

            elseif (already) then

                Mounty:Debug(L["fail"] .. " (" .. L["already"] .. "): " .. infoType .. " " .. typ .. " " .. mountID .. " " .. spellID)

            else

                Mounty:Debug(L["saved: "] .. infoType .. " " .. typ .. " " .. index .. " " .. mountID .. " " .. spellID)
                MountyData.Mounts[typ][index] = spellID
                Mounty:OptionsRenderButtons()
            end
        end

    elseif (button == "RightButton") then

        Mounty:Debug(L["deleted: "] .. typ .. " " .. index)

        for i = index, MountyMounts - 1 do
            MountyData.Mounts[typ][i] = MountyData.Mounts[typ][i + 1]
        end
        MountyData.Mounts[typ][MountyMounts] = 0

        Mounty:OptionsRenderButtons()
    end

    GameTooltip:Hide()

    --self:SetTexture("Interface\\Buttons\\UI-EmptySlot-White");
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

    if MountyData.DebugMode == nil then
        MountyData.DebugMode = false
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

    if MountyData.ArmoredMin == nil then
        MountyData.ArmoredMin = 75
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

    -- Mounty options

    --    MountyOptionsFrame = CreateFrame("Frame", "MountyOptionsFrame", UIParent)
    MountyOptionsFrame:Hide()
    MountyOptionsFrame:SetWidth(300)
    MountyOptionsFrame:SetHeight(410)
    MountyOptionsFrame:SetFrameStrata("DIALOG")

    -- Title text

    temp = MountyOptionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    temp:SetPoint("TOPLEFT", 16, -16)
    temp:SetText(L["Options"])

    local top = 0
    local control_top_delta = 40
    local control_top_delta_small = 20

    -- Random checkbox

    top = -40

    MountyOptionsFrame_Random = CreateFrame("CheckButton", "MountyOptionsFrame_Random", MountyOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyOptionsFrame_Random:SetPoint("TOPLEFT", 16, top)
    MountyOptionsFrame_RandomText:SetText(L["Random"])
    MountyOptionsFrame_Random:SetScript("OnClick", function(self)
        MountyData.Random = not MountyData.Random
        self:SetChecked(MountyData.Random)
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

    -- Armored slider

    top = top - control_top_delta

    MountyOptionsFrame_ArmoredMin = CreateFrame("Slider", "MountyOptionsFrame_ArmoredMin", MountyOptionsFrame, "OptionsSliderTemplate")
    MountyOptionsFrame_ArmoredMin:SetWidth(335)
    MountyOptionsFrame_ArmoredMin:SetHeight(16)
    MountyOptionsFrame_ArmoredMin:SetPoint("TOPLEFT", 25, top)
    MountyOptionsFrame_ArmoredMinLow:SetText("50%")
    MountyOptionsFrame_ArmoredMinHigh:SetText("100%")
    MountyOptionsFrame_ArmoredMin:SetMinMaxValues(50, 100)
    MountyOptionsFrame_ArmoredMin:SetValueStep(1)
    MountyOptionsFrame_ArmoredMin:SetScript("OnValueChanged", function(self, value)
        MountyOptionsFrame_ArmoredMinText:SetFormattedText(L["Summon repair mount if durability is less than %d%%."], value)
        MountyData.ArmoredMin = value
    end)

    -- Taxi!

    top = top - control_top_delta - 10

    MountyOptionsFrame_Hello = CreateFrame("EditBox", "MountyOptionsFrame_Hello", MountyOptionsFrame, "InputBoxTemplate")
    MountyOptionsFrame_Hello:SetWidth(335)
    MountyOptionsFrame_Hello:SetHeight(16)
    MountyOptionsFrame_Hello:SetPoint("TOPLEFT", 25, top)
    MountyOptionsFrame_Hello:SetAutoFocus(false)
    MountyOptionsFrame_Hello:CreateFontString("MountyOptionsFrame_HelloLabel", "BACKGROUND", "GameFontNormalSmall")
    MountyOptionsFrame_HelloLabel:SetPoint("BOTTOMLEFT", MountyOptionsFrame_Hello, "TOPLEFT", 0, 1)
    MountyOptionsFrame_HelloLabel:SetText(L["How to call a passenger"])
    MountyOptionsFrame_Hello:SetScript("OnEnterPressed", function(self)
        MountyData.Hello = self:GetText()
        self:ClearFocus()
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
            MountyOptionsFrame_Buttons[t][i]:SetDisabledTexture("Interface\\Buttons\\UI-EmptySlot", "ARTWORK")
            MountyOptionsFrame_Buttons[t][i]:GetDisabledTexture():SetTexCoord(0.15, 0.85, 0.15, 0.85);
            MountyOptionsFrame_Buttons[t][i]:SetHighlightTexture("Interface\\Buttons\\YellowOrange64_Radial", "ARTWORK")
            MountyOptionsFrame_Buttons[t][i]:SetPoint("TOPLEFT", 48 + i * 38, top)
            MountyOptionsFrame_Buttons[t][i]:SetScript("OnMouseUp", MountySetMount)
            MountyOptionsFrame_Buttons[t][i]:SetScript("OnEnter", MountyTooltip)
            MountyOptionsFrame_Buttons[t][i]:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)
        end
    end

    -- DebugMode checkbox

    top = top - control_top_delta

    MountyOptionsFrame_DebugMode = CreateFrame("CheckButton", "MountyOptionsFrame_DebugMode", MountyOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyOptionsFrame_DebugMode:SetPoint("TOPLEFT", 16, top)
    MountyOptionsFrame_DebugModeText:SetText(L["Debug mode"])
    MountyOptionsFrame_DebugMode:SetScript("OnClick", function(self)
        MountyData.DebugMode = not MountyData.DebugMode
        self:SetChecked(MountyData.DebugMode)
    end)

    -- Add to Blizzard Interface Options

    MountyOptionsFrame.name = "Mounty"
    InterfaceOptions_AddCategory(MountyOptionsFrame)
end

local function MountyOptionsRender()

    MountyOptionsFrame_DebugMode:SetChecked(MountyData.DebugMode)

    MountyOptionsFrame_TaxiMode:SetChecked(MountyData.TaxiMode)
    MountyOptionsFrame_DoNotFly:SetChecked(MountyData.DoNotFly)
    MountyOptionsFrame_Random:SetChecked(MountyData.Random)
    MountyOptionsFrame_ArmoredMin:SetValue(MountyData.ArmoredMin)

    MountyOptionsFrame_Hello:SetText(MountyData.Hello)

    Mounty:OptionsRenderButtons()
end

function Mounty:OptionsRenderButtons()

    local spellID
    local icon

    for t = 1, MountyTypes do

        for i = 1, MountyMounts do

            if (MountyData.Mounts[t][i] == 0) then
                MountyOptionsFrame_Buttons[t][i]:SetNormalTexture(nil)
                MountyOptionsFrame_Buttons[t][i]:Disable()
            else
                icon = GetSpellTexture(MountyData.Mounts[t][i])
                MountyOptionsFrame_Buttons[t][i]:SetNormalTexture(icon, "ARTWORK")
                MountyOptionsFrame_Buttons[t][i]:Enable()
            end
        end
    end
end

MountyOptionsFrame = CreateFrame("Frame", "MountyOptionsFrame", UIParent)

MountyOptionsFrame:RegisterEvent("ADDON_LOADED")
MountyOptionsFrame:SetScript("OnEvent", MountyInit)
MountyOptionsFrame:SetScript("OnShow", MountyOptionsRender)

-- /mounty

SLASH_MOUNTY1 = "/mounty"
SlashCmdList["MOUNTY"] = function(message)

    if message == "debug on" then

        MountyData.DebugMode = true
        Mounty:Chat(L["Debug: "] .. "|cff00f000" .. L["on"] .. "|r.")

    elseif message == "debug off" then

        MountyData.DebugMode = false
        Mounty:Chat(L["Debug: "] .. "|cfff00000" .. L["off"] .. "|r.")

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

        InterfaceOptionsFrame_OpenToCategory("Mounty");
        InterfaceOptionsFrame_OpenToCategory("Mounty"); -- Muss 2 x aufgerufen werden ?! Bug im Blizzard Code !!
    end
end
