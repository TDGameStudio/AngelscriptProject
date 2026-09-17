/**
 * @version v1
 * @summary Observe asynchronous line, sweep, and overlap queries returning frame-scoped FTraceHandle values, including default-argument omission.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe asynchronous line, sweep, and overlap queries returning frame-scoped FTraceHandle values, including default-argument omission.
 * @topic Baseline
 */
// Runner supplies Start/End and bExpectHit so queued vs rejected handles are
// exact, not "either outcome".
// AS-facing API: FTraceHandle System::AsyncLineTraceByChannel(...);
// FTraceHandle System::AsyncLineTraceByObjectType(...);
// FTraceHandle System::AsyncLineTraceByProfile(...);
// FTraceHandle System::AsyncSweepByChannel(...);
// FTraceHandle System::AsyncSweepByObjectType(...);
// FTraceHandle System::AsyncSweepByProfile(...);
// FTraceHandle System::AsyncOverlapByChannel(...);
// FTraceHandle System::AsyncOverlapByObjectType(...);
// FTraceHandle System::AsyncOverlapByProfile(...);
// Inputs: Runner-owned Start/End, FQuat::Identity, ECollisionChannel::WorldStatic,
// MakeSphere(16), n"BlockAll", empty FScriptTraceDelegate/FScriptOverlapDelegate,
// UserData 0 and 7, and bExpectHit.
// Expected observations: Each call returns a handle whose IsValid matches
// bExpectHit. Default params/response/delegate/UserData overloads are issued.
// Boundary/ownership: Handles are frame-scoped. Delegates are copied, not owned
// by the caller after queueing. FixtureIsolated. SetupOwner=Runner.

namespace TS_WorldCollision_ConversionAndFormatting_01
{
	bool Observe_AsyncLineTraceByChannel_Nominal(const FVector& Start, const FVector& End, bool bExpectHit)
	{
		FScriptTraceDelegate Delegate;
		FTraceHandle Defaulted = System::AsyncLineTraceByChannel(EAsyncTraceType::Test, Start, End, ECollisionChannel::WorldStatic);
		FTraceHandle Explicit = System::AsyncLineTraceByChannel(
			EAsyncTraceType::Single,
			Start,
			End,
			ECollisionChannel::Visibility,
			FCollisionQueryParams::DefaultQueryParam,
			FCollisionResponseParams::DefaultResponseParam,
			Delegate,
			7);
		return Defaulted.IsValid() == bExpectHit && Explicit.IsValid() == bExpectHit;
	}

	bool Observe_AsyncLineTraceByObjectType_Nominal(const FVector& Start, const FVector& End, bool bExpectHit)
	{
		FCollisionObjectQueryParams ObjectQueryParams(ECollisionChannel::WorldStatic);
		FScriptTraceDelegate Delegate;
		FTraceHandle Defaulted = System::AsyncLineTraceByObjectType(EAsyncTraceType::Multi, Start, End, ObjectQueryParams);
		FTraceHandle Explicit = System::AsyncLineTraceByObjectType(
			EAsyncTraceType::Single,
			Start,
			End,
			ObjectQueryParams,
			FCollisionQueryParams::DefaultQueryParam,
			Delegate,
			7);
		return Defaulted.IsValid() == bExpectHit && Explicit.IsValid() == bExpectHit;
	}

	bool Observe_AsyncLineTraceByProfile_Nominal(const FVector& Start, const FVector& End, bool bExpectHit)
	{
		FName ProfileName = n"BlockAll";
		FScriptTraceDelegate Delegate;
		FTraceHandle Defaulted = System::AsyncLineTraceByProfile(EAsyncTraceType::Test, Start, End, ProfileName);
		FTraceHandle Explicit = System::AsyncLineTraceByProfile(
			EAsyncTraceType::Single,
			Start,
			End,
			ProfileName,
			FCollisionQueryParams::DefaultQueryParam,
			Delegate,
			7);
		return Defaulted.IsValid() == bExpectHit && Explicit.IsValid() == bExpectHit;
	}

	bool Observe_AsyncSweepByChannel_Nominal(const FVector& Start, const FVector& End, bool bExpectHit)
	{
		FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
		FScriptTraceDelegate Delegate;
		FTraceHandle Defaulted = System::AsyncSweepByChannel(
			EAsyncTraceType::Test,
			Start,
			End,
			FQuat::Identity,
			ECollisionChannel::WorldStatic,
			Sphere);
		FTraceHandle Explicit = System::AsyncSweepByChannel(
			EAsyncTraceType::Single,
			Start,
			End,
			FQuat::Identity,
			ECollisionChannel::WorldDynamic,
			Sphere,
			FCollisionQueryParams::DefaultQueryParam,
			FCollisionResponseParams::DefaultResponseParam,
			Delegate,
			7);
		return Defaulted.IsValid() == bExpectHit && Explicit.IsValid() == bExpectHit;
	}

	bool Observe_AsyncSweepByObjectType_Nominal(const FVector& Start, const FVector& End, bool bExpectHit)
	{
		FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
		FCollisionObjectQueryParams ObjectQueryParams(ECollisionChannel::WorldStatic);
		FScriptTraceDelegate Delegate;
		FTraceHandle Defaulted = System::AsyncSweepByObjectType(
			EAsyncTraceType::Multi,
			Start,
			End,
			FQuat::Identity,
			ObjectQueryParams,
			Sphere);
		FTraceHandle Explicit = System::AsyncSweepByObjectType(
			EAsyncTraceType::Single,
			Start,
			End,
			FQuat::Identity,
			ObjectQueryParams,
			Sphere,
			FCollisionQueryParams::DefaultQueryParam,
			Delegate,
			7);
		return Defaulted.IsValid() == bExpectHit && Explicit.IsValid() == bExpectHit;
	}

	bool Observe_AsyncSweepByProfile_Nominal(const FVector& Start, const FVector& End, bool bExpectHit)
	{
		FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
		FName ProfileName = n"BlockAll";
		FScriptTraceDelegate Delegate;
		FTraceHandle Defaulted = System::AsyncSweepByProfile(
			EAsyncTraceType::Test,
			Start,
			End,
			FQuat::Identity,
			ProfileName,
			Sphere);
		FTraceHandle Explicit = System::AsyncSweepByProfile(
			EAsyncTraceType::Single,
			Start,
			End,
			FQuat::Identity,
			ProfileName,
			Sphere,
			FCollisionQueryParams::DefaultQueryParam,
			Delegate,
			7);
		return Defaulted.IsValid() == bExpectHit && Explicit.IsValid() == bExpectHit;
	}

	bool Observe_AsyncOverlapByChannel_Nominal(const FVector& Start, const FVector& End, bool bExpectHit)
	{
		FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
		FScriptOverlapDelegate Delegate;
		FTraceHandle Defaulted = System::AsyncOverlapByChannel(Start, FQuat::Identity, ECollisionChannel::WorldStatic, Sphere);
		FTraceHandle Explicit = System::AsyncOverlapByChannel(
			Start,
			FQuat::Identity,
			ECollisionChannel::Visibility,
			Sphere,
			FCollisionQueryParams::DefaultQueryParam,
			FCollisionResponseParams::DefaultResponseParam,
			Delegate,
			7);
		return Defaulted.IsValid() == bExpectHit && Explicit.IsValid() == bExpectHit;
	}

	bool Observe_AsyncOverlapByObjectType_Nominal(const FVector& Start, const FVector& End, bool bExpectHit)
	{
		FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
		FCollisionObjectQueryParams ObjectQueryParams(ECollisionChannel::WorldStatic);
		FScriptOverlapDelegate Delegate;
		FTraceHandle Defaulted = System::AsyncOverlapByObjectType(Start, FQuat::Identity, ObjectQueryParams, Sphere);
		FTraceHandle Explicit = System::AsyncOverlapByObjectType(
			Start,
			FQuat::Identity,
			ObjectQueryParams,
			Sphere,
			FCollisionQueryParams::DefaultQueryParam,
			Delegate,
			7);
		return Defaulted.IsValid() == bExpectHit && Explicit.IsValid() == bExpectHit;
	}

	bool Observe_AsyncOverlapByProfile_Nominal(const FVector& Start, const FVector& End, bool bExpectHit)
	{
		FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
		FName ProfileName = n"BlockAll";
		FScriptOverlapDelegate Delegate;
		FTraceHandle Defaulted = System::AsyncOverlapByProfile(Start, FQuat::Identity, ProfileName, Sphere);
		FTraceHandle Explicit = System::AsyncOverlapByProfile(
			Start,
			FQuat::Identity,
			ProfileName,
			Sphere,
			FCollisionQueryParams::DefaultQueryParam,
			Delegate,
			7);
		return Defaulted.IsValid() == bExpectHit && Explicit.IsValid() == bExpectHit;
	}
}
/** @end */
