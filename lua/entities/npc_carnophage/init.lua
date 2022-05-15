AddCSLuaFile("shared.lua")

include('shared.lua')

ENT.NPCFaction = NPC_FACTION_LYCANTHROPE
ENT.iClass = CLASS_LYCANTHROPE
ENT.sModel = "models/eyedc/carnophage.mdl"
ENT.fMeleeDistance	= 70
ENT.bFlinchOnDamage = true
ENT.bPlayDeathSequence = false
ENT.CollisionBounds = Vector(25,25,83)
ENT.skName = "carnophage"
ENT.tblAlertAct = {ACT_IDLE_ANGRY}
ENT.AlertChance = 25
//ENT.idleChance = 8

ENT.iBloodType = BLOOD_COLOR_RED
ENT.sSoundDir = "npc/carnophage/"

ENT.tblFlinchActivities = {
	[HITBOX_CHEST] = ACT_GESTURE_FLINCH_CHEST,
	[HITBOX_HEAD] = ACT_GESTURE_FLINCH_HEAD,
	[HITBOX_LEFTARM] = ACT_GESTURE_FLINCH_LEFTARM,
	[HITBOX_RIGHTARM] = ACT_GESTURE_FLINCH_RIGHTARM,
	[HITBOX_LEFTLEG] = ACT_GESTURE_FLINCH_LEFTLEG,
	[HITBOX_RIGHTLEG] = ACT_GESTURE_FLINCH_RIGHTLEG,
	[HITBOX_STOMACH] = ACT_GESTURE_FLINCH_STOMACH,
	[HITBOX_GENERIC] = ACT_GESTURE_BIG_FLINCH
}

ENT.m_tbSounds = {
	["AttackA"] = "werewolf_attack_a0[1-3].mp3",
	["AttackB"] = "werewolf_attack_b0[1-3].mp3",
	["Death"] = "werewolf_death0[1-2].mp3",
	["Feeding"] = "werewolf_feeding01.mp3",
	["FeedingKill"] = "werewolf_feedingkill01.mp3",
	["Growl"] = "werewolf_growl0[1-3].mp3",
	["HeadSmash"] = "werewolf_headsmash01.mp3",
	["Pain"] = "werewolf_injured01.mp3",
	["Maul"] = "werewolf_maul.mp3",
	["Shout"] = "werewolf_shout01.mp3",
	["Transformation"] = "werewolf_transformation01.mp3",
	["FootRun"] = "foot/werewolf_foot_run0[1-4].mp3",
	["FootWalk"] = "foot/werewolf_foot_walk0[1-4].mp3"
}

function ENT:OnInit()
	self:SetNPCFaction(NPC_FACTION_LYCANTHROPE,CLASS_LYCANTHROPE)
	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()
	self:SetCollisionBounds(self.CollisionBounds,Vector(self.CollisionBounds.x *-1,self.CollisionBounds.y *-1,0))
	
	self:slvCapabilitiesAdd(bit.bor(CAP_MOVE_GROUND,CAP_OPEN_DOORS))
	self:slvSetHealth(GetConVarNumber("sk_" .. self.skName .. "_health"))
	self:SetSkin(math.random(0,3))
	
	self.moveSideways = 0
	self:SetSoundLevel(90)
end

function ENT:_PossShouldFaceMoving(possessor)
	return true
end

function ENT:_PossPrimaryAttack(entPossessor,fcDone)
	self:SLVPlayActivity(ACT_MELEE_ATTACK1,false,fcDone)
end

function ENT:OnThink()
	self:UpdateLastEnemyPositions()
	if(IsValid(self.entEnemy) && self.moveSideways && CurTime() < self.moveSideways) then
		local ang = self:GetAngles()
		local yawTgt = (self.entEnemy:GetPos() -self:GetPos()):Angle().y
		ang.y = math.ApproachAngle(ang.y,yawTgt,10)
		self:SetAngles(ang)
		self:NextThink(CurTime())
		return true
	end
end

function ENT:EventHandle(...)
	local event = select(1,...)
	if(event == "mattack") then
		local dist = self.fMeleeDistance
		local dmg
		local ang
		local force
		local atk = select(2,...)
		if(atk == "left") then
			dmg = GetConVarNumber("sk_" .. self.skName .. "_dmg_slash")
			ang = Angle(10,0,0)
			force = Vector(30,0,0)
		elseif(atk == "right") then
			dmg = GetConVarNumber("sk_" .. self.skName .. "_dmg_slash")
			ang = Angle(15,0,0)
			force = Vector(30,0,0)
		end
		self:DealMeleeDamage(dist,dmg,ang,force)
		return true
	end
end

local flinchTimes = {
	[ACT_GESTURE_FLINCH_CHEST] = 0.53,
	[ACT_GESTURE_FLINCH_HEAD] = 0.7,
	[ACT_GESTURE_FLINCH_LEFTARM] = 0.53,
	[ACT_GESTURE_FLINCH_RIGHTARM] = 0.53,
	[ACT_GESTURE_FLINCH_LEFTLEG] = 0.53,
	[ACT_GESTURE_FLINCH_RIGHTLEG] = 0.53,
	[ACT_GESTURE_FLINCH_STOMACH] = 0.7,
	[ACT_GESTURE_BIG_FLINCH] = 0.7
}
function ENT:Flinch(hitgroup)
	local act = self.tblFlinchActivities[hitgroup] || self.tblFlinchActivities[HITGROUP_GENERIC] || self.tblFlinchActivities[HITBOX_GENERIC]
	if(!act) then return end
	self:RestartGesture(act)
	self:StopMoving()
	self:StopMoving()
	if(!flinchTimes[act]) then return end
	self.m_tStopMoving = CurTime() +flinchTimes[act]
end

function ENT:OnLostEnemy(entEnemy)
	self.m_bNextAngry = nil
end

function ENT:SelectScheduleHandle(enemy,dist,distPred,disp)
	if(self.m_tStopMoving && CurTime() < self.m_tStopMoving) then return end
	if(disp == D_HT) then
		if(self:CanSee(self.entEnemy)) then
			-- if(self.moveSideways) then
				-- if(CurTime() > self.moveSideways || dist > 120 || dist <= 40) then
					-- self:SetRunActivity(ACT_RUN)
					-- self.moveSideways = nil
					-- self.nextMoveSideways = CurTime() +4
				-- else
					-- self:MoveToPosDirect(self:GetPos() +self:GetRight() *(self.moveDir == 0 && 1 || -1) *80,true,true)
					-- return
				-- end
			-- elseif(dist <= 100 && dist > 40) then
				-- if(CurTime() >= self.nextMoveSideways) then
					-- if(math.random(1,3) == 1) then
						-- self.moveSideways = CurTime() +math.Rand(2,4)
						-- self.moveDir = math.random(0,1)
						-- self:SetRunActivity(ACT_RUN)
						-- self:MoveToPosDirect(self:GetPos() +self:GetRight() *(self.moveDir == 0 && 1 || -1) *80,true,true)
						-- return
					-- else self.nextMoveSideways = CurTime() +4 end
				-- end
			-- end
			if(self.m_bNextAngry) then
				self.m_bNextAngry = nil
				self:SLVPlayActivity(ACT_IDLE_ANGRY,true)
				return
			end
			if(dist <= self.fMeleeDistance || distPred <= self.fMeleeDistance) then
				self:SLVPlayActivity(ACT_MELEE_ATTACK1)
				self.m_bNextAngry = math.random(1,3) == 3
				return
			end
		end
		self:ChaseEnemy()
	elseif(disp == D_FR) then
		self:Hide()
	end
end

-- util.AddNetworkString("ss_carno_burst") // No! Stop it!
-- local cvSpawnChance = CreateConVar("ss_carnophage_spawn_chance",0.05,FCVAR_ARCHIVE)
-- hook.Add("OnNPCKilled","carnophage_spawn",function(npc,killer,inflictor)
	-- local f = cvSpawnChance:GetFloat()
	-- if(f == 0) then return end
	-- if(npc:GetClass() == "npc_carnophage") then return end
	-- if(inflictor == "npc_carnophage") then
		-- local min,max = npc:OBBMins(),npc:OBBMaxs()
		-- local e = max -min
		-- if(e.x >= 20 && e.y >= 20 && e.z >= 60) then
			-- if(math.Rand(0,1) <= f) then
				-- local ent = ents.Create("npc_carnophage")
				-- if(!ent:IsValid()) then return end
				-- ent:SetPos(npc:GetPos())
				-- ent:SetAngles(npc:GetAngles())
				-- ent:Spawn()
				-- ent:Activate()
				-- timer.Simple(0.2,function()
					-- if(ent:IsValid() && ent:GetActivity() != ACT_IDLE_ANGRY) then
						-- ent:SLVPlayActivity(ACT_IDLE_ANGRY)
					-- end
				-- end)
				-- net.Start("ss_carno_burst")
					-- net.WriteUInt(ent:EntIndex(),24)
					-- net.WriteUInt(ent.iBloodType || BLOOD_COLOR_RED,6)
				-- net.Broadcast()
				-- npc:Remove()
			-- end
		-- end
	-- end
-- end)