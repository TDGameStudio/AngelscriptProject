// Theme: Definitions.UClass. WorldStory specifier ordering: last Blueprintable/NotBlueprintable wins.
// C++: AngelscriptCoverageUClassTests.cpp::UClassSpecifierOrderAndBoundaryCombinations
// Oracle: Blueprintable then NotBlueprintable => IsBlueprintBase=false; reverse => Blueprint base.
// Extra: unset handles are null. FixtureIsolated.

UCLASS(Blueprintable, NotBlueprintable, BlueprintType)
class UCoverageUClassBlueprintOrderNotBaseObject : UObject
{
}

UCLASS(NotBlueprintable, Blueprintable, BlueprintType)
class UCoverageUClassBlueprintOrderBaseObject : UObject
{
}

UCLASS(DefaultConfig)
class UCoverageUClassDefaultConfigWithoutConfigObject : UObject
{
}

UCLASS(NotPlaceable, Abstract, Blueprintable)
class ACoverageUClassAbstractNotPlaceableActor : AActor
{
}

UCLASS(HideCategories="Rendering", meta=(ShowCategories="Rendering", HideCategories="Input", ClassGroupNames="MetaGroup"))
class ACoverageUClassMetaOverridesActor : AActor
{
}

UCLASS(ClassGroup="FirstGroup", meta=(ClassGroupNames="SecondGroup"))
class UCoverageUClassClassGroupOverrideObject : UObject
{
}

bool Observe_BlueprintOrderNotBase_EmptyDefaultIsNull()
{
	UCoverageUClassBlueprintOrderNotBaseObject Obj;
	return Obj == nullptr;
}

bool Observe_BlueprintOrderBase_EmptyDefaultIsNull()
{
	UCoverageUClassBlueprintOrderBaseObject Obj;
	return Obj == nullptr;
}

bool Observe_DefaultConfigWithoutConfig_EmptyDefaultIsNull()
{
	UCoverageUClassDefaultConfigWithoutConfigObject Obj;
	return Obj == nullptr;
}

bool Observe_AbstractNotPlaceable_EmptyDefaultIsNull()
{
	ACoverageUClassAbstractNotPlaceableActor Actor;
	return Actor == nullptr;
}

bool Observe_MetaOverrides_EmptyDefaultIsNull()
{
	ACoverageUClassMetaOverridesActor Actor;
	return Actor == nullptr;
}

bool Observe_ClassGroupOverride_EmptyDefaultIsNull()
{
	UCoverageUClassClassGroupOverrideObject Obj;
	return Obj == nullptr;
}
