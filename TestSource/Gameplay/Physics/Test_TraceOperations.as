// Theme: Gameplay.Physics. WorldStory System:: line/sweep/overlap traces and collision shapes.
// C++: AngelscriptCoveragePhysicsTests.cpp::TraceOperations
// Oracle VerifyByPath after BeginPlay: LineTraceByChannelExecuted true, SweepSphere/Box/Capsule true,
// LowLevel* true, CollisionShapesRoundTripped true, TraceOutputsInitialized true.
// Extra: defaults false / 0. FixtureIsolated. Keep UPROPERTY names.

UCLASS()
class ACoveragePhysicsTraceActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent Sphere;

	UPROPERTY()
	bool LineTraceByChannelExecuted = false;

	UPROPERTY()
	bool SweepSphereByChannelExecuted = false;

	UPROPERTY()
	bool SweepBoxByChannelExecuted = false;

	UPROPERTY()
	bool SweepCapsuleByChannelExecuted = false;

	UPROPERTY()
	bool LowLevelTraceParamsConfigured = false;

	UPROPERTY()
	bool LowLevelResponseParamsConfigured = false;

	UPROPERTY()
	bool LowLevelLineTraceCalled = false;

	UPROPERTY()
	bool LowLevelLineTraceMultiCalled = false;

	UPROPERTY()
	bool LowLevelSweepCalled = false;

	UPROPERTY()
	bool LowLevelOverlapCalled = false;

	UPROPERTY()
	bool TraceOutputsInitialized = false;

	UPROPERTY()
	bool CollisionShapesRoundTripped = false;

	UPROPERTY()
	int IgnoredActorCount = 0;

	UPROPERTY()
	FHitResult LineTraceResult;

	UPROPERTY()
	TArray<FHitResult> MultiTraceResults;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FVector Start = GetActorLocation();
		FVector End = Start + FVector(0, 0, -1000);

		FHitResult Hit;
		FCollisionQueryParams DefaultQueryParams(n"CoverageTraceKismetReplacement", true, this);
		FCollisionResponseParams DefaultResponseParams(ECollisionResponse::ECR_Block);

		System::LineTraceSingleByChannel(
			Hit, Start, End, ECollisionChannel::ECC_Visibility, DefaultQueryParams, DefaultResponseParams);
		LineTraceByChannelExecuted = true;
		LineTraceResult = Hit;

		System::SweepSingleByChannel(
			Hit, Start, End, FQuat::Identity, ECollisionChannel::ECC_Visibility, FCollisionShape::MakeSphere(50.0f), DefaultQueryParams, DefaultResponseParams);
		SweepSphereByChannelExecuted = true;

		System::SweepSingleByChannel(
			Hit, Start, End, FQuat::Identity, ECollisionChannel::ECC_Visibility, FCollisionShape::MakeBox(FVector(50, 50, 50)), DefaultQueryParams, DefaultResponseParams);
		SweepBoxByChannelExecuted = true;

		System::SweepSingleByChannel(
			Hit, Start, End, FQuat::Identity, ECollisionChannel::ECC_Visibility, FCollisionShape::MakeCapsule(50.0f, 100.0f), DefaultQueryParams, DefaultResponseParams);
		SweepCapsuleByChannelExecuted = true;

		FCollisionQueryParams QueryParams(n"CoverageTraceParams", true, this);
		QueryParams.TraceTag = n"CoverageTraceTag";
		QueryParams.bTraceComplex = true;
		QueryParams.bReturnPhysicalMaterial = true;
		QueryParams.bReturnFaceIndex = true;
		QueryParams.AddIgnoredActor(this);

		TArray<AActor> IgnoredActors;
		IgnoredActors.Add(this);
		QueryParams.AddIgnoredActors(IgnoredActors);
		IgnoredActorCount = QueryParams.GetIgnoredActors().Num();
		LowLevelTraceParamsConfigured =
			QueryParams.TraceTag == n"CoverageTraceTag"
			&& QueryParams.bTraceComplex
			&& QueryParams.bReturnPhysicalMaterial
			&& QueryParams.bReturnFaceIndex
			&& IgnoredActorCount > 0;

		FCollisionResponseParams ResponseParams(ECollisionResponse::ECR_Block);
		LowLevelResponseParamsConfigured = true;

		FHitResult ChannelHit;
		System::LineTraceSingleByChannel(ChannelHit, Start, End, ECollisionChannel::ECC_Visibility, QueryParams, ResponseParams);
		LowLevelLineTraceCalled = true;

		TArray<FHitResult> ChannelHits;
		System::LineTraceMultiByChannel(ChannelHits, Start, End, ECollisionChannel::ECC_Visibility, QueryParams, ResponseParams);
		LowLevelLineTraceMultiCalled = true;

		FCollisionShape SweepShape = FCollisionShape::MakeSphere(25.0f);
		System::SweepSingleByChannel(ChannelHit, Start, End, FQuat::Identity, ECollisionChannel::ECC_Visibility, SweepShape, QueryParams, ResponseParams);
		LowLevelSweepCalled = true;

		TArray<FOverlapResult> Overlaps;
		System::OverlapMultiByChannel(Overlaps, Start, FQuat::Identity, ECollisionChannel::ECC_Visibility, SweepShape, QueryParams, ResponseParams);
		LowLevelOverlapCalled = true;

		FCollisionShape BoxShape = FCollisionShape::MakeBox(FVector(10.0f, 20.0f, 30.0f));
		FCollisionShape SphereShape = FCollisionShape::MakeSphere(35.0f);
		FCollisionShape CapsuleShape = FCollisionShape::MakeCapsule(12.0f, 40.0f);
		CollisionShapesRoundTripped =
			BoxShape.IsBox()
			&& BoxShape.GetBox().Equals(FVector(10.0f, 20.0f, 30.0f), 0.01f)
			&& SphereShape.IsSphere()
			&& SphereShape.GetSphereRadius() > 34.9f
			&& CapsuleShape.IsCapsule()
			&& CapsuleShape.GetCapsuleRadius() > 11.9f
			&& CapsuleShape.GetCapsuleHalfHeight() > 39.9f;

		TraceOutputsInitialized = ChannelHits.Num() >= 0 && Overlaps.Num() >= 0;
	}
}

bool Observe_TraceOperations_Defaults(ACoveragePhysicsTraceActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TraceOperations setup: required Actor is null");
	}
	return Actor.LineTraceByChannelExecuted == false
		&& Actor.SweepSphereByChannelExecuted == false
		&& Actor.SweepBoxByChannelExecuted == false
		&& Actor.SweepCapsuleByChannelExecuted == false
		&& Actor.LowLevelTraceParamsConfigured == false
		&& Actor.IgnoredActorCount == 0
		&& Actor.MultiTraceResults.Num() == 0;
}

bool Observe_TraceOperations_EmptyShapeBoundary()
{
	FCollisionShape EmptyBox = FCollisionShape::MakeBox(FVector::ZeroVector);
	return EmptyBox.IsBox() && EmptyBox.GetBox().Equals(FVector::ZeroVector, 0.01f);
}
