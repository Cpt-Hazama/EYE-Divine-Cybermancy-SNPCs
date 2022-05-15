ENT.Base = "npc_creature_base"
ENT.Type = "ai"

ENT.PrintName = "Carnophage"
ENT.Category = "EYE Divine Cybermancy"

if(CLIENT) then
	language.Add("npc_carnophage","Carnophage")
	local particles = {
		[BLOOD_COLOR_RED] = "carnophage_burst_red",
		[BLOOD_COLOR_YELLOW] = "carnophage_burst_yellow",
		[BLOOD_COLOR_ANTLION] = "carnophage_burst_yellow",
		[BLOOD_COLOR_ANTLION_WORKER] = "carnophage_burst_yellow",
		[BLOOD_COLOR_GREEN] = "carnophage_burst_green",
		[BLOOD_COLOR_ZOMBIE] = "carnophage_burst_green",
		[BLOOD_COLOR_MECH] = "carnophage_burst_synth"
	}
	net.Receive("ss_carno_burst",function(len)
		local idx = net.ReadUInt(24)
		local bloodType = net.ReadUInt(6)
		local tEnd = CurTime() +1
		hook.Add("OnEntityCreated","ss_carno_check",function(ent)
			if(IsValid(ent) && ent:EntIndex() == idx) then
				local scaleStart = 0.5
				ent:SetModelScale(scaleStart,0)
				local tScaleStart = UnPredictedCurTime()
				local tScale = 0.8
				ent.RenderOverride = function(ent)
					local t = UnPredictedCurTime()
					local tDelta = t -tScaleStart
					if(tDelta >= tScale) then ent.RenderOverride = nil
					else
						local scale = scaleStart +(tDelta /tScale) *(1 -scaleStart)
						ent:SetModelScale(scale,0)
					end
					ent:DrawModel()
				end
				local csp = CreateSound(ent,"fx/fx_flinder_body_head0" .. math.random(1,3) .. ".wav")
				csp:SetSoundLevel(90)
				csp:Play()
				ParticleEffectAttach(particles[bloodType] || particles[BLOOD_COLOR_RED],PATTACH_ABSORIGIN_FOLLOW,ent,0)
				hook.Remove("OnEntityCreated","ss_carno_check")
			elseif(CurTime() > tEnd) then hook.Remove("OnEntityCreated","ss_carno_check") end
		end)
	end)
end

