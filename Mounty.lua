MountyData = {}

-- debugging https://www.wowace.com/projects/rarity/pages/faq/how-to-enable-and-disable-script-errors-lua-errors

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
    [1] = "Ground",
    [2] = "Flying",
    [3] = "Water",
    [4] = "Repair",
    [5] = "Taxi",
    [6] = "Show off"
}

local MountyDebugForce = false

function MountyChat(msg)

    if DEFAULT_CHAT_FRAME then

        DEFAULT_CHAT_FRAME:AddMessage("|cffa0a0ffMounty|r: " .. msg, 1, 1, 0)
    end
end

function MountyDebug(msg)

    if (MountyData.DebugMode or MountyDebugForce) then
        MountyChat(msg)
    end
end

function MountyArmored()

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

    MountyDebug("Armor is at |cffa0a0ff" .. armored .. "%|r.")

    return armored
end

function MountySelect(typ)

    local ids = {}
    local count = 0
    local usable

    MountyDataGlobal = MountyData

    for i = 1, MountyMounts do

        if (MountyData.Mounts[typ][i] > 0) then

            mountID = C_MountJournal.GetMountFromSpell(MountyData.Mounts[typ][i])
            mname, _, _, _, isUsable = C_MountJournal.GetMountInfoByID(mountID)

            MountyDebug("isUsable:" .. mname .. " -> " .. tostring (isUsable))

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
    
        MountyDebug('selected #' .. picked .. ' of ' .. count)

        return ids[picked]

    end

    MountyDebug('random = not found')
    return 0

end

function MountyMountSpellID (mountID)

    _, spellID = C_MountJournal.GetMountInfoByID(mountID)

    return spellID

end

function MountyMountUsableBySpellID (spellID)

    mountID = C_MountJournal.GetMountFromSpell(spellID)
    _, _, icon = C_MountJournal.GetMountInfoByID(mountID)
    return icon

end

function MountyMount(category)

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

        spellID = MountySelect(typ)

        if (spellID > 0) then
            mountID = C_MountJournal.GetMountFromSpell(spellID)
        end

    end

    MountyDebug('category = ' .. category)
    MountyDebug('typ = ' .. typ)
    MountyDebug('spellID = ' .. spellID)
    MountyDebug('mountID = ' .. mountID)

    C_MountJournal.SummonByID(mountID)
end

function MountyKeyHandler(keypress)

    if (keypress == nil) then
        keypress = "auto"
    end

    MountyDebug("key pressed")
    MountyDebug("keypress: " .. keypress)

    if keypress == "forceoff" then

        if IsMounted() then
            Dismount()
        end

        return

    elseif IsMounted() then

        MountyDebug("IsMounted")

        if not IsFlying() then
            Dismount()
        end

        if (keypress == "auto") then return end

    end
    
    if keypress == "repair" or keypress == "random" or keypress == "showoff" or keypress == "water" or keypress == "taxi" then

        MountyDebug("caught")

        MountyMount(keypress)

    else

        -- auto

        local alone = not IsInGroup()
        local flyable = IsFlyableArea()
        local swimming = IsSwimming()
        local taximode = MountyData.TaxiMode
        local donotfly = MountyData.DoNotFly

        MountyDebug("auto")

        if (donotfly) then

            flyable = false

        end

        local category = "ground"

        if (MountyArmored() < MountyData.ArmoredMin) then

            category = "repair" 
        
        elseif (alone and flyable) then

            category = "fly"

        elseif (not alone and flyable and not taximode) then

            category = "fly"

        elseif (alone and not flyable and swimming) then

            category = "water"

        elseif (not alone and not flyable and swimming and not taximode) then

            category = "water"

        elseif (not alone and taximode) then

            category = "taxi"
        end

        MountyDebug("category: " .. category)
        MountyMount(category)
    end
end

function MountySetMount (self, button)

    local typ = self.MountyTyp
    local index = self.MountyIndex

    if (button == "LeftButton") then

        while (index > 1 and MountyData.Mounts[typ][index-1] == 0) do
            index = index - 1
        end

        infoType, mountID = GetCursorInfo()
        if (infoType == "mount") then
            ClearCursor ()
            spellID = MountyMountSpellID (mountID)

            local already = false

            for i = 1, MountyMounts do
                if (MountyData.Mounts[typ][i] == spellID) then
                     already = true
                end
            end
    
            if (spellID == 0) then
            
                MountyDebug ('fail (spellID = 0): ' .. infoType .. ' ' .. typ .. ' ' .. mountID)
            
            elseif (already) then

                MountyDebug ('fail (already): ' .. infoType .. ' ' .. typ .. ' ' .. mountID .. ' ' .. spellID)

            else

                MountyDebug ('saved: ' .. infoType .. ' ' .. typ .. ' ' .. index .. ' ' .. mountID .. ' ' .. spellID)
                MountyData.Mounts[typ][index] = spellID 
                MountyOptionsRenderButtons ()                    
            
            end
        end

    elseif (button == "RightButton") then
    
        MountyDebug ('deleted: ' .. typ .. ' ' .. index)

        for i = index, MountyMounts - 1 do
            MountyData.Mounts[typ][i] = MountyData.Mounts[typ][i+1] 
        end
        MountyData.Mounts[typ][MountyMounts] = 0

        MountyOptionsRenderButtons ()                    

    end

    GameTooltip:Hide()

    --self:SetTexture("Interface\\Buttons\\UI-EmptySlot-White");
end

function MountyTooltip (self, motion)

    local typ = self.MountyTyp
    local index = self.MountyIndex
   
    local spellID = MountyData.Mounts[typ][index]

    if (spellID) then

            local mountID = C_MountJournal.GetMountFromSpell(spellID)
            local name = C_MountJournal.GetMountInfoByID(mountID)

            GameTooltip_SetDefaultAnchor (GameTooltip, UIParent)
            GameTooltip:SetText (name)
            GameTooltip:Show ()

    end
 
end

function MountyOptionsInit(self, event)

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
        MountyData.Hello = "Taxi!"
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

    self:UnregisterEvent("VARIABLES_LOADED")
    self:SetScript("OnEvent", nil)

    MountyOptionsInit = nil
end

function MountyOptionsOnShow()

    MountyOptionsFrame_DebugMode:SetChecked(MountyData.DebugMode)

    MountyOptionsFrame_TaxiMode:SetChecked(MountyData.TaxiMode)
    MountyOptionsFrame_DoNotFly:SetChecked(MountyData.DoNotFly)    
    MountyOptionsFrame_Random:SetChecked(MountyData.Random)
    MountyOptionsFrame_ArmoredMin:SetValue(MountyData.ArmoredMin)

    MountyOptionsFrame_Hello:SetText(MountyData.Hello)

    MountyOptionsRenderButtons ()

end

function MountyOptionsRenderButtons ()

    local spellID
    local icon

    for t = 1, MountyTypes do
    
        for i = 1, MountyMounts do
            
            if (MountyData.Mounts[t][i] == 0) then
                MountyOptionsFrame_Buttons[t][i]:SetNormalTexture (nil)
                MountyOptionsFrame_Buttons[t][i]:Disable ()
            else
                icon = GetSpellTexture (MountyData.Mounts[t][i])
                MountyOptionsFrame_Buttons[t][i]:SetNormalTexture (icon, "ARTWORK")
                MountyOptionsFrame_Buttons[t][i]:Enable ()
            end

        end
    end

end

do
   
    local top
    local temp
    local spellID
    local infoType
    local mountID
    local icon

    -- Mounty options

    MountyOptionsFrame = CreateFrame("Frame", "MountyOptionsFrame", UIParent)
    MountyOptionsFrame:Hide()
    MountyOptionsFrame:SetWidth(300)
    MountyOptionsFrame:SetHeight(410)
    MountyOptionsFrame:SetFrameStrata("DIALOG")

    -- Title text

    temp = MountyOptionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    temp:SetPoint("TOPLEFT", 16, -16)
    temp:SetText("Mounty options")

    local top = 0
    local control_top_delta = 40

    -- Random checkbox

    top = -40

    MountyOptionsFrame_Random = CreateFrame("CheckButton", "MountyOptionsFrame_Random", MountyOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyOptionsFrame_Random:SetPoint("TOPLEFT", 16, top)
    MountyOptionsFrame_RandomText:SetText("Random")
    MountyOptionsFrame_Random:SetScript("OnClick", function(self)
        MountyData.Random = not MountyData.Random
        self:SetChecked(MountyData.Random)
    end)

    -- DoNotFly checkbox

    top = -40

    MountyOptionsFrame_DoNotFly = CreateFrame("CheckButton", "MountyOptionsFrame_DoNotFly", MountyOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyOptionsFrame_DoNotFly:SetPoint("TOPLEFT", 96, top)
    MountyOptionsFrame_DoNotFlyText:SetText("Nicht fliegen (außer Taxi)")
    MountyOptionsFrame_DoNotFly:SetScript("OnClick", function(self)
        MountyData.DoNotFly = not MountyData.DoNotFly
        self:SetChecked(MountyData.DoNotFly)
    end)

    -- TaxiMode checkbox

    top = -40

    MountyOptionsFrame_TaxiMode = CreateFrame("CheckButton", "MountyOptionsFrame_TaxiMode", MountyOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyOptionsFrame_TaxiMode:SetPoint("TOPLEFT", 256, top)
    MountyOptionsFrame_TaxiModeText:SetText("Taxi mode")
    MountyOptionsFrame_TaxiMode:SetScript("OnClick", function(self)
        MountyData.TaxiMode = not MountyData.TaxiMode
        self:SetChecked(MountyData.TaxiMode)
    end)

    -- DebugMode checkbox

    top = -40

    MountyOptionsFrame_DebugMode = CreateFrame("CheckButton", "MountyOptionsFrame_DebugMode", MountyOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyOptionsFrame_DebugMode:SetPoint("TOPLEFT", 376, top)
    MountyOptionsFrame_DebugModeText:SetText("Debug mode")
    MountyOptionsFrame_DebugMode:SetScript("OnClick", function(self)
        MountyData.DebugMode = not MountyData.DebugMode
        self:SetChecked(MountyData.DebugMode)
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
        MountyOptionsFrame_ArmoredMinText:SetFormattedText("Das Repair kommt bei weniger als %d%% Rüstung.", value)
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
    MountyOptionsFrame_HelloLabel:SetText("How to call a passenger")
    MountyOptionsFrame_Hello:SetScript("OnEnterPressed", function(self)
        MountyData.Hello = self:GetText()
        self:ClearFocus()
    end)
    
    -- Mounts

    for t = 1, MountyTypes do

        MountyOptionsFrame_Buttons[t] = {}

        top = top - control_top_delta

        temp = MountyOptionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        temp:SetPoint("TOPLEFT", 16, top-10)
        temp:SetText(MountyTypesLabel[t])

        for i = 1, MountyMounts do

            MountyOptionsFrame_Buttons[t][i] = CreateFrame("Button", "MountyOptionsFrame_Buttons_t" .. t .. "_i" .. i, MountyOptionsFrame)
            MountyOptionsFrame_Buttons[t][i].MountyTyp = t
            MountyOptionsFrame_Buttons[t][i].MountyIndex = i
            MountyOptionsFrame_Buttons[t][i]:SetSize(32,32)
            MountyOptionsFrame_Buttons[t][i]:SetDisabledTexture ("Interface\\Buttons\\UI-EmptySlot", "ARTWORK")
            MountyOptionsFrame_Buttons[t][i]:GetDisabledTexture():SetTexCoord(0.15, 0.85, 0.15, 0.85);
            MountyOptionsFrame_Buttons[t][i]:SetHighlightTexture ("Interface\\Buttons\\YellowOrange64_Radial", "ARTWORK")
            MountyOptionsFrame_Buttons[t][i]:SetPoint("TOPLEFT", 25 + i * 38, top)
            MountyOptionsFrame_Buttons[t][i]:SetScript("OnMouseUp", MountySetMount)
            MountyOptionsFrame_Buttons[t][i]:SetScript("OnEnter", MountyTooltip) 
            MountyOptionsFrame_Buttons[t][i]:SetScript("OnLeave", function ()
                GameTooltip:Hide()
            end) 
        end
    
    end
   
    -- Add to Blizzard Interface Options
    
    MountyOptionsFrame.name = "Mounty"
    InterfaceOptions_AddCategory(MountyOptionsFrame)
end

MountyOptionsFrame:RegisterEvent("VARIABLES_LOADED")
MountyOptionsFrame:SetScript("OnEvent", MountyOptionsInit)
MountyOptionsFrame:SetScript("OnShow", MountyOptionsOnShow)

-- /mounty

SLASH_MOUNTY1 = "/mounty"
SlashCmdList["MOUNTY"] = function(message)

    if message == "debug on" then

        MountyData.DebugMode = true
        MountyChat("Ddebug mode switched |cff00f000on|r.")

    elseif message == "debug off" then

        MountyData.DebugMode = false
        MountyChat("debug mode switched |cfff00000off|r.")

    elseif message == "fly on" then

        MountyData.DoNotFly = false
        MountyChat("fly mode switched |cff00f000on|r.")
    
    elseif message == "fly off" then
    
        MountyData.DoNotFly = true
        MountyChat("fly mode switched |cfff00000off|r.")
    
    elseif message == "random on" then

        MountyData.Random = false
        MountyChat("random mode switched |cff00f000on|r.")
    
    elseif message == "random off" then
    
        MountyData.Random = true
        MountyChat("random mode switched |cfff00000off|r.")
    
    elseif message == "taxi on" then

        MountyData.TaxiMode = true
        MountyChat("taxi mode switched |cff00f000on|r.")
    
    elseif message == "taxi off" then
    
        MountyData.TaxiMode = false
        MountyChat("taxi mode switched |cfff00000off|r.")
    
    elseif message ~= "" and message ~= nil then

        MountyMount(message)

    else

        InterfaceOptionsFrame_OpenToCategory("Mounty");
        InterfaceOptionsFrame_OpenToCategory("Mounty"); -- Muss 2 x aufgerufen werden ?!

    end
    
end
