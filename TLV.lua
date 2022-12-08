TLV = {}

function TLV:TableDuplicate(src)

    local dest = {}

    for k, v in pairs(src) do

        if type(v) == "table" then
            v = TLV:TableDuplicate(v)
        end
        dest[k] = v
    end

    return dest

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