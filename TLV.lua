TLV = {}

function TLV:TableCopy(copy_from)

    local copy_to = {}

    for k, v in pairs(copy_from) do

        if type(v) == "table" then
            v = TLV:TableCopy(v)
        end
        copy_to[k] = v
    end

    return copy_to

end

function TLV:Button(parent, point, x, y, width, text)

    local temp = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    temp:SetPoint(point, x, y)
    temp:SetSize(width, 21)
    temp:SetText(text)

    return temp

end

function TLV:Alert (alert)

    if (alert == nil) then
        StaticPopup_hide("TLV_ALERT")
        return
    end

    StaticPopupDialogs["TLV_ALERT"] = {
        text = alert,
        button1 = OKAY,
        sound = IG_MAINMENU_OPEN,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true
    }

    StaticPopup_Show("TLV_ALERT")

end