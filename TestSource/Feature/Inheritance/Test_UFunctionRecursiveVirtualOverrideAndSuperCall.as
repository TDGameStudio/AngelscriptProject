// Theme: Feature.Inheritance. WorldStory BlueprintEvent override, recursion, Super::.
// C++: AngelscriptCoverageMacrosTests.cpp::UFunctionRecursiveVirtualOverrideAndSuperCall
// sha256 from theme-refs TS-FEAT-0054; lines 1508-1563.
// Oracle: DispatchVirtual(7) base==8 child==17; Factorial(5)==120; CallParentCompute(7)==111;
// Base TraceValue==1; Child TraceValue==24 after dispatch then Super::BaseOnlyCompute.
// Extra: Factorial(0)==1 and Factorial(1)==1; TraceValue default 0. FixtureIsolated.

UCLASS()
class ACoverageMacrosFunctionVirtualBase : AActor
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

	UFUNCTION()
	int BaseOnlyCompute(int Value)
	{
		TraceValue = TraceValue * 10 + 4;
		return Value + 4;
	}
}

UCLASS()
class ACoverageMacrosFunctionVirtualChild : ACoverageMacrosFunctionVirtualBase
{
	UFUNCTION(BlueprintOverride)
	int ComputeVirtual(int Value)
	{
		TraceValue = TraceValue * 10 + 2;
		return Value + 10;
	}

	UFUNCTION()
	int CallParentCompute(int Value)
	{
		return Super::BaseOnlyCompute(Value) + 100;
	}
}

int Observe_Virtual_DefaultTrace(ACoverageMacrosFunctionVirtualChild Child)
{
	if (Child is null)
	{
		throw("Test_UFunctionRecursiveVirtualOverrideAndSuperCall setup: required Child is null");
	}
	return Child.TraceValue;
}

int Observe_Virtual_FactorialZeroBoundary(ACoverageMacrosFunctionVirtualChild Child)
{
	if (Child is null)
	{
		throw("Test_UFunctionRecursiveVirtualOverrideAndSuperCall setup: required Child is null");
	}
	return Child.Factorial(0);
}

int Observe_Virtual_FactorialOne(ACoverageMacrosFunctionVirtualChild Child)
{
	if (Child is null)
	{
		throw("Test_UFunctionRecursiveVirtualOverrideAndSuperCall setup: required Child is null");
	}
	return Child.Factorial(1);
}

int Observe_Virtual_FactorialFive(ACoverageMacrosFunctionVirtualChild Child)
{
	if (Child is null)
	{
		throw("Test_UFunctionRecursiveVirtualOverrideAndSuperCall setup: required Child is null");
	}
	return Child.Factorial(5);
}

int Observe_Virtual_BaseDispatchSeven(ACoverageMacrosFunctionVirtualBase Base)
{
	if (Base is null)
	{
		throw("Test_UFunctionRecursiveVirtualOverrideAndSuperCall setup: required Base is null");
	}
	return Base.DispatchVirtual(7);
}

int Observe_Virtual_ChildDispatchSeven(ACoverageMacrosFunctionVirtualChild Child)
{
	if (Child is null)
	{
		throw("Test_UFunctionRecursiveVirtualOverrideAndSuperCall setup: required Child is null");
	}
	return Child.DispatchVirtual(7);
}

int Observe_Virtual_CallParentComputeSeven(ACoverageMacrosFunctionVirtualChild Child)
{
	if (Child is null)
	{
		throw("Test_UFunctionRecursiveVirtualOverrideAndSuperCall setup: required Child is null");
	}
	return Child.CallParentCompute(7);
}
