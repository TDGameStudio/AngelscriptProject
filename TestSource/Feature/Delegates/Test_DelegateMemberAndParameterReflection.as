// Theme: Feature.Delegates. Positive delegate UPROPERTY and UFUNCTION parameter reflection.
// C++: AngelscriptCoverageDelegateTests.cpp::DelegateMemberAndParameterReflection
// Oracle: ExecuteCallbackPath()==42 (DoubleValue(21)). Extra: empty object is null;
// unbound ConsumeCallback returns -1. DefaultSafe.

delegate void FCoverageDelegateMemberSignal(int Value, const FString& Label);
delegate int FCoverageDelegateCallback(int Value);

UCLASS()
class UCoverageDelegateReflectionObject : UObject
{
	UPROPERTY()
	FCoverageDelegateMemberSignal OnMemberSignal;

	UFUNCTION()
	int ConsumeCallback(FCoverageDelegateCallback Callback)
	{
		if (!Callback.IsBound())
		{
			return -1;
		}

		return Callback.Execute(21);
	}

	UFUNCTION()
	int DoubleValue(int Value)
	{
		return Value * 2;
	}

	UFUNCTION()
	int ExecuteCallbackPath()
	{
		FCoverageDelegateCallback Callback;
		Callback.BindUFunction(this, n"DoubleValue");
		return ConsumeCallback(Callback);
	}
}

bool Observe_DelegateReflection_EmptyDefaultIsNull()
{
	UCoverageDelegateReflectionObject Obj;
	return Obj == nullptr;
}

int Observe_DelegateReflection_ExecuteCallbackPath(UCoverageDelegateReflectionObject Obj)
{
	if (Obj == nullptr)
	{
		throw("TS-FEAT-0026 setup: required UCoverageDelegateReflectionObject is null");
	}
	return Obj.ExecuteCallbackPath();
}

int Observe_DelegateReflection_UnboundConsumeReturnsMinusOne(UCoverageDelegateReflectionObject Obj)
{
	if (Obj == nullptr)
	{
		throw("TS-FEAT-0026 setup: required UCoverageDelegateReflectionObject is null");
	}
	FCoverageDelegateCallback Callback;
	return Obj.ConsumeCallback(Callback);
}
