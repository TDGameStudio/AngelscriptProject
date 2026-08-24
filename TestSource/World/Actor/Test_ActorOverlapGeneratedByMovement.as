// Theme: World.Actor. WorldStory: ActorBeginOverlap / ActorEndOverlap BlueprintOverride
// payload match when another actor moves into/out of the sphere.
// C++: AngelscriptCoveragePhysicsTests.cpp::ActorOverlapGeneratedByMovement
// Oracle: C++ moves the other actor; counts and payload flags become 1/true.
// Extra: ActorBeginOverlapCount/ActorEndOverlapCount stay 0 and payload flags stay false
// until overlap is generated. Do not spawn from script. FixtureIsolated.

UCLASS()
class ACoveragePhysicsActorOverlapGeneratedByMovementActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent Sphere;

	UPROPERTY()
	int ActorBeginOverlapCount = 0;

	UPROPERTY()
	int ActorEndOverlapCount = 0;

	UPROPERTY()
	bool ActorBeginPayloadMatched = false;

	UPROPERTY()
	bool ActorEndPayloadMatched = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Sphere.SetSphereRadius(75.0f);
		Sphere.SetCollisionEnabled(ECollisionEnabled::QueryOnly);
		Sphere.SetCollisionObjectType(ECollisionChannel::ECC_WorldDynamic);
		Sphere.SetCollisionResponseToAllChannels(ECollisionResponse::ECR_Overlap);
		Sphere.SetGenerateOverlapEvents(true);
	}

	UFUNCTION(BlueprintOverride)
	void ActorBeginOverlap(AActor OtherActor)
	{
		ActorBeginOverlapCount += 1;
		ActorBeginPayloadMatched =
			OtherActor != nullptr
			&& OtherActor != this;
	}

	UFUNCTION(BlueprintOverride)
	void ActorEndOverlap(AActor OtherActor)
	{
		ActorEndOverlapCount += 1;
		ActorEndPayloadMatched =
			OtherActor != nullptr
			&& OtherActor != this;
	}
}
