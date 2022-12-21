local TLV_AddOn_Name, TLV_AddOn = ...

local TLVlib = {}

function TLVlib:AddOnHeader ()

    if (TLVlib.AddOnTitle ~= nil and TLVlib.AddOnVersion ~= nil) then
        return (TLVlib.AddOnTitle .. " " .. TLVlib.AddOnVersion)
    end

    return "untitled"

end

function TLVlib:TableDebug(src, depth)

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
            TLVlib:TableDebug(v, depth + 1)
        elseif type(v) == "string" then
            print(line .. "(string) " .. v)
        elseif type(v) == "number" then
            print(line .. "(number) " .. v)
        else
            print(line .. "(" .. type(v) .. ")")
        end

    end

end

function TLVlib:TableDuplicate(src)

    local dest = {}

    for k, v in pairs(src) do

        if type(v) == "table" then
            v = TLVlib:TableDuplicate(v)
        end
        dest[k] = v
    end

    return dest

end

function TLVlib:Button(parent, point, x, y, width, height, text)

    local temp = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    temp:SetPoint(point, x, y)
    temp:SetSize(width, height)
    temp:SetText(text)

    return temp

end

function TLVlib:Alert (alert)

    if (alert == nil) then
        StaticPopup_hide("TLV_ALERT")
        return
    end

    StaticPopupDialogs["TLV_ALERT"] = {
        text = "|cfff0b040" .. TLVlib:AddOnHeader() .. "|r\n\n" .. alert,
        button1 = OKAY,
        sound = IG_MAINMENU_OPEN,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true
    }

    StaticPopup_Show("TLV_ALERT")

end

function TLVlib:Chat(msg)

    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage(TLVlib:AddOnHeader() .. ": " .. msg, 1, 1, 0)
    end

end

TLVlib.DebugModeForce = false

function TLVlib:Debug(msg)

    if _DataAccount.DebugMode or TLVlib.DebugModeForce then
        TLVlib:Chat(msg)
    end

end

function TLVlib:Init ()

    TLVlib.AddOnTitle = GetAddOnMetadata(TLV_AddOn_Name, "Title")
    TLVlib.AddOnVersion = GetAddOnMetadata(TLV_AddOn_Name, "Version")

end

TLV_AddOn.TLVlib = TLVlib