// Theme: World.Component. WorldStory: OnComponentHit bind; C++ oracle is
// HitCount=0 initially (no hit dispatched in that method).
// C++: AngelscriptCoveragePrimitiveComponentTests.cpp::PrimitiveHitEvents
// sha256=402fb2b34c69d655f33b1bb2434dcbaac2410c75e3aca67afa93eedd13ab02ba; lines 1013-1043.
// Extra: local construct HitCount 0, HitNormal zero, MeshComp null.
// FixtureIsolated.

UCLASS()
class ACoveragePrimitiveHitEventsActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UStaticMeshComponent MeshComp;

	UPROPERTY()
	int HitCount = 0;

	UPROPERTY()
	FVector HitNormal;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		MeshComp.SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);
		MeshComp.SetNotifyRigidBodyCollision(true);

		MeshComp.OnComponentHit.AddUFunction(this, n"HandleHit");
	}

	UFUNCTION()
	void HandleHit(UPrimitiveComponent HitComponent, AActor OtherActor, UPrimitiveComponent OtherComp,
		FVector NormalImpulse, const FHitResult&in Hit)
	{
		HitCount++;
		HitNormal = Hit.Normal;
	}
}

bool Observe_PrimitiveHitEvents_DefaultEmpty(ACoveragePrimitiveHitEventsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_PrimitiveHitEvents setup: required Actor is null");
	}
	return Actor.HitCount == 0
		&& Actor.HitNormal.X == 0.0f
		&& Actor.HitNormal.Y == 0.0f
		&& Actor.HitNormal.Z == 0.0f
		&& Actor.MeshComp == nullptr;
}

bool Observe_PrimitiveHitEvents_CopyIndependence(ACoveragePrimitiveHitEventsActor First, ACoveragePrimitiveHitEventsActor Second)
{
	if (First is null)
	{
		throw("Test_PrimitiveHitEvents setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_PrimitiveHitEvents setup: required Second is null");
	}
	First.HitCount = 1;
	First.HitNormal = FVector(0.0f, 0.0f, 1.0f);
	return First.HitCount == 1
		&& First.HitNormal.Z == 1.0f
		&& Second.HitCount == 0
		&& Second.HitNormal.Z == 0.0f;
}
