void CreateHud()
{
	if(NCvar_NekoKillHud[CKillHud_HudStyle].IntValue > 0 && (NCvar_NekoKillHud[CKillHud_FriendlyFire].BoolValue || NCvar_NekoKillHud[CKillHud_KillSpecials].BoolValue || NCvar_NekoKillHud[CKillHud_AllKill].BoolValue) && !HudRunning)
	{
		HudRunning = true;
		CreateTimer(1.0, RefreshHUD, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}

stock void GetHUDSide(char[] sTemp, float xy[2])
{
	char xytemp[2][4];
	ExplodeString(sTemp, " ", xytemp, 2, 4);
	xy[0] = StringToFloat(xytemp[0]);
	xy[1] = StringToFloat(xytemp[1]);
	
	if((xy[0] > 1.0 || xy[0] < 0.0 || xy[1] > 1.0 || xy[1] < 0.0) && NCvar_NekoKillHud[CKillHud_HudStyle].IntValue == 3)
		LogError("自定义HUD位置超出范围");
}

stock void GetHudTitle(char[] name, char[] buffer, int maxlength)
{
	KeyValues kvSettings = new KeyValues("Settings");
	kvSettings.ImportFromFile(sPath);
	kvSettings.Rewind();
	kvSettings.GetString(name, buffer, maxlength);
	delete kvSettings;
}

stock void Kill_Init()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		Neko_ClientInfo[i].Reset();
	}
	Neko_GlobalState.Reset();
}

void UpdateConfigFile_NekoKillHUD(bool NeedReset)
{
	AutoExecConfig_DeleteConfig();

	for(int i = 1; i < Cvar_Max_NekoKillHud; i++)
	{
		AutoExecConfig_UpdateToConfig(NCvar_NekoKillHud[i], NeedReset);
	}

	AutoExecConfig_OnceExec();
}