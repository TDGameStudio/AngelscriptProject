// Theme: Feature.Inheritance. WorldStory missing UFUNCTION name fails closed; actor state stays readable.
// C++: AngelscriptActorScriptOverrideTests.cpp::MissingFunctionReportsExplicitFailure
// Compile + spawn. Oracle: StableValue==1; CallFunctionByNameWithArguments("DoesNotExist") returns false.
// Extra: empty handle null; StableValue 0 mutation is copy-independent. FixtureIsolated. Keep StableValue.

UCLASS()
class ATestScriptActorMissingFunctionReportsExplicitFailure : AActor
{
	UPROPERTY()
	int StableValue = 1;
}

bool Observe_MissingFunction_EmptyHandleIsNull()
{
	ATestScriptActorMissingFunctionReportsExplicitFailure Actor;
	return Actor == nullptr;
}

int Observe_MissingFunction_StableValue(ATestScriptActorMissingFunctionReportsExplicitFailure Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0174 setup: required ATestScriptActorMissingFunctionReportsExplicitFailure is null");
	}
	return Actor.StableValue;
}

bool Observe_MissingFunction_CopyIndependence(
	ATestScriptActorMissingFunctionReportsExplicitFailure First,
	ATestScriptActorMissingFunctionReportsExplicitFailure Second)
{
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-FEAT-0174 setup: required actors are null");
	}
	First.StableValue = 0;
	return Second.StableValue == 1 && First.StableValue == 0;
}
