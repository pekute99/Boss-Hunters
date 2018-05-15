relic_cursed_whale_heart = class({})

function relic_cursed_whale_heart:DeclareFunctions()
	return {MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE}
end

function relic_cursed_whale_heart:GetModifierHPRegenAmplify_Percentage()
	local regen = 50
	if not self:GetParent():HasModifier("modifier_in_water") then
		regen = -50
	end
	return regen
end

function relic_cursed_whale_heart:IsHidden()
	return true
end

function relic_cursed_whale_heart:IsPurgable()
	return false
end

function relic_cursed_whale_heart:RemoveOnDeath()
	return false
end

function relic_cursed_whale_heart:IsPermanent()
	return true
end

function relic_cursed_whale_heart:AllowIllusionDuplicate()
	return true
end

function relic_cursed_whale_heart:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end