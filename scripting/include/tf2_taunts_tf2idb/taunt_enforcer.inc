/*
**
*/
#if defined _taunt_enforcer_included
 #endinput
#endif
#define _taunt_enforcer_included

#include "tf2items.inc"
#include "sdktools.inc"

Handle g_hForceTaunt;
Handle g_hForceTauntMultiple;

typedef TauntMultipleFilter = function bool(int i_target);
typedef ForceTaunt = function bool(int i_client, int i_defindex, int i_particle_id);
typedef ForceTauntMultiple = function int(const int[] i_targets, bool[] b_success, int i_nof_targets, int i_defindex, int i_particle_id);


/**
 * Registers your taunt enforcer plugin.
 *
 * @param func      ForceTaunt function.
 * @param funcm      ForceTauntMultiple function.
 * @return		True if successful, false if not.
 */
native int RegisterTauntEnforcer(ForceTaunt func, ForceTauntMultiple funcm);

stock void ActivateForwards()
{
	g_hForceTaunt = CreateForward(ET_Single, Param_Cell, Param_Cell, Param_Cell);
	g_hForceTauntMultiple = CreateForward(ET_Single, Param_Array, Param_Array, Param_Cell, Param_Cell, Param_Cell);
}

public int Native_RegisterTauntEnforcer(Handle plugin, int numParams)
{
	if(g_hForceTaunt == INVALID_HANDLE || g_hForceTauntMultiple == INVALID_HANDLE) return 0;

	if(GetForwardFunctionCount(g_hForceTaunt) == 0)
	{
		if(!AddToForward(g_hForceTaunt, plugin, GetNativeFunction(1)))
			return 0;
	}
	else ThrowNativeError(SP_ERROR_NATIVE, "Another plugin is already enforcing taunts, bud.");
	
	if(GetForwardFunctionCount(g_hForceTauntMultiple) == 0)
	{
		if(AddToForward(g_hForceTauntMultiple, plugin, GetNativeFunction(2)))
			return 1;
		else
			return 0;
	}
	else ThrowNativeError(SP_ERROR_NATIVE, "Another plugin is already enforcing taunts, bud.");
}

methodmap CTauntEnforcer < Handle {
	public CTauntEnforcer(Handle h_game_config, const char[] s_prop_name = "CTFPlayer::PlayTauntSceneFromItem")
	{
		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(h_game_config, SDKConf_Signature, s_prop_name);
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
		PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
		return view_as<CTauntEnforcer>(EndPrepSDKCall());
	}

	public bool CBasePlayer_PlayTauntSceneFromItem(int i_client, Address i_pointer)
	{
		return SDKCall(this, i_client, i_pointer);
	}

	property Handle m_hBaseTauntItem
	{
		public get()
		{
			static Handle h_item;
			if (h_item == INVALID_HANDLE)
			{
				h_item = TF2Items_CreateItem(OVERRIDE_ALL|PRESERVE_ATTRIBUTES|FORCE_GENERATION);
				TF2Items_SetClassname(h_item, "tf_wearable_vm");
				TF2Items_SetQuality(h_item, 6);
				TF2Items_SetLevel(h_item, 1);
			}
			return h_item;
		}
	}

	public static void MakeCEconViewItem(int i_defindex, int i_particle_id = 0)
	{
		//since the getter for ``m_hBaseTauntItem`` won't reference ``this``
		CTauntEnforcer i_null_instance = view_as<CTauntEnforcer>(null);
		Handle h_item = i_null_instance.m_hBaseTauntItem;

		TF2Items_SetItemIndex(h_item, i_defindex);
		TF2Items_SetNumAttributes(h_item, i_particle_id ? 1 : 0);
		if (i_particle_id) { TF2Items_SetAttribute(h_item, 0, 2041, float(i_particle_id)); }
	}

	public bool ForceTaunt(int i_client, int i_defindex, int i_particle_id = 0)
	{
		if(GetForwardFunctionCount(g_hForceTaunt) != 0)
		{
			bool b_success;
			
			Call_StartForward(g_hForceTaunt);
			Call_PushCell(i_client);
			Call_PushCell(i_defindex);
			Call_PushCell(i_particle_id);
			
			Call_Finish(b_success);
			
			return b_success;
		}
		else
		{
			CTauntEnforcer.MakeCEconViewItem(i_defindex, i_particle_id);
			int i_ent_index = TF2Items_GiveNamedItem(i_client, this.m_hBaseTauntItem);
			if (!IsValidEntity(i_ent_index))
			{
				return false;
				//:TODO: Add error checks
			}

			Address i_pointer = GetEntityAddress(i_ent_index) + view_as<Address>(FindSendPropInfo("CTFWearable", "m_Item"));
			bool b_success = this.CBasePlayer_PlayTauntSceneFromItem(i_client, i_pointer);

			AcceptEntityInput(i_ent_index, "Kill");
			return b_success;
		}
	}

	public int ForceTauntMultiple(const int[] i_targets, bool[] b_success, int i_nof_targets, int i_defindex, int i_particle_id = 0)
	{
		if(GetForwardFunctionCount(g_hForceTauntMultiple) != 0)
		{
			int i_hits;
			
			Call_StartForward(g_hForceTauntMultiple);
			Call_PushArray(i_targets, sizeof(i_targets[]));
			Call_PushArray(b_success, sizeof(b_success[]));
			Call_PushCell(i_nof_targets);
			Call_PushCell(i_defindex);
			Call_PushCell(i_particle_id);
			
			Call_Finish(i_hits);
			
			return i_hits;
		}
		else
		{
			CTauntEnforcer.MakeCEconViewItem(i_defindex, i_particle_id);
			// a dummy client will actually hold the taunt, but others can pkay it
			int i_ent_index = TF2Items_GiveNamedItem(i_targets[0], this.m_hBaseTauntItem);
			if (!IsValidEntity(i_ent_index))
			{
				return 0;
			//:TODO: Add error checks
			}

			Address i_pointer = GetEntityAddress(i_ent_index) + view_as<Address>(FindSendPropInfo("CTFWearable", "m_Item"));

			int i_hits = 0;

			for (int i_iter = 0; i_iter < i_nof_targets; i_iter++)
			{
				b_success[i_iter] = this.CBasePlayer_PlayTauntSceneFromItem(i_targets[i_iter], i_pointer);
				if (b_success[i_iter]) { i_hits++; }
			}

			AcceptEntityInput(i_ent_index, "Kill");
			return i_hits;
		}
	}

	public int ForceTauntMultipleFiltered(const int[] i_targets, bool[] b_success, int i_nof_targets, int i_defindex, TauntMultipleFilter f_filter, int i_particle_id = 0)
	{
		CTauntEnforcer.MakeCEconViewItem(i_defindex, i_particle_id);
		// a dummy client will actually hold the taunt, but others can pkay it
		int i_ent_index = TF2Items_GiveNamedItem(i_targets[0], this.m_hBaseTauntItem);
		if (!IsValidEntity(i_ent_index))
		{
			return 0;
			//:TODO: Add error checks
		}

		Address i_pointer = GetEntityAddress(i_ent_index) + view_as<Address>(FindSendPropInfo("CTFWearable", "m_Item"));

		int i_hits = 0;
		bool b_continue;

		for (int i_iter = 0; i_iter < i_nof_targets; i_iter++)
		{
			Call_StartFunction(INVALID_HANDLE, f_filter);
			Call_PushCell(i_targets[i_iter]);
			Call_Finish(b_continue);
			if (b_continue)
			{
				b_success[i_iter] = this.CBasePlayer_PlayTauntSceneFromItem(i_targets[i_iter], i_pointer);
			}
			if (b_success[i_iter]) { i_hits++; }
		}

		AcceptEntityInput(i_ent_index, "Kill");
		return i_hits;
	}
}


/* DO NOT EDIT BELOW THIS LINE */

public SharedPlugin __pl_taunt_enforcer =
{
	name = "tf2_taunts_tf2idb",
	file = "tf2_taunts_tf2idb.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
}

#if !defined REQUIRE_PLUGIN
public void __pl_taunt_enforcer_SetNTVOptional()
{
	MarkNativeAsOptional("RegisterTauntEnforcer");
}
#endif
