-- mobs override

override = {}

local sethas = function(needle,haystack)
	for _,i in pairs(haystack) do
		if i == needle then return true end
	end
	return false
end

local mobs_override = function(mobname,def,check)
	local themob = minetest.registered_entities[mobname]
	if not themob then return end

	if type(check) == "function" then
		if not check(themob) then return end
	end

	for property,definition in pairs(def) do
		if type(definition) == "string"
		or type(definition) == "number"
		or type(definition) == "function"
		then
			themob[property] = definition

		elseif type(definition) == "table" then
			if type(definition.check) == "function" then
				if definition.check(themob[property]) then themob[property] = definition.value end

			elseif definition.value then -- straight definition
				themob[property] = definition.value

			elseif sethas(definition.fchain_type, {"after","before"}) and type(definition.fchain_func) == "function" then
				local extantf = themob[property]
				if type(extantf) == "function" then
					if definition.fchain_type == "after" then
						themob[property] = function(...)
							extantf( ... )
							definition.fchain_func( ... )
						end
					elseif definition.fchain_type == "before" then
						themob[property] = function(...)
							if definition.fchain_func( ... ) == true then -- check for the actual boolean value
								extantf( ... )
							end
						end
					end
						
				else
					minetest.debug("Expected existing function in "..property.." for "..mobname.." but got a "..type(extantf))
				end
			else
				minetest.debug("Invalid substitution definition of "..property.." for "..mobname)
			end
		end
	end
	return themob
end

override.rewrite = mobs_override
