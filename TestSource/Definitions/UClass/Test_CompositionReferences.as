// Theme: Definitions.UClass. WorldStory UObject/actor/component/TSubclassOf member references.
// C++: AngelscriptCoverageClassFeaturesTests.cpp::CompositionReferences
// Oracle after BeginPlay: MemberObjectAssigned/ActorReferenceAssigned/ComponentReferenceAssigned/SubclassAssigned all true.
// Extra: unset handle is null; pre-BeginPlay flags stay false. FixtureIsolated.

UCLASS()
class UCoverageMemberObject : UObject
{
	UPROPERTY()
	int Value = 31;
}

UCLASS()
class UCoverageMemberComponent : UActorComponent
{
	UPROPERTY()
	int ComponentValue = 41;
}

UCLASS()
class ACoverageCompositionReferenceActor : AActor
{
	UPROPERTY()
	UCoverageMemberObject MemberObject;

	UPROPERTY()
	AActor OtherActor;

	UPROPERTY(DefaultComponent)
	UCoverageMemberComponent MemberComponent;

	UPROPERTY()
	TSubclassOf<AActor> ActorClass;

	UPROPERTY()
	bool MemberObjectAssigned = false;

	UPROPERTY()
	bool ActorReferenceAssigned = false;

	UPROPERTY()
	bool ComponentReferenceAssigned = false;

	UPROPERTY()
	bool SubclassAssigned = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		MemberObject = Cast<UCoverageMemberObject>(NewObject(this, UCoverageMemberObject::StaticClass()));
		OtherActor = this;
		ActorClass = ACoverageCompositionReferenceActor::StaticClass();

		MemberObjectAssigned = MemberObject != nullptr && MemberObject.Value == 31;
		ActorReferenceAssigned = OtherActor == this;
		ComponentReferenceAssigned = MemberComponent != nullptr && MemberComponent.ComponentValue == 41;
		SubclassAssigned = ActorClass.Get() == ACoverageCompositionReferenceActor::StaticClass();
	}
}

bool Observe_CompositionActor_EmptyDefaultIsNull()
{
	ACoverageCompositionReferenceActor Actor;
	return Actor == nullptr;
}

bool Observe_CompositionActor_FlagsDefaultFalse(ACoverageCompositionReferenceActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-DEF-0039 setup: required ACoverageCompositionReferenceActor is null");
	}
	return Actor.MemberObjectAssigned == false
		&& Actor.ActorReferenceAssigned == false
		&& Actor.ComponentReferenceAssigned == false
		&& Actor.SubclassAssigned == false;
}

int Observe_MemberObject_ValueDefault(UCoverageMemberObject Obj)
{
	if (Obj == nullptr)
	{
		throw("TS-DEF-0039 setup: required UCoverageMemberObject is null");
	}
	return Obj.Value;
}
