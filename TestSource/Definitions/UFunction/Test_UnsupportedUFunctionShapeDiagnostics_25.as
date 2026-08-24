// Theme: Definitions.UFunction. CSV NegativeDiagnostic is wrong: C++ compiles this fork boundary.
// C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics const-override tail
// CompileScriptModule + IsNotNull. Non-const BlueprintOverride of a const BlueprintEvent is accepted
// and the child UFunction keeps FUNC_Const. Oracle: base ReadConstEvent(5)==5; child (5)==6.
// Extra: ReadConstEvent(0) is 0 on base and 1 on child.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class ACoverageUFunctionConstBoundaryBaseActor : AActor
{
	UFUNCTION(BlueprintPure, BlueprintEvent)
	int ReadConstEvent(int Value) const
	{
		return Value;
	}
}

UCLASS()
class ACoverageUFunctionConstBoundaryChildActor : ACoverageUFunctionConstBoundaryBaseActor
{
	UFUNCTION(BlueprintOverride)
	int ReadConstEvent(int Value)
	{
		return Value + 1;
	}
}

int Observe_ConstBoundary_BaseFive(ACoverageUFunctionConstBoundaryBaseActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UnsupportedUFunctionShapeDiagnostics_25 setup: required Actor is null");
	}
	return Actor.ReadConstEvent(5);
}

int Observe_ConstBoundary_ChildFive(ACoverageUFunctionConstBoundaryChildActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UnsupportedUFunctionShapeDiagnostics_25 setup: required Actor is null");
	}
	return Actor.ReadConstEvent(5);
}

int Observe_ConstBoundary_BaseZero(ACoverageUFunctionConstBoundaryBaseActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UnsupportedUFunctionShapeDiagnostics_25 setup: required Actor is null");
	}
	return Actor.ReadConstEvent(0);
}

int Observe_ConstBoundary_ChildZero(ACoverageUFunctionConstBoundaryChildActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UnsupportedUFunctionShapeDiagnostics_25 setup: required Actor is null");
	}
	return Actor.ReadConstEvent(0);
}
