// Theme: Definitions.UFunction. Positive global UFUNCTION with a sanitizable module path.
// C++: AngelscriptCompilerGlobalUFunctionTests.cpp::GlobalUFunctionSanitizesModuleNameForStaticsClass
// Oracle: GetSanitizedGlobalValue() == 77.
// Extra: 0 is a distinct unused boundary; repeating the call is stable.
// DefaultSafe.

UFUNCTION(BlueprintCallable)
int GetSanitizedGlobalValue()
{
	return 77;
}

bool Observe_SanitizedGlobalValue_Nominal()
{
	return GetSanitizedGlobalValue() == 77;
}

bool Observe_SanitizedGlobalValue_EmptyBoundary()
{
	return GetSanitizedGlobalValue() != 0;
}

bool Observe_SanitizedGlobalValue_RepeatCall()
{
	int First = GetSanitizedGlobalValue();
	int Second = GetSanitizedGlobalValue();
	return First == 77 && Second == 77;
}
