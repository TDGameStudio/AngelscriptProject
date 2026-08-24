// Theme: Feature.Default. WorldStory int UFUNCTION specifier, default, and &out edges.
// C++: AngelscriptCoverageIntFunctionTests.cpp::UFunctionSpecifierDefaultsAndOutParameters
// Oracle: CallableAdd(20, 22)==42; PureDouble(21)==42; DefaultInt(10)==42; SplitOut(40) A=41 B=42.
// Extra: zeros; DefaultInt() uses 10; SplitOut(0) A=1 B=2. Keep the four UFUNCTION names.
// FixtureIsolated.

UCLASS()
class ACoverageIntFunctionEdgesActor : AActor
{
	UFUNCTION(BlueprintCallable, Category = "Coverage|Int")
	int CallableAdd(int A, int B)
	{
		return A + B;
	}

	UFUNCTION(BlueprintPure, Category = "Coverage|Int")
	int PureDouble(int Value) const
	{
		return Value * 2;
	}

	UFUNCTION()
	int DefaultInt(int Value = 10)
	{
		return Value * 4 + 2;
	}

	UFUNCTION()
	void SplitOut(int Input, int&out A, int&out B)
	{
		A = Input + 1;
		B = Input + 2;
	}
}

int Observe_CallableAdd_Nominal(ACoverageIntFunctionEdgesActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0044 setup: required ACoverageIntFunctionEdgesActor is null");
	}
	return Actor.CallableAdd(20, 22);
}

int Observe_CallableAdd_Zeros(ACoverageIntFunctionEdgesActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0044 setup: required ACoverageIntFunctionEdgesActor is null");
	}
	return Actor.CallableAdd(0, 0);
}

int Observe_PureDouble_Nominal(ACoverageIntFunctionEdgesActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0044 setup: required ACoverageIntFunctionEdgesActor is null");
	}
	return Actor.PureDouble(21);
}

int Observe_DefaultInt_ExplicitTen(ACoverageIntFunctionEdgesActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0044 setup: required ACoverageIntFunctionEdgesActor is null");
	}
	return Actor.DefaultInt(10);
}

int Observe_DefaultInt_OmittedDefault(ACoverageIntFunctionEdgesActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0044 setup: required ACoverageIntFunctionEdgesActor is null");
	}
	return Actor.DefaultInt();
}

int Observe_DefaultInt_ZeroBoundary(ACoverageIntFunctionEdgesActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0044 setup: required ACoverageIntFunctionEdgesActor is null");
	}
	return Actor.DefaultInt(0);
}

int Observe_SplitOut_NominalA(ACoverageIntFunctionEdgesActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0044 setup: required ACoverageIntFunctionEdgesActor is null");
	}
	int A = 0;
	int B = 0;
	Actor.SplitOut(40, A, B);
	return A;
}

int Observe_SplitOut_NominalB(ACoverageIntFunctionEdgesActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0044 setup: required ACoverageIntFunctionEdgesActor is null");
	}
	int A = 0;
	int B = 0;
	Actor.SplitOut(40, A, B);
	return B;
}

int Observe_SplitOut_ZeroBoundaryA(ACoverageIntFunctionEdgesActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0044 setup: required ACoverageIntFunctionEdgesActor is null");
	}
	int A = 0;
	int B = 0;
	Actor.SplitOut(0, A, B);
	return A;
}
