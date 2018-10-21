/*
**
*/
#if defined _tf2_extra_stocks_included
 #endinput
#endif
#define _tf2_extra_stocks_included

#define TF_MAX_CLASS_NAME_LENGTH	14

stock int TF2_ClassEnumToString(TFClassType i_class, char[] s_class, int maxlen)
{
	switch (i_class)
	{
			case TFClass_Scout: 	return strcopy(s_class, maxlen, "scout");
			case TFClass_Soldier: 	return strcopy(s_class, maxlen, "soldier");
			case TFClass_Pyro: 		return strcopy(s_class, maxlen, "pyro");
			case TFClass_DemoMan: 	return strcopy(s_class, maxlen, "demoman");
			case TFClass_Heavy: 	return strcopy(s_class, maxlen, "heavy");
			case TFClass_Medic: 	return strcopy(s_class, maxlen, "medic");
			case TFClass_Sniper: 	return strcopy(s_class, maxlen, "sniper");
			case TFClass_Spy: 		return strcopy(s_class, maxlen, "spy");
			case TFClass_Engineer: 	return strcopy(s_class, maxlen, "engineer");
	}
	return 0;
}