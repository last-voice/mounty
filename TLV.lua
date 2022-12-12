TLV = {}

function TLV:TableDebug(src, depth)

    local line

    depth = depth or 0

    for k, v in pairs(src) do

        line = ""

        for s = 1, depth do
            line = line .. "  "
        end

        line = line .. k .. " = "

        if type(v) == "table" then
            print(line .. "(table)")
            TLV:TableDebug(v, depth + 1)
        elseif type(v) == "string" then
            print(line .. "(string) " .. v)
        elseif type(v) == "number" then
            print(line .. "(number) " .. v)
        else
            print(line .. "(" .. type(v) .. ")")
        end

    end

end

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

function TLV:Button(parent, point, x, y, width, height, text)

    local temp = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    temp:SetPoint(point, x, y)
    temp:SetSize(width, height)
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