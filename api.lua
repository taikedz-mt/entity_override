-- mobs override

mobs.override = {}

local sethas = function(needle,haystack)
	for _,i in pairs(haystack) do
		if i == needle then return true end
	end
	return false
end

local mobs_override = function(mobname,def,check)
	local themob = minetest.registered_entities[mobname]
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

			elseif sethas(definition.fchain_type, {"after","before"}) and type(fchain_func) == "function" then
				local extantf = themob[property]
				if type(extantf) == "function" then
					if definition.fchain_type == "after" then
						themob[property] = function(...)
							local newargs = {}
							for i,val in ipairs(arg) do if i > 1 then newargs[i] = val end end
							extantf( unpack(newargs) )
							definition.fchain_func( unpack(newargs) )
						end
					elseif definition.fchain_type == "before" then
						themob[property] = function(...)
							local newargs = {}
							for i,val in ipairs(arg) do if i > 1 then newargs[i] = val end end
							if definition.fchain_func( unpack(newargs) ) == true then -- check for the actual boolean value
								extantf( unpack(newargs) )
							end
						end
					end
						
				else
					minetest.debug("Expected existing function in "..property.." for "..mobname.." but got a "..type(extantf))
				end
			else
				minetest.debug("Assigning table directly for "..mobname.." : "..property)
				themob[property] = definition -- actually assign the table
			end
		end
	end
end

mobs.override = mobs_override
