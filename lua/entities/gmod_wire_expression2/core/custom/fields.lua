E2Lib.RegisterExtension("fields", false)
Fields = {}

local fieldTypes = {"radiation", "dissolve", "nervegas", "electric", "fire", "heal", "acceleration"}
local damageTypes = {["radiation"] = 262144, ["dissolve"] = 67108864, ["nervegas"] = 65536, ["electric"] = 256, ["fire"] = 8}
local fieldCounter = 1
local fields = {}

local function isInBox(pos, min, max)
	if pos[1] >= min[1] and pos[1] <= max[1] and pos[2] >= min[2] and pos[2] <= max[2] and pos[3] >= min[3] and pos[3] <= max[3] then
		return true
	else return false end
end

local function getOwner(ent)
	players = player.GetAll()
	
	local i = 1
	local max = table.Count(players)
	local owner = nil
	
	while (i <= max) do
		if isOwner(players[i], ent) then
			owner = players[i]
			break
		end
	end
	
	return owner
end

local function getDamageInfo(field)
	dmg = DamageInfo()
	print("Attacker: ", field.Attacker, " Inflictor: ", inflictor, " Damage: ", field.Damage)
	dmg:SetAttacker(field.Attacker)
	dmg:SetDamage(field.Damage)
	dmg:SetDamageType(damageTypes[field.Type])
	dmg:SetInflictor(field.Inflictor)
	
	return dmg
end

local function applyField(id)
	
	if id then
		field = fields[id]
		
		if not field then
			print("Field == nil")
		else
			print("Min: ", field.Min, " Max: ", field.Max)
			print("Fields: ", fields[id].ID, " ID: ", id)
		end
		
		players = player.GetAll()
		
		local i = 1
		local max = table.Count(players)
		
		while (i <= max) do
			local player = players[i]
			steamID = player:SteamID()
			
			if not table.HasValue(field.Filter.Players, steamID) then
				pos = player:GetPos()
				
				if isInBox(pos, field.Min, field.Max) then
					handleFieldTypesPlayer(player, field)
				end
				
			end
			
			i = i + 1
		end
		
		local ents = ents.GetAll()
		i = 1
		max = table.Count(ents)
		
		while (i <= max) do
			local ent = ents[i]
			local owner = getOwner(ent)
			local applyField = true
			
			if owner then
				if table.HasValue(field.Filter.PlayerEnts, owner:SteamID()) then
					applyField = false
				end
			end
			
			if not table.HasValue(field.Filter.Ents, ent:GetCreationID()) and applyField then
				pos = ent:GetPos()
				
				if isInBox(pos, field.Min, field.Max) then
					handleFieldTypesEntity(ent, field)
				end
			end
			
			i = i + 1
		end
	end	
	
end

local function handleFieldTypesPlayer(player, field)
	if field.Type == "fire" and not player:IsOnFire() then
		player:Ignite(1, 0)
	elseif field.Type == "heal" then
		local maxHealth = player:GetMaxHealth()
		local health = player:Health()
		local maxHeal = maxHealth - health
		local heal = field.Damage
		
		if heal <= maxHeal then
			player:SetHealth(health + heal)
		elseif not maxHealth == health then
			player:SetHealth(health + maxHeal)
		end
	elseif field.Type == "acceleration" then
		if field.Damage <= 10 and field.Damage >= 0 then
			local velocity = player:GetVelocity()
			player:SetVelocity(velocity * field.Damage)
		end
	else 
		player:TakeDamageInfo(getDamageInfo(field))
	end
end

local function handleFieldTypesEntity(ent, field)
	if ent:Health() == 0 and field.Type == "dissolve" then
		ent:SetPersistent(false)
		phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			mass = phys:GetMass()
			ent:SetMaxHealth(mass)
			ent:SetHealth(mass)
		else
			ent:SetHealth(1)
		end
	elseif field.Type == "fire" then
		if not ent:IsOnFire() then
			ent:Ignite(1, 0)
		end
	elseif field.Type == "heal" then
		if not ent:Health() <= 0 then
			local maxHealth = ent:GetMaxHealth()
			local health = ent:Health()
			local maxHeal = maxHealth - health
			local heal = field.Damage
			
			if heal <= maxHeal then
				ent:SetHealth(health + heal)
			elseif not maxHealth == health then
				ent:SetHealth(health + maxHeal)
			end
		end
	elseif field.Type == "acceleration" then
		if field.Damage <= 10 and field.Damage >= 0 then
			local velocity = ent:GetVelocity()
			ent:SetVelocity(velocity * field.Damage)
		end
	else
		ent:TakeDamageInfo(getDamageInfo(field))
	end
end

local function applyFields()
	local i = 1
	local max = table.Count(fields)
	
	while (i <= max) do
		applyField(i)
		i = i + 1
	end
end

local function createField(origin, size, type, damage, attacker, inflictor)
	if origin and size and type and damage and attacker and inflictor then
		if table.HasValue(fieldTypes, type) then
			min = Vector(origin[1] - size[1], origin[2] - size[2], origin[3] - size[3])
			max = Vector(origin[1] + size[1], origin[2] + size[2], origin[3] + size[3])
			field = {ID = fieldCounter, Min = min, Max = max, Pos = origin, Size = size, Type = type, Damage = damage, Filter = {Players = {}, Ents = {}, PlayerEnts = {}}, Attacker = attacker, Inflictor = inflictor}
			fieldCounter = fieldCounter + 1
			table.insert(fields, field)
			if fieldCounter == 2 then timer.Create("Field", 1, 0, applyFields) end
			return field.ID
		else return -1 end
	else return -1 end
end

local function deleteField(id)
	
	if id then
		if id > 0 and id <= table.Count(fields) then
			table.remove(fields,id)
			if not table.Count(fields) then
				timer.Destroy("Field")
			end
		end
	end
end

local function deleteAllFields()
	local i = 1
	local max = table.Count(fields)
	
	while (i <= max) do
		deleteField(i)
		i = i + 1
	end
	
	fieldCounter = 1
end

registerCallback("destruct", function(self)
	deleteAllFields()
end)
	

e2function number createField(vector pos, vector size, string type, number damage)
	return createField(Vector(pos[1], pos[2], pos[3]), Vector(size[1], size[2], size[3]), type, damage, self.player, self.entity)
end

e2function void setFieldPos(number n, vector pos)
	if pos and n then
		if n <= table.Count(fields) and n > 0 then
			min = Vector(pos[1] - fields[n].Size[1], pos[2] - fields[n].Size[2], pos[3] - fields[n].Size[3])
			max = Vector(pos[1] + fields[n].Size[1], pos[2] + fields[n].Size[2], pos[3] + fields[n].Size[3])
			fields[n].Min = min
			fields[n].Max = max
		end
	end
end

e2function void setFieldSize(number n, vector size)
	if size and n then
		if n <= table.Count(fields) and n > 0 then
			min = Vector(fields[n].Pos[1] - size[1], fields[n].Pos[2] - size[2], fields[n].Pos[3] - size[3])
			max = Vector(fields[n].Pos[1] + size[1], fields[n].Pos[2] + size[2], fields[n].Pos[3] + size[3])
			fields[n].Min = min
			fields[n].Max = max
		end
	end
end

e2function void setFieldType(number n, string type)
	if type and n then
		if n <= table.Count(fields) and n > 0 and table.HasValue(fieldTypes, type) then
			fields[n].Type = type
		end
	end
end

e2function void setFieldDamage(number n, number damage)
	if damage and n then
		if n <= table.Count(fields) and n > 0 and damage > 0 then
			fields[n].Damage = damage
		end
	end
end

e2function void addFieldPlayerFilter(number n, entity ply)
	if ply:IsPlayer() then
		local steamID = ply:SteamID()
		if n <= table.Count(fields) and n > 0 and steamID then
			if not table.HasValue(fields[n].Filter.Players, steamID) then
				table.insert(fields[n].Filter.Players, steamID)
			end
		end
	end
end

e2function void addFieldPlayerPropsFilter(number n, entity ply)
	if ply:IsPlayer() then
		local steamID = ply:SteamID()
		if n <= table.Count(fields) and n > 0 and steamID then
			if not table.HasValue(fields[n].Filter.PlayerEnts, steamID) then
				table.insert(fields[n].Filter.PlayerEnts, steamID)
			end
		end
	end
end

e2function void addFieldPropFilter(numbern, entity ent)
	if isentity(ent) then
		local creationID = ent:GetCreationID()
		if n <= table.Count(fields) and n > 0 and creationID then
			if not table.HasValue(fields[n].Filter.Ents, creationID) then
				table.insert(fields[n].Filter.Ents, creationID)
			end
		end
	end
end

e2function void deleteField(number id)
	deleteField(id)
end

e2function void deleteAllFields()
	deleteAllFields()
end

e2function table getFieldTypes()
	return fieldTypes
end