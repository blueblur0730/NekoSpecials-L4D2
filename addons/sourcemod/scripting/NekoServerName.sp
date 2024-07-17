#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <left4dhooks>
#include <neko/nekotools>
#include <neko/nekonative>

#define PLUGIN_CONFIG		 "Neko_ServerName"

#define SPECIALS_AVAILABLE() (GetFeatureStatus(FeatureType_Native, "NekoSpecials_GetSpecialsNum") == FeatureStatus_Available)

char		  CorePath[PLATFORM_MAX_PATH], ServerNameFormat[256];

float		  GetMapMaxFlow, CheckGameTime;

int			  RoundFailCounts;

GlobalForward N_Forward_OnChangeServerName;

#define CServerName_AutoUpdate		1
#define CServerName_UpdateTime		2
#define CServerName_ShowTimeSeconds 3
#define Cvar_Max					4

ConVar NCvar[Cvar_Max];

char   CustomText[256];

public Plugin myinfo =
{
	name		= "Neko ServerName",
	description = "Neko ServerName",
	author		= "Neko Channel",
	version		= PLUGIN_VERSION,
	url			= "https://himeneko.cn/nekospecials"
	//请勿修改插件信息！
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
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
	return APLRes_Success;
}

public any NekoServerName_REPlHandle(Handle plugin, int numParams)
{
	return GetMyHandle();
}

public any NekoServerName_REChangeCustomTest(Handle plugin, int numParams)
{
	GetNativeString(1, CustomText, sizeof(CustomText));
	SetServerName();
	return 0;
}

public void OnPluginStart()
{
	AutoExecConfig_SetFile(PLUGIN_CONFIG);

	NCvar[CServerName_AutoUpdate]	   = AutoExecConfig_CreateConVar("ServerName_AutoUpdate", "1", "[0=关|1=开]禁用/启用自动更新服务器名字功能[显示路程需要打开]", _, true, 0.0, true, 1.0);
	NCvar[CServerName_UpdateTime]	   = AutoExecConfig_CreateConVar("ServerName_UpdateTime", "15", "服务器名字自动更新延迟", _, true, 1.0, true, 120.0);
	NCvar[CServerName_ShowTimeSeconds] = AutoExecConfig_CreateConVar("ServerName_ShowTimeSeconds", "1", "[0=关|1=开]禁用/启用计时显秒", _, true, 0.0, true, 1.0);

	AutoExecConfig_OnceExec();

	BuildPath(Path_SM, CorePath, sizeof(CorePath), "data/nekocustom.cfg");
	if (!FileExists(CorePath))
		CreateConfigFire(CorePath);

	RequestFrame(SetCvarHook);

	HookEvent("mission_lost", mission_lost, EventHookMode_Pre);

	RegAdminCmd("sm_updateservername", StartNekoUpdate, ADMFLAG_ROOT, "执行服务器名字更新");
	RegAdminCmd("sm_host", StartNekoUpdate, ADMFLAG_ROOT, "执行服务器名字更新");
	RegAdminCmd("sm_hosts", StartNekoUpdate, ADMFLAG_ROOT, "执行服务器名字更新");
}

public void HookChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	SetServerName();
}

void SetCvarHook()
{
	for (int i = 1; i < Cvar_Max; i++)
	{
		NCvar[i].AddChangeHook(HookChanged);
	}
}

public Action StartNekoUpdate(int client, int args)
{
	SetServerName();
	return Plugin_Continue;
}

public void OnMapStart()
{
	FindConVar("sv_hibernate_when_empty").SetInt(0);
	StartCatchTime();
}

public void OnConfigsExecuted()
{
	GetServerName(ServerNameFormat, sizeof(ServerNameFormat));

	RoundFailCounts = 0;
	CheckGameTime	= 0.0;
	GetMapMaxFlow	= L4D2Direct_GetMapMaxFlowDistance();

	SetServerName();
}

public void mission_lost(Event event, const char[] name, bool dontBroadcast)
{
	RoundFailCounts++;
}

public Action NekoSpecials_OnSetSpecialsNum()
{
	SetServerName();
	return Plugin_Continue;
}

public Action NekoSpecials_OnSetSpecialsTime()
{
	SetServerName();
	return Plugin_Continue;
}

public Action NekoSpecials_OnStartFirstSpawn()
{
	SetServerName();
	return Plugin_Continue;
}

public void OnGameFrame()
{
	if (GetGameTime() - CheckGameTime >= NCvar[CServerName_UpdateTime].FloatValue)
	{
		if (NCvar[CServerName_AutoUpdate].BoolValue)
		{
			SetServerName();
		}
		CheckGameTime = GetGameTime();
	}
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

stock void GetServerName(char[] buffer, int maxlength)
{
	KeyValues kvSettings = new KeyValues("Settings");
	kvSettings.ImportFromFile(CorePath);
	kvSettings.Rewind();
	kvSettings.GetString("ServerNameFormat", buffer, maxlength);
	delete kvSettings;
}

stock void GetRunMapTime(char[] sTime, int maxlength)
{
	if (NCvar[CServerName_ShowTimeSeconds].BoolValue)
		FormatEx(sTime, maxlength, "[计时:%sm:%ss]", GetNowTime_Minutes(), GetNowTime_Seconds());
	else
		FormatEx(sTime, maxlength, "[计时:%sm]", GetNowTime_Minutes());
}