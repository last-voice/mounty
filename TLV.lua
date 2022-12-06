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

--- Opts:
---     name (string): Name of the dropdown (lowercase)
---     parent (Frame): Parent frame of the dropdown.
---     items (Table): String table of the dropdown options.
---     defaultVal (String): String value for the dropdown to default to (empty otherwise).
---     changeFunc (Function): A custom function to be called, after selecting a dropdown option.
---
--- Thanks to Jordan Benge
--- https://jordanbenge.medium.com/creating-a-wow-dropdown-menu-in-pure-lua-db7b2f9c0364
---
function TLV:Dropdown(opts)
    local dropdown_name = "$parent_" .. opts["name"] .. "_dropdown"
    local menu_items = opts["items"] or {}
    local title_text = opts["title"] or ""
    local dropdown_width = 0
    local default_val = opts["defaultVal"] or ""
    local change_func = opts["changeFunc"] or function(dropdown_val)
    end

    local dropdown = CreateFrame("Frame", dropdown_name, opts["parent"], "UIDropDownMenuTemplate")
    local dd_title = dropdown:CreateFontString(nil, "OVERLAY", "GameFontNormal")

    dd_title:SetPoint("TOPLEFT", 20, 10)

    for _, item in pairs(menu_items) do
        -- Sets the dropdown width to the largest item string width.
        dd_title:SetText(item)
        local text_width = dd_title:GetStringWidth() + 40
        if text_width > dropdown_width then
            dropdown_width = text_width
        end
    end

    UIDropDownMenu_SetWidth(dropdown, dropdown_width)
    UIDropDownMenu_SetText(dropdown, default_val)
    dd_title:SetText(title_text)

    UIDropDownMenu_Initialize(dropdown, function(self, level, _)
        local info = UIDropDownMenu_CreateInfo()
        for key, val in pairs(menu_items) do
            info.text = val;
            info.checked = false
            info.menuList = key
            info.hasArrow = false
            info.func = function(b)
                UIDropDownMenu_SetSelectedValue(dropdown, b.value, b.value)
                UIDropDownMenu_SetText(dropdown, b.value)
                b.checked = true
                change_func(dropdown, b.value)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    return dropdown
end

function TLV:Button(parent, point, x, y, width, strata, text)

    local temp = CreateFrame("Button", nil, parent)
    temp:SetFrameStrata(strata)
    temp:SetPoint(point, x, y)
    temp:SetSize(width, 21)
    temp:SetNormalFontObject(GameFontNormal)
    temp:SetHighlightFontObject(GameFontHighlight)
    temp:SetNormalTexture(130763) -- "Interface\\Buttons\\UI-DialogBox-Button-Up"
    temp:GetNormalTexture():SetTexCoord(0.0, 1.0, 0.0, 0.71875)
    temp:SetPushedTexture(130761) -- "Interface\\Buttons\\UI-DialogBox-Button-Down"
    temp:GetPushedTexture():SetTexCoord(0.0, 1.0, 0.0, 0.71875)
    temp:SetHighlightTexture(130762) -- "Interface\\Buttons\\UI-DialogBox-Button-Highlight"
    temp:GetHighlightTexture():SetTexCoord(0.0, 1.0, 0.0, 0.71875)
    temp:SetText(text)

    return temp

end
