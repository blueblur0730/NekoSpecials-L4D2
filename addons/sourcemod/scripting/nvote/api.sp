

any NekoVote_REPlHandle(Handle plugin, int numParams)
{
	return GetMyHandle();
}

any NekoVote_REVoteStatus(Handle plugin, int numParams)
{
	return NCvar_Neko_Vote[Neko_CanSwitch].BoolValue;
}