E2Lib.RegisterExtension("shoot", false)
--E2Helper.Descriptions["shoot(vv)"] = "Shoots a bullet from position pos in the direction dir"
Shoot = {}

local damage = 100
local force = 1000
local distance = 5000
local hull_size = 2
local bullet_num = 1
local tracer_num = 1
local ammo_type = "SniperRound"
local tracer_type = "AR2Tracer"
local spread = Vector(0, 0, 0)

local ValidTracers = {"Tracer", "AR2Tracer", "AirboatGunHeavyTracer", "LaserTracer", ""}

local function shootCallback(ply, tr, dmgInfo)

	print("Callback!")

	if tr then
		util.ParticleTrace(tracer_type, tr.StartPos(), tr.HitPos(), true)
	end
	
	if ply and tr and dmgInfo then
		print("Name: ", ply:GetName())
		if tr.Hit then
			dmg:SetDamagePosition(tr.HitPos)
			ent = tr.Entity
			
			if ent then
				ent:TakeDamageInfo(dmgInfo)
			end
		end
	end	
end

local function getDamageInfo(attacker, inflictor, dir)
	dmg = DamageInfo()
	dmg:SetAttacker(attacker)
	dmg:SetDamage(damage)
	dmg:SetDamageForce(dir:GetNormalized() * force)
	dmg:SetDamageType(2)
	dmg:SetInflictor(inflictor)
	dmg:SetMaxDamage(damage)
	
	return dmg
end

local function getBulletStructure(attacker, inflictor, src, dir)
	trace = util.TraceLine({start = src, endpos = src + distance * dir, filter = {inflictor}, ignoreworld = true})
	
	bullet = {Attacker = nil, Callback = nil, Damage = nil, Force = nil, Distance = nil, HullSize = nil, Num = nil, Tracer = nil, AmmoType = nil, TracerName = nil, Dir = nil, Spread = nil, Src = nil}
	bullet.Attacker = attacker
	bullet.CallBack = shootCallback
	bullet.Damage = damage
	bullet.Force = force
	bullet.Distance = distance
	bullet.HullSize = hull_size
	bullet.Num = bullet_num
	bullet.Tracer = tracer_num
	bullet.AmmoType = ammo_type
	bullet.TracerName = tracer_type
	bullet.Dir = dir
	bullet.Spread = spread
	bullet.Src = src
	
	return bullet
	
end



local function fire(entity, attacker, src, dir)
	if dir and src and entity and attacker then
		data = getBulletStructure(attacker, entity, src, dir)
		entity:FireBullets(data)
		return 1
	else
		return 0
	end
end

function Shoot.setDamage(num)
	if num and num > 0 then 
		damage = num
		return 1
	else return 0 end
end

function Shoot.setForce(num)
	if num and num > 0 then
		force = num
		return 1
	else return 0 end
end

function Shoot.setDistance(num)
	if num and num > 0 then
		distance = num
		return 1
	else return 0 end
end

function Shoot.setHullSize(num)
	if num and num > 0 then
		hull_size = num
		return 1
	else return 0 end
end

function Shoot.setBulletNumber(num)
	if num and num > 0 then
		bullet_num = num
		return 1
	else return 0 end
end

function Shoot.setTracerNumber(num)
	if num and num > 0 then
		tracer_num = num
		return 1
	else return 0 end
end

function Shoot.setAmmoType(str)
	if str then
		if table.HasValue(game.BuildAmmoTypes(), str) then
			ammo_type = str
			return 1
		else
			return 0
		end
	else return 0 end
end

function Shoot.setTracerType(str)
	if str then
		if table.HasValue(ValidTracers, str) then
			tracer_type = str
			return 1
		else return 0 end
	else return 0 end
end

function Shoot.setSpread(vec)
	if vec then
		spread = vec
		return 1
	else return 0 end
end

__e2setcost(1)


e2function number setShootDamage(number damage)
	return Shoot.setDamage(damage)
end

e2function number setShootForce(number force)
	return Shoot.setForce(force)
end

e2function number setShootDistance(number distance)
	return Shoot.setDistance(distance)
end

e2function number setShootHullSize(number size)
	return Shoot.setHullSize(size)
end

e2function number setShootBulletNumber(number amount)
	return Shoot.setBulletNumber(amount)
end

e2function number setShootTracerNumber(number number)
	return Shoot.setTracerNumber(number)
end

e2function number setShootAmmo(string ammo)
	return Shoot.setAmmoType(ammo)
end

e2function number setShootTracer(string tracer)
	return Shoot.setTracerType(tracer)
end

e2function number setShootSpread(vector2 spread)
	if spread then
		return Shoot.setSpread(Vector(spread[1], spread[2], 0))
	else return 0 end
end

e2function number entity:shoot(vector dir)
	if this then
		if isOwner(self, this) then
			return fire(this, self.player, this:GetPos(), Vector(dir[1], dir[2], dir[3]))
		else return 0 end
		
	else return 0 end
end

	


		
		