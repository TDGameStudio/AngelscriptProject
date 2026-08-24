// Theme: Gameplay.Physics. WorldStory object/profile/sweep/overlap/component query variants.
// C++: AngelscriptCoveragePhysicsTests.cpp::TraceObjectProfileAndSweepVariants
// Oracle VerifyByPath after BeginPlay: ObjectTraceCallsExecuted, ProfileTraceCallsExecuted,
// SweepSingleVariantsExecuted, SweepMultiCallsExecuted, OverlapMultiVariantsExecuted,
// OverlapTestCallsExecuted, ComponentQueryCallsExecuted all true.
// Extra: defaults false. FixtureIsolated. Keep UPROPERTY names.

UCLASS()
class ACoveragePhysicsTraceVariantActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent Sphere;

	UPROPERTY()
	bool ObjectTraceCallsExecuted = false;

	UPROPERTY()
	bool ProfileTraceCallsExecuted = false;

	UPROPERTY()
	bool SweepMultiCallsExecuted = false;

	UPROPERTY()
	bool OverlapTestCallsExecuted = false;

	UPROPERTY()
	bool ComponentQueryCallsExecuted = false;

	UPROPERTY()
	bool SweepSingleVariantsExecuted = false;

	UPROPERTY()
	bool OverlapMultiVariantsExecuted = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FVector Start = GetActorLocation();
		FVector End = Start + FVector(10.0f, 0.0f, 0.0f);
		FCollisionQueryParams QueryParams(n"CoverageTraceVariant", false, this);
		QueryParams.AddIgnoredActor(this);
		FCollisionShape SphereShape = FCollisionShape::MakeSphere(8.0f);
		FCollisionObjectQueryParams ObjectQueryParams;
		ObjectQueryParams.AddObjectTypesToQuery(ECollisionChannel::ECC_WorldDynamic);

		FHitResult Hit;
		TArray<FHitResult> Hits;
		TArray<FOverlapResult> Overlaps;

		System::LineTraceTestByObjectType(Start, End, ObjectQueryParams, QueryParams);
		System::LineTraceSingleByObjectType(Hit, Start, End, ObjectQueryParams, QueryParams);
		System::LineTraceMultiByObjectType(Hits, Start, End, ObjectQueryParams, QueryParams);
		ObjectTraceCallsExecuted = ObjectQueryParams.IsValid();

		System::LineTraceTestByProfile(Start, End, n"BlockAll", QueryParams);
		System::LineTraceSingleByProfile(Hit, Start, End, n"BlockAll", QueryParams);
		System::LineTraceMultiByProfile(Hits, Start, End, n"BlockAll", QueryParams);
		System::SweepSingleByProfile(Hit, Start, End, FQuat::Identity, n"BlockAll", SphereShape, QueryParams);
		System::SweepMultiByProfile(Hits, Start, End, FQuat::Identity, n"BlockAll", SphereShape, QueryParams);
		System::OverlapMultiByProfile(Overlaps, Start, FQuat::Identity, n"OverlapAll", SphereShape, QueryParams);
		ProfileTraceCallsExecuted = true;

		System::SweepTestByChannel(Start, End, FQuat::Identity, ECollisionChannel::ECC_Visibility, SphereShape, QueryParams);
		System::SweepTestByObjectType(Start, End, FQuat::Identity, ObjectQueryParams, SphereShape, QueryParams);
		System::SweepSingleByChannel(Hit, Start, End, FQuat::Identity, ECollisionChannel::ECC_Visibility, SphereShape, QueryParams);
		System::SweepSingleByObjectType(Hit, Start, End, FQuat::Identity, ObjectQueryParams, SphereShape, QueryParams);
		System::SweepSingleByProfile(Hit, Start, End, FQuat::Identity, n"BlockAll", SphereShape, QueryParams);
		System::SweepMultiByChannel(Hits, Start, End, FQuat::Identity, ECollisionChannel::ECC_Visibility, SphereShape, QueryParams);
		System::SweepMultiByObjectType(Hits, Start, End, FQuat::Identity, ObjectQueryParams, SphereShape, QueryParams);
		System::SweepMultiByProfile(Hits, Start, End, FQuat::Identity, n"BlockAll", SphereShape, QueryParams);
		SweepSingleVariantsExecuted = true;
		SweepMultiCallsExecuted = true;

		System::OverlapBlockingTestByChannel(Start, FQuat::Identity, ECollisionChannel::ECC_Visibility, SphereShape, QueryParams);
		System::OverlapAnyTestByChannel(Start, FQuat::Identity, ECollisionChannel::ECC_Visibility, SphereShape, QueryParams);
		System::OverlapAnyTestByObjectType(Start, FQuat::Identity, ObjectQueryParams, SphereShape, QueryParams);
		System::OverlapBlockingTestByProfile(Start, FQuat::Identity, n"BlockAll", SphereShape, QueryParams);
		System::OverlapAnyTestByProfile(Start, FQuat::Identity, n"OverlapAll", SphereShape, QueryParams);
		System::OverlapMultiByChannel(Overlaps, Start, FQuat::Identity, ECollisionChannel::ECC_Visibility, SphereShape, QueryParams);
		System::OverlapMultiByObjectType(Overlaps, Start, FQuat::Identity, ObjectQueryParams, SphereShape, QueryParams);
		System::OverlapMultiByProfile(Overlaps, Start, FQuat::Identity, n"OverlapAll", SphereShape, QueryParams);
		OverlapMultiVariantsExecuted = true;
		OverlapTestCallsExecuted = true;

		FComponentQueryParams ComponentQueryParams(n"CoverageComponentTraceVariant", this, FCollisionEnabledMask(ECollisionEnabled::QueryOnly));
		System::ComponentSweepMulti(Hits, Sphere, Start, End, FQuat::Identity, ComponentQueryParams);
		System::ComponentSweepMultiByChannel(Hits, Sphere, Start, End, FQuat::Identity, ECollisionChannel::ECC_Visibility, ComponentQueryParams);
		System::ComponentOverlapMulti(Overlaps, Sphere, Start, FQuat::Identity, ComponentQueryParams, ObjectQueryParams);
		System::ComponentOverlapMultiByChannel(Overlaps, Sphere, Start, FQuat::Identity, ECollisionChannel::ECC_Visibility, ComponentQueryParams, ObjectQueryParams);
		ComponentQueryCallsExecuted = true;
	}
}

bool Observe_TraceVariants_Defaults(ACoveragePhysicsTraceVariantActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TraceObjectProfileAndSweepVariants setup: required Actor is null");
	}
	return Actor.ObjectTraceCallsExecuted == false
		&& Actor.ProfileTraceCallsExecuted == false
		&& Actor.SweepMultiCallsExecuted == false
		&& Actor.OverlapTestCallsExecuted == false
		&& Actor.ComponentQueryCallsExecuted == false
		&& Actor.SweepSingleVariantsExecuted == false
		&& Actor.OverlapMultiVariantsExecuted == false;
}

bool Observe_TraceVariants_EmptyHitsBoundary()
{
	TArray<FHitResult> Hits;
	TArray<FOverlapResult> Overlaps;
	return Hits.Num() == 0 && Overlaps.Num() == 0;
}
