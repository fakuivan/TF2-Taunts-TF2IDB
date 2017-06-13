/*
**
*/
#if defined _target_symbols_included
 #endinput
#endif
#define _target_symbols_included

#define MAX_TARGET_SYMBOL_LENGTH	sizeof(gs_target_symbols[])
#define INVALID_TARGET_SYMBOL		view_as<TargetSymbol>(-1)

// we'll enable more symbols as we start using them, along with their translations
enum TargetSymbol {
	TargetSymbol_All = 0,
//	TargetSymbol_BLU,
//	TargetSymbol_RED,
//	TargetSymbol_NotMe,
//	TargetSymbol_Humans,
//	TargetSymbol_Bots,
}

char gs_target_symbols[TargetSymbol][] = {
	"@all",
//	"@blu",
//	"@red",
//	"@notme",
//	"@humans",
//	"@bots",
};

char gs_target_symbols_ml[TargetSymbol][] = {
	PLUGIN_SHORT_NAME ... "__TargetSymbols__@all",
//	PLUGIN_SHORT_NAME ... "__TargetSymbols__@blu",
//	PLUGIN_SHORT_NAME ... "__TargetSymbols__@red",
//	PLUGIN_SHORT_NAME ... "__TargetSymbols__@notme",
//	PLUGIN_SHORT_NAME ... "__TargetSymbols__@humans",
//	PLUGIN_SHORT_NAME ... "__TargetSymbols__@bots",
};

stock TargetSymbol ParseTargetSymbol(const char[] s_source)
{
	for (int i_index; i_index < view_as<int>(TargetSymbol); i_index++)
	{
		if (StrEqual(s_source, gs_target_symbols[i_index]))
		{
			return view_as<TargetSymbol>(i_index);
		}
	}
	return INVALID_TARGET_SYMBOL;
}
