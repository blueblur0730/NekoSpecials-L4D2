void NekoVote_OnPluginStart()
{
	NekoVoteInit();
}

void NekoVote_CreateNatives()
{
	RegPluginLibrary("nekovote");
	CreateNative("NekoVote_PlHandle", NekoVote_REPlHandle);
	CreateNative("NekoVote_VoteStatus", NekoVote_REVoteStatus);
}

void NekoVote_OnConfigsExecuted()
{
	for (int i = 1; i < Cvar_Max_NekoSpecials; i++)
	{
		if (i == CGame_Difficulty)
			continue;

		NCvar[i] = NekoSpecials_GetConVar(i);
	}
}

static void NekoVoteInit()
{
	NCvar_Neko_Vote[Neko_CanSwitch]			= AutoExecConfig_CreateConVar("Neko_CanSwitch", "0", "[0=关|1=开]全局投票开关", _, true, 0.0, true, 1.0);
	NCvar_Neko_Vote[Neko_SwitchStatus]		= AutoExecConfig_CreateConVar("Neko_SwitchStatus", "0", "[0=关|1=开]玩家是否能投票更改插件状态", _, true, 0.0, true, 1.0);
	NCvar_Neko_Vote[Neko_SwitchNumber]		= AutoExecConfig_CreateConVar("Neko_SwitchNumber", "0", "[0=关|1=开]玩家是否能投票更改特感数量", _, true, 0.0, true, 1.0);
	NCvar_Neko_Vote[Neko_SwitchTime]		= AutoExecConfig_CreateConVar("Neko_SwitchTime", "0", "[0=关|1=开]玩家是否能投票更改刷特时间", _, true, 0.0, true, 1.0);
	NCvar_Neko_Vote[Neko_SwitchRandom]		= AutoExecConfig_CreateConVar("Neko_SwitchRandom", "0", "[0=关|1=开]玩家是否能投票开关随机特感", _, true, 0.0, true, 1.0);
	NCvar_Neko_Vote[Neko_SwitchGameMode]	= AutoExecConfig_CreateConVar("Neko_SwitchGameMode", "0", "[0=关|1=开]玩家是否能投票更改插件特感模式", _, true, 0.0, true, 1.0);
	NCvar_Neko_Vote[Neko_SwitchSpawnMode]	= AutoExecConfig_CreateConVar("Neko_SwitchSpawnMode", "0", "[0=关|1=开]玩家是否能投票更改插件刷特模式", _, true, 0.0, true, 1.0);
	NCvar_Neko_Vote[Neko_SwitchPlayerJoin]	= AutoExecConfig_CreateConVar("Neko_SwitchPlayerJoin", "0", "[0=关|1=开]玩家是否能投票设置根据玩家加入数量变动特感数量功能", _, true, 0.0, true, 1.0);
	NCvar_Neko_Vote[Neko_SwitchTankAlive]	= AutoExecConfig_CreateConVar("Neko_SwitchTankAlive", "0", "[0=关|1=开]玩家是否能开关坦克存活时依旧刷特功能", _, true, 0.0, true, 1.0);
	NCvar_Neko_Vote[Neko_NeedResetNoPlayer] = AutoExecConfig_CreateConVar("Neko_NeedResetNoPlayer", "0", "[0=关|1=开]全部玩家离开游戏后自动重置特感数据", _, true, 0.0, true, 1.0);
	NCvar_Neko_Vote[Neko_NeedResetTime]		= AutoExecConfig_CreateConVar("Neko_NeedResetTime", "10", "全部玩家离开游戏多少秒后自动重置");

	HookEventEx("player_disconnect", Event_PlayerDisconnect, EventHookMode_Pre);

	AddCommandListener(ChatListener, "say");
	AddCommandListener(ChatListener, "say2");
	AddCommandListener(ChatListener, "say_team");

	RegConsoleCmd("sm_tgvote", OpenVoteMenu, "打开特感投票菜单");

	RegAdminCmd("sm_tgvoteadmin", OpenVoteAdminMenu, ADMFLAG_ROOT, "打开管理员投票控制菜单");
}