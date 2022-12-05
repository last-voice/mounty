function deepTableCopy(copy_from)

    local copy_to = {}

    for k, v in pairs(copy_from) do
        if type(v) == "table" then
            v = deepTableCopy(v)
        end
        copy_to[k] = v
    end

    return copy_to

end