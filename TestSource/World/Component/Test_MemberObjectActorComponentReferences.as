// Theme: World.Component. WorldStory: UObject/AActor/UActorComponent member
// handles assigned from NewObject, SpawnActor, CreateComponent.
// C++: AngelscriptCoverageHandleTests.cpp::MemberObjectActorComponentReferences
// sha256=40d8a84d0c47d5de267d9cad87c3ac5d6d7ddbccfefbf4298519c72b92d44b9e; lines 433-471.
// Oracle VerifyByPath ObjectReferenceWorked, ActorReferenceWorked,
// ComponentReferenceWorked, ComponentOwnerWorked true. Extra: local construct
// all handles null and flags false. FixtureIsolated.

UCLASS()
class ACoverageHandleMemberReferenceActor : AActor
{
	UPROPERTY()
	UObject MemberObject;

	UPROPERTY()
	AActor MemberActor;

	UPROPERTY()
	UActorComponent MemberComponent;

	UPROPERTY()
	bool ObjectReferenceWorked = false;

	UPROPERTY()
	bool ActorReferenceWorked = false;

	UPROPERTY()
	bool ComponentReferenceWorked = false;

	UPROPERTY()
	bool ComponentOwnerWorked = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		MemberObject = NewObject(this, UTexture2D::StaticClass(), n"CoverageMemberObject");
		MemberActor = SpawnActor(AActor::StaticClass());
		MemberComponent = CreateComponent(USceneComponent::StaticClass(), n"CoverageMemberComponent");

		ObjectReferenceWorked = MemberObject != nullptr && MemberObject.GetOuter() == this;
		ActorReferenceWorked = MemberActor != nullptr && MemberActor != this;
		ComponentReferenceWorked = MemberComponent != nullptr && MemberComponent.GetName() == n"CoverageMemberComponent";
		ComponentOwnerWorked = MemberComponent != nullptr && MemberComponent.GetOwner() == this;
	}
}

bool Observe_MemberReferences_DefaultNull(ACoverageHandleMemberReferenceActor Actor)
{
	if (Actor is null)
	{
		throw("Test_MemberObjectActorComponentReferences setup: required Actor is null");
	}
	return Actor.MemberObject == nullptr
		&& Actor.MemberActor == nullptr
		&& Actor.MemberComponent == nullptr
		&& !Actor.ObjectReferenceWorked
		&& !Actor.ActorReferenceWorked
		&& !Actor.ComponentReferenceWorked
		&& !Actor.ComponentOwnerWorked;
}

bool Observe_MemberReferences_CopyIndependence(ACoverageHandleMemberReferenceActor First, ACoverageHandleMemberReferenceActor Second)
{
	if (First is null)
	{
		throw("Test_MemberObjectActorComponentReferences setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_MemberObjectActorComponentReferences setup: required Second is null");
	}
	First.ObjectReferenceWorked = true;
	First.ActorReferenceWorked = true;
	return First.ObjectReferenceWorked
		&& First.ActorReferenceWorked
		&& !Second.ObjectReferenceWorked
		&& !Second.ActorReferenceWorked
		&& Second.MemberObject == nullptr;
}
