if(!SLVBase_Fixed) then
	include("slvbase/slvbase.lua")
	if(!SLVBase_Fixed) then return end
end
local addon = "E.Y.E: Divine Cybermancy"
if(SLVBase_Fixed.AddonInitialized(addon)) then return end
if(SERVER) then
	AddCSLuaFile("autorun/edc_sh_init.lua")
	AddCSLuaFile("autorun/slvbase/slvbase.lua")
end
SLVBase_Fixed.AddDerivedAddon(addon,{tag = "EDC"})
if(SERVER) then
	Add_NPC_Class("CLASS_LYCANTHROPE")
	Add_NPC_Class("CLASS_FEDERALIST")
end

game.AddParticles("particles/carnophage_explode.pcf")
for _, particle in pairs({
		"carnophage_burst_red",
		"carnophage_burst_yellow",
		"carnophage_burst_green",
		"carnophage_burst_synth"
	}) do
	PrecacheParticleSystem(particle)
end

SLVBase_Fixed.InitLua("edc_init")

local Category = "E.Y.E: Divine Cybermancy"
-- SLVBase_Fixed.AddNPC(Category,"Federalist","npc_federalist") // WIP

SLVBase_Fixed.AddNPC(Category,"Carnophage","npc_carnophage")
SLVBase_Fixed.AddNPC(Category,"Limacue","npc_limacue")