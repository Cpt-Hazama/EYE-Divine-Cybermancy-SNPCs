local ConVars = {}

// CARNOPHAGE
ConVars["sk_carnophage_health"] = 260
ConVars["sk_carnophage_dmg_slash"] = 12

// LIMACUE
ConVars["sk_limacue_health"] = 26

// FEDERALIST
ConVars["sk_federalist_health"] = 125
ConVars["sk_federalist_dmg"] = 12

for k,v in pairs(ConVars) do
	CreateConVar(k,v,{})
end