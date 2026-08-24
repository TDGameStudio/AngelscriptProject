// Theme: Definitions.UClass. WorldStory DefaultComponent/ShowOnActor on a non-actor UObject owner.
// C++: AngelscriptCoverageUClassTests.cpp::UClassNonActorComponentSpecifierMetadataBoundary
// Oracle: owner is not an AActor; DefaultComponent metadata stays property-local; Logic is the component type.
// Extra: unset handles are null; Logic default is null. FixtureIsolated.

UCLASS()
class UCoverageUClassNonActorSpecifierComponent : UActorComponent
{
}

UCLASS()
class UCoverageUClassNonActorComponentSpecifierBaseOwner : UObject
{
	UPROPERTY(DefaultComponent, ShowOnActor)
	UCoverageUClassNonActorSpecifierComponent Logic;
}

bool Observe_NonActorSpecifierComponent_EmptyDefaultIsNull()
{
	UCoverageUClassNonActorSpecifierComponent Comp;
	return Comp == nullptr;
}

bool Observe_NonActorOwner_EmptyDefaultIsNull()
{
	UCoverageUClassNonActorComponentSpecifierBaseOwner Owner;
	return Owner == nullptr;
}

bool Observe_NonActorOwner_LogicDefaultNull(UCoverageUClassNonActorComponentSpecifierBaseOwner Owner)
{
	if (Owner == nullptr)
	{
		throw("TS-DEF-0161 setup: required UCoverageUClassNonActorComponentSpecifierBaseOwner is null");
	}
	return Owner.Logic == nullptr;
}
