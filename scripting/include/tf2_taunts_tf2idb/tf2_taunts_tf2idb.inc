/*
**
*/
#if defined _tf2_taunts_tf2idb_included
 #endinput
#endif
#define _tf2_taunts_tf2idb_included

#define INT_HEX_LENGTH	10
#define INT_DEC_LENGTH	12

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

// notify stocks {

stock void ReplyToTauntTarget(int i_target, TauntExecution i_result)
{
	switch (i_result)
	{
		case TauntExecution_InvalidClient:
		{
			ReplyToCommand(i_target, "[SM] %t", PLUGIN_SHORT_NAME ... "__failed_to_target__InvalidClient");
		}
		case TauntExecution_ClientIsSpectator:
		{
			ReplyToCommand(i_target, "[SM] %t", PLUGIN_SHORT_NAME ... "__failed_to_target__ClientIsSpectator");
		}
		case TauntExecution_ClientIsUnassigned:
		{
			ReplyToCommand(i_target, "[SM] %t", PLUGIN_SHORT_NAME ... "__failed_to_target__ClientIsUnassigned");
		}
		case TauntExecution_InvalidClass:
		{
			ReplyToCommand(i_target, "[SM] %t", PLUGIN_SHORT_NAME ... "__failed_to_target__InvalidClass");
		}
		case TauntExecution_TargetIsDead:
		{
			ReplyToCommand(i_target, "[SM] %t", PLUGIN_SHORT_NAME ... "__failed_to_target__TargetIsDead");
		}
		case TauntExecution_WrongClass:
		{
			ReplyToCommand(i_target, "[SM] %t", PLUGIN_SHORT_NAME ... "__failed_to_target__WrongClass");
		}
		case TauntExecution_IvalidIDX:
		{
			ReplyToCommand(i_target, "[SM] %t", PLUGIN_SHORT_NAME ... "__failed_to_target__IvalidIDX");
		}
		case TauntExecution_TauntFailed:
		{
			ReplyToCommand(i_target, "[SM] %t", PLUGIN_SHORT_NAME ... "__failed_to_target__TauntFailed");
		}
	}
}

stock void ReplyToTauntTargetOther(int i_target, TauntExecution i_result)
{
	switch (i_result)
	{
		case TauntExecution_InvalidClient:
		{
			ReplyToCommand(i_target, "[SM] %t", PLUGIN_SHORT_NAME ... "__failed_to_target_other__InvalidClient");
		}
		case TauntExecution_ClientIsSpectator:
		{
			ReplyToCommand(i_target, "[SM] %t", PLUGIN_SHORT_NAME ... "__failed_to_target_other__ClientIsSpectator");
		}
		case TauntExecution_ClientIsUnassigned:
		{
			ReplyToCommand(i_target, "[SM] %t", PLUGIN_SHORT_NAME ... "__failed_to_target_other__ClientIsUnassigned");
		}
		case TauntExecution_InvalidClass:
		{
			ReplyToCommand(i_target, "[SM] %t", PLUGIN_SHORT_NAME ... "__failed_to_target_other__InvalidClass");
		}
		case TauntExecution_TargetIsDead:
		{
			ReplyToCommand(i_target, "[SM] %t", PLUGIN_SHORT_NAME ... "__failed_to_target_other__TargetIsDead");
		}
		case TauntExecution_WrongClass:
		{
			ReplyToCommand(i_target, "[SM] %t", PLUGIN_SHORT_NAME ... "__failed_to_target_other__WrongClass");
		}
		case TauntExecution_IvalidIDX:
		{
			ReplyToCommand(i_target, "[SM] %t", PLUGIN_SHORT_NAME ... "__failed_to_target_other__IvalidIDX");
		}
		case TauntExecution_TauntFailed:
		{
			ReplyToCommand(i_target, "[SM] %t", PLUGIN_SHORT_NAME ... "__failed_to_target_other__TauntFailed");
		}
	}
}

stock void Notify_ForceTaunt(	int i_client, 
								int i_idx, 
								bool b_tn_is_ml, 
								const char[] s_target_name,
								const int[] i_target_list, 
								const bool[] b_success, 
								int i_nof_targets, 
								CTauntCacheSystem h_cache)
{
	int i_taunt_index = h_cache.FindTauntByDefIndex(i_idx);
	int i_hits;
	char[] s_taunt_name = new char[h_cache.m_iMaxNameLength];
	h_cache.GetTauntName(i_taunt_index, s_taunt_name, h_cache.m_iMaxNameLength);
	for (int i_iter = 0; i_iter < i_nof_targets; i_iter++)
	{
		if (b_success[i_iter])
		{
			LogAction(	i_client, i_target_list[i_iter], 
						"%T", PLUGIN_SHORT_NAME ... "__taunt_force__LogAction", LANG_SERVER, i_client, 
																				i_target_list[i_iter], 
																				i_idx);
			i_hits++;
		}
	}
	
	if (i_nof_targets > 1)
	{
		ShowActivity2(i_client, "[SM] ", "%t", b_tn_is_ml 	? PLUGIN_SHORT_NAME ... "__taunt_force__ShowActivity_TauntSuccessfulMultipleML"
															: PLUGIN_SHORT_NAME ... "__taunt_force__ShowActivity_TauntSuccessfulMultiple", 
															s_target_name, i_hits, i_nof_targets, s_taunt_name);
	}
	else
	{
		if (b_success[0])
		{
			ShowActivity2(i_client, "[SM] ", "%t", b_tn_is_ml 	? PLUGIN_SHORT_NAME ... "__taunt_force__ShowActivity_TauntSuccessfulSingularML"
																: PLUGIN_SHORT_NAME ... "__taunt_force__ShowActivity_TauntSuccessfulSingular",
																s_target_name, s_taunt_name);
		}
		else
		{
			TauntExecution i_result = CheckClassToo(i_target_list[0], i_idx, h_cache);
			ReplyToTauntTargetOther(i_client, (i_result == TauntExecution_Success) ? TauntExecution_TauntFailed : i_result);
		}
	}
}

// }

// checkers and filters {

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

stock TauntExecution CheckClassToo(int i_target, int i_idx, CTauntCacheSystem h_taunts, TFClassType &i_class = TFClass_Unknown)
{
	TauntExecution i_check_only_result;
	if ((i_check_only_result = CheckOnly(i_target, i_class)) != TauntExecution_Success) { return i_check_only_result; }
	
	int i_index;
	if (h_taunts.IsValidTaunt(i_idx, i_class, i_index))
	{
		return TauntExecution_Success;
	}
	else
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
}

stock TauntExecution CheckAndTaunt(int i_target, int i_idx, CTauntEnforcer h_enforcer, CTauntCacheSystem h_taunts, TFClassType &i_class = TFClass_Unknown)
{
	TauntExecution i_check_only_result;
	if ((i_check_only_result = CheckClassToo(i_target, i_idx, h_taunts, i_class)) != TauntExecution_Success) { return i_check_only_result; }
	
	if (h_enforcer.ForceTaunt(i_target, i_idx))
	{
		return TauntExecution_Success;
	}
	else
	{
		return TauntExecution_TauntFailed;
	}
}

stock int FindValidTauntTargets(int i_client, int[] i_valid_targets, int i_valid_targets_size, int i_idx, CTauntCacheSystem h_cache, bool b_ignore_immunity = false)
{
	int i_hits = 0;
	for (int i_target = 1; (i_target <= MaxClients) && (i_hits < i_valid_targets_size); i_target++)
	{
		if ((CheckClassToo(i_target, i_idx, h_cache) == TauntExecution_Success) && (b_ignore_immunity || CanUserTarget(i_client, i_target)))
		{
			i_valid_targets[i_hits] = i_target;
			i_hits++;
		}
	}
	return i_hits;
}

// }

// command helpers {

stock int GetCmdArgInt(int i_argnum, int i_length = INT_DEC_LENGTH, int i_base = 10)
{
	char[] s_buffer = new char[i_length];
	GetCmdArg(i_argnum, s_buffer, i_length);
	return StringToInt(s_buffer, i_base);
}

// }

// menu stocks {

stock int GetSelectedTauntIDXFromMenu(Handle h_menu, int i_position)
{
	char s_hex_idx[INT_HEX_LENGTH];
	GetMenuItem(h_menu, i_position, s_hex_idx, sizeof(s_hex_idx));
	return StringToInt(s_hex_idx, 16);
}

stock bool AddDataToMenuAsInvisibleItem(Handle h_menu, any a_data)
{
	char s_data[INT_HEX_LENGTH];
	Format(s_data, sizeof(s_data), "%x", a_data);
	return AddMenuItem(h_menu, s_data, "", ITEMDRAW_IGNORE);
}

stock any GetDataFromInvisibleMenuItem(Handle h_menu, bool b_last_position = true, int i_position = -1, bool &b_success = false)
{
	char s_data[INT_HEX_LENGTH];
	if (b_last_position)
	{
		i_position = GetMenuItemCount(h_menu) - 1;
	}
	b_success = GetMenuItem(h_menu, i_position, s_data, sizeof(s_data));
	return view_as<any>(StringToInt(s_data, 16));
}

stock int AddTauntsToMenu(Handle h_menu, TFClassType i_class, CTauntCacheSystem h_taunts)
{
	int i_name_maxlen = h_taunts.m_iMaxNameLength;
	char[] s_name = new char[i_name_maxlen];
	char s_hex_idx[INT_HEX_LENGTH];
	
	// Add all-class taunts first
	for (int i_iter = 0; i_iter < GetArraySize(h_taunts.m_hAllClassTaunts); i_iter++)
	{
		int i_index = GetArrayCell(h_taunts.m_hAllClassTaunts, i_iter);
		h_taunts.GetTauntName(i_index, s_name, i_name_maxlen);
		Format(s_hex_idx, sizeof(s_hex_idx), "%x", h_taunts.GetTauntItemID(i_index));
		AddMenuItem(h_menu, s_hex_idx, s_name);
	}
	
	if (i_class == TFClass_Unknown)
	{
		char s_class[TF_MAX_CLASS_NAME_LENGTH];
	
		for (TFClassType i_current_class = view_as<TFClassType>(view_as<int>(TFClassType) - 1); view_as<int>(i_current_class) > 0; i_current_class--)
		{
			ArrayList h_taunts_for_class = h_taunts.GetListForClass(i_current_class);
			TF2_ClassEnumToString(i_current_class, s_class);
			for (int i_iter = 0; i_iter < GetArraySize(h_taunts_for_class); i_iter++)
			{
				int i_taunt_internal_index = GetArrayCell(h_taunts_for_class, i_iter);
				Format(s_hex_idx, sizeof(s_hex_idx), "%x", h_taunts.GetTauntItemID(i_taunt_internal_index));
				h_taunts.GetTauntName(i_taunt_internal_index, s_name, h_taunts.m_iMaxNameLength);
				AddFormattedMenuItem(h_menu, s_hex_idx, ITEMDRAW_DEFAULT, "%s (%s)", s_name, s_class);
			}
		}
	}
	else
	{
		ArrayList h_list_for_class = h_taunts.GetListForClass(i_class);
		for (int i_iter = 0; i_iter < GetArraySize(h_list_for_class); i_iter++)
		{
			int i_index = GetArrayCell(h_list_for_class, i_iter);
			h_taunts.GetTauntName(i_index, s_name, i_name_maxlen);
			Format(s_hex_idx, sizeof(s_hex_idx), "%x", h_taunts.GetTauntItemID(i_index));
			AddMenuItem(h_menu, s_hex_idx, s_name);
		}
	}
}

stock void AddForcedTauntTargetsToMenu(Handle h_menu, int i_client, int i_idx, CTauntCacheSystem h_cache, bool b_include_id = true)
{
	char s_id[INT_DEC_LENGTH];
	int[] i_valid_targets = new int[MaxClients];
	int i_hits = FindValidTauntTargets(i_client, i_valid_targets, MaxClients, i_idx, h_cache);
	
	for (int i_iter = 0; i_iter < i_hits; i_iter++)
	{
		int i_uid = GetClientUserId(i_valid_targets[i_iter]);
		IntToString(i_uid, s_id, sizeof(s_id));
		AddFormattedMenuItem(h_menu, s_id, ITEMDRAW_DEFAULT, b_include_id ? "%N (%d)" : "%N", i_valid_targets[i_iter], i_uid);
	}
}

stock bool AddFormattedMenuItem(Handle h_menu, const char[] s_info, int i_style, const char[] s_format , any ...)
{
	int i_written, i_length;
	i_length = 64;
	do
	{
		i_length *= 2;
		char[] s_buffer = new char[i_length];
		i_written = VFormat(s_buffer, i_length, s_format, 5);
		if ((i_length - 1) > i_written)
		{
			return AddMenuItem(h_menu, s_info, s_buffer, i_style);
		}
	} while (!((i_length - 1) > i_written));
	return false;
}

// }
