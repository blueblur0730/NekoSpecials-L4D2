Action Timer_ReloadMenu_NekoVote(Handle timer, any client)
{
	client = GetClientOfUserId(client);
	if (IsValidClient(client))
		NekoVoteMenu(client).DisplayAt(client, MenuPageItem[client], MENU_TIME);
	return Plugin_Continue;
}

Action Timer_ReloadAdminMenu(Handle timer, any client)
{
	client = GetClientOfUserId(client);
	if (IsValidClient(client))
		NekoVoteAdminMenu(client).DisplayAt(client, AdminMenuPageItem[client], MENU_TIME);
	return Plugin_Continue;
}

Action Timer_CheckPlayers(Handle timer, any UserId)
{
	if (!RealPlayerExist())
	{
		NekoSpecials_ReLoadAllConfig();
		LogMessage("[NekoVote] Reset Specials Config!");
	}
	return Plugin_Stop;
}