relic_generic_stick = class(relicBaseClass)

function relic_generic_stick:OnCreated()
	self:SetStackCount(1)
	if IsServer() then
		self.funcID = EventManager:SubscribeListener("boss_hunters_event_finished", function(args) self:OnEventFinished(args) end)
	end
end

function relic_generic_stick:OnEventFinished(args)
	EVENT_TYPE_EVENT = 3
	if args.eventType ~= EVENT_TYPE_EVENT then
		self:SetStackCount( math.min( 300, math.ceil(self:GetStackCount() * 1.2) ) )
	end
end

function relic_generic_stick:OnDestroy()
	if IsServer() then
		EventManager:UnsubscribeListener("boss_hunters_event_finished", self.funcID)
	end
end

function relic_generic_stick:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function relic_generic_stick:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount()
end