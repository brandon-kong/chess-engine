return function(...)
    local b = {}
    if ... then
       for i, v in ipairs({...}) do
            if type(v) == "table" then
                 for i2, v2 in ipairs(v) do
                    table.insert(b, v2)
                 end
            else
                 table.insert(b, v)
            end
       end
    end
    return b
end