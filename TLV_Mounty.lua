local Mounty_Name, Mounty = ...

local L = Mounty.L
local TLVlib = Mounty.TLVlib

Mounty.NumCategories = 10
Mounty.NumMounts = 10
Mounty.NumMountsExpanded = 110

Mounty.TypeGround = 1
Mounty.TypeFlying = 2
Mounty.TypeDragonflight = 3
Mounty.TypeWater = 4
Mounty.TypeRepair = 5
Mounty.TypeTaxi = 6
Mounty.TypeShowOff = 7
Mounty.TypeCustom1 = 8
Mounty.TypeCustom2 = 9
Mounty.TypeCustom3 = 10

Mounty.CategoriesLabel = {
    [1] = L["mode.Ground"],
    [2] = L["mode.Flying"],
    [3] = L["mode.Dragonflight"],
    [4] = L["mode.Water"],
    [5] = L["mode.Repair"],
    [6] = L["mode.Taxi"],
    [7] = L["mode.Show off"],
    [8] = L["mode.Custom1"],
    [9] = L["mode.Custom2"],
    [10] = L["mode.Custom3"]
}

Mounty.FallbackQueue = {}
Mounty.FallbackAlready = {}

Mounty.TestDragon = nil

function Mounty:IsDebug ()

    return _Mounty_A.DebugMode or false

end

function Mounty:CheckIfCasting ()

    if UnitCastingInfo("player") ~= nil then

        TLVlib:Debug("You are already casting a spell.")
        return true

    end

    return false

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

    TLVlib:Debug("Durability: |cfff01000" .. durability .. "%|r")

    return durability
end

function Mounty:Fallback(category)

    Mounty.FallbackAlready[category] = true

    local FallbackTo = 0

    if not Mounty.FallbackAlready[Mounty.FallbackQueue[1]] then

        FallbackTo = Mounty.FallbackQueue[1]

    elseif not Mounty.FallbackAlready[Mounty.FallbackQueue[2]] then

        FallbackTo = Mounty.FallbackQueue[2]
    end

    if FallbackTo == Mounty.TypeFlying then

        TLVlib:Debug("Fallback: '" .. L["mode.Flying"] .. "'")
        return Mounty.TypeFlying

    elseif FallbackTo == Mounty.TypeGround then

        TLVlib:Debug("Fallback: '" .. L["mode.Ground"] .. "'")
        return Mounty.TypeGround
    end

    TLVlib:Debug("Fallback: '" .. L["mode.Random"] .. "'")
    return 0
end

function Mounty:SelectMountByCategory(category, only_flyable_showoffs)

    if category == 0 then
        return 0
    end

    local ids = {}
    local count = 0
    local picked
    local usable
    local mountID
    local mname

    for i = 1, Mounty.NumMountsExpanded do

        if Mounty.CurrentProfile.Mounts[category][i] > 0 then

            usable = IsUsableSpell(Mounty.CurrentProfile.Mounts[category][i])

            mountID = C_MountJournal.GetMountFromSpell(Mounty.CurrentProfile.Mounts[category][i])
            mname = C_MountJournal.GetMountInfoByID(mountID)

            if usable and only_flyable_showoffs then

                local _, _, _, _, mountTypeID = C_MountJournal.GetMountInfoExtraByID(mountID)

                if mountTypeID ~= 248 then
                    -- 248 = mostly flyable
                    -- 402 = dragonflight, but why?
                    usable = false
                end
            end

            TLVlib:Debug("Usable: " .. "[" .. mountID .. "] " .. mname .. " -> " .. tostring(usable))

            if usable then
                count = count + 1
                ids[count] = Mounty.CurrentProfile.Mounts[category][i]
            end
        end

    end

    if count > 0 then

        if Mounty.CurrentProfile.Random then
            picked = math.random(count)
        else
            if Mounty.CurrentProfile.Iterator[category] < count then
                Mounty.CurrentProfile.Iterator[category] = Mounty.CurrentProfile.Iterator[category] + 1
            else
                Mounty.CurrentProfile.Iterator[category] = 1
            end
            picked = Mounty.CurrentProfile.Iterator[category]
        end

        TLVlib:Debug("Selected: " .. picked .. " of " .. count)

        return ids[picked]
    end

    TLVlib:Debug("No (usable) mount found in category.")

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

function Mounty:YouCanRideDragonsHere()

    local ridingmounts = C_MountJournal.GetCollectedDragonridingMounts()

    if (ridingmounts[1] ~= nil) then
        -- dragonride mount found in collection

        -- local isUsable, error = C_MountJournal.GetMountUsabilityByID(ridingmounts[1], false); always true, weil das mount grundsätzlich benutzt werden kann ???
        -- local name, _, _, _, isUsable = C_MountJournal.GetMountInfoByID(ridingmounts[1]) always true, weil das mount grundsätzlich benutzt werden kann ???

        local name, spellID = C_MountJournal.GetMountInfoByID(ridingmounts[1])

        local isUsable = IsUsableSpell(spellID)

        if (isUsable) then
            TLVlib:Debug("Dragon '" .. name .. "' found and you can ride it here.")
        end

        return isUsable

    end

    return false

end

function Mounty:Mount(mode)

    local mountID = 0
    local spellID = 0
    local only_flyable_showoffs = false

    if (Mounty:CheckIfCasting()) then
        return
    end

    local category = Mounty.TypeGround

    if mode == "dragonflight" then

        category = Mounty.TypeDragonflight

    elseif mode == "fly" then

        category = Mounty.TypeFlying

    elseif mode == "water" then

        category = Mounty.TypeWater

    elseif mode == "repair" then

        category = Mounty.TypeRepair

    elseif mode == "taxi" then

        if IsInGroup() and not IsMounted() then
            if Mounty.CurrentProfile.Hello ~= "" then
                SendChatMessage(Mounty.CurrentProfile.Hello)
            end
        end

        category = Mounty.TypeTaxi

    elseif mode == "custom1" then

        category = Mounty.TypeCustom1

    elseif mode == "custom2" then

        category = Mounty.TypeCustom2

    elseif mode == "custom3" then

        category = Mounty.TypeCustom3

    elseif mode == "showoff" then

        category = Mounty.TypeShowOff

        if Mounty:UserCanFlyHere() then
            only_flyable_showoffs = true
        end

    elseif mode == "random" then

        category = 0

    end

    TLVlib:Debug("Mode: " .. mode)
    TLVlib:Debug("Category: " .. category)

    if category > 0 then

        Mounty.FallbackAlready = {} -- Muss wieder auf leer gesetzt werden

        if Mounty:UserCanFlyHere() then
            Mounty.FallbackQueue = { Mounty.TypeFlying, Mounty.TypeGround }
        else
            Mounty.FallbackQueue = { Mounty.TypeGround, Mounty.TypeFlying }
        end

        spellID = Mounty:SelectMountByCategory(category, only_flyable_showoffs)

        if spellID > 0 then
            mountID = C_MountJournal.GetMountFromSpell(spellID)
        end
    end

    TLVlib:Debug("mountID: " .. mountID)
    TLVlib:Debug("spellID: " .. spellID)

    C_MountJournal.SummonByID(mountID)
end

function Mounty:KeyHandler(keypress)

    local mounted = IsMounted()
    local flying = IsFlying()
    local resting = IsResting()
    local dragonflight = Mounty:YouCanRideDragonsHere()
    local alone = not IsInGroup()
    local flyable = Mounty:UserCanFlyHere()
    local swimming = IsSwimming()
    local taximode = Mounty.CurrentProfile.TaxiMode
    local together = Mounty.CurrentProfile.Together
    local amphibian = Mounty.CurrentProfile.Amphibian
    local showoff = Mounty.CurrentProfile.ShowOff
    local parachute = _Mounty_A.Parachute

    if (Mounty:CheckIfCasting()) then
        return
    end

    if keypress == nil then
        keypress = "magic"
    end

    TLVlib:Debug("--- --- --- --- --- --- ---")
    TLVlib:Debug("Key pressed: " .. keypress)

    if keypress == "forceoff" then

        if mounted then
            Dismount()
        end

        return

    elseif mounted then

        if flying and not parachute then
            TLVlib:Debug("You are mounted and flying.")
            return
        end

        Dismount()

        if keypress == "magic" then
            return
        end

    end

    if keypress == "magic" then

        -- magic

        TLVlib:Debug("Magic key")

        if not alone and together then
            flyable = false
        end

        if not amphibian then
            Mounty.ForceWaterMount = false
        else

            -- amphibian
            if (swimming) then
                Mounty.ForceWaterMount = not Mounty.ForceWaterMount
            else
                Mounty.ForceWaterMount = false
            end

        end

        TLVlib:Debug("ForceWaterMount: " .. tostring(Mounty.ForceWaterMount))

        local mode

        if Mounty:Durability() < Mounty.CurrentProfile.DurabilityMin then

            mode = "repair"

        elseif swimming and Mounty.ForceWaterMount then

            mode = "water"

        elseif dragonflight then

            mode = "dragonflight"

        elseif not alone and taximode then

            mode = "taxi"

        elseif resting and showoff and not swimming then

            mode = "showoff"

        elseif flyable then

            mode = "fly"

        elseif swimming then

            mode = "water"

        else

            mode = "ground"
        end

        Mounty:Mount(mode)

    else

        TLVlib:Debug("Dedicated key")

        Mounty:Mount(keypress)

    end

end

function Mounty:PickupMountBySpellID(pickupSpellID)

    C_MountJournal.SetDefaultFilters()

    local pickup_ID = -1

    for i = 1, C_MountJournal.GetNumDisplayedMounts() do

        local _, spellID = C_MountJournal.GetDisplayedMountInfo(i)

        if (spellID == pickupSpellID) then
            pickup_ID = i
            break
        end

    end

    if (pickup_ID ~= -1) then

        C_MountJournal.Pickup(pickup_ID)

        return true

    end

    return false

end

function Mounty:AddMount(calling, expanded)

    local infoType, mountID = GetCursorInfo()

    local category = calling.MountyCategory or 0
    local index = calling.MountyIndex

    if expanded then
        category = Mounty:ValidCategory(Mounty.ExpandedFrame.MountyCategory)
    end

    if not category then
        return
    end

    if infoType == "mount" then

        ClearCursor()

        local spellID = Mounty:MountSpellID(mountID)

        if spellID == 0 then

            TLVlib:Debug("Fail: spellID = 0 | " .. infoType .. " " .. category .. " " .. mountID)

        elseif Mounty:AlreadyInCategory(category, spellID) then

            TLVlib:Alert(L["options.popup.Already"])

            TLVlib:Debug("Fail: Already | " .. infoType .. " " .. category .. " " .. mountID .. " " .. spellID)

        else

            if index < Mounty.NumMounts then

                -- find the first empty slot
                while (index > 1 and Mounty.CurrentProfile.Mounts[category][index - 1] == 0) do
                    index = index - 1
                end

            end

            TLVlib:Debug("Mount saved: " .. infoType .. " " .. category .. " " .. index .. " " .. mountID .. " " .. spellID)
            Mounty.CurrentProfile.Mounts[category][index] = spellID
            Mounty:OptionsRenderButtons()
        end

        GameTooltip:Hide()

    end

end

function Mounty:CopyMount(calling, expanded)

    local category = calling.MountyCategory or 0
    local index = calling.MountyIndex

    if expanded then
        category = Mounty:ValidCategory(Mounty.ExpandedFrame.MountyCategory)
    end

    if not category then
        return
    end

    if (Mounty:PickupMountBySpellID(Mounty.CurrentProfile.Mounts[category][index])) then

        TLVlib:Debug("Mount picked up: " .. category .. " " .. index)

    else

        TLVlib:Debug("Something went wrong: Couldn't pick up mount " .. category .. " " .. index)

    end

end

function Mounty:RemoveMount(calling, expanded)

    local category = calling.MountyCategory or 0
    local index = calling.MountyIndex

    if expanded then
        category = Mounty:ValidCategory(Mounty.ExpandedFrame.MountyCategory)
    end

    if not category then
        return
    end

    TLVlib:Debug("Mount removed: " .. category .. " " .. index)

    if index < Mounty.NumMounts then

        for i = index, Mounty.NumMounts - 1 do
            Mounty.CurrentProfile.Mounts[category][i] = Mounty.CurrentProfile.Mounts[category][i + 1]
        end

        Mounty.CurrentProfile.Mounts[category][Mounty.NumMounts] = 0

    else

        Mounty.CurrentProfile.Mounts[category][index] = 0

    end

    Mounty:OptionsRenderButtons()

    GameTooltip:Hide()

end

function Mounty:AlreadyInCategory (category, spellID)

    for i = 1, Mounty.NumMountsExpanded do
        if Mounty.CurrentProfile.Mounts[category][i] == spellID then
            return true
        end
    end

    return false

end

function Mounty:Tooltip(calling, expanded)

    local category = calling.MountyCategory or 0
    local index = calling.MountyIndex

    if expanded then
        category = Mounty:ValidCategory(Mounty.ExpandedFrame.MountyCategory)
    end

    if not category then
        return
    end

    local spellID = Mounty.CurrentProfile.Mounts[category][index]

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

function Mounty:InitOptionsFrame()

    local top
    local temp

    local delta = 8

    Mounty.OptionsFrame = CreateFrame("Frame", nil, UIParent, "SettingsFrameTemplate")

    Mounty.OptionsFrame:Hide()

    tinsert(UISpecialFrames, "Mounty.OptionsFrame");

    Mounty.OptionsFrame:SetScript("OnShow", Mounty.OnShow)
    Mounty.OptionsFrame:SetScript("OnHide", Mounty.OnHide)

    Mounty.OptionsFrame:SetWidth(490)
    Mounty.OptionsFrame:SetPoint("CENTER")

    Mounty.OptionsFrame:SetFrameStrata("HIGH")

    Mounty:SettingsFrameTemplateSetBg(Mounty.OptionsFrame)

    Mounty.OptionsFrame:EnableMouse(true)
    Mounty.OptionsFrame:SetMovable(true)
    Mounty.OptionsFrame:RegisterForDrag("LeftButton")
    Mounty.OptionsFrame:SetScript("OnDragStart", function(calling)
        calling:StartMoving()
    end)
    Mounty.OptionsFrame:SetScript("OnDragStop", function(calling)
        calling:StopMovingOrSizing()
    end)

    -- Title text
    temp = Mounty.OptionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    temp:SetPoint("TOP", 0, -6)
    temp:SetText(TLVlib:AddOnHeader())

    top = 0

    -- Mounts

    Mounty.OptionsFrame_Buttons = {}

    for category = 1, Mounty.NumCategories do

        Mounty.OptionsFrame_Buttons[category] = {}

        top = top - delta * 4

        temp = Mounty.OptionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        temp:SetPoint("TOPLEFT", 20, top - 10)
        temp:SetText(Mounty.CategoriesLabel[category])

        local plusi = 0

        for i = 1, Mounty.NumMounts do

            Mounty.OptionsFrame_Buttons[category][i] = CreateFrame("Button", nil, Mounty.OptionsFrame)
            Mounty.OptionsFrame_Buttons[category][i].MountyCategory = category
            Mounty.OptionsFrame_Buttons[category][i].MountyIndex = i
            Mounty.OptionsFrame_Buttons[category][i]:SetSize(32, 32)
            Mounty.OptionsFrame_Buttons[category][i]:SetDisabledTexture("Interface\\Buttons\\UI-EmptySlot")
            Mounty.OptionsFrame_Buttons[category][i]:GetDisabledTexture():SetTexCoord(0.15, 0.85, 0.15, 0.85)
            Mounty.OptionsFrame_Buttons[category][i]:SetHighlightTexture("Interface\\Buttons\\UI-StopButton")
            Mounty.OptionsFrame_Buttons[category][i]:SetPoint("TOPLEFT", 60 + i * 32, top)
            Mounty.OptionsFrame_Buttons[category][i]:SetScript("OnMouseUp", function(calling, button)
                if button == "LeftButton" then
                    Mounty:AddMount(calling, false)
                elseif button == "RightButton" then
                    Mounty:RemoveMount(calling, false)
                end
            end)
            Mounty.OptionsFrame_Buttons[category][i]:SetScript("OnDoubleClick", function(calling)
                Mounty:CopyMount(calling, false)
            end)
            Mounty.OptionsFrame_Buttons[category][i]:SetScript("OnEnter", function(calling)
                Mounty:Tooltip(calling, false)
            end)
            Mounty.OptionsFrame_Buttons[category][i]:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            plusi = i

        end

        temp = TLVlib:Button(Mounty.OptionsFrame, "TOPLEFT", 64 + (plusi + 1) * 32 + 2, top, 24, 32, "+")
        temp.MountyCategory = category
        temp:SetScript("OnClick", function(calling)

            if Mounty.ExpandedFrame:IsVisible() and Mounty.ExpandedFrame.MountyCategory == calling.MountyCategory then

                Mounty.ExpandedFrame:Hide()

            else

                Mounty.ExpandedFrame_Title:SetText("+ " .. Mounty.CategoriesLabel[calling.MountyCategory])
                Mounty.ExpandedFrame.MountyCategory = calling.MountyCategory
                Mounty.ExpandedFrame:Show()
                Mounty:OptionsRenderExpandedButtons()

            end
        end)

    end

    -- Helptext

    top = top - delta * 4

    temp = Mounty.OptionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    temp:SetPoint("TOPLEFT", 102, top - 3)
    temp:SetText(L["options.Helptext"])

    -- Random checkbox

    top = top - 22

    Mounty.OptionsFrame_Random = CreateFrame("CheckButton", "Mounty_OptionsFrame_Random", Mounty.OptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    Mounty.OptionsFrame_Random:SetPoint("TOPLEFT", 16, top)
    Mounty_OptionsFrame_RandomText:SetText(L["options.Random"])
    Mounty.OptionsFrame_Random:SetScript("OnClick", function(calling)
        Mounty.CurrentProfile.Random = not Mounty.CurrentProfile.Random
        calling:SetChecked(Mounty.CurrentProfile.Random)
    end)

    -- ShowOff checkbox

    top = top - 22

    Mounty.OptionsFrame_ShowOff = CreateFrame("CheckButton", "Mounty_OptionsFrame_ShowOff", Mounty.OptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    Mounty.OptionsFrame_ShowOff:SetPoint("TOPLEFT", 16, top)
    Mounty_OptionsFrame_ShowOffText:SetText(L["options.Look"])
    Mounty.OptionsFrame_ShowOff:SetScript("OnClick", function(calling)
        Mounty.CurrentProfile.ShowOff = not Mounty.CurrentProfile.ShowOff
        calling:SetChecked(Mounty.CurrentProfile.ShowOff)
    end)

    -- Amphibian checkbox

    top = top - 22

    Mounty.OptionsFrame_Amphibian = CreateFrame("CheckButton", "Mounty_OptionsFrame_Amphibian", Mounty.OptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    Mounty.OptionsFrame_Amphibian:SetPoint("TOPLEFT", 16, top)
    Mounty_OptionsFrame_AmphibianText:SetText(L["options.Amphibian"])
    Mounty.OptionsFrame_Amphibian:SetScript("OnClick", function(calling)
        Mounty.CurrentProfile.Amphibian = not Mounty.CurrentProfile.Amphibian
        calling:SetChecked(Mounty.CurrentProfile.Amphibian)
    end)

    -- Together checkbox

    top = top - 22

    Mounty.OptionsFrame_Together = CreateFrame("CheckButton", "Mounty_OptionsFrame_Together", Mounty.OptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    Mounty.OptionsFrame_Together:SetPoint("TOPLEFT", 16, top)
    Mounty_OptionsFrame_TogetherText:SetText(L["options.Together"])
    Mounty.OptionsFrame_Together:SetScript("OnClick", function(calling)
        Mounty.CurrentProfile.Together = not Mounty.CurrentProfile.Together
        calling:SetChecked(Mounty.CurrentProfile.Together)
    end)

    -- TaxiMode checkbox

    top = top - 22

    Mounty.OptionsFrame_TaxiMode = CreateFrame("CheckButton", "Mounty_OptionsFrame_TaxiMode", Mounty.OptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    Mounty.OptionsFrame_TaxiMode:SetPoint("TOPLEFT", 16, top)
    Mounty_OptionsFrame_TaxiModeText:SetText(L["options.Taxi"])
    Mounty.OptionsFrame_TaxiMode:SetScript("OnClick", function(calling)
        Mounty.CurrentProfile.TaxiMode = not Mounty.CurrentProfile.TaxiMode
        --        calling:SetChecked(Mounty.CurrentProfile.TaxiMode)
        Mounty:OptionsRender()
    end)

    -- Taxi!

    top = top - delta * 5

    Mounty.OptionsFrame_Hello = CreateFrame("EditBox", nil, Mounty.OptionsFrame, "InputBoxTemplate")
    Mounty.OptionsFrame_Hello:SetWidth(335)
    Mounty.OptionsFrame_Hello:SetHeight(16)
    Mounty.OptionsFrame_Hello:SetPoint("TOPLEFT", 25, top)
    Mounty.OptionsFrame_Hello:SetAutoFocus(false)
    temp = Mounty.OptionsFrame_Hello:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    temp:SetPoint("BOTTOMLEFT", Mounty.OptionsFrame_Hello, "TOPLEFT", 0, 2)
    temp:SetText(L["options.Hello"])
    Mounty.OptionsFrame_Hello:SetScript("OnEnterPressed", function(calling)
        Mounty.CurrentProfile.Hello = calling:GetText()
        calling:ClearFocus()
    end)
    Mounty.OptionsFrame_Hello:SetScript("OnEscapePressed", function(calling)
        calling:SetText(Mounty.CurrentProfile.Hello)
    end)

    temp = TLVlib:Button(Mounty.OptionsFrame, "TOPLEFT", 360, top + 3, 32, 22, L["button.OK"])
    temp:SetScript("OnClick", function()
        Mounty.CurrentProfile.Hello = Mounty.OptionsFrame_Hello:GetText()
        Mounty.OptionsFrame_Hello:ClearFocus()
    end)

    -- Durability slider

    top = top - delta * 5

    Mounty.OptionsFrame_DurabilityMin = CreateFrame("Slider", "Mounty_OptionsFrame_DurabilityMin", Mounty.OptionsFrame, "OptionsSliderTemplate")
    Mounty.OptionsFrame_DurabilityMin:SetWidth(440)
    Mounty.OptionsFrame_DurabilityMin:SetHeight(16)
    Mounty.OptionsFrame_DurabilityMin:SetPoint("TOPLEFT", 25, top)
    Mounty_OptionsFrame_DurabilityMinLow:SetText("50%")
    Mounty_OptionsFrame_DurabilityMinHigh:SetText("100%")
    Mounty.OptionsFrame_DurabilityMin:SetMinMaxValues(50, 100)
    Mounty.OptionsFrame_DurabilityMin:SetValueStep(1)
    Mounty.OptionsFrame_DurabilityMin:SetScript("OnValueChanged", function(_, value)
        Mounty_OptionsFrame_DurabilityMinText:SetFormattedText(L["options.Durability"], value)
        Mounty.CurrentProfile.DurabilityMin = value
    end)

    -- Current profile

    top = top - delta * 6

    Mounty.OptionsFrame_ProfileDropdown = CreateFrame("FRAME", nil, Mounty.OptionsFrame, "UIDropDownMenuTemplate")
    Mounty.OptionsFrame_ProfileDropdown:SetPoint("TOPLEFT", 0, top + 6);
    temp = Mounty.OptionsFrame_ProfileDropdown:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    temp:SetPoint("BOTTOMLEFT", Mounty.OptionsFrame_ProfileDropdown, "TOPLEFT", 20, -2)
    temp:SetText(L["options.Profile"])
    UIDropDownMenu_SetWidth(Mounty.OptionsFrame_ProfileDropdown, 100)
    UIDropDownMenu_SetText(Mounty.OptionsFrame_ProfileDropdown, _Mounty_C.CurrentProfile)
    UIDropDownMenu_JustifyText(Mounty.OptionsFrame_ProfileDropdown, "LEFT")
    UIDropDownMenu_Initialize(Mounty.OptionsFrame_ProfileDropdown, function()

        local info = UIDropDownMenu_CreateInfo()

        for _, profile in ipairs(Mounty:ProfilesSorted()) do

            info.text = profile
            info.checked = profile == _Mounty_C.CurrentProfile
            info.func = function(p)
                Mounty:SwitchProfile(p.value)
            end

            UIDropDownMenu_AddButton(info)

        end

    end)

    Mounty.OptionsFrame_Profile = CreateFrame("EditBox", nil, Mounty.OptionsFrame, "InputBoxTemplate")
    Mounty.OptionsFrame_Profile:SetWidth(80)
    Mounty.OptionsFrame_Profile:SetHeight(16)
    Mounty.OptionsFrame_Profile:SetPoint("TOPLEFT", 155, top)
    Mounty.OptionsFrame_Profile:SetAutoFocus(false)
    Mounty.OptionsFrame_Profile:SetScript("OnEnterPressed", function(calling)
        calling:ClearFocus()
        Mounty:NewProfile(calling:GetText())
    end)

    -- Profile buttons 1

    local left = 242

    temp = TLVlib:Button(Mounty.OptionsFrame, "TOPLEFT", left, top + 3, 60, 22, L["button.Add"])
    temp:SetScript("OnClick", function()
        Mounty:NewProfile(Mounty.OptionsFrame_Profile:GetText())
    end)

    temp = TLVlib:Button(Mounty.OptionsFrame, "TOPLEFT", left + 58, top + 3, 60, 22, L["button.Duplicate"])
    temp:SetScript("OnClick", function()
        Mounty:DuplicateProfile(_Mounty_C.CurrentProfile, Mounty.OptionsFrame_Profile:GetText())
    end)

    temp = TLVlib:Button(Mounty.OptionsFrame, "TOPLEFT", left + 116, top + 3, 60, 22, L["button.Edit"])
    temp:SetScript("OnClick", function()
        Mounty:DuplicateProfile(_Mounty_C.CurrentProfile, Mounty.OptionsFrame_Profile:GetText(), true)
    end)

    temp = TLVlib:Button(Mounty.OptionsFrame, "TOPLEFT", left + 174, top + 3, 60, 22, L["button.Delete"])
    temp:SetScript("OnClick", function()
        Mounty:DeleteProfile(_Mounty_C.CurrentProfile)
    end)

    -- Share profiles checkbox

    top = top - 22

    Mounty.OptionsFrame_ShareProfiles = CreateFrame("CheckButton", "Mounty_OptionsFrame_ShareProfiles", Mounty.OptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    Mounty.OptionsFrame_ShareProfiles:SetPoint("TOPLEFT", 16, top)
    Mounty_OptionsFrame_ShareProfilesText:SetText(L["options.ShareProfiles"])
    Mounty.OptionsFrame_ShareProfiles:SetScript("OnClick", function()
        _Mounty_C.ShareProfiles = not _Mounty_C.ShareProfiles
        _Mounty_C.CurrentProfile = nil
        Mounty:InitSavedVariables()
        Mounty:OptionsRender()

    end)

    -- Profile buttons 2

    temp = TLVlib:Button(Mounty.OptionsFrame, "TOPLEFT", left + 40, top, 98, 22, L["button.CopyC2A"])
    temp:SetScript("OnClick", function()
        Mounty:CopyProfiles("c>a")
    end)

    temp = TLVlib:Button(Mounty.OptionsFrame, "TOPLEFT", left + 40 + 96, top, 98, 22, L["button.CopyA2C"])
    temp:SetScript("OnClick", function()
        Mounty:CopyProfiles("a>c")
    end)

    -- Parachute checkbox

    top = top - delta * 4

    Mounty.OptionsFrame_Parachute = CreateFrame("CheckButton", "Mounty_OptionsFrame_Parachute", Mounty.OptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    Mounty.OptionsFrame_Parachute:SetPoint("TOPLEFT", 16, top)
    Mounty_OptionsFrame_ParachuteText:SetText(L["options.Parachute"])
    Mounty.OptionsFrame_Parachute:SetScript("OnClick", function(calling)
        _Mounty_A.Parachute = not _Mounty_A.Parachute
        calling:SetChecked(_Mounty_A.Parachute)
    end)

    -- Auto open checkbox

    top = top - 22

    Mounty.OptionsFrame_AutoOpen = CreateFrame("CheckButton", "Mounty_OptionsFrame_AutoOpen", Mounty.OptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    Mounty.OptionsFrame_AutoOpen:SetPoint("TOPLEFT", 16, top)
    Mounty_OptionsFrame_AutoOpenText:SetText(L["options.Autoopen"])
    Mounty.OptionsFrame_AutoOpen:SetScript("OnClick", function(calling)
        _Mounty_A.AutoOpen = not _Mounty_A.AutoOpen
        --        calling:SetChecked(_Mounty_A.AutoOpen)
        Mounty:OptionsRender()
    end)

    -- Journal button slider

    top = top - delta * 5

    Mounty.OptionsFrame_JournalButtonOffset = CreateFrame("Slider", "Mounty_OptionsFrame_JournalButtonOffset", Mounty.OptionsFrame, "OptionsSliderTemplate")
    Mounty.OptionsFrame_JournalButtonOffset:SetWidth(440)
    Mounty.OptionsFrame_JournalButtonOffset:SetHeight(16)
    Mounty.OptionsFrame_JournalButtonOffset:SetPoint("TOPLEFT", 25, top)
    Mounty_OptionsFrame_JournalButtonOffsetLow:SetText("-425")
    Mounty_OptionsFrame_JournalButtonOffsetHigh:SetText("1")
    Mounty.OptionsFrame_JournalButtonOffset:SetMinMaxValues(-425, 1)
    Mounty.OptionsFrame_JournalButtonOffset:SetValueStep(1)
    Mounty.OptionsFrame_JournalButtonOffset:SetScript("OnValueChanged", function(_, value)
        Mounty_OptionsFrame_JournalButtonOffsetText:SetFormattedText(L["options.JournalButtonOffset"], value)
        _Mounty_A.JournalButtonOffset = value
        Mounty:OptionsRender()
    end)

    -- DebugMode checkbox

    top = top - delta * 4

    Mounty.OptionsFrame_DebugMode = CreateFrame("CheckButton", "Mounty_OptionsFrame_DebugMode", Mounty.OptionsFrame, "InterfaceOptionsCheckButtonTemplate")
    Mounty.OptionsFrame_DebugMode:SetPoint("TOPLEFT", 16, top)
    Mounty_OptionsFrame_DebugModeText:SetText(L["options.Debug"])
    Mounty.OptionsFrame_DebugMode:SetScript("OnClick", function(calling)
        _Mounty_A.DebugMode = not _Mounty_A.DebugMode
        calling:SetChecked(_Mounty_A.DebugMode)
    end)

    -- Open Mounts

    Mounty.OptionsFrame_JournalButton = TLVlib:Button(Mounty.OptionsFrame, "TOPLEFT", left + 40, top, 98, 22, L["button.Journal"])
    Mounty.OptionsFrame_JournalButton:SetScript("OnClick", function()
        ToggleCollectionsJournal(1)
    end)

    -- Open Quick start

    temp = TLVlib:Button(Mounty.OptionsFrame, "TOPLEFT", left + 40 + 96, top, 98, 22, L["button.Help"])
    temp:SetScript("OnClick", function()
        if Mounty.QuickStartFrame:IsVisible() then
            Mounty.QuickStartFrame:Hide()
        else
            Mounty.QuickStartFrame:Show()
        end
    end)

    Mounty.OptionsFrame:SetHeight(-top + 34)


end

function Mounty:InitQuickStartFrame()

    Mounty.QuickStartFrame = CreateFrame("Frame", nil, Mounty.OptionsFrame, "SettingsFrameTemplate")
    Mounty.QuickStartFrame:SetWidth(640)
    Mounty.QuickStartFrame:SetHeight(150)
    Mounty.QuickStartFrame:SetPoint("CENTER", 0, 0)
    Mounty.QuickStartFrame:SetFrameStrata("DIALOG")

    Mounty:SettingsFrameTemplateSetBg(Mounty.QuickStartFrame)

    temp = Mounty.QuickStartFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    temp:SetPoint("TOP", 0, -6)
    temp:SetText(L["quick.title"])

    temp = Mounty.QuickStartFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    temp:SetPoint("TOP", 0, -32)
    temp:SetJustifyH("LEFT")
    temp:SetText(L["quick.text"])

    temp = CreateFrame("EditBox", nil, Mounty.QuickStartFrame, "InputBoxTemplate")
    temp:SetWidth(400)
    temp:SetHeight(16)
    temp:SetPoint("TOP", 0, -120)
    temp:SetAutoFocus(false)
    temp:SetText(L["readme.URL"])

    if not _Mounty_A.QuickStart then
        Mounty.QuickStartFrame:Hide()
    end

end

function Mounty:InitExpandedFrame()

    local temp

    Mounty.ExpandedFrame = CreateFrame("Frame", nil, Mounty.OptionsFrame, "SettingsFrameTemplate")
    Mounty.ExpandedFrame:SetWidth(288)
    Mounty.ExpandedFrame:SetHeight(360)
    Mounty.ExpandedFrame:SetPoint("TOPRIGHT", 288, 0)
    Mounty.ExpandedFrame:SetFrameStrata("HIGH")

    Mounty:SettingsFrameTemplateSetBg(Mounty.ExpandedFrame)

    Mounty.ExpandedFrame:EnableMouse(true)
    Mounty.ExpandedFrame:SetMovable(true)
    Mounty.ExpandedFrame:RegisterForDrag("LeftButton")
    Mounty.ExpandedFrame:SetScript("OnDragStart", function(calling)
        calling:StartMoving()
    end)
    Mounty.ExpandedFrame:SetScript("OnDragStop", function(calling)
        calling:StopMovingOrSizing()
    end)

    Mounty.ExpandedFrame_Title = Mounty.ExpandedFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    Mounty.ExpandedFrame_Title:SetPoint("TOP", 0, -6)
    Mounty.ExpandedFrame_Title:SetText("TITLE to be replaced")

    Mounty.ExpandedFrame.MountyCategory = Mounty.TypeGround -- safety 1st

    -- Mounts 10 x 10

    Mounty.ExpandedFrame_Buttons = {}

    local top = -12

    local index = Mounty.NumMounts

    for y = 1, 10 do

        y = y -- use

        top = top - 26

        for x = 1, 10 do

            index = index + 1

            Mounty.ExpandedFrame_Buttons[index] = CreateFrame("Button", nil, Mounty.ExpandedFrame)
            Mounty.ExpandedFrame_Buttons[index].MountyIndex = index
            Mounty.ExpandedFrame_Buttons[index]:SetSize(24, 24)
            Mounty.ExpandedFrame_Buttons[index]:SetDisabledTexture("Interface\\Buttons\\UI-EmptySlot")
            Mounty.ExpandedFrame_Buttons[index]:GetDisabledTexture():SetTexCoord(0.15, 0.85, 0.15, 0.85)
            Mounty.ExpandedFrame_Buttons[index]:SetHighlightTexture("Interface\\Buttons\\UI-StopButton")
            Mounty.ExpandedFrame_Buttons[index]:SetPoint("TOPLEFT", 18 + (x - 1) * 26, top)
            Mounty.ExpandedFrame_Buttons[index]:SetScript("OnMouseUp", function(calling, button)
                if button == "LeftButton" then
                    Mounty:AddMount(calling, true)
                elseif button == "RightButton" then
                    Mounty:RemoveMount(calling, true)
                end
            end)
            Mounty.ExpandedFrame_Buttons[index]:SetScript("OnDoubleClick", function(calling)
                Mounty:CopyMount(calling, true)
            end)
            Mounty.ExpandedFrame_Buttons[index]:SetScript("OnEnter", function(calling)
                Mounty:Tooltip(calling, true)
            end)
            Mounty.ExpandedFrame_Buttons[index]:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

        end

    end

    top = top - 32

    temp = TLVlib:Button(Mounty.ExpandedFrame, "TOPLEFT", 18, top, 192, 22, L["expanded.Add"])
    temp:SetScript("OnClick", function()
        Mounty:AddMountsFromJournalToCategory()
    end)

    temp = TLVlib:Button(Mounty.ExpandedFrame, "TOPLEFT", 216, top, 60, 22, L["expanded.Refresh"])
    temp:SetScript("OnClick", function()
        Mounty:RefreshCategory()
    end)

    top = top - 24

    temp = TLVlib:Button(Mounty.ExpandedFrame, "TOPLEFT", 216, top, 60, 22, L["expanded.Clear"])
    temp:SetScript("OnClick", function()
        Mounty:ClearCategory()
    end)

    Mounty.ExpandedFrame:Hide()

end

function Mounty:AddMountsFromJournalToCategory()

    StaticPopupDialogs["Mounty_AddMountsFromJournal"] = {
        text = L["expanded.popup.add-journal-confirm"],
        button1 = YES,
        button2 = NO,
        sound = IG_MAINMENU_OPEN,
        timeout = 20,
        whileDead = true,
        hideOnEscape = true,
        OnAccept = function()

            local category

            local empty

            category = Mounty:ValidCategory(Mounty.ExpandedFrame.MountyCategory)

            if not category then
                return
            end

            Mounty:ReorderCategory(category)

            -- find 1st empty slot

            empty = 0

            for i = 1, Mounty.NumMountsExpanded do
                if empty == 0 and Mounty.CurrentProfile.Mounts[category][i] == 0 then
                    empty = i
                end
            end

            if empty == 0 then
                return
            end

            local added = 0

            for i = 1, C_MountJournal.GetNumDisplayedMounts() do

                local mountID = C_MountJournal.GetDisplayedMountID(i)

                if empty <= Mounty.NumMountsExpanded then

                    if Mounty.CurrentProfile.Mounts[category][empty] == 0 then

                        if not Mounty:AlreadyInCategory(category, spellID) then

                            local _, spellID, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID);

                            if isCollected and hideOnChar ~= true then

                                Mounty.CurrentProfile.Mounts[category][empty] = spellID
                                added = added + 1
                                empty = empty + 1

                            end
                        end

                    end

                end

            end

            Mounty:OptionsRenderButtons()

            TLVlib:Debug("Added " .. added .. " new mounts to the current category.")

        end
    }

    -- https://wowpedia.fandom.com/wiki/Creating_simple_pop-up_dialog_boxes

    StaticPopup_Show("Mounty_AddMountsFromJournal")

end

function Mounty:RefreshCategory()

    StaticPopupDialogs["Mounty_RefreshExpanded"] = {
        text = L["expanded.popup.refresh-confirm"],
        button1 = YES,
        button2 = NO,
        sound = IG_MAINMENU_OPEN,
        timeout = 20,
        whileDead = true,
        hideOnEscape = true,
        OnAccept = function()

            local category = Mounty:ValidCategory(Mounty.ExpandedFrame.MountyCategory)

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
        text = L["expanded.popup.clear-confirm"],
        button1 = YES,
        button2 = NO,
        sound = IG_MAINMENU_OPEN,
        timeout = 20,
        whileDead = true,
        hideOnEscape = true,
        OnAccept = function()

            local category = Mounty:ValidCategory(Mounty.ExpandedFrame.MountyCategory)

            if not category then
                return
            end

            for i = 1, Mounty.NumMountsExpanded do
                Mounty.CurrentProfile.Mounts[category][i] = 0
            end

            Mounty:OptionsRenderButtons()

        end
    }

    -- https://wowpedia.fandom.com/wiki/Creating_simple_pop-up_dialog_boxes

    StaticPopup_Show("Mounty_ClearExpanded")

end

function Mounty:ReorderCategory (category)

    local j

    for i = 1, Mounty.NumMountsExpanded - 1 do

        if Mounty.CurrentProfile.Mounts[category][i] == 0 then

            j = i + 1

            while (j < Mounty.NumMountsExpanded and Mounty.CurrentProfile.Mounts[category][j] == 0) do
                j = j + 1
            end

            if Mounty.CurrentProfile.Mounts[category][j] > 0 then
                Mounty.CurrentProfile.Mounts[category][i] = Mounty.CurrentProfile.Mounts[category][j]
                Mounty.CurrentProfile.Mounts[category][j] = 0
            end

        end

    end

end

function Mounty:ValidCategory (category)

    if category == nil then
        return false
    end

    if category < 1 or category > Mounty.NumCategories then
        return false
    end

    return category

end

function Mounty:InitFrames()

    Mounty:InitOptionsFrame()
    Mounty:InitQuickStartFrame()
    Mounty:InitExpandedFrame()

end

function Mounty:OptionsRender()

    if not Mounty.OptionsFrame:IsVisible() then
        return
    end

    Mounty.OptionsFrame_Random:SetChecked(Mounty.CurrentProfile.Random)
    Mounty.OptionsFrame_Together:SetChecked(Mounty.CurrentProfile.Together)
    Mounty.OptionsFrame_Amphibian:SetChecked(Mounty.CurrentProfile.Amphibian)
    Mounty.OptionsFrame_ShowOff:SetChecked(Mounty.CurrentProfile.ShowOff)
    Mounty.OptionsFrame_TaxiMode:SetChecked(Mounty.CurrentProfile.TaxiMode)
    Mounty.OptionsFrame_Hello:SetText(Mounty.CurrentProfile.Hello)
    Mounty.OptionsFrame_DurabilityMin:SetValue(Mounty.CurrentProfile.DurabilityMin)
    Mounty.OptionsFrame_JournalButtonOffset:SetValue(_Mounty_A.JournalButtonOffset)

    Mounty.OptionsFrame_ShareProfiles:SetChecked(_Mounty_C.ShareProfiles)

    Mounty.OptionsFrame_Parachute:SetChecked(_Mounty_A.Parachute)
    Mounty.OptionsFrame_DebugMode:SetChecked(_Mounty_A.DebugMode)
    Mounty.OptionsFrame_AutoOpen:SetChecked(_Mounty_A.AutoOpen)

    Mounty.OptionsFrame_Profile:SetText("")

    UIDropDownMenu_SetText(Mounty.OptionsFrame_ProfileDropdown, _Mounty_C.CurrentProfile)

    if Mounty.CurrentProfile.TaxiMode then
        Mounty.OptionsFrame_Together:Disable()
        Mounty.OptionsFrame_Together:SetAlpha(0.4)
    else
        Mounty.OptionsFrame_Together:Enable()
        Mounty.OptionsFrame_Together:SetAlpha(1)
    end

    if _Mounty_A.AutoOpen then
        Mounty.OptionsFrame_JournalButton:Hide()
    else
        Mounty.OptionsFrame_JournalButton:Show()
    end

    if Mounty.JournalButton ~= nil then

        if _Mounty_A.JournalButtonOffset == 1 then
            Mounty.JournalButton:Hide()
        else
            Mounty.JournalButton:SetPoint("BOTTOMRIGHT", -6 + _Mounty_A.JournalButtonOffset, 4)
            Mounty.JournalButton:Show()
        end

    end

    Mounty:OptionsRenderButtons()

end

function Mounty:OptionsRenderButtons()

    local icon

    for category = 1, Mounty.NumCategories do

        for i = 1, Mounty.NumMounts do

            Mounty.OptionsFrame_Buttons[category][i]:Hide() -- Muss sein, sonst werden die nicht immer neu gezeichnet ?!

            if Mounty.CurrentProfile.Mounts[category][i] == 0 then
                Mounty.OptionsFrame_Buttons[category][i]:SetNormalTexture("")
                Mounty.OptionsFrame_Buttons[category][i]:Disable()
            else
                icon = GetSpellTexture(Mounty.CurrentProfile.Mounts[category][i])
                Mounty.OptionsFrame_Buttons[category][i]:SetNormalTexture(icon)
                Mounty.OptionsFrame_Buttons[category][i]:Enable()
            end

            Mounty.OptionsFrame_Buttons[category][i]:Show() -- Muss sein, sonst werden die nicht immer neu gezeichnet ?!
        end

    end

    Mounty:OptionsRenderExpandedButtons()

end

function Mounty:OptionsRenderExpandedButtons()

    if not Mounty.ExpandedFrame:IsVisible() then
        return
    end

    local icon

    local category = Mounty:ValidCategory(Mounty.ExpandedFrame.MountyCategory)

    if not category then
        return
    end

    for i = Mounty.NumMounts + 1, Mounty.NumMountsExpanded do

        Mounty.ExpandedFrame_Buttons[i]:Hide() -- Muss sein, sonst werden die nicht immer neu gezeichnet ?!

        if Mounty.CurrentProfile.Mounts[category][i] == 0 then
            Mounty.ExpandedFrame_Buttons[i]:SetNormalTexture("")
            Mounty.ExpandedFrame_Buttons[i]:Disable()
        else
            icon = GetSpellTexture(Mounty.CurrentProfile.Mounts[category][i])
            Mounty.ExpandedFrame_Buttons[i]:SetNormalTexture(icon)
            Mounty.ExpandedFrame_Buttons[i]:Enable()
        end

        Mounty.ExpandedFrame_Buttons[i]:Show() -- Muss sein, sonst werden die nicht immer neu gezeichnet ?!

    end

end

function Mounty:AddJournalButton()

    Mounty.JournalButton = TLVlib:Button(MountJournal, "BOTTOMRIGHT", -6 + _Mounty_A.JournalButtonOffset, 4, 128, 22, L["Mount journal - Open Mounty"])
    Mounty.JournalButton:SetScript("OnClick", function()
        if Mounty.OptionsFrame:IsVisible() then
            Mounty.OptionsFrame:Hide()
        else
            Mounty.OptionsFrame:ClearAllPoints()
            Mounty.OptionsFrame:SetPoint("TOPLEFT", CollectionsJournal, "TOPRIGHT", 0, 0)
            Mounty.OptionsFrame:Show()
        end
    end)

    if _Mounty_A.JournalButtonOffset == 1 then
        Mounty.JournalButton:Hide()
    end

end

function Mounty:ProfileNameDefault ()

    local profiles = Mounty:ProfilesSorted()

    local default = profiles[1]

    if Mounty.Profiles[default] == nil then
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
        err = "profile.popup.empty"
    elseif p ~= string.match(p, "[a-zA-Z0-9_]+") then
        err = "profile.popup.error"
    end

    if err ~= "" and alert then
        TLVlib:Alert(L[err])
    end

    return err == ""

end

function Mounty:DeleteProfile(p)

    if not Mounty:ProfileCheckName(p, true) then
        return
    end

    if Mounty.Profiles[p] == nil then

        TLVlib:Alert(string.format(L["profile.popup.none"], p))
        return

    end

    StaticPopupDialogs["Mounty_Delete_Profile"] = {
        text = L["profile.popup.delete-confirm"],
        button1 = YES,
        button2 = NO,
        sound = IG_MAINMENU_OPEN,
        timeout = 20,
        whileDead = true,
        hideOnEscape = true,
        OnAccept = function(_, data)
            Mounty.Profiles[data] = nil
            Mounty:SwitchProfile(Mounty:ProfileNameDefault())
        end
    }

    -- https://wowpedia.fandom.com/wiki/Creating_simple_pop-up_dialog_boxes

    local popup = StaticPopup_Show("Mounty_Delete_Profile", p) -- Ersetzt automatisch %s in L["profile.popup.delete-confirm"] durch p
    if popup then
        popup.data = p -- setzt data im Objekt auf p
    end

end

function Mounty:NewProfile (p)

    if not Mounty:ProfileCheckName(p, true) then
        return
    end

    if Mounty.Profiles[p] ~= nil then
        TLVlib:Alert(string.format(L["profile.popup.already"], p))
        return
    end

    Mounty:SwitchProfile(p)

end

function Mounty:DuplicateProfile (p_from, p, rename)

    if not Mounty:ProfileCheckName(p, true) then
        return
    end

    if Mounty.Profiles[p] ~= nil then
        TLVlib:Alert(string.format(L["profile.popup.already"], p))
        return
    end

    if not Mounty:ProfileCheckName(p_from, true) then
        return
    end

    if Mounty.Profiles[p_from] == nil then

        TLVlib:Alert(string.format(L["profile.popup.none"], p_from))
        return

    end

    Mounty.Profiles[p] = TLVlib:TableDuplicate(Mounty.Profiles[p_from])

    if rename then
        Mounty.Profiles[p_from] = nil
    end

    Mounty:SwitchProfile(p)

end

function Mounty:SwitchProfile(p)

    if p == "" then
        TLVlib:Alert(string.format(L["profile.popup.empty"], p))
        return
    end

    if not Mounty:ProfileCheckName(p, true) then
        return
    end

    Mounty:SelectProfile(p)

    if Mounty.OptionsFrame:IsVisible() then
        Mounty:OptionsRender()
    end

end

function Mounty:SelectProfile(p)

    if not Mounty:ProfileCheckName(p) then
        return
    end

    if Mounty.Profiles[p] == nil then
        Mounty.Profiles[p] = {}
    end

    if Mounty.Profiles[p].TaxiMode == nil then
        Mounty.Profiles[p].TaxiMode = false
    end

    if Mounty.Profiles[p].Together == nil then
        Mounty.Profiles[p].Together = false
    end

    if Mounty.Profiles[p].Amphibian == nil then
        Mounty.Profiles[p].Amphibian = false
    end

    if Mounty.Profiles[p].DoNotShowOff == nil then
        Mounty.Profiles[p].DoNotShowOff = false
    end

    if Mounty.Profiles[p].ShowOff == nil then
        Mounty.Profiles[p].ShowOff = not Mounty.Profiles[p].DoNotShowOff
    end

    if Mounty.Profiles[p].Random == nil then
        Mounty.Profiles[p].Random = false
    end

    if Mounty.Profiles[p].DurabilityMin == nil then
        Mounty.Profiles[p].DurabilityMin = 75
    end

    if Mounty.Profiles[p].Hello == nil then
        Mounty.Profiles[p].Hello = L["options.Hello-Default"]
    end

    if Mounty.Profiles[p].Mounts == nil then
        Mounty.Profiles[p].Mounts = {}
    end

    if Mounty.Profiles[p].Iterator == nil then
        Mounty.Profiles[p].Iterator = {}
    end

    for category = 1, Mounty.NumCategories do

        if Mounty.Profiles[p].Iterator[category] == nil then
            Mounty.Profiles[p].Iterator[category] = 0
        end

        if Mounty.Profiles[p].Mounts[category] == nil then
            Mounty.Profiles[p].Mounts[category] = {}
        end

        for i = 1, Mounty.NumMountsExpanded do
            if Mounty.Profiles[p].Mounts[category][i] == nil then
                Mounty.Profiles[p].Mounts[category][i] = 0
            end
        end
    end

    _Mounty_C.CurrentProfile = p

    Mounty.CurrentProfile = Mounty.Profiles[p];

end

function Mounty:ProfilesSorted (joined)

    local profiles = {}

    for k, _ in pairs(Mounty.Profiles) do

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
        text = L["profile.popup.copy-confirm"],
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
                Profiles_Src = _Mounty_C.Profiles
                Profiles_Dst = _Mounty_A.Profiles
            else
                Profiles_Src = _Mounty_A.Profiles
                Profiles_Dst = _Mounty_C.Profiles
            end

            for k, _ in pairs(Profiles_Src) do

                local i = 1
                local dk = k

                while (Profiles_Dst[dk] ~= nil) do
                    dk = string.format("%s_%d", k, i)
                    i = i + 1
                end

                Profiles_Dst[dk] = TLVlib:TableDuplicate(Profiles_Src[k])

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

    if _Mounty_A == nil then
        _Mounty_A = {}
    end

    if _Mounty_C == nil then
        _Mounty_C = {}
    end

    if _Mounty_C.ShareProfiles == nil then
        _Mounty_C.ShareProfiles = false
    end

    if _Mounty_C.Profiles == nil then
        _Mounty_C.Profiles = {}
    end

    if _Mounty_A.Profiles == nil then
        _Mounty_A.Profiles = {}
    end

    if _Mounty_C.ShareProfiles then
        Mounty.Profiles = _Mounty_A.Profiles -- Pointer per Reference!
    else
        Mounty.Profiles = _Mounty_C.Profiles -- Pointer per Reference!
    end

    if Mounty.Profiles == nil then
        Mounty.Profiles = {}
    end

    if _Mounty_C.CurrentProfile == nil then

        local profiles = Mounty:ProfilesSorted()

        _Mounty_C.CurrentProfile = profiles[1]

        if Mounty.Profiles[_Mounty_C.CurrentProfile] == nil then
            _Mounty_C.CurrentProfile = Mounty:ProfileNameDefault()

        end

    end

    if _Mounty_A.Parachute == nil then
        _Mounty_A.Parachute = false
    end

    if _Mounty_A.DebugMode == nil then
        _Mounty_A.DebugMode = false
    end

    if _Mounty_A.AutoOpen == nil then
        _Mounty_A.AutoOpen = true
    end

    if _Mounty_A.JournalButtonOffset == nil then
        _Mounty_A.JournalButtonOffset = 0
    end

    Mounty:SelectProfile(_Mounty_C.CurrentProfile)

    -- show quick start?

    if _Mounty_A.QuickStart == nil then
        _Mounty_A.QuickStart = true
    else
        _Mounty_A.QuickStart = true
        for category = 1, Mounty.NumCategories do
            if Mounty.CurrentProfile.Mounts[category][1] ~= 0 then
                _Mounty_A.QuickStart = false
            end
        end
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

EventRegistry:RegisterCallback("MountJournal.OnShow", function()

    -- add button just once
    if CollectionsJournal.selectedTab == COLLECTIONS_JOURNAL_TAB_INDEX_MOUNTS and not Mounty.JournalButtonAdded then
        Mounty:AddJournalButton()
        Mounty.JournalButtonAdded = true
    end

    -- auto open mounty with mount journal
    if _Mounty_A.AutoOpen then
        Mounty.OptionsFrame:ClearAllPoints()
        Mounty.OptionsFrame:SetPoint("TOPLEFT", CollectionsJournal, "TOPRIGHT", 0, 0)
        Mounty.OptionsFrame:Show()
    end

end, Mounty_Name)

EventRegistry:RegisterCallback("MountJournal.OnHide", function()
    if _Mounty_A.AutoOpen then
        Mounty.OptionsFrame:Hide()
    end
end, Mounty_Name)

function Mounty:Init (event, arg1)

    if event == "ADDON_LOADED" and arg1 == Mounty_Name then

        TLVlib:Init()

        Mounty:Upgrade()

        Mounty:InitSavedVariables()

        Mounty:InitFrames()

        self:UnregisterEvent("ADDON_LOADED")

    end

end

local TLV_Init_Frame = CreateFrame("Frame")
TLV_Init_Frame:RegisterEvent("ADDON_LOADED")
TLV_Init_Frame:SetScript("OnEvent", Mounty.Init)

-- /mounty

SLASH_TLV_MOUNTY1 = "/mounty"
SlashCmdList["TLV_MOUNTY"] = function(message)

    message = message or ""

    local mode, arg1, arg2 = string.split(" ", message, 3)

    mode = string.lower(mode or "")
    arg1 = arg1 or ""
    arg2 = arg2 or ""

    local okay = true

    if mode == "" then

        Mounty.OptionsFrame:Show();

    elseif mode == "magic" then

        Mounty:KeyHandler()

    elseif mode == "version" then

        TLVlib:Chat("<-- ;)")

    elseif mode == "profile" then

        if arg1 == "" then
            TLVlib:Chat(string.format(L["profile.current"], _Mounty_C.CurrentProfile))
        else
            Mounty:SwitchProfile(arg1)
            if arg1 == _Mounty_C.CurrentProfile then
                TLVlib:Chat(string.format(L["profile.switched"], arg1))
            end
        end

    elseif mode == "set" then

        local suffix

        if arg2 == "on" then

            suffix = "|cff00f010" .. L["on"] .. "|r."

        elseif arg2 == "off" then

            suffix = "|cfff01000" .. L["off"] .. "|r."

        else

            okay = false

        end

        if okay then

            if arg1 == "amphibian" then

                Mounty.CurrentProfile.Amphibian = (arg2 == "on")
                TLVlib:Chat(L["chat.Amphibian"] .. suffix)

            elseif arg1 == "auto" then

                _Mounty_A.AutoOpen = (arg2 == "on")
                TLVlib:Chat(L["chat.Autoopen"] .. suffix)

            elseif arg1 == "debug" then

                _Mounty_A.DebugMode = (arg2 == "on")
                TLVlib:Chat(L["chat.Debug"] .. suffix)

            elseif arg1 == "parachute" then

                _Mounty_A.Parachute = (arg2 == "on")
                TLVlib:Chat(L["chat.Parachute"] .. suffix)

            elseif arg1 == "random" then

                Mounty.CurrentProfile.Random = (arg2 == "on")
                TLVlib:Chat(L["chat.Random"] .. suffix)

            elseif arg1 == "showoff" then

                Mounty.CurrentProfile.ShowOff = (arg2 == "on")
                TLVlib:Chat(L["chat.Showoff"] .. suffix)

            elseif arg1 == "taxi" then

                Mounty.CurrentProfile.TaxiMode = (arg2 == "on")
                TLVlib:Chat(L["chat.Taxi"] .. suffix)

            elseif arg1 == "together" then

                Mounty.CurrentProfile.Together = (arg2 == "on")
                TLVlib:Chat(L["chat.Together"] .. suffix)

            else

                okay = false

            end

            if okay then

                Mounty:OptionsRender()

            end

        end

    -- elseif mode == "dbg" then

        --    TLVlib:TableDebug(Mounty.QuickStartFrame)

    elseif mode == "dragonflight"
            or mode == "fly"
            or mode == "ground"
            or mode == "water"
            or mode == "repair"
            or mode == "taxi"
            or mode == "showoff"
            or mode == "random"
            or mode == "custom1"
            or mode == "custom2"
            or mode == "custom3"
    then

        Mounty:Mount(mode)

    else

        okay = false

    end

    if not okay then

        TLVlib:Chat(gsub(L["help"], "||", "|cfff0b040|||r"))

    end

end

