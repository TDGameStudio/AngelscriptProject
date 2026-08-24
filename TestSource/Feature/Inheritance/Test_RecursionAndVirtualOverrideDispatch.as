// Theme: Feature.Inheritance. WorldStory recursive UFUNCTION + virtual BlueprintOverride dispatch.
// C++: AngelscriptCoverageUFunctionTests.cpp::RecursionAndVirtualOverrideDispatch
// Oracle: base DispatchVirtual(7)==8 TraceValue==1; child DispatchVirtual(7)==17 TraceValue==2;
// Factorial(5)==120.
// Extra: empty handle null; Factorial(1)==1 and Factorial(0)==1 base cases. FixtureIsolated.
// Keep TraceValue.

UCLASS()
class ACoverageUFunctionVirtualBase : AActor
{
	UPROPERTY()
	int TraceValue = 0;

	UFUNCTION(BlueprintEvent)
	int ComputeVirtual(int Value)
	{
		TraceValue = TraceValue * 10 + 1;
		return Value + 1;
	}

	UFUNCTION()
	int Factorial(int Value)
	{
		if (Value <= 1)
		{
			return 1;
		}

		return Value * Factorial(Value - 1);
	}

	UFUNCTION()
	int DispatchVirtual(int Value)
	{
		return ComputeVirtual(Value);
	}
}

UCLASS()
class ACoverageUFunctionVirtualChild : ACoverageUFunctionVirtualBase
{
	UFUNCTION(BlueprintOverride)
	int ComputeVirtual(int Value)
	{
		TraceValue = TraceValue * 10 + 2;
		return Value + 10;
	}
}

bool Observe_VirtualDispatch_EmptyHandleIsNull()
{
	ACoverageUFunctionVirtualChild Actor;
	return Actor == nullptr;
}

int Observe_VirtualDispatch_BaseReturn(ACoverageUFunctionVirtualBase Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0130 setup: required ACoverageUFunctionVirtualBase is null");
	}
	return Actor.DispatchVirtual(7);
}

int Observe_VirtualDispatch_BaseTrace(ACoverageUFunctionVirtualBase Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0130 setup: required ACoverageUFunctionVirtualBase is null");
	}
	Actor.DispatchVirtual(7);
	return Actor.TraceValue;
}

int Observe_VirtualDispatch_ChildReturn(ACoverageUFunctionVirtualChild Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0130 setup: required ACoverageUFunctionVirtualChild is null");
	}
	return Actor.DispatchVirtual(7);
}

int Observe_VirtualDispatch_ChildTrace(ACoverageUFunctionVirtualChild Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0130 setup: required ACoverageUFunctionVirtualChild is null");
	}
	Actor.DispatchVirtual(7);
	return Actor.TraceValue;
}

int Observe_VirtualDispatch_FactorialFive(ACoverageUFunctionVirtualChild Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0130 setup: required ACoverageUFunctionVirtualChild is null");
	}
	return Actor.Factorial(5);
}

int Observe_VirtualDispatch_FactorialBaseCases(ACoverageUFunctionVirtualChild Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0130 setup: required ACoverageUFunctionVirtualChild is null");
	}
	return Actor.Factorial(1) + Actor.Factorial(0);
}
