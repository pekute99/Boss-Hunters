	local function CheckPlayerChoices(self)
	local votedYes = 0
	local votedNo = 0
	local voted = 0
	local players = 0
	for i = 0, GameRules.BasePlayers do
		if PlayerResource:IsValidPlayerID(i) and PlayerResource:GetPlayer(i) then
			players = players + 1
			if self._playerChoices[i] ~= nil then
				voted = voted + 1
				if self._playerChoices[i] then
					votedYes = votedYes + 1
				else
					votedNo = votedNo + 1
				end
			end
		end
	end
	
	if not self.eventEnded and not self.combatStarted then
		if votedYes > votedNo + (players - voted) then -- yes votes exceed non-votes and no votes
			self:RollLoot( RollPercentage(50) )
			Timers:CreateTimer(3, function()
				local roll = RandomInt(1, 100)
				if roll <= 10 then
					self:StartCombat(true, true)
				elseif roll <= 70 then
					self:StartCombat(true, false)
				else
					self:StartCombat(false)
				end
			end)
			return true
		elseif votedNo > votedYes + (players - voted) then -- no votes exceed yes and non-votes and every other situation
			self:StartCombat(false)
			return true
		end
	end
	return false
end

local function RollLoot(self, bRelic)
	for _, hero in ipairs( HeroList:GetRealHeroes() ) do
		local pID = hero:GetPlayerOwnerID()
		if bRelic then
			RelicManager:PushCustomRelicDropsForPlayer(pID, {RelicManager:RollRandomGenericRelicForPlayer(pID)})
		else
			hero:AddGold(500)
		end
	end
	if bRelic then
		CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_reward_given", {event = self:GetEventName(), reward = 2})
	else
		CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_reward_given", {event = self:GetEventName(), reward = 1})
	end
end

local function StartCombat(self, bFight, bBoss)
	if bFight then
		self._vEventHandles = {
			ListenToGameEvent( "entity_killed", require("events/base_combat"), self ),
		}
		self.timeRemaining = 0
		self.combatStarted = true
		local mobToSpawn = "npc_dota_boss22b"
		if bBoss then
			self.eventType = EVENT_TYPE_ELITE
			CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_reward_given", {event = self:GetEventName(), reward = 3})
			self.enemiesToSpawn = 1
			mobToSpawn = "npc_dota_boss22"
		else
			CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_reward_given", {event = self:GetEventName(), reward = 4})
			self.enemiesToSpawn = 5 * (RoundManager:GetRaidsFinished() + 1) * HeroList:GetActiveHeroCount()
			mobToSpawn = "npc_dota_boss22b"
		end
		
		Timers:CreateTimer(1, function()
			local spawn = CreateUnitByName(mobToSpawn, RoundManager:PickRandomSpawn(), true, nil, nil, DOTA_TEAM_BADGUYS)
			spawn.unitIsRoundBoss = true
			if not bBoss then spawn:SetCoreHealth( 100 * GameRules:GetGameDifficulty() ) end
			self.enemiesToSpawn = self.enemiesToSpawn - 1
			if self.enemiesToSpawn > 0 then
				return 3 / (RoundManager:GetRaidsFinished() + 1)
			end
		end)
	else
		self:EndEvent(true)
	end
end

local function FirstChoice(self, userid, event)
	local hero = PlayerResource:GetSelectedHeroEntity( event.pID )
	self._playerChoices[event.pID] = true
	CheckPlayerChoices(self)
end

local function SecondChoice(self, userid, event)
	local hero = PlayerResource:GetSelectedHeroEntity( event.pID )
	self._playerChoices[event.pID] = false
	CheckPlayerChoices(self)
end

local function StartEvent(self)	
	CustomGameEventManager:Send_ServerToAllClients("boss_hunters_event_has_started", {event = self:GetEventName(), choices = 2})
	self._vListenerHandles = {
		CustomGameEventManager:RegisterListener('player_selected_event_choice_1', Context_Wrap( self, 'FirstChoice') ),
		CustomGameEventManager:RegisterListener('player_selected_event_choice_2', Context_Wrap( self, 'SecondChoice') ),
	}
	self._vEventHandles = {}
	self.timeRemaining = 15
	self.eventEnded = false
	self.combatStarted = false
	self.waitTimer = Timers:CreateTimer(1, function()
		CustomGameEventManager:Send_ServerToAllClients("updateQuestPrepTime", {prepTime = self.timeRemaining})
		if not self.eventEnded and not self.combatStarted then
			if self.timeRemaining >= 0 then
				self.timeRemaining = self.timeRemaining - 1
				return 1
			else
				if not CheckPlayerChoices(self) then
					self:EndEvent(true)
				end
			end
		end
	end)
	self._playerChoices = {}
end

local function EndEvent(self, bWon)
	for _, eID in pairs( self._vEventHandles ) do
		StopListeningToGameEvent( eID )
	end
	for _, eID in pairs( self._vListenerHandles ) do
		CustomGameEventManager:UnregisterListener( eID )
	end
	
	self.eventType = EVENT_TYPE_EVENT
	self.eventEnded = true
	self.timeRemaining = -1
	Timers:CreateTimer(3, function() RoundManager:EndEvent(true) end)
end

local function PrecacheUnits(self, context)
	PrecacheUnitByNameSync("npc_dota_boss22", context)
	PrecacheUnitByNameSync("npc_dota_boss22b", context)
	return true
end

local function LoadSpawns(self)
	if not self.spawnLoadCompleted then
		RoundManager.spawnPositions = {}
		RoundManager.boundingBox = "sepulcher_event_abandoned_shack"
		for _,spawnPos in ipairs( Entities:FindAllByName( RoundManager.boundingBox.."_spawner" ) ) do
			table.insert( RoundManager.spawnPositions, spawnPos:GetAbsOrigin() )
		end
		self.heroSpawnPosition = self.heroSpawnPosition or nil
		for _,spawnPos in ipairs( Entities:FindAllByName( RoundManager.boundingBox.."_heroes") ) do
			self.heroSpawnPosition = spawnPos:GetAbsOrigin()
			break
		end
		
		self.spawnLoadCompleted = true
	end
end

local funcs = {
	["StartEvent"] = StartEvent,
	["EndEvent"] = EndEvent,
	["PrecacheUnits"] = PrecacheUnits,
	["LoadSpawns"] = LoadSpawns,
	["FirstChoice"] = FirstChoice,
	["SecondChoice"] = SecondChoice,
	["StartCombat"] = StartCombat,
	["RollLoot"] = RollLoot,
}

return funcs