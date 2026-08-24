// Theme: Gameplay.Physics. Value oracle: object-query init types and bitfield mutation.
// C++: AngelscriptCoveragePhysicsTests.cpp::CollisionObjectQueryInitTypes
// CSV NegativeDiagnostic; C++ compiles. Run() == 1; InitTypes/Channel/Manual/InvalidTrace flags true.
// Extra: defaults false. DefaultSafe. Keep UPROPERTY names.

UCLASS()
class UCoveragePhysicsObjectQueryHarness : UObject
{
	UPROPERTY()
	bool InitTypesRoundTripped = false;

	UPROPERTY()
	bool ChannelConstructorRoundTripped = false;

	UPROPERTY()
	bool ManualBitfieldRoundTripped = false;

	UPROPERTY()
	bool InvalidTraceChannelRejected = false;

	UFUNCTION()
	int Run()
	{
		FCollisionObjectQueryParams AllObjects(ECollisionObjectQueryInitType::AllObjects);
		FCollisionObjectQueryParams StaticObjects(ECollisionObjectQueryInitType::AllStaticObjects);
		FCollisionObjectQueryParams DynamicObjects(ECollisionObjectQueryInitType::AllDynamicObjects);
		InitTypesRoundTripped =
			AllObjects.IsValid()
			&& StaticObjects.IsValid()
			&& DynamicObjects.IsValid()
			&& AllObjects.GetQueryBitfield64() != 0
			&& StaticObjects.GetQueryBitfield64() != 0
			&& DynamicObjects.GetQueryBitfield64() != 0;

		ChannelConstructorRoundTripped =
			FCollisionObjectQueryParams::IsValidObjectQuery(ECollisionChannel::ECC_PhysicsBody)
			&& FCollisionObjectQueryParams::IsValidObjectQuery(ECollisionChannel::ECC_Pawn);

		FCollisionObjectQueryParams ManualObjects;
		ManualObjects.AddObjectTypesToQuery(ECollisionChannel::ECC_WorldStatic);
		ManualObjects.AddObjectTypesToQuery(ECollisionChannel::ECC_WorldDynamic);
		ManualObjects.AddObjectTypesToQuery(ECollisionChannel::ECC_PhysicsBody);
		int64 SnapshotBitfield = ManualObjects.GetObjectTypesToQuery();
		ManualObjects.RemoveObjectTypesToQuery(ECollisionChannel::ECC_PhysicsBody);
		ManualObjects.SetObjectTypesToQuery(SnapshotBitfield);
		ManualObjects.IgnoreMask = 7;
		ManualBitfieldRoundTripped =
			ManualObjects.IsValid()
			&& ManualObjects.GetObjectTypesToQuery() == SnapshotBitfield
			&& ManualObjects.GetQueryBitfield64() != 0
			&& ManualObjects.IgnoreMask == 7;

		InvalidTraceChannelRejected =
			!FCollisionObjectQueryParams::IsValidObjectQuery(ECollisionChannel::ECC_Visibility)
			&& !FCollisionObjectQueryParams::IsValidObjectQuery(ECollisionChannel::ECC_Camera);

		return InitTypesRoundTripped
			&& ChannelConstructorRoundTripped
			&& ManualBitfieldRoundTripped
			&& InvalidTraceChannelRejected ? 1 : 0;
	}
}

bool Observe_ObjectQueryInitTypes_Nominal(UCoveragePhysicsObjectQueryHarness Harness)
{
	if (Harness is null)
	{
		throw("Test_CollisionObjectQueryInitTypes setup: required Harness is null");
	}
	return Harness.Run() == 1;
}

bool Observe_ObjectQueryInitTypes_Defaults(UCoveragePhysicsObjectQueryHarness Harness)
{
	if (Harness is null)
	{
		throw("Test_CollisionObjectQueryInitTypes setup: required Harness is null");
	}
	return Harness.InitTypesRoundTripped == false
		&& Harness.ChannelConstructorRoundTripped == false
		&& Harness.ManualBitfieldRoundTripped == false
		&& Harness.InvalidTraceChannelRejected == false;
}

bool Observe_ObjectQueryInitTypes_EmptyManualBoundary()
{
	FCollisionObjectQueryParams ManualObjects;
	return ManualObjects.IgnoreMask == 0;
}
