

Menu NekoVoteMenu(int client)
{
	if (!IsValidClient(client))
		return null;

	N_MenuVoteMenu[client] = new Menu(VoteMenuHandler);

	char line[2048];
	int	 itemsflags = ITEMDRAW_DEFAULT;

	if (NCvar[CSpecial_PluginStatus].BoolValue)
		Format(line, sizeof(line), "+|NS|+ 特感玩家菜单\n刷特进程[%s]\n特感数量[%d] 刷特时间[%d]", !GetSpecialRunning() ? "未开始" : "已开始", NekoSpecials_GetSpecialsNum(), NekoSpecials_GetSpecialsTime());
	else
		Format(line, sizeof(line), "+|NS|+ 特感玩家菜单\n插件已关闭");
	N_MenuVoteMenu[client].SetTitle(line);

	if (!NCvar_Neko_Vote[Neko_CanSwitch].BoolValue)
		itemsflags = ITEMDRAW_DISABLED;

	Format(line, sizeof(line), "插件目前状态 [%s]", !NCvar[CSpecial_PluginStatus].BoolValue ? "关" : "开");
	N_MenuVoteMenu[client].AddItem("tgstat", line, !NCvar_Neko_Vote[Neko_SwitchStatus].BoolValue ? ITEMDRAW_DISABLED : itemsflags);

	if (NCvar[CSpecial_PluginStatus].BoolValue)
	{
		Format(line, sizeof(line), "全局刷特时间 [%ds]", NCvar[CSpecial_Spawn_Time].IntValue);
		if (!NCvar[CSpecial_Spawn_Time_DifficultyChange].BoolValue)
			N_MenuVoteMenu[client].AddItem("tgtime", line, !NCvar_Neko_Vote[Neko_SwitchTime].BoolValue ? ITEMDRAW_DISABLED : itemsflags);
		else
			N_MenuVoteMenu[client].AddItem("tgtime", line, ITEMDRAW_DISABLED);

		Format(line, sizeof(line), "初始刷特数量 [%d]", NCvar[CSpecial_Num].IntValue);
		N_MenuVoteMenu[client].AddItem("tgnum", line, !NCvar_Neko_Vote[Neko_SwitchNumber].BoolValue ? ITEMDRAW_DISABLED : itemsflags);

		Format(line, sizeof(line), "进人增加数量 [%d]", NCvar[CSpecial_AddNum].IntValue);
		N_MenuVoteMenu[client].AddItem("tgadd", line, !NCvar_Neko_Vote[Neko_SwitchNumber].BoolValue ? ITEMDRAW_DISABLED : itemsflags);

		Format(line, sizeof(line), "初始玩家数量 [%d]", NCvar[CSpecial_PlayerNum].IntValue);
		N_MenuVoteMenu[client].AddItem("tgpnum", line, !NCvar_Neko_Vote[Neko_SwitchPlayerJoin].BoolValue ? ITEMDRAW_DISABLED : itemsflags);

		Format(line, sizeof(line), "玩家增加数量 [%d]", NCvar[CSpecial_PlayerAdd].IntValue);
		N_MenuVoteMenu[client].AddItem("tgpadd", line, !NCvar_Neko_Vote[Neko_SwitchPlayerJoin].BoolValue ? ITEMDRAW_DISABLED : itemsflags);

		Format(line, sizeof(line), "克活着时刷新 [%s]", !NCvar[CSpecial_Spawn_Tank_Alive].BoolValue ? "否" : "是");
		N_MenuVoteMenu[client].AddItem("tgtanklive", line, !NCvar_Neko_Vote[Neko_SwitchTankAlive].BoolValue ? ITEMDRAW_DISABLED : itemsflags);

		Format(line, sizeof(line), "特感游戏模式 [%s]", SpecialName[NCvar[CSpecial_Default_Mode].IntValue]);
		N_MenuVoteMenu[client].AddItem("tgmode", line, !NCvar_Neko_Vote[Neko_SwitchGameMode].BoolValue ? ITEMDRAW_DISABLED : itemsflags);

		Format(line, sizeof(line), "特感刷新模式 [%s]", SpawnModeName[GetSpecialSpawnMode()]);
		N_MenuVoteMenu[client].AddItem("tgspawn", line, !NCvar_Neko_Vote[Neko_SwitchSpawnMode].BoolValue ? ITEMDRAW_DISABLED : itemsflags);

		Format(line, sizeof(line), "随机特感状态 [%s]", !NCvar[CSpecial_Random_Mode].BoolValue ? "关" : "开");
		N_MenuVoteMenu[client].AddItem("tgrandom", line, !NCvar_Neko_Vote[Neko_SwitchRandom].BoolValue ? ITEMDRAW_DISABLED : itemsflags);
	}

	N_MenuVoteMenu[client].ExitBackButton = true;

	return N_MenuVoteMenu[client];
}

static int VoteMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsValidClient(client))
			{
				if (!L4D2NativeVote_IsAllowNewVote())
				{
					PrintToChat(client, "\x05%s \x04暂时不能开启新的投票", NEKOTAG);
					return 0;
				}

				char items[50];
				MenuPageItem[client] = GetMenuSelectionPosition();
				cleanplayerwait(client);
				N_MenuVoteMenu[client] = null;
				menu.GetItem(selection, items, sizeof(items));
				bool NeedOpenMenu = true;

				if (StrEqual(items, "tgstat") || StrEqual(items, "tgrandom") || StrEqual(items, "tgtanklive"))
				{
					VoteMenuItems[client] = items;
					StartVoteYesNo(client);
				}
				if (StrEqual(items, "tgmode"))
				{
					NekoVote_SpecialMenuMode(client);
					NeedOpenMenu = false;
				}
				if (StrEqual(items, "tgspawn"))
				{
					NekoVote_SpecialMenuSpawn(client);
					NeedOpenMenu = false;
				}
				if (StrEqual(items, "tgtime") || StrEqual(items, "tgnum") || StrEqual(items, "tgadd") || StrEqual(items, "tgpnum") || StrEqual(items, "tgpadd"))
				{
					int	 DDMax, DDMin;
					char FChar[128];

					if (StrEqual(items, "tgtime"))
					{
						DDMax = 180;
						DDMin = 3;
						Format(FChar, sizeof FChar, "刷特时间");
					}
					else if (StrEqual(items, "tgnum"))
					{
						DDMax = 32;
						DDMin = 1;
						Format(FChar, sizeof FChar, "初始刷特数量");
					}
					else if (StrEqual(items, "tgadd"))
					{
						DDMax = 8;
						DDMin = 0;
						Format(FChar, sizeof FChar, "进人增加数量");
					}
					else if (StrEqual(items, "tgpnum"))
					{
						DDMax = 32;
						DDMin = 1;
						Format(FChar, sizeof FChar, "初始玩家数量");
					}
					else if (StrEqual(items, "tgpadd"))
					{
						DDMax = 8;
						DDMin = 1;
						Format(FChar, sizeof FChar, "玩家增加数量");
					}
					PrintToChat(client, "\x05%s \x04请在聊天栏输入你需要投票%s的数值 \x03范围[%d - %d]", NEKOTAG, FChar, DDMin, DDMax);
					WaitForVoteItems[client]	 = items;
					BoolWaitForVoteItems[client] = true;
				}
				if (NeedOpenMenu)
					CreateTimer(0.2, Timer_ReloadMenu_NekoVote, GetClientUserId(client));
			}
		}
		case MenuAction_End:
		{
			delete menu;
			if (IsValidClient(client))
				N_MenuVoteMenu[client] = null;
		}
	}

	return 0;
}

static Action NekoVote_SpecialMenuMode(int client)
{
	Menu menu = new Menu(NekoVote_SpecialMenuModeHandler);
	char line[1024];

	Format(line, sizeof(line), "+|NS|+ 选择特感模式\n选择一个模式");
	menu.SetTitle(line);

	Format(line, sizeof(line), "默认模式");
	menu.AddItem("7", line);
	Format(line, sizeof(line), "牛子模式");
	menu.AddItem("1", line);
	Format(line, sizeof(line), "胖子模式");
	menu.AddItem("2", line);
	Format(line, sizeof(line), "口水模式");
	menu.AddItem("3", line);
	Format(line, sizeof(line), "舌头模式");
	menu.AddItem("4", line);
	Format(line, sizeof(line), "猴子模式");
	menu.AddItem("5", line);
	Format(line, sizeof(line), "猎人模式");
	menu.AddItem("6", line);

	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME);
	return Plugin_Handled;
}

static int NekoVote_SpecialMenuModeHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsValidClient(client))
			{
				char items[50];
				menu.GetItem(selection, items, sizeof(items));
				SubMenuVoteItems[client] = items;
				VoteMenuItems[client]	 = "tgmode";
				StartVoteYesNo(client);
			}
		}
		case MenuAction_Cancel:
		{
			if (IsValidClient(client) && selection == MenuCancel_ExitBack)
				NekoVoteMenu(client).DisplayAt(client, MenuPageItem[client], MENU_TIME);
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
	return 0;
}

static Action NekoVote_SpecialMenuSpawn(int client)
{
	Menu menu = new Menu(NekoVote_SpecialMenuSpawnHandler);
	char line[1024];

	Format(line, sizeof(line), "+|NS|+ 选择刷特模式\n选择一个模式");
	menu.SetTitle(line);

	Format(line, sizeof(line), "导演刷特");
	menu.AddItem("0", line);
	Format(line, sizeof(line), "普通刷特");
	menu.AddItem("1", line);
	Format(line, sizeof(line), "噩梦刷特");
	menu.AddItem("2", line);
	Format(line, sizeof(line), "地狱刷特");
	menu.AddItem("3", line);
	Format(line, sizeof(line), "可变刷特");
	menu.AddItem("4", line);

	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME);
	return Plugin_Handled;
}

static int NekoVote_SpecialMenuSpawnHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (IsValidClient(client))
			{
				char items[50];
				menu.GetItem(selection, items, sizeof(items));
				SubMenuVoteItems[client] = items;
				VoteMenuItems[client]	 = "tgspawn";
				StartVoteYesNo(client);
			}
		}
		case MenuAction_Cancel:
		{
			if (IsValidClient(client) && selection == MenuCancel_ExitBack)
				NekoVoteMenu(client).DisplayAt(client, MenuPageItem[client], MENU_TIME);
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
	return 0;
}