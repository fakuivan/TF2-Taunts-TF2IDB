#include <sourcemod>
#include <sourcemod>
#include <morecolors>
#include <sdktools>
#include "tf2_taunts_tf2idb/taunt_enforcer.inc"

Handle hGameConf2;
Handle hForceTaunt;

public void OnAllPluginsLoaded() // You have to use this instead of OnPluginStart(), otherwise it may not register the taunt enforcer
{
	hGameConf2 = LoadGameConfigFile("tf2.tauntem");

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConf2, SDKConf_Signature, "CTFPlayer::PlayTauntSceneFromItem");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	hForceTaunt = EndPrepSDKCall();
	
	CloseHandle(hGameConf2);

	if(RegisterTauntEnforcer(ForceTaunt, ForceTauntMultiple)) // Adds your plugin to the private forwards list, so your functions (ForceTaunt, ForceTauntMultiple) get called once a client chooses a taunt from the !taunt menu
	{
		PrintToServer("Successfully registered taunt enforcer");
	}
	else
	{
		PrintToServer("Unsuccessful registering the taunt enforcer");
	}
}

public bool ForceTaunt(int client, int tauntIndex, int particle)
{
	int ent = CreateEntityByName("tf_wearable_vm");
	SetEntProp(ent, Prop_Send, "m_iItemDefinitionIndex", tauntIndex);
	
	Address pointer = GetEntityAddress(ent) + view_as<Address>(FindSendPropInfo("CTFWearable", "m_Item"));
	bool b_success = SDKCall(hForceTaunt, client, pointer);

	AcceptEntityInput(ent, "Kill");
	
	return b_success;
}

public int ForceTauntMultiple(const int[] targets, bool[] success, int i_nof_targets, int tauntIndex, int particle)
{
	int hits;
	
	int ent = CreateEntityByName("tf_wearable_vm");
	SetEntProp(ent, Prop_Send, "m_iItemDefinitionIndex", tauntIndex);
	Address pointer = GetEntityAddress(ent) + view_as<Address>(FindSendPropInfo("CTFWearable", "m_Item"));
	
	for(int i = 0; i < i_nof_targets; ++i)
	{
		success[i] = SDKCall(hForceTaunt, targets[i], pointer);
		if(success[i])
		{
			++hits;
		}
	}
	
	AcceptEntityInput(ent, "Kill");
	return hits;
	
}
#include <sourcemod>
#include <sourcemod>
#include <morecolors>
#include <sdktools>
#include "tf2_taunts_tf2idb/taunt_enforcer.inc"

Handle hGameConf2;
Handle hForceTaunt;

public void OnAllPluginsLoaded() // You have to use this instead of OnPluginStart(), otherwise it may not register the taunt enforcer
{
	hGameConf2 = LoadGameConfigFile("tf2.tauntem");

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConf2, SDKConf_Signature, "CTFPlayer::PlayTauntSceneFromItem");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	hForceTaunt = EndPrepSDKCall();
	
	CloseHandle(hGameConf2);

	if(RegisterTauntEnforcer(ForceTaunt, ForceTauntMultiple)) // Adds your plugin to the private forwards list, so your functions (ForceTaunt, ForceTauntMultiple) get called once a client chooses a taunt from the !taunt menu
	{
		PrintToServer("Successfully registered taunt enforcer");
	}
	else
	{
		PrintToServer("Unsuccessful registering the taunt enforcer");
	}
}

public bool ForceTaunt(int client, int tauntIndex, int particle)
{
	int ent = CreateEntityByName("tf_wearable_vm");
	SetEntProp(ent, Prop_Send, "m_iItemDefinitionIndex", tauntIndex);
	
	Address pointer = GetEntityAddress(ent) + view_as<Address>(FindSendPropInfo("CTFWearable", "m_Item"));
	bool b_success = SDKCall(hForceTaunt, client, pointer);

	AcceptEntityInput(ent, "Kill");
	
	return b_success;
}

public int ForceTauntMultiple(const int[] targets, bool[] success, int i_nof_targets, int tauntIndex, int particle)
{
	int hits;
	
	int ent = CreateEntityByName("tf_wearable_vm");
	SetEntProp(ent, Prop_Send, "m_iItemDefinitionIndex", tauntIndex);
	Address pointer = GetEntityAddress(ent) + view_as<Address>(FindSendPropInfo("CTFWearable", "m_Item"));
	
	for(int i = 0; i < i_nof_targets; ++i)
	{
		success[i] = SDKCall(hForceTaunt, targets[i], pointer);
		if(success[i])
		{
			++hits;
		}
	}
	
	AcceptEntityInput(ent, "Kill");
	return hits;
	
}
