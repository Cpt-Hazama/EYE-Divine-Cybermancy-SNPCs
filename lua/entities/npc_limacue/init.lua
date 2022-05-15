AddCSLuaFile("shared.lua")

include('shared.lua')

function ENT:SetupSLVFactions()
	self:SetNPCFaction(NPC_FACTION_PLAYER,CLASS_PLAYER_ALLY)
end
ENT.sModel = "models/eyedc/limacue.mdl"
ENT.CollisionBounds = Vector(10,10,13)
ENT.skName = "limacue"
ENT.idleChance = 2

ENT.iBloodType = BLOOD_COLOR_RED
ENT.sSoundDir = "npc/limacue/"

ENT.m_tbSounds = {
	["Death"] = "limacue_die[1-2].wav",
	["Fear"] = "limacue_fear.wav",
	["Idle"] = "limacue_idle[1-2].wav"
}

function ENT:OnInit()
	self:SetHullType(HULL_TINY)
	self:SetHullSizeNormal()
	self:SetCollisionBounds(self.CollisionBounds,Vector(self.CollisionBounds.x *-1,self.CollisionBounds.y *-1,0))
	
	self:slvCapabilitiesAdd(bit.bor(CAP_MOVE_GROUND,CAP_OPEN_DOORS))
	self:slvSetHealth(GetConVarNumber("sk_" .. self.skName .. "_health"))
	self.m_bNoStatusEffects = true
	self:SetState(NPC_STATE_ALERT)
end

function ENT:OnStateChanged(old, new)
	if(new == NPC_STATE_IDLE) then self:SetState(NPC_STATE_ALERT) end
end

function ENT:SelectScheduleHandle(enemy,dist,distPred,disp)
	if self:CanSee(enemy) then
		self:Hide()
	end
end