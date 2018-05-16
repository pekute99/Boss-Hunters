faceless_clock_stopper = class({})
LinkLuaModifier( "modifier_faceless_clock_stopper_handle", "heroes/hero_faceless_void/faceless_clock_stopper.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_faceless_clock_stopper_buff", "heroes/hero_faceless_void/faceless_clock_stopper.lua",LUA_MODIFIER_MOTION_NONE )

function faceless_clock_stopper:GetIntrinsicModifierName()
	return "modifier_faceless_clock_stopper_handle"
end

function faceless_clock_stopper:IsStealable()
	return true
end

function faceless_clock_stopper:IsHiddenWhenStolen()
	return false
end

function faceless_clock_stopper:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("Hero_FacelessVoid.TimeDilation.Cast", caster)
	caster:AddNewModifier(caster, self, "modifier_faceless_clock_stopper_buff", {Duration = self:GetTalentSpecialValueFor("duration")})
end

modifier_faceless_clock_stopper_handle = class({})

if IsServer() then
	function modifier_faceless_clock_stopper_handle:OnCreated(kv)
		self:StartIntervalThink(0.1)
	end

	function modifier_faceless_clock_stopper_handle:DeclareFunctions()
	    local funcs = { MODIFIER_EVENT_ON_ATTACK_START}
	    return funcs
	end

	function modifier_faceless_clock_stopper_handle:OnAttackStart(params)
		local caster = params.attacker
		local ability = self:GetAbility()

		if caster:HasTalent("special_bonus_unique_faceless_clock_stopper_2") and caster:HasModifier("modifier_faceless_chrono_buff") then
			caster:AddNewModifier(caster, ability, "modifier_faceless_clock_stopper_buff", {Duration = 0.25})
		else
			if caster == self:GetParent() then
				if ability:GetAutoCastState() and ability:IsCooldownReady() and ability:IsOwnersManaEnough() then
					caster:CastAbilityImmediately( ability, caster:GetPlayerOwnerID() )
				elseif not ability:IsOwnersManaEnough() and ability:GetAutoCastState() then
					ability:ToggleAutoCast()
				end
			end
		end
	end
end

function modifier_faceless_clock_stopper_handle:IsHidden() return true end

modifier_faceless_clock_stopper_buff = class({})
function modifier_faceless_clock_stopper_buff:DeclareFunctions()
    local funcs = { MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
					MODIFIER_EVENT_ON_ATTACK_START}
    return funcs
end

function modifier_faceless_clock_stopper_buff:OnAttackStart(params)
	local caster = params.attacker
	local ability = self:GetAbility()

	if caster == self:GetParent() then
		ParticleManager:FireParticle("particles/units/heroes/hero_faceless_void/faceless_clock_stopper.vpcf", PATTACH_POINT, caster, {})
	end
end

function modifier_faceless_clock_stopper_buff:GetModifierBaseAttackTimeConstant()
	return self:GetTalentSpecialValueFor("base_attack_time")
end

function modifier_faceless_clock_stopper_buff:GetStatusEffectName()
	return "particles/status_fx/status_effect_faceless_chronosphere.vpcf"
end

function modifier_faceless_clock_stopper_buff:StatusEffectPriority()
	return 10
end

function modifier_faceless_clock_stopper_buff:IsDebuff()
	return false
end