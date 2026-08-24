// Theme: Definitions.UFunction. Positive: function- and class-level BlueprintThreadSafe dispatch.
// C++: AngelscriptCoverageUFunctionTests.cpp::ThreadSafeDispatchSubclassMatrix
// Compile + CDO invoke. Oracle: FastReturn 10, FunctionThreadSafeReturn 20,
// ClassThreadSafeReturn 30, ClassThreadSafeOptOutReturn 40.
// Extra: repeat calls are stable; default-constructed objects still return those constants.
// DefaultSafe.

UCLASS()
class UCoverageUFunctionThreadSafeObject : UObject
{
	UFUNCTION()
	int FastReturn()
	{
		return 10;
	}

	UFUNCTION(meta=(BlueprintThreadSafe))
	int FunctionThreadSafeReturn()
	{
		return 20;
	}
}

UCLASS(meta=(BlueprintThreadSafe))
class UCoverageUFunctionThreadSafeClassObject : UObject
{
	UFUNCTION()
	int ClassThreadSafeReturn()
	{
		return 30;
	}

	UFUNCTION(meta=(NotBlueprintThreadSafe))
	int ClassThreadSafeOptOutReturn()
	{
		return 40;
	}
}

int Observe_ThreadSafe_FastReturn(UCoverageUFunctionThreadSafeObject Object)
{
	if (Object is null)
	{
		throw("Test_ThreadSafeDispatchSubclassMatrix setup: required Object is null");
	}
	return Object.FastReturn();
}

int Observe_ThreadSafe_FunctionLevel(UCoverageUFunctionThreadSafeObject Object)
{
	if (Object is null)
	{
		throw("Test_ThreadSafeDispatchSubclassMatrix setup: required Object is null");
	}
	return Object.FunctionThreadSafeReturn();
}

int Observe_ThreadSafe_ClassLevel(UCoverageUFunctionThreadSafeClassObject Object)
{
	if (Object is null)
	{
		throw("Test_ThreadSafeDispatchSubclassMatrix setup: required Object is null");
	}
	return Object.ClassThreadSafeReturn();
}

int Observe_ThreadSafe_ClassOptOut(UCoverageUFunctionThreadSafeClassObject Object)
{
	if (Object is null)
	{
		throw("Test_ThreadSafeDispatchSubclassMatrix setup: required Object is null");
	}
	return Object.ClassThreadSafeOptOutReturn();
}

bool Observe_ThreadSafe_RepeatStable(UCoverageUFunctionThreadSafeObject Object, UCoverageUFunctionThreadSafeClassObject ClassObject)
{
	if (Object is null)
	{
		throw("Test_ThreadSafeDispatchSubclassMatrix setup: required Object is null");
	}
	if (ClassObject is null)
	{
		throw("Test_ThreadSafeDispatchSubclassMatrix setup: required ClassObject is null");
	}
	return Object.FastReturn() == 10
		&& Object.FunctionThreadSafeReturn() == 20
		&& ClassObject.ClassThreadSafeReturn() == 30
		&& ClassObject.ClassThreadSafeOptOutReturn() == 40
		&& Object.FastReturn() == Object.FastReturn();
}
