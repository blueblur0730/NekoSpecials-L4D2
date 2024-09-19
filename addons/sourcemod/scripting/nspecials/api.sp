void NekoSpecial_AskPluginLoad2()
{
	CreateNative("NekoSpecials_PlHandle", NekoSpecials_REPlHandle);
	CreateNative("NekoSpecials_GetSpawnMode", NekoSpecials_REGetSpawnMode);
	CreateNative("NekoSpecials_GetSpecialsNum", NekoSpecials_REGetSpecialsNum);
	CreateNative("NekoSpecials_GetSpecialsTime", NekoSpecials_REGetSpecialsTime);
	CreateNative("NekoSpecials_GetPluginStatus", NekoSpecials_REGetPluginStatus);
	CreateNative("NekoSpecials_GetSpecialsMode", NekoSpecials_REGetSpecialsMode);
	CreateNative("NekoSpecials_ShowSpecialsTips", NekoSpecials_REShowSpecialsTips);
	CreateNative("NekoSpecials_ShowYourTips", NekoSpecials_REShowYourTips);
	CreateNative("NekoSpecials_GetConVar", NekoSpecials_REGetConVar);
	CreateNative("NekoSpecials_ShowSpecialsModeTips", NekoSpecials_REShowSpecialsModeTips);
	CreateNative("NekoSpecials_ReLoadAllConfig", NekoSpecials_REReLoadAllConfig);

	N_Forward_OnSetSpecialsNum	= new GlobalForward("NekoSpecials_OnSetSpecialsNum", ET_Event);
	N_Forward_OnSetSpecialsTime = new GlobalForward("NekoSpecials_OnSetSpecialsTime", ET_Event);
	N_Forward_OnStartFirstSpawn = new GlobalForward("NekoSpecials_OnStartFirstSpawn", ET_Event);
}

any NekoSpecials_REReLoadAllConfig(Handle plugin, int numParams)
{
	AutoExecConfig_OnceExec();
	return 0;
}

any NekoSpecials_REShowSpecialsTips(Handle plugin, int numParams)
{
	InfectedTips();
	return 0;
}

any NekoSpecials_REShowSpecialsModeTips(Handle plugin, int numParams)
{
	ModeTips();
	return 0;
}

any NekoSpecials_REShowYourTips(Handle plugin, int numParams)
{
	char cshowtips[48];
	GetNativeString(1, cshowtips, sizeof(cshowtips));
	HUDShowMsg(cshowtips);
	return 0;
}

int NekoSpecials_REGetSpawnMode(Handle plugin, int numParams)
{
	return GetSpecialSpawnMode();
}

int NekoSpecials_REGetSpecialsMode(Handle plugin, int numParams)
{
	return NCvar[CSpecial_Default_Mode].IntValue;
}

int NekoSpecials_REGetPluginStatus(Handle plugin, int numParams)
{
	return NCvar[CSpecial_PluginStatus].BoolValue;
}

int NekoSpecials_REGetSpecialsNum(Handle plugin, int numParams)
{
	return GetSpecialMax();
}

int NekoSpecials_REGetSpecialsTime(Handle plugin, int numParams)
{
	return GetSpecialRespawnInterval();
}

any NekoSpecials_REPlHandle(Handle plugin, int numParams)
{
	return GetMyHandle();
}

any NekoSpecials_REGetConVar(Handle plugin, int numParams)
{
	return NCvar[GetNativeCell(1)];
}