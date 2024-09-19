void NekoServerName_CreateNatives()
{
	RegPluginLibrary("nekoservername");

	CreateNative("NekoServerName_PlHandle", NekoServerName_REPlHandle);
	CreateNative("NekoServerName_ChangeCustomTest", NekoServerName_REChangeCustomTest);

	N_Forward_OnChangeServerName = new GlobalForward("NekoServerName_OnChangeServerName", ET_Event);

	MarkNativeAsOptional("NekoSpecials_GetSpecialsNum");
	MarkNativeAsOptional("NekoSpecials_GetSpecialsTime");
	MarkNativeAsOptional("NekoSpecials_OnSetSpecialsNum");
	MarkNativeAsOptional("NekoSpecials_OnSetSpecialsTime");
	MarkNativeAsOptional("NekoSpecials_GetSpawnMode");
	MarkNativeAsOptional("NekoSpecials_GetSpecialsMode");
	MarkNativeAsOptional("NekoSpecials_OnStartFirstSpawn");
}

any NekoServerName_REPlHandle(Handle plugin, int numParams)
{
	return GetMyHandle();
}

any NekoServerName_REChangeCustomTest(Handle plugin, int numParams)
{
	GetNativeString(1, CustomText, sizeof(CustomText));
	SetServerName();
	return 0;
}

void NekoServerName_OnPluginStart()
{
	AutoExecConfig_SetFile(NEKO_SERVERNAME_PLUGIN_CONFIG);

	NCvar_Neko_ServerName[CServerName_AutoUpdate]	   = AutoExecConfig_CreateConVar("ServerName_AutoUpdate", "1", "[0=关|1=开]禁用/启用自动更新服务器名字功能[显示路程需要打开]", _, true, 0.0, true, 1.0);
	NCvar_Neko_ServerName[CServerName_UpdateTime]	   = AutoExecConfig_CreateConVar("ServerName_UpdateTime", "15", "服务器名字自动更新延迟", _, true, 1.0, true, 120.0);
	NCvar_Neko_ServerName[CServerName_ShowTimeSeconds] = AutoExecConfig_CreateConVar("ServerName_ShowTimeSeconds", "1", "[0=关|1=开]禁用/启用计时显秒", _, true, 0.0, true, 1.0);

	AutoExecConfig_OnceExec();

	BuildPath(Path_SM, sCorePath, sizeof(sCorePath), "data/nekocustom.cfg");
	if (!FileExists(sCorePath))
		CreateConfigFire(sCorePath);

	RequestFrame(SetCvarHook_ServerName);

	HookEvent("mission_lost", mission_lost, EventHookMode_Pre);

	RegAdminCmd("sm_updateservername", StartNekoUpdate, ADMFLAG_ROOT, "执行服务器名字更新");
	RegAdminCmd("sm_host", StartNekoUpdate, ADMFLAG_ROOT, "执行服务器名字更新");
	RegAdminCmd("sm_hosts", StartNekoUpdate, ADMFLAG_ROOT, "执行服务器名字更新");
}

void SetCvarHook_ServerName()
{
	for (int i = 1; i < Neko_ServerName_Cvar_Max; i++)
	{
		NCvar_Neko_ServerName[i].AddChangeHook(HookChanged_ServerName);
	}
}

static void HookChanged_ServerName(ConVar convar, const char[] oldValue, const char[] newValue)
{
	SetServerName();
}

void NekoServerName_OnMapStart()
{
	FindConVar("sv_hibernate_when_empty").SetInt(0);
	StartCatchTime();
}

void NekoServerName_OnConfigsExecuted()
{
	GetServerName(ServerNameFormat, sizeof(ServerNameFormat));

	RoundFailCounts = 0;
	CheckGameTime	= 0.0;
	GetMapMaxFlow	= L4D2Direct_GetMapMaxFlowDistance();

	SetServerName();
}

void NekoServerName_OnGameFrame()
{
	if (GetGameTime() - CheckGameTime >= NCvar_Neko_ServerName[CServerName_UpdateTime].FloatValue)
	{
		if (NCvar_Neko_ServerName[CServerName_AutoUpdate].BoolValue)
		{
			SetServerName();
		}
		CheckGameTime = GetGameTime();
	}
}

Action StartNekoUpdate(int client, int args)
{
	SetServerName();
	return Plugin_Continue;
}

static void mission_lost(Event event, const char[] name, bool dontBroadcast)
{
	RoundFailCounts++;
}

void SetServerName()
{
	char ServerPort[6], ServerName[512], tmp[512];

	FindConVar("hostport").GetString(ServerPort, sizeof(ServerPort));

	Format(ServerName, sizeof(ServerName), ServerNameFormat);

	if (SPECIALS_AVAILABLE())
	{
		IntToString(NekoSpecials_GetSpecialsNum(), tmp, sizeof(tmp));
		ReplaceString(ServerName, sizeof(ServerName), "{specials}", tmp, false);
		IntToString(NekoSpecials_GetSpecialsTime(), tmp, sizeof(tmp));
		ReplaceString(ServerName, sizeof(ServerName), "{times}", tmp, false);

		ReplaceString(ServerName, sizeof(ServerName), "{spawnmode}", SpawnModeName[NekoSpecials_GetSpawnMode()], false);
		ReplaceString(ServerName, sizeof(ServerName), "{specialsmode}", SpecialName[NekoSpecials_GetSpecialsMode()], false);
	}

	if (IsNullString(ServerPort[4]))
		ReplaceString(ServerName, sizeof(ServerName), "{servernum}", ServerPort[3], false);
	else
	{
		if (!StrEqual(ServerPort[3], "0"))
		{
			Format(tmp, sizeof(tmp), "%s%s", ServerPort[3], ServerPort[4]);
		}
		else
		{
			Format(tmp, sizeof(tmp), "%s", ServerPort[4]);
		}
		ReplaceString(ServerName, sizeof(ServerName), "{servernum}", tmp, false);
	}

	ReplaceString(ServerName, sizeof(ServerName), "{gamedifficulty}", GameDifficulty[GameDifficultyNum()], false);

	IntToString(RoundFailCounts, tmp, sizeof(tmp));
	ReplaceString(ServerName, sizeof(ServerName), "{restartcount}", tmp, false);

	ReplaceString(ServerName, sizeof(ServerName), "{customtext}", CustomText, false);

	IntToString(GetRealPlayers(false), tmp, sizeof(tmp));
	ReplaceString(ServerName, sizeof(ServerName), "{realplayernum}", tmp, false);

	IntToString(GetPlayers(false), tmp, sizeof(tmp));
	ReplaceString(ServerName, sizeof(ServerName), "{playernum}", tmp, false);

	IntToString(GetRealAlivePlayers(false), tmp, sizeof(tmp));
	ReplaceString(ServerName, sizeof(ServerName), "{realaliveplayernum}", tmp, false);

	IntToString(GetAlivePlayers(false), tmp, sizeof(tmp));
	ReplaceString(ServerName, sizeof(ServerName), "{aliveplayernum}", tmp, false);

	if (L4D_HasAnySurvivorLeftSafeArea())
	{
		int	  OneSurvivor;

		float fHighestFlow = IsValidSurvivor((OneSurvivor = L4D_GetHighestFlowSurvivor())) ? L4D2Direct_GetFlowDistance(OneSurvivor) : L4D2_GetFurthestSurvivorFlow();

		if (fHighestFlow)
			fHighestFlow = fHighestFlow / GetMapMaxFlow * 100;

		char playflow[64];
		Format(playflow, sizeof(playflow), "%d%%", RoundToNearest(fHighestFlow));

		ReplaceString(ServerName, sizeof(ServerName), "{flow}", playflow);
	}
	else
	{
		ReplaceString(ServerName, sizeof(ServerName), "{flow}", "0%");
	}

	GetRunMapTime(tmp, sizeof(tmp));

	ReplaceString(ServerName, sizeof(ServerName), "{maptime}", tmp, false);

	FindConVar("hostname").SetString(ServerName, true, false);

	FindConVar("sv_hibernate_when_empty").SetInt(0);

	Call_StartForward(N_Forward_OnChangeServerName);
	Call_Finish(N_Forward_OnChangeServerName);
}

static void GetServerName(char[] buffer, int maxlength)
{
	KeyValues kvSettings = new KeyValues("Settings");
	kvSettings.ImportFromFile(sCorePath);
	kvSettings.Rewind();
	kvSettings.GetString("ServerNameFormat", buffer, maxlength);
	delete kvSettings;
}

static void GetRunMapTime(char[] sTime, int maxlength)
{
	if (NCvar[CServerName_ShowTimeSeconds].BoolValue)
		FormatEx(sTime, maxlength, "[计时:%sm:%ss]", GetNowTime_Minutes(), GetNowTime_Seconds());
	else
		FormatEx(sTime, maxlength, "[计时:%sm]", GetNowTime_Minutes());
}