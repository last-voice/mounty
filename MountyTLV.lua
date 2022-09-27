MountxTLVData = {}

-- debugging https://www.wowace.com/projects/rarity/pages/faq/how-to-enable-and-disable-script-errors-lua-errors

local MountxTLVOptionsFrame = nil
local MountxTLVOptionsFrame_DebugMode = nil
local MountxTLVOptionsFrame_TaxiMode = nil
local MountxTLVOptionsFrame_DoNotFly = nil
local MountxTLVOptionsFrame_Random = nil
local MountxTLVOptionsFrame_ArmoredMin = nil
local MountxTLVOptionsFrame_Hello = nil

local MountxTLVOptionsFrame_Buttons = {}

local MountxTLVGround = 1
local MountxTLVFlying = 2
local MountxTLVWater = 3
local MountxTLVRepair = 4
local MountxTLVTaxi = 5
local MountxTLVShowOff = 6

local MountxTLVTypes = 6
local MountxTLVMounts = 10

local MountxTLVTypesLabel = {
    [1] = "Ground",
    [2] = "Flying",
    [3] = "Water",
    [4] = "Repair",
    [5] = "Taxi",
    [6] = "Show off"
}

local MountxTLVDebugForce = false

function MountxTLVChat(msg)

    if DEFAULT_CHAT_FRAME then

        DEFAULT_CHAT_FRAME:AddMessage("|cffa0a0ffMounty #TLV|r: " .. msg, 1, 1, 0)
    end
end

function MountxTLVDebug(msg)

    if (MountxTLVData.DebugMode or MountxTLVDebugForce) then
        MountxTLVChat(msg)
    end
end

function MountxTLVArmored()

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

    MountxTLVDebug("Armor is at |cffa0a0ff" .. armored .. "%|r.")

    return armored
end

function MountxTLVSelect(typ)

    local ids = {}
    local count = 0
    local usable

    MountxTLVDataGlobal = MountxTLVData

    for i = 1, MountxTLVMounts do

        if (MountxTLVData.Mounts[typ][i] > 0) then

            mountID = C_MountJournal.GetMountFromSpell(MountxTLVData.Mounts[typ][i])
            mname, _, _, _, isUsable = C_MountJournal.GetMountInfoByID(mountID)

            MountxTLVDebug("isUsable:" .. mname .. " -> " .. tostring (isUsable))

            if (isUsable) then
                count = count + 1
                ids[count] = MountxTLVData.Mounts[typ][i]
            end

        end
    
    end

    if (count > 0) then

        if MountxTLVData.Random then
            picked = math.random(count)
        else
            if (MountxTLVData.Iterator[typ] < count) then
                MountxTLVData.Iterator[typ] = MountxTLVData.Iterator[typ] + 1
            else
                MountxTLVData.Iterator[typ] = 1
            end
            picked = MountxTLVData.Iterator[typ]
        end
    
        MountxTLVDebug('selected #' .. picked .. ' of ' .. count)

        return ids[picked]

    end

    MountxTLVDebug('random = not found')
    return 0

end

function MountxTLVMountSpellID (mountID)

    _, spellID = C_MountJournal.GetMountInfoByID(mountID)

    return spellID

end

function MountxTLVMountUsableBySpellID (spellID)

    mountID = C_MountJournal.GetMountFromSpell(spellID)
    _, _, icon = C_MountJournal.GetMountInfoByID(mountID)
    return icon

end

function MountxTLVMount(category)

    local mountID = 0
    local typ = MountxTLVGround
    local spellID = 0

    if (category == "fly") then

        typ = MountxTLVFlying

    elseif (category == "water") then

        typ = MountxTLVWater

    elseif (category == "repair") then

        typ = MountxTLVRepair

    elseif (category == "taxi") then

        if not IsMounted() then
            SendChatMessage(MountxTLVData.Hello)
        end

        typ = MountxTLVTaxi

    elseif (category == "showoff") then

        typ = MountxTLVShowOff

    elseif (category == "random") then

        typ = 0

    end
    
    if (typ > 0) then

        spellID = MountxTLVSelect(typ)

        if (spellID > 0) then
            mountID = C_MountJournal.GetMountFromSpell(spellID)
        end

    end

    MountxTLVDebug('category = ' .. category)
    MountxTLVDebug('typ = ' .. typ)
    MountxTLVDebug('spellID = ' .. spellID)
    MountxTLVDebug('mountID = ' .. mountID)

    C_MountJournal.SummonByID(mountID)
end

function MountxTLVKeyHandler(keypress)

    if (keypress == nil) then
        keypress = "auto"
    end

    MountxTLVDebug("key pressed")
    MountxTLVDebug("keypress: " .. keypress)

    if keypress == "forceoff" then

        if IsMounted() then
            Dismount()
        end

        return

    elseif IsMounted() then

        MountxTLVDebug("IsMounted")

        if not IsFlying() then
            Dismount()
        end

        if (keypress == "auto") then return end

    end
    
    if keypress == "repair" or keypress == "random" or keypress == "showoff" or keypress == "water" or keypress == "taxi" then

        MountxTLVDebug("caught")

        MountxTLVMount(keypress)

    else

        -- auto

        local alone = not IsInGroup()
        local flyable = IsFlyableArea()
        local swimming = IsSwimming()
        local taximode = MountxTLVData.TaxiMode
        local donotfly = MountxTLVData.DoNotFly

        MountxTLVDebug("auto")

        if (donotfly) then

            flyable = false

        end

        local category = "ground"

        if (MountxTLVArmored() < MountxTLVData.ArmoredMin) then

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

        MountxTLVDebug("category: " .. category)
        MountxTLVMount(category)
    end
end

function MountxTLVSetMount (self, button)

    local typ = self.MountxTLVTyp
    local index = self.MountxTLVIndex

    if (button == "LeftButton") then

        while (index > 1 and MountxTLVData.Mounts[typ][index-1] == 0) do
            index = index - 1
        end

        infoType, mountID = GetCursorInfo()
        if (infoType == "mount") then
            ClearCursor ()
            spellID = MountxTLVMountSpellID (mountID)

            local already = false

            for i = 1, MountxTLVMounts do
                if (MountxTLVData.Mounts[typ][i] == spellID) then
                     already = true
                end
            end
    
            if (spellID == 0) then
            
                MountxTLVDebug ('fail (spellID = 0): ' .. infoType .. ' ' .. typ .. ' ' .. mountID)
            
            elseif (already) then

                MountxTLVDebug ('fail (already): ' .. infoType .. ' ' .. typ .. ' ' .. mountID .. ' ' .. spellID)

            else

                MountyTLVDebug ('saved: ' .. infoType .. ' ' .. typ .. ' ' .. index .. ' ' .. mountID .. ' ' .. spellID)
                MountyTLVData.Mounts[typ][index] = spellID
                MountyTLVOptionsRenderButtons ()
            
            end
        end

    elseif (button == "RightButton") then
    
        MountyTLVDebug ('deleted: ' .. typ .. ' ' .. index)

        for i = index, MountyTLVMounts - 1 do
            MountyTLVData.Mounts[typ][i] = MountyTLVData.Mounts[typ][i+1]
        end
        MountyTLVData.Mounts[typ][MountyTLVMounts] = 0

        MountyTLVOptionsRenderButtons ()

    end

    GameTooltip:Hide()

    --self:SetTexture("Interface\\Buttons\\UI-EmptySlot-White");
end

function MountyTLVTooltip (self, motion)

    local typ = self.MountyTLVTyp
    local index = self.MountyTLVIndex
   
    local spellID = MountyTLVData.Mounts[typ][index]

    if (spellID) then

            local mountID = C_MountJournal.GetMountFromSpell(spellID)
            local name = C_MountJournal.GetMountInfoByID(mountID)

            GameTooltip_SetDefaultAnchor (GameTooltip, UIParent)
            GameTooltip:SetText (name)
            GameTooltip:Show ()

    end
 
end

function MountyTLVOptionsInit(self, event)

    if MountyTLVData.DebugMode == nil then
        MountyTLVData.DebugMode = false
    end

    if MountyTLVData.TaxiMode == nil then
        MountyTLVData.TaxiMode = false
    end

    if MountyTLVData.DoNotFly == nil then
        MountyTLVData.DoNotFly = false
    end

    if MountyTLVData.Random == nil then
        MountyTLVData.Random = false
    end

    if MountyTLVData.ArmoredMin == nil then
        MountyTLVData.ArmoredMin = 75
    end

    if MountyTLVData.Hello == nil then
        MountyTLVData.Hello = "Taxi!"
    end

    if MountyTLVData.Mounts == nil then
        MountyTLVData.Mounts = {}
    end

    if MountyTLVData.Iterator == nil then
        MountyTLVData.Iterator = {}
    end

    for t = 1, MountyTLVTypes do

        if MountyTLVData.Iterator[t] == nil then
            MountyTLVData.Iterator[t] = 0
        end

        if MountyTLVData.Mounts[t] == nil then
            MountyTLVData.Mounts[t] = {}
        end

        for i = 1, MountyTLVMounts do
            if (MountyTLVData.Mounts[t][i] == nil) then
                MountyTLVData.Mounts[t][i] = 0
            end
        end

    end

    self:UnregisterEvent("VARIABLES_LOADED")
    self:SetScript("OnEvent", nil)

    MountyTLVOptionsInit = nil
end

function MountyTLVOptionsOnShow()

    MountyTLVOptionsFrame_DebugMode:SetChecked(MountyTLVData.DebugMode)

    MountyTLVOptionsFrame_TaxiMode:SetChecked(MountyTLVData.TaxiMode)
    MountyTLVOptionsFrame_DoNotFly:SetChecked(MountyTLVData.DoNotFly)
    MountyTLVOptionsFrame_Random:SetChecked(MountyTLVData.Random)
    MountyTLVOptionsFrame_ArmoredMin:SetValue(MountyTLVData.ArmoredMin)

    MountyTLVOptionsFrame_Hello:SetText(MountyTLVData.Hello)

    MountyTLVOptionsRenderButtons ()

end

function MountyTLVOptionsRenderButtons ()

    local spellID
    local icon

    for t = 1, MountyTLVTypes do
    
        for i = 1, MountyTLVMounts do
            
            if (MountyTLVData.Mounts[t][i] == 0) then
                MountyTLVOptionsFrame_Buttons[t][i]:SetNormalTexture (nil)
                MountyTLVOptionsFrame_Buttons[t][i]:Disable ()
            else
                icon = GetSpellTexture (MountyTLVData.Mounts[t][i])
                MountyTLVOptionsFrame_Buttons[t][i]:SetNormalTexture (icon, "ARTWORK")
                MountyTLVOptionsFrame_Buttons[t][i]:Enable ()
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

    -- Mounty #TLV options

    MountyTLVOptionsFrame = CreateFrame("Frame", "MountyTLVOptionsFrame", UIParent)
    MountyTLVOptionsFrame:Hide()
    MountyTLVOptionsFrame:SetWidth(300)
    MountyTLVOptionsFrame:SetHeight(410)
    MountyTLVOptionsFrame:SetFrameStrata("DIALOG")

    -- Title text

    temp = MountyTLVOptionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    temp:SetPoint("TOPLEFT", 16, -16)
    temp:SetText("Mounty #TLV options")

    local top = 0
    local control_top_delta = 40

    -- Random checkbox

    top = -40

    MountyTLVOptionsFrame_Random = CreateFrame("CheckButton", "MountyTLVOptionsFrame_Random", MountyTLVOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyTLVOptionsFrame_Random:SetPoint("TOPLEFT", 16, top)
    MountyTLVOptionsFrame_RandomText:SetText("Random")
    MountyTLVOptionsFrame_Random:SetScript("OnClick", function(self)
        MountyTLVData.Random = not MountyTLVData.Random
        self:SetChecked(MountyTLVData.Random)
    end)

    -- DoNotFly checkbox

    top = -40

    MountyTLVOptionsFrame_DoNotFly = CreateFrame("CheckButton", "MountyTLVOptionsFrame_DoNotFly", MountyTLVOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyTLVOptionsFrame_DoNotFly:SetPoint("TOPLEFT", 96, top)
    MountyTLVOptionsFrame_DoNotFlyText:SetText("Nicht fliegen (außer Taxi)")
    MountyTLVOptionsFrame_DoNotFly:SetScript("OnClick", function(self)
        MountyTLVData.DoNotFly = not MountyTLVData.DoNotFly
        self:SetChecked(MountyTLVData.DoNotFly)
    end)

    -- TaxiMode checkbox

    top = -40

    MountyTLVOptionsFrame_TaxiMode = CreateFrame("CheckButton", "MountyTLVOptionsFrame_TaxiMode", MountyTLVOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyTLVOptionsFrame_TaxiMode:SetPoint("TOPLEFT", 256, top)
    MountyTLVOptionsFrame_TaxiModeText:SetText("Taxi mode")
    MountyTLVOptionsFrame_TaxiMode:SetScript("OnClick", function(self)
        MountyTLVData.TaxiMode = not MountyTLVData.TaxiMode
        self:SetChecked(MountyTLVData.TaxiMode)
    end)

    -- DebugMode checkbox

    top = -40

    MountyTLVOptionsFrame_DebugMode = CreateFrame("CheckButton", "MountyTLVOptionsFrame_DebugMode", MountyTLVOptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    MountyTLVOptionsFrame_DebugMode:SetPoint("TOPLEFT", 376, top)
    MountyTLVOptionsFrame_DebugModeText:SetText("Debug mode")
    MountyTLVOptionsFrame_DebugMode:SetScript("OnClick", function(self)
        MountyTLVData.DebugMode = not MountyTLVData.DebugMode
        self:SetChecked(MountyTLVData.DebugMode)
    end)

    -- Armored slider

    top = top - control_top_delta

    MountyTLVOptionsFrame_ArmoredMin = CreateFrame("Slider", "MountyTLVOptionsFrame_ArmoredMin", MountyTLVOptionsFrame, "OptionsSliderTemplate")
    MountyTLVOptionsFrame_ArmoredMin:SetWidth(335)
    MountyTLVOptionsFrame_ArmoredMin:SetHeight(16)
    MountyTLVOptionsFrame_ArmoredMin:SetPoint("TOPLEFT", 25, top)
    MountyTLVOptionsFrame_ArmoredMinLow:SetText("50%")
    MountyTLVOptionsFrame_ArmoredMinHigh:SetText("100%")
    MountyTLVOptionsFrame_ArmoredMin:SetMinMaxValues(50, 100)
    MountyTLVOptionsFrame_ArmoredMin:SetValueStep(1)
    MountyTLVOptionsFrame_ArmoredMin:SetScript("OnValueChanged", function(self, value)
        MountyTLVOptionsFrame_ArmoredMinText:SetFormattedText("Das Repair kommt bei weniger als %d%% Rüstung.", value)
        MountyTLVData.ArmoredMin = value
    end)

    -- Taxi!

    top = top - control_top_delta - 10

    MountyTLVOptionsFrame_Hello = CreateFrame("EditBox", "MountyTLVOptionsFrame_Hello", MountyTLVOptionsFrame, "InputBoxTemplate")
    MountyTLVOptionsFrame_Hello:SetWidth(335)
    MountyTLVOptionsFrame_Hello:SetHeight(16)
    MountyTLVOptionsFrame_Hello:SetPoint("TOPLEFT", 25, top)
    MountyTLVOptionsFrame_Hello:SetAutoFocus(false)
    MountyTLVOptionsFrame_Hello:CreateFontString("MountyTLVOptionsFrame_HelloLabel", "BACKGROUND", "GameFontNormalSmall")
    MountyTLVOptionsFrame_HelloLabel:SetPoint("BOTTOMLEFT", MountyTLVOptionsFrame_Hello, "TOPLEFT", 0, 1)
    MountyTLVOptionsFrame_HelloLabel:SetText("How to call a passenger")
    MountyTLVOptionsFrame_Hello:SetScript("OnEnterPressed", function(self)
        MountyTLVData.Hello = self:GetText()
        self:ClearFocus()
    end)
    
    -- Mounts

    for t = 1, MountyTLVTypes do

        MountyTLVOptionsFrame_Buttons[t] = {}

        top = top - control_top_delta

        temp = MountyTLVOptionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        temp:SetPoint("TOPLEFT", 16, top-10)
        temp:SetText(MountyTLVTypesLabel[t])

        for i = 1, MountyTLVMounts do

            MountyTLVOptionsFrame_Buttons[t][i] = CreateFrame("Button", "MountyTLVOptionsFrame_Buttons_t" .. t .. "_i" .. i, MountyTLVOptionsFrame)
            MountyTLVOptionsFrame_Buttons[t][i].MountyTLVTyp = t
            MountyTLVOptionsFrame_Buttons[t][i].MountyTLVIndex = i
            MountyTLVOptionsFrame_Buttons[t][i]:SetSize(32,32)
            MountyTLVOptionsFrame_Buttons[t][i]:SetDisabledTexture ("Interface\\Buttons\\UI-EmptySlot", "ARTWORK")
            MountyTLVOptionsFrame_Buttons[t][i]:GetDisabledTexture():SetTexCoord(0.15, 0.85, 0.15, 0.85);
            MountyTLVOptionsFrame_Buttons[t][i]:SetHighlightTexture ("Interface\\Buttons\\YellowOrange64_Radial", "ARTWORK")
            MountyTLVOptionsFrame_Buttons[t][i]:SetPoint("TOPLEFT", 25 + i * 38, top)
            MountyTLVOptionsFrame_Buttons[t][i]:SetScript("OnMouseUp", MountyTLVSetMount)
            MountyTLVOptionsFrame_Buttons[t][i]:SetScript("OnEnter", MountyTLVTooltip)
            MountyTLVOptionsFrame_Buttons[t][i]:SetScript("OnLeave", function ()
                GameTooltip:Hide()
            end) 
        end
    
    end
   
    -- Add to Blizzard Interface Options
    
    MountyTLVOptionsFrame.name = "MountyTLV"
    InterfaceOptions_AddCategory(MountyTLVOptionsFrame)
end

MountyTLVOptionsFrame:RegisterEvent("VARIABLES_LOADED")
MountyTLVOptionsFrame:SetScript("OnEvent", MountyTLVOptionsInit)
MountyTLVOptionsFrame:SetScript("OnShow", MountyTLVOptionsOnShow)

-- /mounty

SLASH_MOUNTY1 = "/mounty"
SlashCmdList["MOUNTY"] = function(message)

    if message == "debug on" then

        MountyTLVData.DebugMode = true
        MountyTLVChat("Ddebug mode switched |cff00f000on|r.")

    elseif message == "debug off" then

        MountyTLVData.DebugMode = false
        MountyTLVChat("debug mode switched |cfff00000off|r.")

    elseif message == "fly on" then

        MountyTLVData.DoNotFly = false
        MountyTLVChat("fly mode switched |cff00f000on|r.")
    
    elseif message == "fly off" then
    
        MountyTLVData.DoNotFly = true
        MountyTLVChat("fly mode switched |cfff00000off|r.")
    
    elseif message == "random on" then

        MountyTLVData.Random = false
        MountyTLVChat("random mode switched |cff00f000on|r.")
    
    elseif message == "random off" then
    
        MountyTLVData.Random = true
        MountyTLVChat("random mode switched |cfff00000off|r.")
    
    elseif message == "taxi on" then

        MountyTLVData.TaxiMode = true
        MountyTLVChat("taxi mode switched |cff00f000on|r.")
    
    elseif message == "taxi off" then
    
        MountyTLVData.TaxiMode = false
        MountyTLVChat("taxi mode switched |cfff00000off|r.")
    
    elseif message ~= "" and message ~= nil then

        MountyTLVMount(message)

    else

        InterfaceOptionsFrame_OpenToCategory("MountyTLV");
        InterfaceOptionsFrame_OpenToCategory("MountyTLV"); -- Muss 2 x aufgerufen werden ?!

    end
    
end
