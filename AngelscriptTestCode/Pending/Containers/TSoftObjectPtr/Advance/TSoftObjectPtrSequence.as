/**
 * @version v1
 * @summary Composite positive: multi-step soft-pointer lifecycles that the single-API Function entries do not cover on their own — repeated assign/reset cycles, handing a path across UFUNCTION boundaries, and swapping a pending.
 * @topic Containers
 */
/**
 * @version root
 * @summary Composite positive: multi-step soft-pointer lifecycles that the single-API Function entries do not cover on their own — repeated assign/reset cycles, handing a path across UFUNCTION boundaries, and swapping a pending.
 * @topic Baseline
 */
UCLASS()
class UTSoftObjectPtrSequenceObject : UObject
{
}

namespace TSoftObjectPtrTest
{
	/**
	 * Repeated assign/reset cycles keep the pointer usable and the state correct.
	 *
	 * @Kind Observe
	 * @Covers TSoftObjectPtr.Reset
	 * @Inputs One pointer cycled through assign, reset, assign, reset, assign
	 * @Return true when the final state holds the first path again
	 */
	UFUNCTION()
	bool RepeatedAssignResetCyclesKeepStateCorrect()
	{
		FSoftObjectPath FirstPath("/Game/AngelscriptTest/PackageA.AssetA");
		FSoftObjectPath SecondPath("/Game/AngelscriptTest/PackageB.AssetB");

		TSoftObjectPtr<UObject> Soft;

		Soft = FirstPath;
		if (Soft.ToSoftObjectPath() != FirstPath)
		{
			return false;
		}

		Soft.Reset();
		if (!Soft.IsNull())
		{
			return false;
		}

		Soft = SecondPath;
		if (Soft.ToSoftObjectPath() != SecondPath)
		{
			return false;
		}

		Soft.Reset();
		if (!Soft.IsNull())
		{
			return false;
		}

		Soft = FirstPath;
		return Soft.ToSoftObjectPath() == FirstPath;
	}

	/**
	 * Swap a pending reference for a resolved one: the pointer moves from
	 * pending (path only) to valid (object loaded) without being reset first.
	 *
	 * @Kind Observe
	 * @Covers TSoftObjectPtr.opAssign
	 * @Inputs Pointer assigned an unloaded path; then assigned a live object
	 * @Return true when the pointer ends valid and resolves to that object
	 */
	UFUNCTION()
	bool PendingSwapsToResolvedWithoutReset()
	{
		TSoftObjectPtr<UObject> Soft;
		Soft = FSoftObjectPath("/Game/AngelscriptTest/NotLoaded.Never");
		if (!Soft.IsPending())
		{
			return false;
		}

		UObject Target = NewObject(GetTransientPackage(), UTSoftObjectPtrSequenceObject::StaticClass(), n"TSoftPtrSeq_Swap", true);
		if (Target == nullptr)
		{
			return false;
		}

		Soft = Target;
		return Soft.IsValid() && Soft.Get() == Target && !Soft.IsPending();
	}

	/**
	 * Hand a path across a UFUNCTION boundary and read it back on the
	 * receiving side without loading anything.
	 *
	 * @Kind RoundTrip
	 * @Covers TSoftObjectPtr.ToSoftObjectPath
	 * @Param Value Source pointer received as const TSoftObjectPtr<UObject>&in
	 * @Inputs Value was constructed from the canonical path
	 * @Return true when the path round-trips and the asset name matches
	 */
	UFUNCTION()
	bool ReadPathWithoutLoading(const TSoftObjectPtr<UObject>&in Value)
	{
		FSoftObjectPath Expected("/Game/AngelscriptTest/SomePackage.SomeAsset");
		return Value.ToSoftObjectPath() == Expected
			&& Value.GetAssetName() == "SomeAsset";
	}

	/**
	 * Out-only: publish a pending path through an &out pointer so the caller
	 * can request a load later.
	 *
	 * @Kind RoundTrip
	 * @Covers TSoftObjectPtr.opAssign
	 * @Param Result Destination received as TSoftObjectPtr<UObject>&out
	 * @Inputs Empty &out TSoftObjectPtr<UObject>
	 * @Return void; Result holds a pending path
	 */
	UFUNCTION()
	void PublishPendingPath(TSoftObjectPtr<UObject>&out Result)
	{
		Result = FSoftObjectPath("/Game/AngelscriptTest/NotLoaded.Never");
	}

	/**
	 * Inout: replace a live object reference with a plain path, moving the
	 * pointer back into the pending state.
	 *
	 * @Kind RoundTrip
	 * @Covers TSoftObjectPtr.opAssign
	 * @Param Value Pointer received as TSoftObjectPtr<UObject>&inout, starts valid
	 * @Inputs Value.IsValid() is true
	 * @Return void; Value holds a path and is no longer valid
	 */
	UFUNCTION()
	void ReplaceObjectWithPath(TSoftObjectPtr<UObject>&inout Value)
	{
		Value = FSoftObjectPath("/Game/AngelscriptTest/NotLoaded.Never");
	}
}
/** @end */
