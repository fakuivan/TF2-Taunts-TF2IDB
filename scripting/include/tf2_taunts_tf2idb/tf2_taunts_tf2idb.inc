/*
**
*/
#if defined _tf2_taunts_tf2idb_included
 #endinput
#endif
#define _tf2_taunts_tf2idb_included

enum TauntExecution {
	TauntExecution_Success = 0,
	TauntExecution_InvalidClient,
	TauntExecution_ClientNotInGame,
	TauntExecution_ClientIsUnassigned,
	TauntExecution_ClientIsSpectator,
	TauntExecution_InvalidClass,
	TauntExecution_TargetIsDead,
	TauntExecution_WrongClass,
	TauntExecution_IvalidIDX,
	TauntExecution_TauntFailed,
}

enum InitializationStatus {
	InitializationStatus_Success = 0,
	InitializationStatus_InvalidGamedataFile,
	InitializationStatus_InvalidGamedataOutdated,
#if defined _tf2idb_included //{
	InitializationStatus_FromTF2IDB_Error,
#endif //}
}

stock void ReplyToTauntTarget(int i_target, TauntExecution i_result)
{
	switch (i_result)
	{
		case TauntExecution_InvalidClient:
		{
			ReplyToCommand(i_target, "[SM] %t", "tf2_taunts_tf2idb__failed_to_target__InvalidClient");
		}
		case TauntExecution_ClientIsSpectator:
		{
			ReplyToCommand(i_target, "[SM] %t", "tf2_taunts_tf2idb__failed_to_target__ClientIsSpectator");
		}
		case TauntExecution_ClientIsUnassigned:
		{
			ReplyToCommand(i_target, "[SM] %t", "tf2_taunts_tf2idb__failed_to_target__ClientIsUnassigned");
		}
		case TauntExecution_InvalidClass:
		{
			ReplyToCommand(i_target, "[SM] %t", "tf2_taunts_tf2idb__failed_to_target__InvalidClass");
		}
		case TauntExecution_TargetIsDead:
		{
			ReplyToCommand(i_target, "[SM] %t", "tf2_taunts_tf2idb__failed_to_target__TargetIsDead");
		}
		case TauntExecution_WrongClass:
		{
			ReplyToCommand(i_target, "[SM] %t", "tf2_taunts_tf2idb__failed_to_target__WrongClass");
		}
		case TauntExecution_IvalidIDX:
		{
			ReplyToCommand(i_target, "[SM] %t", "tf2_taunts_tf2idb__failed_to_target__IvalidIDX");
		}
		case TauntExecution_TauntFailed:
		{
			ReplyToCommand(i_target, "[SM] %t", "tf2_taunts_tf2idb__failed_to_target__TauntFailed");
		}
	}
}

stock TauntExecution CheckOnly(int i_target, TFClassType &i_class = TFClass_Unknown)
{
	if (!(i_target > 0 && i_target <= MaxClients))
	{
		return TauntExecution_InvalidClient;
	}
	if (!IsClientInGame(i_target))
	{
		return TauntExecution_ClientNotInGame;
	}
	if (TF2_GetClientTeam(i_target) == TFTeam_Unassigned)
	{
		return TauntExecution_ClientIsUnassigned;
	}
	if (TF2_GetClientTeam(i_target) == TFTeam_Spectator)
	{
		return TauntExecution_ClientIsSpectator;
	}
	if ((i_class = TF2_GetPlayerClass(i_target)) == TFClass_Unknown)
	{
		return TauntExecution_InvalidClass;
	}
	if (!IsPlayerAlive(i_target))
	{
		return TauntExecution_TargetIsDead;
	}
	return TauntExecution_Success;
}

stock TauntExecution CheckAndTaunt(int i_target, int i_idx, CTauntEnforcer h_enforcer, CTauntCacheSystem h_taunts)
{
	TauntExecution i_check_only_result;
	TFClassType i_class;
	if ((i_check_only_result = CheckOnly(i_target, i_class)) != TauntExecution_Success) { return i_check_only_result; }
	
	i_class = TF2_GetPlayerClass(i_target);
	int i_index;
	if (!h_taunts.IsValidTaunt(i_idx, i_class, i_index))
	{
		if (i_index != -1)	//if IsValidTaunt returns false but the index is not -1, the idx is valid, but the classes don't match
		{
			return TauntExecution_WrongClass;
		}
		else
		{
			return TauntExecution_IvalidIDX;
		}
	}
	if (!h_enforcer.ForceTaunt(i_target, i_idx))
	{
		return TauntExecution_TauntFailed;
	}
	else
	{	
		return TauntExecution_Success;
	}
}

stock int GetCmdArgInt(int i_argnum, int i_length = 12, int i_base = 10)
{
	char[] s_buffer = new char[i_length];
	GetCmdArg(i_argnum, s_buffer, i_length);
	return StringToInt(s_buffer, i_base);
}
