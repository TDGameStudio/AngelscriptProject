// Theme: Language.Syntax.Reference. WorldStory: UPROPERTY handles, upcast, TSubclassOf, nullptr.
// C++: AngelscriptCoverageTypeConversionTests.cpp::MemberReferenceAndNullableHandleConversions
// spawn + BeginPlay + VerifyByPath ObjectRefAssigned, ActorUpcastAssigned, ComponentRefAssigned,
// SubclassRefAssigned, NullComparisonWorked, CastFromNullableWorked, IsValidAfterNullReset all true.
// sha256=96c98711f5271d97d80a36a6f679e75b067d4cee25a969c88d456b1504c52a0c; lines 389-476.
// Extra: local construct leaves refs null and flags false. FixtureIsolated.

UCLASS()
class ACoverageReferenceBaseActor : AActor
{
}

UCLASS()
class ACoverageReferenceDerivedActor : ACoverageReferenceBaseActor
{
}

UCLASS()
class UCoverageReferenceMemberObject : UObject
{
}

UCLASS()
class UCoverageReferenceMemberComponent : UActorComponent
{
}

UCLASS()
class ACoverageReferenceOwnerActor : AActor
{
	UPROPERTY()
	UObject ObjectRef;

	UPROPERTY()
	AActor ActorRef;

	UPROPERTY()
	UActorComponent ComponentRef;

	UPROPERTY()
	TSubclassOf<AActor> ActorClassRef;

	UPROPERTY()
	bool ObjectRefAssigned = false;

	UPROPERTY()
	bool ActorUpcastAssigned = false;

	UPROPERTY()
	bool ComponentRefAssigned = false;

	UPROPERTY()
	bool SubclassRefAssigned = false;

	UPROPERTY()
	bool NullComparisonWorked = false;

	UPROPERTY()
	bool CastFromNullableWorked = false;

	UPROPERTY()
	bool IsValidAfterNullReset = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ObjectRef = NewObject(this, UCoverageReferenceMemberObject::StaticClass(), n"CoverageObjectRef", true);

		ACoverageReferenceDerivedActor Derived = Cast<ACoverageReferenceDerivedActor>(SpawnActor(ACoverageReferenceDerivedActor::StaticClass()));
		ActorRef = Derived;

		// UObject and UActorComponent are abstract; NewObject must target concrete script subclasses.
		ComponentRef = Cast<UActorComponent>(NewObject(this, UCoverageReferenceMemberComponent::StaticClass(), n"CoverageComponentRef", true));
		ActorClassRef = ACoverageReferenceDerivedActor::StaticClass();

		ObjectRefAssigned = ObjectRef != nullptr && IsValid(ObjectRef);
		ActorUpcastAssigned = ActorRef != nullptr && ActorRef.IsA(ACoverageReferenceBaseActor::StaticClass());
		ComponentRefAssigned = ComponentRef != nullptr && ComponentRef.IsA(UActorComponent::StaticClass());
		SubclassRefAssigned = ActorClassRef.IsValid() && ActorClassRef.Get() == ACoverageReferenceDerivedActor::StaticClass();

		AActor NullableActor = nullptr;
		NullComparisonWorked = NullableActor == nullptr && !IsValid(NullableActor);
		NullableActor = Derived;
		CastFromNullableWorked = Cast<ACoverageReferenceDerivedActor>(NullableActor) == Derived;
		NullableActor = nullptr;
		IsValidAfterNullReset = !IsValid(NullableActor);

		if (Derived != nullptr)
		{
			Derived.DestroyActor();
		}
	}
}

bool Observe_MemberRef_DefaultEmpty(ACoverageReferenceOwnerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_MemberReferenceAndNullableHandleConversions setup: required Actor is null");
	}
	return Actor.ObjectRef == nullptr
		&& Actor.ActorRef == nullptr
		&& Actor.ComponentRef == nullptr
		&& !Actor.ActorClassRef.IsValid()
		&& !Actor.ObjectRefAssigned
		&& !Actor.ActorUpcastAssigned
		&& !Actor.ComponentRefAssigned
		&& !Actor.SubclassRefAssigned
		&& !Actor.NullComparisonWorked
		&& !Actor.CastFromNullableWorked
		&& !Actor.IsValidAfterNullReset;
}
