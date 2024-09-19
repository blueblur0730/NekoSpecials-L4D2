

void NekoVote_OnClientSayCommand(int client, const char[] args)
{
	static char voteCommands[][] = { "tgvote", ".tgvote", "!TGVOTE", "TGVOTE", ".TGVOTE" };

	for (int i = 0; i < sizeof(voteCommands); i++)
	{
		if (strcmp(args[0], voteCommands[i], false) == 0)
		{
			NekoVoteMenu(client).Display(client, MENU_TIME);
			break;
		}
	}
}

void NekoVote_ChatListener(int client)
{
	if (!IsValidClient(client) || IsFakeClient(client) || IsChatTrigger())
		return;

	if (BoolWaitForVoteItems[client])
	{
		if (!L4D2NativeVote_IsAllowNewVote())
		{
			PrintToChat(client, "\x05%s \x04暂时不能开启新的投票", NEKOTAG);
			cleanplayerwait(client);
			return;
		}

		char msg[128];

		GetCmdArgString(msg, sizeof(msg));
		StripQuotes(msg);

		if (StrEqual(msg, "!cancel"))
		{
			PrintToChat(client, "\x05%s \x04本次操作取消", NEKOTAG);
			cleanplayerwait(client);
			cleanplayerchar(client);
			return;
		}

		int	 DDMax, DDMin;
		char FChar[128];

		if (StrEqual(WaitForVoteItems[client], "tgtime"))
		{
			DDMax = 180;
			DDMin = 3;
			Format(FChar, sizeof FChar, "刷特时间");
		}
		else if (StrEqual(WaitForVoteItems[client], "tgnum"))
		{
			DDMax = 32;
			DDMin = 1;
			Format(FChar, sizeof FChar, "初始刷特数量");
		}
		else if (StrEqual(WaitForVoteItems[client], "tgadd"))
		{
			DDMax = 8;
			DDMin = 0;
			Format(FChar, sizeof FChar, "进人增加数量");
		}
		else if (StrEqual(WaitForVoteItems[client], "tgpnum"))
		{
			DDMax = 32;
			DDMin = 1;
			Format(FChar, sizeof FChar, "初始玩家数量");
		}
		else if (StrEqual(WaitForVoteItems[client], "tgpadd"))
		{
			DDMax = 8;
			DDMin = 1;
			Format(FChar, sizeof FChar, "玩家增加数量");
		}

		if (GetCmdArgInt(1) < DDMin || GetCmdArgInt(1) > DDMax)
		{
			PrintToChat(client, "\x05%s \x04输入的%s有误，请重试 \x03范围[%d - %d]", NEKOTAG, FChar, DDMin, DDMax);
			return;
		}
		else
		{
			VoteMenuItems[client]	  = WaitForVoteItems[client];
			VoteMenuItemValue[client] = GetCmdArgInt(1);
			StartVoteYesNo(client);
		}

		cleanplayerwait(client);

		return;
	}
}