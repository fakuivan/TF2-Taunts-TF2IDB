#if defined _USE_TF2II_INSTEAD_OF_TF2IDB
 #define _USING_ITEMS_HELPER	"tf2ii"
 #include "tf2itemsinfo.inc"
#else
 #define _USING_ITEMS_HELPER	"tf2idb"
 #include "tf2idb.inc"
#endif
#include "tf2items.inc"
#undef REQUIRE_PLUGIN
#include <updater>
#define REQUIRE_PLUGIN

#include <sourcemod>
#include <tf2_stocks>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_SHORT_NAME "tf2_taunts_tf2idb"

#include "tf2_taunts_tf2idb/taunt_cache_system.inc"
#include "tf2_taunts_tf2idb/taunt_enforcer.inc"
#include "tf2_taunts_tf2idb/tf2_extra_stocks.inc"
#include "tf2_taunts_tf2idb/autoversioning.inc"
#include "tf2_taunts_tf2idb/updater_helpers.inc"
#include "tf2_taunts_tf2idb/target_symbols.inc"

#include "tf2_taunts_tf2idb/tf2_taunts_tf2idb.inc"

#if defined _autoversioning_included
 #define PLUGIN_VERSION	AUTOVERSIONING_TAG ... "." ... AUTOVERSIONING_COMMIT ... "-" ... _USING_ITEMS_HELPER
#else
 #define PLUGIN_VERSION "1.6" ... "." ... "*" ... "-" ... _USING_ITEMS_HELPER
#endif

public Plugin myinfo = 
{
	name = "TF2 Taunts TF2IDB",
	author = "fakuivan",
	description = "An extensible taunt menu that updates along with tf2idb",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/member.php?u=264797"
};

#define UPDATE_URL	UPDATER_HELPER_URL

CTauntCacheSystem gh_cache;
CTauntEnforcer gh_enforcer;

InitializationStatus gi_initialization = InitializationStatus_Success;

public void OnAllPluginsLoaded()
{
#if defined _tf2idb_included //{
	CTauntCacheSystem_FromTF2IDB_Error i_error;
	gh_cache = CTauntCacheSystem.FromTF2IDB();
	if (i_error != CTauntCacheSystem_FromTF2IDB_Error_None)
	{
		gi_initialization = view_as<InitializationStatus>(i_error) + InitializationStatus_FromTF2IDB_Error;
	}
	if (gi_initialization >= InitializationStatus_FromTF2IDB_Error)
	{
		LogError("Failed to initialize taunt cache, error code %d", gi_initialization - InitializationStatus_FromTF2IDB_Error);
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
		gi_initialization = InitializationStatus_InvalidGamedataFile;
	}
	else
	{
		if ((gh_enforcer = new CTauntEnforcer(h_conf)) == INVALID_HANDLE)
		{
			gi_initialization = InitializationStatus_InvalidGamedataOutdated;
		}
	}
	
	if (gi_initialization == InitializationStatus_InvalidGamedataFile)
	{
		LogError("Unable to load gamedata/tf2.tauntem.txt.");
	}
	else if (gi_initialization == InitializationStatus_InvalidGamedataOutdated)
	{
		LogError("Unable to initialize CTauntEnforcer, gamedata files outdated.");
	}
	
	if (LibraryExists("updater"))
	{
		if (gi_initialization != InitializationStatus_Success)
		{
			LogError("Halting user interface initialization. Plugin loaded, waiting for updates.");
		}
		Updater_AddPlugin(UPDATE_URL);
	}
	else if (gi_initialization != InitializationStatus_Success)
	{
		LogError("Halting user interface initialization. Plugin loaded but updater not found.");
		LogError("Try using the latest version from here https://github.com/fakuivan/TF2-Taunts-TF2IDB .");
	}
	
	CreateConVar("sm_" ... PLUGIN_SHORT_NAME ... "_version", PLUGIN_VERSION, "Version of TF2 Taunts TF2IDB", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	
	if (gi_initialization == InitializationStatus_Success)
	{
		LoadTranslations("common.phrases");
		LoadTranslations("tf2.taunts.tf2idb");
		
		RegConsoleCmd("sm_taunts_list", Command_ListTaunts, "Shows a list of taunts ordered by class");
		RegConsoleCmd("sm_taunt_list", Command_ListTaunts, "Shows a list of taunts ordered by class");
		RegConsoleCmd("sm_taunts", Command_ForceSelfToTaunt, "Shows the taunts menu");
		RegConsoleCmd("sm_taunt", Command_ForceSelfToTaunt, "Shows the taunts menu");
		RegAdminCmd("sm_taunts_force", Command_ForceOtherToTaunt, ADMFLAG_KICK, "Forces a player to taunt");
		RegAdminCmd("sm_taunt_force", Command_ForceOtherToTaunt, ADMFLAG_KICK, "Forces a player to taunt");
	}
}

public void OnLibraryAdded(const char[] s_name)
{
	if (StrEqual(s_name, "updater"))
	{
		Updater_AddPlugin(UPDATE_URL);
	}
}

public Action Command_ListTaunts(int i_client, int i_args)
{
#if defined _tf2itemsinfo_included //{
	if (CheckAndReplyCacheNotLoaded(i_client))return Plugin_Handled;
#endif //}
	
	ReplyToCommand(i_client, "[SM] %t:", PLUGIN_SHORT_NAME ... "__taunts_list__ListOfTaunts");
	char[] s_taunt_name = new char[gh_cache.m_iMaxNameLength];
	char s_class[TF_MAX_CLASS_NAME_LENGTH];
	
	for (TFClassType i_class = view_as<TFClassType>(view_as<int>(TFClassType) - 1); view_as<int>(i_class) > 0; i_class--)
	{
		ArrayList h_taunts_for_class = gh_cache.GetListForClass(i_class);
		TF2_ClassEnumToString(i_class, s_class);
		ReplyToCommand(i_client, "- %t: ", PLUGIN_SHORT_NAME ... "__taunts_list__TauntsForClassX", s_class);
		for (int i_iter = 0; i_iter < GetArraySize(h_taunts_for_class); i_iter++)
		{
			int i_idx = gh_cache.GetTauntItemID(GetArrayCell(h_taunts_for_class, i_iter));
			gh_cache.GetTauntName(GetArrayCell(h_taunts_for_class, i_iter), s_taunt_name, gh_cache.m_iMaxNameLength);
			ReplyToCommand(i_client, "-  %d: %s (%s)", i_idx, s_taunt_name, s_class);
		}
	}
	
	ReplyToCommand(i_client, "- %t:", PLUGIN_SHORT_NAME ... "__taunts_list__TauntsForAllClasses");
	for (int i_iter = 0; i_iter < GetArraySize(gh_cache.m_hAllClassTaunts); i_iter++)
	{
		int i_idx = gh_cache.GetTauntItemID(GetArrayCell(gh_cache.m_hAllClassTaunts, i_iter));
		gh_cache.GetTauntName(GetArrayCell(gh_cache.m_hAllClassTaunts, i_iter), s_taunt_name, gh_cache.m_iMaxNameLength);
		ReplyToCommand(i_client, "-  %d: %s (%t)", i_idx, s_taunt_name, PLUGIN_SHORT_NAME ... "__taunts_list__AllClass");
	}
	return Plugin_Handled;
}

public Action Command_ForceSelfToTaunt(int i_client, int i_args)
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
		MenuMaker_TauntsMenu(i_client, MenuHandler_TauntsSelfMenu);
	}
	else if (i_args == 1)
	{
		int i_taunt_idx = GetCmdArgInt(1);
		TauntExecution i_result;
		if ((i_result = CheckAndTaunt(i_client, i_taunt_idx, gh_enforcer, gh_cache)) != TauntExecution_Success)
		{
			ReplyToTauntTarget(i_client, i_result);
			return Plugin_Handled;
		}
	}
	else
	{
		ReplyToCommand(i_client, "%t: sm_taunt [taunt_idx]", PLUGIN_SHORT_NAME ... "__commands__Usage");
	}
	return Plugin_Handled;
}

public Action Command_ForceOtherToTaunt(int i_client, int i_args)
{
#if defined _tf2itemsinfo_included //{
	if (CheckAndReplyCacheNotLoaded(i_client))return Plugin_Handled;
#endif //}
	if (i_args == 2)
	{
		int i_taunt_idx = GetCmdArgInt(2);
		int i_taunt_index;
		if (!gh_cache.IsValidTaunt(i_taunt_idx, TFClass_Unknown, i_taunt_index))
		{
			ReplyToTauntTarget(i_client, TauntExecution_IvalidIDX);
			return Plugin_Handled;
		}
		
		char s_target[MAX_NAME_LENGTH];
		GetCmdArg(1, s_target, sizeof(s_target));
		
		char s_target_name[MAX_TARGET_LENGTH];
		int i_target_list[MAXPLAYERS], i_target_count;
		bool b_target_hits[MAXPLAYERS];
		bool b_tn_is_ml;
	 
		if ((i_target_count = ProcessTargetString(
				s_target,
				i_client,
				i_target_list,
				MAXPLAYERS,
				COMMAND_FILTER_ALIVE,
				s_target_name,
				sizeof(s_target_name),
				b_tn_is_ml)) <= 0)
		{
			ReplyToTargetError(i_client, i_target_count);
			return Plugin_Handled;
		}
		
		gh_enforcer.ForceTauntMultiple(i_target_list, b_target_hits, i_target_count, i_taunt_idx);
		Notify_ForceTaunt(i_client, i_taunt_idx, b_tn_is_ml, s_target_name, i_target_list, b_target_hits, i_target_count, gh_cache);
	}
	else if (i_args == 0 && i_client != 0)
	{
		MenuMaker_TauntOther_SelectTaunt(i_client);
	}
	else
	{
		ReplyToCommand(i_client, i_client == 0 	? "%t: sm_taunt_force <target> <taunt_idx>"
												: "%t: sm_taunt_force [<target> <taunt_idx>]", 
		PLUGIN_SHORT_NAME ... "__commands__Usage");
	}
	return Plugin_Handled;
}

//menu thingies
bool MenuMaker_TauntsMenu(int i_client, MenuHandler f_handler, any a_data = 0)
{
	TFClassType i_class =  TF2_GetPlayerClass(i_client);
	
	Menu h_menu = CreateMenu(f_handler);
	
	SetMenuTitle(h_menu, "%T", PLUGIN_SHORT_NAME ... "__menu__title", i_client);
	
	AddTauntsToMenu(h_menu, i_class, gh_cache);
	AddDataToMenuAsInvisibleItem(h_menu, a_data);
	
	return DisplayMenu(h_menu, i_client, MENU_TIME_FOREVER);
}

public int MenuHandler_TauntsSelfMenu(Menu h_menu, MenuAction i_action, int i_param1, int i_param2)
{
	if(i_action == MenuAction_End)
	{
		CloseHandle(h_menu);
	}
	
	if(i_action == MenuAction_Select)
	{
		int i_taunt_idx = GetSelectedTauntIDXFromMenu(h_menu, i_param2);
		TauntExecution i_result = CheckAndTaunt(i_param1, i_taunt_idx, gh_enforcer, gh_cache);
		ReplyToTauntTarget(i_param1, i_result);
	}
}

bool MenuMaker_TauntOther_SelectTaunt(int i_client)
{
	Menu h_menu = CreateMenu(MenuHandler_TauntOther_SelectTaunt);
	SetMenuTitle(h_menu, "%T:", PLUGIN_SHORT_NAME ... "__taunt_force_menu__TauntsTitle", i_client);
	SetMenuExitBackButton(h_menu, false);
	
	AddTauntsToMenu(h_menu, TFClass_Unknown, gh_cache);
	
	return h_menu.Display(i_client, MENU_TIME_FOREVER);
}

public int MenuHandler_TauntOther_SelectTaunt(Menu h_menu, MenuAction i_action, int i_param1, int i_param2)
{
	switch(i_action)
	{
		case MenuAction_Select:
		{
			MenuMaker_TauntOther_SelectTarget(	i_param1,  
												GetSelectedTauntIDXFromMenu(h_menu, i_param2));
		}
		case MenuAction_End:
		{
			CloseHandle(h_menu);
		}
	}
}

bool MenuMaker_TauntOther_SelectTarget(int i_client, int i_idx)
{
	ArrayList h_data = CreateArray();
	h_data.Push(i_idx);
	
	Menu h_menu = CreateMenu(MenuHandler_TauntOther_SelectTarget);
	SetMenuTitle(h_menu, "%T:", PLUGIN_SHORT_NAME ... "__taunt_force_menu__TargetsTitle", i_client);
	SetMenuExitBackButton(h_menu, true);
	
	AddFormattedMenuItem(	h_menu,
							gs_target_symbols[TargetSymbol_All], 
							ITEMDRAW_DEFAULT, 
							"%T", gs_target_symbols_ml[TargetSymbol_All], i_client);
	AddForcedTauntTargetsToMenu(h_menu, i_client, i_idx, gh_cache);
	
	AddDataToMenuAsInvisibleItem(h_menu, h_data);
	
	return h_menu.Display(i_client, MENU_TIME_FOREVER);
}

public int MenuHandler_TauntOther_SelectTarget(Menu h_menu, MenuAction i_action, int i_param1, int i_param2)
{
	switch(i_action)
	{
		case MenuAction_Select:
		{
			ArrayList h_data = GetDataFromInvisibleMenuItem(h_menu);
			int i_idx = h_data.Get(0);
			
			char s_target_name[MAX_TARGET_LENGTH];
			
			int i_target_count = 0;
			bool b_tn_is_ml;
			int[] i_targets = new int[MaxClients]; 
			bool[] b_hits = new bool[MaxClients];
			
			char s_info[MAX_TARGET_SYMBOL_LENGTH + INT_DEC_LENGTH];
			
			GetMenuItem(h_menu, i_param2, s_info, sizeof(s_info));
			
			TargetSymbol i_target_symbol = ParseTargetSymbol(s_info);
			if (i_target_symbol == TargetSymbol_All)
			{
				b_tn_is_ml = true;
				strcopy(s_target_name, sizeof(s_target_name), gs_target_symbols_ml[i_target_symbol]);
				
				i_target_count = FindValidTauntTargets(i_param1, i_targets, MaxClients, i_idx, gh_cache);
				gh_enforcer.ForceTauntMultiple(i_targets, b_hits, i_target_count, i_idx);
			}
			else if (i_target_symbol == INVALID_TARGET_SYMBOL)
			{
				b_tn_is_ml = false;
				i_target_count = 1;
				i_targets[0] = GetClientOfUserId(StringToInt(s_info));
				GetClientName(i_targets[0], s_target_name, sizeof(s_target_name));
				b_hits[0] = gh_enforcer.ForceTaunt(i_targets[0], i_idx);
			} else { return 0; } //unsupported target symbol
			
			Notify_ForceTaunt(i_param1, i_idx, b_tn_is_ml, s_target_name, i_targets, b_hits, i_target_count, gh_cache);
			MenuMaker_TauntOther_SelectTarget(i_param1, i_idx);
		}
		case MenuAction_Cancel:
		{
			if (i_param2 == MenuCancel_ExitBack)
			{
				MenuMaker_TauntOther_SelectTaunt(i_param1);
			}
		}
		case MenuAction_End:
		{
			CloseHandle(GetDataFromInvisibleMenuItem(h_menu));
			CloseHandle(h_menu);
		}
	}
	return 0;
}

#if defined _tf2itemsinfo_included //{
bool CheckAndReplyCacheNotLoaded(int i_client)
{
	if (gh_cache == INVALID_HANDLE)
	{
		ReplyToCommand(i_client, "[SM] %t", PLUGIN_SHORT_NAME ... "__schema__Reply_NotCached");
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
