Enum = {}

---@param tab table 
---@return table
function Enum.def(tab)
  if type(tab) ~= "table" then
    error("Expected table, received " .. type(tab))
  end
  local enum = {}
  for _, v in pairs(tab) do
    local variant_meta = {
      __metatable = "variant",
      __call = function (_, body)
        local instance = {
          label = v,
          body = body,
        }
        function instance:switch(branches)
          local expr = branches[self.label]
          if type(expr) == "function" then
            if type(self.body) == "table" then
              return expr(unpack(self.body))
            end
            return expr(self.body)
          end
          return expr
        end
        return setmetatable(instance, {
          __metatable = "variant_instance",
        })
      end,
    }
    local variant = {v}
    setmetatable(variant, variant_meta)
    enum[v] = variant
  end
  local enum_meta = {
    __metatable = "enum",
    __index = function(_, key)
      if enum[key] == nil then
        error("Variant " .. key .. " not found for this enum")
      end
      -- returns variant
      return enum[key]
    end,
    __newindex = function(_, key, _)
      error("Attempted to modify enum definition " .. key)
    end,
  }
  return setmetatable({}, enum_meta)
end

return setmetatable(Enum, {
  __call = function (_, tab)
    return Enum.def(tab)
  end
})