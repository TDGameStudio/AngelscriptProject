/**
 * @version v1
 * @summary Object-query init types, channel constructors, manual bitfield mutation and invalid trace-channel rejection. C++ compiles this harness and treats Run() == 1 as the oracle, so the UCLASS, UFUNCTION and UPROPERTY names are.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary Object-query init types, channel constructors, manual bitfield mutation and invalid trace-channel rejection. C++ compiles this harness and treats Run() == 1 as the oracle, so the UCLASS, UFUNCTION and UPROPERTY names are.
 * @topic Baseline
 */
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

	/**
	 * Walk All/Static/Dynamic init types, valid object-query channels, a manual
	 * bitfield round-trip and invalid trace-channel rejection.
	 *
	 * @Kind Action
	 * @Covers Physics.CollisionObjectQueryInitTypes
	 * @Inputs none
	 * @Return 1 when InitTypesRoundTripped, ChannelConstructorRoundTripped,
	 * ManualBitfieldRoundTripped and InvalidTraceChannelRejected are true, otherwise 0
	 */
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

		if (!InitTypesRoundTripped)
		{
			return 0;
		}
		if (!ChannelConstructorRoundTripped)
		{
			return 0;
		}
		if (!ManualBitfieldRoundTripped)
		{
			return 0;
		}
		if (!InvalidTraceChannelRejected)
		{
			return 0;
		}
		return 1;
	}

	/**
	 * Observe that Run returns 1 after the four flags are written.
	 *
	 * @Kind Observe
	 * @Covers Physics.CollisionObjectQueryInitTypes
	 * @Inputs none
	 * @Return true when Run returns 1
	 */
	UFUNCTION()
	bool RunReturnsOne()
	{
		return Run() == 1;
	}

	/**
	 * Observe that an untouched harness holds every flag false.
	 *
	 * @Kind Observe
	 * @Covers Physics.CollisionObjectQueryInitTypes
	 * @Inputs a harness that has not run
	 * @Return true when InitTypesRoundTripped, ChannelConstructorRoundTripped,
	 * ManualBitfieldRoundTripped and InvalidTraceChannelRejected are false
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		if (InitTypesRoundTripped)
		{
			return false;
		}
		if (ChannelConstructorRoundTripped)
		{
			return false;
		}
		if (ManualBitfieldRoundTripped)
		{
			return false;
		}
		return InvalidTraceChannelRejected == false;
	}

	/**
	 * Observe that a default manual object-query params value has IgnoreMask 0.
	 *
	 * @Kind Observe
	 * @Covers Physics.CollisionObjectQueryInitTypes
	 * @Inputs a default-constructed FCollisionObjectQueryParams
	 * @Return true when IgnoreMask is 0
	 * @Boundary empty manual query
	 */
	UFUNCTION()
	bool EmptyManualBoundary()
	{
		FCollisionObjectQueryParams ManualObjects;
		return ManualObjects.IgnoreMask == 0;
	}
}
/** @end */
