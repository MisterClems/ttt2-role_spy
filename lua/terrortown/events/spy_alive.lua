EVENT.base = "base_event"

if SERVER then
	resource.AddFile("materials/vgui/ttt/vskin/events/spy_alive.vmt")
end

if CLIENT then
	EVENT.icon = Material("vgui/ttt/vskin/events/spy_alive")
	EVENT.title = "title_event_spy_alive"

	function EVENT:GetText()
		return {
			{
				string = "desc_event_spy_alive"
			}
		}
	end
end

if SERVER then
	function EVENT:Trigger()
		local plys = player.GetAll()
		local eventPlys = {}
		local spyAlive = false

		for i = 1, #plys do
			local ply = plys[i]

			if not ply:IsTerror() or not ply:Alive() or ply:GetSubRole() ~= ROLE_SPY then continue end

			self:AddAffectedPlayers(
				{ply:SteamID64()},
				{ply:Nick()}
			)

			eventPlys[#eventPlys + 1] = {
				nick = ply:Nick(),
				sid64 = ply:SteamID64()
			}

			-- only add this event if a spy is alive
			spyAlive = true
		end

		if not spyAlive then return end

		return self:Add({plys = eventPlys})
	end

	function EVENT:CalculateScore()
		local plys = self.event.plys

		for i = 1, #plys do
			local ply = plys[i]

			self:SetPlayerScore(ply.sid64, {
				score = GetConVar("ttt2_spy_survival_bonus"):GetInt()
			})
		end
	end
end

function EVENT:Serialize()
	return "One or more Spies have survived the round."
end

-- trigger this event once the round ended but before the events are synced
hook.Add("TTT2AddedEvent", "trigger_spy_survival_event", function(type)
	if type ~= EVENT_FINISH then return end

	events.Trigger(EVENT_SPY_ALIVE)
end)
