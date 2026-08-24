// Theme: Definitions.UFunction. Positive global UFUNCTION materializes a statics class.
// C++: AngelscriptCompilerGlobalUFunctionTests.cpp::GlobalUFunctionCreatesStaticsClass
// Oracle: GetGlobalValue() == 42.
// Extra: 0 is a distinct unused boundary; repeating the call is stable.
// DefaultSafe.

UFUNCTION(BlueprintCallable)
int GetGlobalValue()
{
	return 42;
}

bool Observe_GlobalValue_Nominal()
{
	return GetGlobalValue() == 42;
}

bool Observe_GlobalValue_EmptyBoundary()
{
	return GetGlobalValue() != 0;
}

bool Observe_GlobalValue_RepeatCall()
{
	int First = GetGlobalValue();
	int Second = GetGlobalValue();
	return First == 42 && Second == 42;
}
