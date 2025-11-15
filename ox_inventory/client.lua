local Ome = setmetatable({}, {
    __index = function(self, index)
        return self[index]
    end
})
