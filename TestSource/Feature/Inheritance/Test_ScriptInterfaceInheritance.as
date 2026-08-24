// Theme: Feature.Inheritance. WorldStory script methods remain on a Blueprint child.
// C++: AngelscriptBlueprintChildTests.cpp::ScriptInterfaceInheritance
// Oracle: GetInterfaceValue()==42, GetLabel()=="InterfaceActor", InterfaceResult==42.
// Extra: empty handle null; empty Label mutation is copy-independent. FixtureIsolated.
// Keep InterfaceResult.

UCLASS()
class ATestBPChildScriptInterfaceActor : AActor
{
	UPROPERTY()
	int InterfaceResult = 42;

	UFUNCTION()
	int GetInterfaceValue()
	{
		return InterfaceResult;
	}

	UFUNCTION()
	FString GetLabel()
	{
		return "InterfaceActor";
	}
}

bool Observe_ScriptInterface_EmptyHandleIsNull()
{
	ATestBPChildScriptInterfaceActor Actor;
	return Actor == nullptr;
}

int Observe_ScriptInterface_GetValue(ATestBPChildScriptInterfaceActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0182 setup: required ATestBPChildScriptInterfaceActor is null");
	}
	return Actor.GetInterfaceValue();
}

FString Observe_ScriptInterface_GetLabel(ATestBPChildScriptInterfaceActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0182 setup: required ATestBPChildScriptInterfaceActor is null");
	}
	return Actor.GetLabel();
}

int Observe_ScriptInterface_ZeroResultBoundary(ATestBPChildScriptInterfaceActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0182 setup: required ATestBPChildScriptInterfaceActor is null");
	}
	Actor.InterfaceResult = 0;
	return Actor.GetInterfaceValue();
}

bool Observe_ScriptInterface_CopyIndependence(
	ATestBPChildScriptInterfaceActor First,
	ATestBPChildScriptInterfaceActor Second)
{
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-FEAT-0182 setup: required actors are null");
	}
	First.InterfaceResult = 0;
	return Second.GetInterfaceValue() == 42 && First.GetInterfaceValue() == 0;
}
