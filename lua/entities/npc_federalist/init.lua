AddCSLuaFile("shared.lua")

include('shared.lua')

ENT.iClass = CLASS_FEDERALIST

ENT.NPCFaction = CLASS_FEDERALIST
ENT.sModel = "models/eyedc/federal/cop.mdl"
ENT.fMeleeDistance = 55
ENT.fMeleeForwardDistance = 320
ENT.iBloodType = BLOOD_COLOR_RED
ENT.sSoundDir = "npc/federalist/"
ENT.skName = "federalist"
ENT.BoneRagdollMain = "Bip01 Spine"
ENT.m_bKnockDownable = true
ENT.ForceMultiplier = 1
ENT.m_tbSounds = {
	-- ["FootLeft"] = "foot/supermutant_foot_l0[1-3].mp3",
	-- ["FootRight"] = "foot/supermutant_foot_r0[1-3].mp3"
}

ENT.tblFlinchActivities = {
	[HITBOX_GENERIC] = ACT_FLINCH_CHEST,
	[HITBOX_HEAD] = ACT_FLINCH_HEAD,
	[HITBOX_CHEST] = ACT_FLINCH_CHEST,
	[HITBOX_LEFTARM] = ACT_FLINCH_LEFTARM,
	[HITBOX_RIGHTARM] = ACT_FLINCH_RIGHTARM,
	[HITBOX_LEFTLEG] = ACT_FLINCH_LEFTLEG,
	[HITBOX_RIGHTLEG] = ACT_FLINCH_RIGHTLEG
}

function ENT:SelectGetUpActivity()
	local _, ang = self.ragdoll:GetBonePosition(self:GetMainRagdollBone())
	return ang.r >= 0 && ACT_ROLL_RIGHT || ACT_ROLL_LEFT
end

function ENT:OnInit()
	self:SetNPCFaction(NPC_FACTION_FEDERALISTS,CLASS_FEDERALISTS)
	self:SetHullType(HULL_MEDIUM_TALL)
	self:SetHullSizeNormal()
	self:SetCollisionBounds(Vector(30,30,105),Vector(-30,-30,0))
	self:slvCapabilitiesAdd(bit.bor(CAP_MOVE_GROUND,CAP_OPEN_DOORS))
	
	self:SetIdleActivity(self:GetSequenceActivity(self:LookupSequence("Idle_unarmed")))
	self:SetWalkActivity(self:GetSequenceActivity(self:LookupSequence("walk_all")))
	self:SetRunActivity(self:GetSequenceActivity(self:LookupSequence("walk_all")))

	self.m_tNextMeleeAttack = 0
	self:slvSetHealth(GetConVarNumber("sk_" .. self.skName .. "_health"))
	self:FrameInit()
end

local tbAnimationFrames = {
	["walk_all"] = 30
}

local bFramesInitialized
function ENT:FrameInit()
	-- default NPC initialization stuff (model has to be set here!)
	-- if(!bFramesInitialized) then	-- this is stupid, but I'm too tired to think of something better right now
		-- bFramesInitialized = true
		-- for seq, numFrames in pairs(tbAnimationFrames) do
			-- tbAnimationFrames[seq] = nil
			-- tbAnimationFrames[seq] = self:LookupSequence(seq)
		-- end
	-- end
	self.tblAnimEvents = {}
	self.m_tbAnimEvents = {}
	self.m_frameLast = -1
	self.m_seqLast = -1
	self:AddEvent(self:LookupSequence("walk_all"),12,AE_NPC_LEFTFOOT)
	self:AddEvent(self:LookupSequence("walk_all"),27,AE_NPC_RIGHTFOOT)
	self:AddAnimationEvent(self:LookupSequence("walk_all"),12,AE_NPC_LEFTFOOT)
	self:AddAnimationEvent(self:LookupSequence("walk_all"),27,AE_NPC_RIGHTFOOT)
end

function ENT:AddAnimationEvent(seq,frame,ev)	-- Sequence ID, target frame and animation event
	if(!tbAnimationFrames[seq]) then return end
	self.m_tbAnimEvents[seq] = self.m_tbAnimEvents[seq] || {}
	self.m_tbAnimEvents[seq][frame] = self.m_tbAnimEvents[seq][frame] || {}
	table.insert(self.m_tbAnimEvents[seq][frame],ev)
end

function ENT:AddEvent(seq,frame,ev)	-- Sequence ID, target frame and animation event
	-- if(!tbAnimationFrames[seq]) then return end
	if (!self:LookupSequence(seq)) then return end
	self.tblAnimEvents[seq] = self.tblAnimEvents[seq] || {}
	self.tblAnimEvents[seq][frame] = self.tblAnimEvents[seq][frame] || {}
	table.insert(self.tblAnimEvents[seq][frame],ev)
end

function ENT:OnThink()
	local seq = self:GetSequence()
	local tblseq = self:LookupSequence(seq)
	local fps = math.floor(self:GetCycle() *30)
	if table.HasValue(self.tblAnimEvents[seq],seq) then
		for _, ev in ipairs(self.tblAnimEvents[seq][frame]) do
			if fps == self.tblAnimEvents[seq][frame] then
				self:HandleAnimationEvent(ev)
			end
		end
	end

	-- local seq = self:GetSequence()
	-- if(self.m_tbAnimEvents[seq]) then
		-- if(self.m_seqLast != seq) then self.m_seqLast = seq; self.m_frameLast = -1 end
		-- local frameNew = math.floor(self:GetCycle() *tbAnimationFrames[seq])	-- Despite what the wiki says, GetCycle doesn't return the frame, but a float between 0 and 1
		-- for frame = self.m_frameLast +1,frameNew do	-- a loop, just in case the think function is too slow to catch all frame changes
			-- if(self.m_tbAnimEvents[seq][frame]) then
				-- for _, ev in ipairs(self.m_tbAnimEvents[seq][frame]) do
					-- self:HandleAnimationEvent(ev)
				-- end
			-- end
		-- end
		-- self.m_frameLast = frameNew
	-- end
	-- print(math.floor(self:GetCycle() *30))
	for _,v in ipairs(player.GetAll()) do v:ChatPrint(math.floor(self:GetCycle() *30)) end
	self:NextThink(CurTime())
	return true
end

function ENT:HandleAnimationEvent(ev)
	if(ev == AE_NPC_LEFTFOOT) then self:EmitSound("npc/federalist/step" .. math.random(1,4) .. ".wav",75,100)
	elseif(ev == AE_NPC_RIGHTFOOT) then self:EmitSound("npc/federalist/step" .. math.random(1,4) .. ".wav",75,100)
	else -- other events
	end
end

function ENT:_PossShouldFaceMoving(possessor)
	return false
end

function ENT:LegsCrippled()
	return self:LimbCrippled(HITBOX_LEFTLEG) || self:LimbCrippled(HITBOX_RIGHTLEG)
end

function ENT:EventHandle(...)
	local event = select(1,...)
	for _,v in ipairs(player.GetAll()) do v:ChatPrint(event) end
	-- local atk = select(2,...)
	-- local atk2 = select(3,...)

	-- if(event == "2hm") then
		-- local dmg
		-- local ang
		-- local dist = self.fMeleeDistance
		-- local lefta = string.find(atk,"lefta")
		-- local righta = !left && string.find(atk,"righta")
		-- local leftb = string.find(atk,"leftb")
		-- local rightb = !left && string.find(atk,"rightb")
		-- local power = string.find(atk,"power")
		-- local leftpower = string.find(atk,"leftpower")
		-- local rightpower = string.find(atk,"rightpower")
		-- local force
		-- self:DealMeleeDamage(dist,GetConVarNumber("sk_fev_dmg_fist"),Angle(0,0,0),Vector(100,100,0),nil,nil,true)
		-- return true
	-- end
	
	-- if(event == "swing") then
		-- return true
	-- end
	
	-- if(event == "mattack") then
		-- local dmg
		-- local ang
		-- local dist = self.fMeleeDistance
		-- local lefta = string.find(atk,"lefta")
		-- local righta = !left && string.find(atk,"righta")
		-- local leftb = string.find(atk,"leftb")
		-- local rightb = !left && string.find(atk,"rightb")
		-- local power = string.find(atk,"power")
		-- local leftpower = string.find(atk,"leftpower")
		-- local rightpower = string.find(atk,"rightpower")
		-- local force
		-- self:DealMeleeDamage(dist,GetConVarNumber("sk_fev_dmg_fist"),Angle(0,0,0),Vector(100,100,0),nil,nil,true)
		-- return true
	-- end
end

function ENT:_PossPrimaryAttack(entPossessor,fcDone)
	self:RestartGesture(ACT_GESTURE_MELEE_ATTACK1)
	fcDone(true)
end

function ENT:_PossJump(entPossessor,fcDone)
	self:SLVPlayActivity(ACT_MELEE_ATTACK2,false,fcDone)
end

function ENT:SelectScheduleHandle(enemy,dist,distPred,disp)
	if(disp == D_HT) then
		if(self:CanSee(enemy)) then
			if(CurTime() >= self.m_tNextMeleeAttack && dist <= self.fMeleeDistance || distPred <= self.fMeleeDistance) then
				self.m_tNextMeleeAttack = CurTime() +0.8
				-- self:ChaseEnemy()
				self:SLVPlayActivity(ACT_MELEE_ATTACK1,true)
				-- self:RestartGesture(ACT_GESTURE_MELEE_ATTACK1)
				-- print('ran')
				return
			end
		end
		self:ChaseEnemy()
	elseif(disp == D_FR) then
		self:Hide()
	end
end
