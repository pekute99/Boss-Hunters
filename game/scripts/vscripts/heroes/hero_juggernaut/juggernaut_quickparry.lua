juggernaut_quickparry = class({})

function juggernaut_quickparry:GetIntrinsicModifierName()
	return "modifier_juggernaut_quickparry_passive"
end

function juggernaut_quickparry:ShouldUseResources()
	return true
end

function juggernaut_quickparry:OnToggle()
end

modifier_juggernaut_quickparry_passive = class({})
LinkLuaModifier("modifier_juggernaut_quickparry_passive", "heroes/hero_juggernaut/juggernaut_quickparry", LUA_MODIFIER_MOTION_NONE)

function modifier_juggernaut_quickparry_passive:OnCreated()
	self.chance = self:GetAbility():GetSpecialValueFor("parry_chance")
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
	self.cost = self:GetAbility():GetSpecialValueFor("active_momentum_cost")
end

function modifier_juggernaut_quickparry_passive:OnRefresh()
	self.chance = self:GetAbility():GetSpecialValueFor("parry_chance")
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
	self.cost = self:GetAbility():GetSpecialValueFor("active_momentum_cost")
end

function modifier_juggernaut_quickparry_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK}
end

function modifier_juggernaut_quickparry_passive:GetModifierTotal_ConstantBlock(params)
	local ability = self:GetAbility()
	if params.attacker == self:GetParent() then return end
	if ability:IsCooldownReady() then
		local caster = self:GetCaster()
		if ability:GetToggleState() and caster:AttemptDecrementMomentum(self.cost) then
			caster:StartGestureWithPlaybackRate( ACT_DOTA_ATTACK_STATUE , 5 )
			ability:DealDamage(caster, params.attacker, self.damage )
			if caster:HasTalent("special_bonus_unique_juggernaut_quickparry_2") then
				caster:AddNewModifier(caster, ability, "modifier_juggernaut_quickparry_talent", {duration = caster:FindTalentValue("special_bonus_unique_juggernaut_quickparry_2", "duration")})
			end
			return params.damage
		end
		if RollPercentage(self.chance) then
			ability:SetCooldown()
			caster:StartGestureWithPlaybackRate( ACT_DOTA_ATTACK_STATUE , 5 )
			ability:DealDamage(caster, params.attacker, self.damage )
			if caster:HasTalent("special_bonus_unique_juggernaut_quickparry_1") then
				caster:AddMomentum(caster:FindTalentValue("special_bonus_unique_juggernaut_quickparry_1"))
			end
			if caster:HasTalent("special_bonus_unique_juggernaut_quickparry_2") then
				caster:AddNewModifier(caster, ability, "modifier_juggernaut_quickparry_talent", {duration = caster:FindTalentValue("special_bonus_unique_juggernaut_quickparry_2", "duration")})
			end
			return params.damage
		end
	end
end

function modifier_juggernaut_quickparry_passive:IsHidden()
	return true
end



modifier_juggernaut_quickparry_talent = class({})
LinkLuaModifier("modifier_juggernaut_quickparry_talent", "heroes/hero_juggernaut/juggernaut_quickparry", LUA_MODIFIER_MOTION_NONE)

function modifier_juggernaut_quickparry_talent:OnCreated()
	local caster = self:GetCaster()
	self.as = caster:FindTalentValue("special_bonus_unique_juggernaut_quickparry_2", "as")
	self.ms = caster:FindTalentValue("special_bonus_unique_juggernaut_quickparry_2", "ms")
	self:SetStackCount(1)
end

function modifier_juggernaut_quickparry_talent:OnRefresh()
	local caster = self:GetCaster()
	self.as = caster:FindTalentValue("special_bonus_unique_juggernaut_quickparry_2", "as")
	self.ms = caster:FindTalentValue("special_bonus_unique_juggernaut_quickparry_2", "ms")
	if IsServer() then
		self:AddIndependentStack( self:GetRemainingTime() )
	end
end

function modifier_juggernaut_quickparry_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_juggernaut_quickparry_talent:GetModifierAttackSpeedBonus_Constant(params)
	return self.as * self:GetStackCount()
end

function modifier_juggernaut_quickparry_talent:GetModifierMoveSpeedBonus_Percentage(params)
	return self.ms * self:GetStackCount()
end