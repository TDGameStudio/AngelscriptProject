// Theme: Definitions.UClass. WorldStory Blueprintable Abstract vs NotBlueprintable BlueprintType.
// C++: AngelscriptCoverageUClassTests.cpp::UClassBlueprintAndAbstractSpecifiers
// Oracle: Abstract CLASS_Abstract + IsBlueprintBase=true; variable-only BlueprintType=true IsBlueprintBase=false.
// Extra: unset handles are null. FixtureIsolated.

UCLASS(Blueprintable, Abstract)
class ACoverageUClassAbstractBlueprintableActor : AActor
{
}

UCLASS(NotBlueprintable, BlueprintType)
class UCoverageUClassBlueprintVariableOnlyObject : UObject
{
}

bool Observe_AbstractBlueprintable_EmptyDefaultIsNull()
{
	ACoverageUClassAbstractBlueprintableActor Actor;
	return Actor == nullptr;
}

bool Observe_BlueprintVariableOnly_EmptyDefaultIsNull()
{
	UCoverageUClassBlueprintVariableOnlyObject Obj;
	return Obj == nullptr;
}

bool Observe_AbstractBlueprintable_AssignAliases()
{
	ACoverageUClassAbstractBlueprintableActor First;
	ACoverageUClassAbstractBlueprintableActor Second;
	First = Second;
	return First is Second;
}
