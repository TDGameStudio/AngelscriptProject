// Theme: Definitions.UClass. Positive function-only UObject, no user properties.
// C++: AngelscriptScriptClassStructureTests.cpp::FunctionOnlyClassCompilesAndExecutes
// Oracle: GetValue returns 17; 0 declared user properties.
// Extra: nullptr handle is the empty vector; repeating GetValue is stable.
// DefaultSafe.

UCLASS()
class UFunctionOnlyScriptClass : UObject
{
	UFUNCTION()
	int GetValue()
	{
		return 17;
	}
}

int Observe_GetValue_Nominal(UFunctionOnlyScriptClass Object)
{
	return Object.GetValue();
}

bool Observe_GetValue_NullDefault()
{
	UFunctionOnlyScriptClass Object = nullptr;
	return Object == nullptr;
}

bool Observe_GetValue_RepeatCall(UFunctionOnlyScriptClass Object)
{
	int First = Object.GetValue();
	int Second = Object.GetValue();
	return First == 17 && Second == 17;
}
