#if defined _USE_TF2II_INSTEAD_OF_TF2IDB
 #define _USING_ITEMS_HELPER	"tf2ii"
 #include "tf2itemsinfo.inc"
#else
 #define _USING_ITEMS_HELPER	"tf2idb"
 #include "tf2idb.inc"
#endif
#include "tf2items.inc"

#include <sourcemod>
#include <tf2_stocks>

#pragma semicolon 1
#pragma newdecls required

#include "tf2_taunts_tf2idb/taunt_cache_system.inc"
#include "tf2_taunts_tf2idb/taunt_enforcer.inc"
#include "tf2_taunts_tf2idb/tf2_extra_stocks.inc"
#include "tf2_taunts_tf2idb/autoversioning.inc"

//#define _USING_AUTOVERSIONING

#if defined _autoversioning_included
 #define PLUGIN_VERSION	AUTOVERSIONING_TAG ... "." ... AUTOVERSIONING_COMMIT ... "_" ... _USING_ITEMS_HELPER
#else
 #define PLUGIN_VERSION "1.0" ... "." ... "*" ... "_" ... _USING_ITEMS_HELPER
#endif

public Plugin myinfo = 
{
	name = "TF2 Taunts TF2IDB",
	author = "fakuivan",
	description = "An extensible taunt menu that updates along with tf2idb",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/member.php?u=264797"
};

CTauntCacheSystem gh_cache;
CTauntEnforcer gh_enforcer;

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

public void OnPluginStart()
{
#if defined _tf2idb_included //{
	CTauntCacheSystem_FromTF2IDB_Error i_error;
	gh_cache = CTauntCacheSystem.FromTF2IDB();
	if (i_error != CTauntCacheSystem_FromTF2IDB_Error_None)
	{
		SetFailState("Failed to initialize taunt cache, error code %d", i_error);
	}
#endif //}

#if defined _tf2itemsinfo_included //{
	if (TF2II_IsItemSchemaPrecached())
	{
		gh_cache = CTauntCacheSystem.FromTF2II();
	}
#endif //}
	
	Handle h_conf = LoadGameConfigFile("tf2.tauntem");
	if (h_conf == INVALID_HANDLE)
	{
		SetFailState("Unable to load gamedata/tf2.tauntem.txt.");
	}
	gh_enforcer = new CTauntEnforcer(h_conf);
	
	CreateConVar("sm_tf2_taunts_tf2idb_version", PLUGIN_VERSION, "Version of TF2 Taunts TF2IDB", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	
	LoadTranslations("common.phrases");
	LoadTranslations("tf2.taunts.tf2idb");
	
	RegConsoleCmd("sm_taunts_list", Command_ListTaunts, "Lists the available taunts for a client on a specific class");
	RegConsoleCmd("sm_taunt_list", Command_ListTaunts, "Lists the available taunts for a client on a specific class");
	RegConsoleCmd("sm_taunts", Command_ForceToTaunt, "Shows the taunts menu");
	RegConsoleCmd("sm_taunt", Command_ForceToTaunt, "Shows the taunts menu");
}

public Action Command_ListTaunts(int i_client, int i_args)
{
#if defined _tf2itemsinfo_included //{
	if (CheckAndReplyCacheNotLoaded(i_client))return Plugin_Handled;
#endif //}
	ReplyToCommand(i_client, "[SM] %t:", "tf2_taunts_tf2idb__taunts_list__ListOfTaunts");
	char[] s_taunt_name = new char[gh_cache.m_iMaxNameLength];
	char s_class[TF_MAX_CLASS_NAME_LENGTH];
	
	for (TFClassType i_class = view_as<TFClassType>(view_as<int>(TFClassType) - 1); view_as<int>(i_class) > 0; i_class--)
	{
		ArrayList h_taunts_for_class = gh_cache.GetListForClass(i_class);
		TF2_ClassEnumToString(i_class, s_class);
		ReplyToCommand(i_client, "- %t: ", "tf2_taunts_tf2idb__taunts_list__TauntsForClassX", s_class);
		for (int i_iter = 0; i_iter < GetArraySize(h_taunts_for_class); i_iter++)
		{
			int i_idx = gh_cache.GetTauntItemID(GetArrayCell(h_taunts_for_class, i_iter));
			gh_cache.GetTauntName(GetArrayCell(h_taunts_for_class, i_iter), s_taunt_name, gh_cache.m_iMaxNameLength);
			ReplyToCommand(i_client, "-  %d: %s (%s)", i_idx, s_taunt_name, s_class);
		}
	}
	
	ReplyToCommand(i_client, "- %t:", "tf2_taunts_tf2idb__taunts_list__TauntsForAllClasses");
	for (int i_iter = 0; i_iter < GetArraySize(gh_cache.m_hAllClassTaunts); i_iter++)
	{
		int i_idx = gh_cache.GetTauntItemID(GetArrayCell(gh_cache.m_hAllClassTaunts, i_iter));
		gh_cache.GetTauntName(GetArrayCell(gh_cache.m_hAllClassTaunts, i_iter), s_taunt_name, gh_cache.m_iMaxNameLength);
		ReplyToCommand(i_client, "-  %d: %s (%t)", i_idx, s_taunt_name, "tf2_taunts_tf2idb__taunts_list__AllClass");
	}
	return Plugin_Handled;
}

public Action Command_ForceToTaunt(int i_client, int i_args)
{
#if defined _tf2itemsinfo_included //{
	if (CheckAndReplyCacheNotLoaded(i_client))return Plugin_Handled;
#endif //}
	if (i_args == 0)
	{
		TauntExecution i_result = CheckOnly(i_client);
		if (i_result != TauntExecution_Success)
		{
			ReplyToTauntTarget(i_client, i_result);
			return Plugin_Handled;
		}
		MenuMaker_TauntsMenu(i_client);
	}
	else if (i_args == 1)
	{
		int i_taunt_idx = GetCmdArgInt(1);
		TauntExecution i_result;
		if ((i_result = CheckAndTaunt(i_client, i_taunt_idx)) != TauntExecution_Success)
		{
			ReplyToTauntTarget(i_client, i_result);
			return Plugin_Handled;
		}
	}
	else
	{
		ReplyToCommand(i_client, "%t: sm_taunt [taunt_idx]", "tf2_taunts_tf2idb__commands__Usage");
	}
	return Plugin_Handled;
}


//menu thingies
bool MenuMaker_TauntsMenu(int i_client)
{
	TFClassType i_class =  TF2_GetPlayerClass(i_client);
	
	Menu h_menu = CreateMenu(MenuHandler_TauntsMenu);
	
	ArrayList h_list_for_class = gh_cache.GetListForClass(i_class);
	int i_name_maxlen = gh_cache.m_iMaxNameLength;
	char[] s_name = new char[i_name_maxlen];
	char s_hex_idx[10];
	
	SetMenuTitle(h_menu, "%T", "tf2_taunts_tf2idb__menu__title", i_client);
	
	for (int i_iter = 0; i_iter < GetArraySize(h_list_for_class); i_iter++)
	{
		int i_index = GetArrayCell(h_list_for_class, i_iter);
		gh_cache.GetTauntName(i_index, s_name, i_name_maxlen);
		Format(s_hex_idx, sizeof(s_hex_idx), "%x", gh_cache.GetTauntItemID(i_index));
		AddMenuItem(h_menu, s_hex_idx, s_name);
	}
	
	for (int i_iter = 0; i_iter < GetArraySize(gh_cache.m_hAllClassTaunts); i_iter++)
	{
		int i_index = GetArrayCell(gh_cache.m_hAllClassTaunts, i_iter);
		gh_cache.GetTauntName(i_index, s_name, i_name_maxlen);
		Format(s_hex_idx, sizeof(s_hex_idx), "%x", gh_cache.GetTauntItemID(i_index));
		AddMenuItem(h_menu, s_hex_idx, s_name);
	}
	
	return DisplayMenu(h_menu, i_client, MENU_TIME_FOREVER);
}

public int MenuHandler_TauntsMenu(Menu h_menu, MenuAction i_action, int i_param1, int i_param2)
{
	if(i_action == MenuAction_End)
	{
		CloseHandle(h_menu);
	}
	
	if(i_action == MenuAction_Select)
	{
		char s_hex_idx[10];
		
		GetMenuItem(h_menu, i_param2, s_hex_idx, sizeof(s_hex_idx));
		int i_taunt_idx = StringToInt(s_hex_idx, 16);
		TauntExecution i_result = CheckAndTaunt(i_param1, i_taunt_idx);
		ReplyToTauntTarget(i_param1, i_result);
	}
}

void ReplyToTauntTarget(int i_target, TauntExecution i_result)
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

TauntExecution CheckOnly(int i_target, TFClassType &i_class = TFClass_Unknown)
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

TauntExecution CheckAndTaunt(int i_target, int i_idx)
{
	TauntExecution i_check_only_result;
	TFClassType i_class;
	if ((i_check_only_result = CheckOnly(i_target, i_class)) != TauntExecution_Success) { return i_check_only_result; }
	
	i_class = TF2_GetPlayerClass(i_target);
	int i_index;
	if (!gh_cache.IsValidTaunt(i_idx, i_class, i_index))
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
	if (!gh_enforcer.ForceTaunt(i_target, i_idx))
	{
		return TauntExecution_TauntFailed;
	}
	else
	{	
		return TauntExecution_Success;
	}
}

//stocks
stock int GetCmdArgInt(int i_argnum, int i_length = 12, int i_base = 10)
{
	char[] s_buffer = new char[i_length];
	GetCmdArg(i_argnum, s_buffer, i_length);
	return StringToInt(s_buffer, i_base);
}

#if defined _tf2itemsinfo_included //{
bool CheckAndReplyCacheNotLoaded(int i_client)
{
	if (gh_cache == INVALID_HANDLE)
	{
		ReplyToCommand(i_client, "[SM] %t", "tf2_taunts_tf2idb__schema__Reply_NotCached");
		return true;
	}
	return false;
}

public int TF2II_OnItemSchemaUpdated()	//should this return ``void``?
{
	if (gh_cache == INVALID_HANDLE)
	{
		gh_cache = CTauntCacheSystem.FromTF2II();
	}
	else
	{
		gh_cache.CloseChild();
		gh_cache.Close();
		gh_cache = CTauntCacheSystem.FromTF2II();
	}
}
#endif //}
