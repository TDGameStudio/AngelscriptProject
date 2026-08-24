// Theme: Definitions.UStruct. WorldStory: extended member types (double, FText, math structs, object/soft/weak).
// C++: AngelscriptCoverageUStructTests.cpp::UStructExtendedMemberTypeMatrix spawn + BeginPlay.
// Oracle: Data.DoubleValue 6.25, Text "Struct extended text", Rotator (10,20,30), ObjectRef live,
// WeakActor == this. Extra: local construct leaves DoubleValue 0.0 and ObjectRef null.
// FixtureIsolated. Runner owns spawn.

UCLASS()
class UCoverageStructMemberObject : UObject
{
	UPROPERTY()
	int Value = 17;
}

USTRUCT(BlueprintType)
struct FStructExtendedMemberData
{
	UPROPERTY()
	double DoubleValue = 0.0;

	UPROPERTY()
	FText TextValue;

	UPROPERTY()
	FRotator RotatorValue;

	UPROPERTY()
	FQuat QuatValue;

	UPROPERTY()
	FTransform TransformValue;

	UPROPERTY()
	UCoverageStructMemberObject ObjectRef;

	UPROPERTY()
	TSubclassOf<AActor> ActorClass;

	UPROPERTY()
	TWeakObjectPtr<AActor> WeakActor;

	UPROPERTY()
	TSoftObjectPtr<AActor> SoftActor;

	UPROPERTY()
	TSoftClassPtr<AActor> SoftActorClass;
}

UCLASS()
class ACoverageStructExtendedMemberActor : AActor
{
	UPROPERTY()
	FStructExtendedMemberData Data;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Data.DoubleValue = 6.25;
		Data.TextValue = FText::FromString("Struct extended text");
		Data.RotatorValue = FRotator(10, 20, 30);
		Data.QuatValue = FQuat(FRotator(0, 90, 0));
		Data.TransformValue = FTransform(FRotator(0, 45, 0), FVector(3, 4, 5), FVector(2, 2, 2));
		Data.ObjectRef = Cast<UCoverageStructMemberObject>(NewObject(this, UCoverageStructMemberObject::StaticClass()));
		Data.ActorClass = ACoverageStructExtendedMemberActor::StaticClass();
		Data.WeakActor = this;
		Data.SoftActor = this;
		Data.SoftActorClass = ACoverageStructExtendedMemberActor::StaticClass();
	}
}

bool Observe_ExtendedMember_DefaultEmpty(ACoverageStructExtendedMemberActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructExtendedMemberTypeMatrix setup: required Actor is null");
	}
	return Actor.Data.DoubleValue == 0.0
		&& Actor.Data.ObjectRef == nullptr
		&& Actor.Data.ActorClass.Get() == nullptr;
}

bool Observe_ExtendedMember_NominalBeginPlay(ACoverageStructExtendedMemberActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructExtendedMemberTypeMatrix setup: required Actor is null");
	}
	Actor.BeginPlay();
	return Actor.Data.DoubleValue == 6.25
		&& Actor.Data.TextValue.ToString() == "Struct extended text"
		&& Actor.Data.RotatorValue.Equals(FRotator(10, 20, 30), 0.001)
		&& Actor.Data.ObjectRef != nullptr
		&& Actor.Data.ObjectRef.Value == 17
		&& Actor.Data.ActorClass.Get() == ACoverageStructExtendedMemberActor::StaticClass()
		&& Actor.Data.WeakActor.Get() == Actor;
}

bool Observe_ExtendedMember_CopyIndependence(ACoverageStructExtendedMemberActor First, ACoverageStructExtendedMemberActor Second)
{
	if (First is null)
	{
		throw("Test_UStructExtendedMemberTypeMatrix setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_UStructExtendedMemberTypeMatrix setup: required Second is null");
	}
	First.BeginPlay();
	return First.Data.DoubleValue == 6.25 && Second.Data.DoubleValue == 0.0 && Second.Data.ObjectRef == nullptr;
}
