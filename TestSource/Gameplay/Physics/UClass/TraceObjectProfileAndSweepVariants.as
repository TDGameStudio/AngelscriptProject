/**
 * Object, profile, sweep, overlap and component-query variants. C++ verifies the
 * seven flags by path after BeginPlay, so those UPROPERTY names are part of the
 * contract and are kept verbatim. The observers cover the local-construct defaults
 * and empty hit/overlap arrays.
 *
 * @Theme Gameplay.Physics
 * @Subject Physics.TraceObjectProfileAndSweepVariants
 * @Harness UClass
 * @Tag Gameplay.Physics.TraceObjectProfileAndSweepVariants
 * @Provenance Theme: Gameplay.Physics. WorldStory object/profile/sweep/overlap/component query variants.
 * @Provenance C++: AngelscriptCoveragePhysicsTests.cpp::TraceObjectProfileAndSweepVariants
 * @Provenance Oracle VerifyByPath after BeginPlay: ObjectTraceCallsExecuted, ProfileTraceCallsExecuted,
 * @Provenance SweepSingleVariantsExecuted, SweepMultiCallsExecuted, OverlapMultiVariantsExecuted,
 * @Provenance OverlapTestCallsExecuted, ComponentQueryCallsExecuted all true.
 * @Provenance Extra: defaults false. FixtureIsolated. Keep UPROPERTY names.
 */

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

	/**
	 * WorldStory: BeginPlay dispatches object-type, profile, sweep, overlap-test,
	 * overlap-multi and component-query variants.
	 *
	 * @Kind WorldStory
	 * @Covers Physics.TraceObjectProfileAndSweepVariants
	 * @Inputs a default-attached USphereComponent
	 * @Return ObjectTraceCallsExecuted, ProfileTraceCallsExecuted, SweepSingleVariantsExecuted,
	 * SweepMultiCallsExecuted, OverlapMultiVariantsExecuted, OverlapTestCallsExecuted and
	 * ComponentQueryCallsExecuted true
	 */
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

	/**
	 * Observe that a locally constructed actor holds every flag false.
	 *
	 * @Kind Observe
	 * @Covers Physics.TraceObjectProfileAndSweepVariants
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when ObjectTraceCallsExecuted, ProfileTraceCallsExecuted,
	 * SweepMultiCallsExecuted, OverlapTestCallsExecuted, ComponentQueryCallsExecuted,
	 * SweepSingleVariantsExecuted and OverlapMultiVariantsExecuted are false
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		if (ObjectTraceCallsExecuted)
		{
			return false;
		}
		if (ProfileTraceCallsExecuted)
		{
			return false;
		}
		if (SweepMultiCallsExecuted)
		{
			return false;
		}
		if (OverlapTestCallsExecuted)
		{
			return false;
		}
		if (ComponentQueryCallsExecuted)
		{
			return false;
		}
		if (SweepSingleVariantsExecuted)
		{
			return false;
		}
		return OverlapMultiVariantsExecuted == false;
	}

	/**
	 * Observe that freshly declared hit and overlap arrays are empty.
	 *
	 * @Kind Observe
	 * @Covers Physics.TraceObjectProfileAndSweepVariants
	 * @Inputs newly declared hit and overlap arrays
	 * @Return true when both arrays have Num 0
	 * @Boundary empty arrays
	 */
	UFUNCTION()
	bool EmptyHitsBoundary()
	{
		TArray<FHitResult> Hits;
		TArray<FOverlapResult> Overlaps;

		if (Hits.Num() != 0)
		{
			return false;
		}
		return Overlaps.Num() == 0;
	}
}
