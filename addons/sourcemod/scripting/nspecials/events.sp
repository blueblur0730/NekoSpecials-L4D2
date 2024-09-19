

Action OnRoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	IsPlayerLeftCP = false;
	SetSpecialRunning(false);
	TgModeStartSet();
	CreateTimer(0.1, PlayerLeftStart, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Continue;
}

Action player_team(Event event, const char[] name, bool dontBroadcast)
{
	CreateTimer(0.1, Timer_SetMaxSpecialsCount, _, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Continue;
}

void OnPlayerDisconnect(Event hEvent, const char[] sName, bool bDontBroadcast)
{
	int client = GetClientOfUserId(hEvent.GetInt("userid"));
	if (IsValidClient(client))
	{
		if (IsFakeClient(client))
		{
			if (NCvar[CSpecial_PluginStatus].BoolValue && IsPlayerLeftCP)
			{
				if (IsPlayerTank(client))
					CreateTimer(0.5, Timer_DelayDeath);
			}
			else
				SetSpecialRunning(false);
		}
		else
		{
			CheckBiledTime[client] = 0.0;
			CheckFreeTime[client]  = 0.0;
			CheckNotCombat[client] = 0;
			N_ClientItem[client].Reset();
			N_ClientMenu[client].Reset(true);
			CreateTimer(0.1, Timer_SetMaxSpecialsCount, _, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

Action OnRoundEnd(Event hEvent, const char[] sName, bool bDontBroadcast)
{
	IsPlayerLeftCP = false;
	SetSpecialRunning(false);
	return Plugin_Continue;
}

Action OnTankDeath(Handle event, const char[] name, bool dontBroadcast)
{
	if (NCvar[CSpecial_PluginStatus].BoolValue)
		CreateTimer(0.2, Timer_DelayDeath);
	else
		SetSpecialRunning(false);

	return Plugin_Continue;
}

static Action Timer_DelayDeath(Handle hTimer)
{
	if (L4D2_IsTankInPlay() && !NCvar[CSpecial_Spawn_Tank_Alive].BoolValue)
		SetSpecialRunning(false);
	else
		SetSpecialRunning(true);

	return Plugin_Continue;
}

Action OnPlayerDeath(Event hEvent, const char[] sName, bool bDontBroadcast)
{
	int client = GetClientOfUserId(hEvent.GetInt("userid"));
	if (IsValidClient(client) && IsFakeClient(client) && GetClientTeam(client) == 3)
		RequestFrame(Timer_KickBot, GetClientUserId(client));

	if (IsValidClient(client) && GetClientTeam(client) == 2 && NCvar[CSpecial_Num_NotCul_Death].BoolValue)
		SetMaxSpecialsCount();

	return Plugin_Continue;
}

Action OnPlayerSpawn(Event hEvent, const char[] sName, bool bDontBroadcast)
{
	int client = GetClientOfUserId(hEvent.GetInt("userid"));

	if (IsValidClient(client) && GetClientTeam(client) == 2 && NCvar[CSpecial_Num_NotCul_Death].BoolValue)
		SetMaxSpecialsCount();

	return Plugin_Continue;
}

Action OnTankSpawn(Event event, const char[] name, bool dontBroadcast)
{
	if (NCvar[CSpecial_PluginStatus].BoolValue)
		SetSpecialRunning(NCvar[CSpecial_Spawn_Tank_Alive].BoolValue);
	else
		SetSpecialRunning(false);

	return Plugin_Continue;
}

void NekoSpecials_OnPlayerStuck(int client)
{
	if (IsValidClient(client) && IsPlayerAlive(client) && GetClientTeam(client) == 3 && IsFakeClient(client))
	{
		if (IsPlayerTank(client) && !NCvar[CSpecial_AutoKill_StuckTank].BoolValue)
			return;

		if (!NCvar[CSpecial_AutoKill_StuckSpecials].BoolValue)
			return;

		KickClient(client, "Infected Stuck");
	}
}