/**
 * @version v1
 * @summary Composite positive: multi-step object-pointer lifecycles that the single-API Function entries do not cover on their own — repeated assign/clear cycles, handing a pointer across UFUNCTION boundaries, and using one pointer.
 * @topic Containers
 */
/**
 * @version root
 * @summary Composite positive: multi-step object-pointer lifecycles that the single-API Function entries do not cover on their own — repeated assign/clear cycles, handing a pointer across UFUNCTION boundaries, and using one pointer.
 * @topic Baseline
 */
UCLASS()
class UTObjectPtrSequenceObject : UObject
{
}

namespace TObjectPtrTest
{
	/**
	 * Repeated assign/clear cycles keep the pointer usable and the state correct.
	 *
	 * @Kind Observe
	 * @Covers TObjectPtr.opAssign
	 * @Inputs One pointer cycled through assign, clear, assign, clear, assign
	 * @Return true when the final state holds the third object
	 */
	UFUNCTION()
	bool RepeatedAssignClearCyclesKeepStateCorrect()
	{
		UObject First = NewObject(GetTransientPackage(), UTObjectPtrSequenceObject::StaticClass(), n"TObjPtrSeq_0", true);
		UObject Second = NewObject(GetTransientPackage(), UTObjectPtrSequenceObject::StaticClass(), n"TObjPtrSeq_1", true);
		UObject Third = NewObject(GetTransientPackage(), UTObjectPtrSequenceObject::StaticClass(), n"TObjPtrSeq_2", true);
		if (First == nullptr || Second == nullptr || Third == nullptr)
		{
			return false;
		}

		TObjectPtr<UObject> Ptr;

		Ptr = First;
		if (Ptr.Get() != First)
		{
			return false;
		}

		Ptr = nullptr;
		if (Ptr.Get() != nullptr)
		{
			return false;
		}

		Ptr = Second;
		if (Ptr.Get() != Second)
		{
			return false;
		}

		Ptr = nullptr;
		if (Ptr.Get() != nullptr)
		{
			return false;
		}

		Ptr = Third;
		return Ptr.Get() == Third;
	}

	/**
	 * "Current target" slot: reassigning replaces the previous target without
	 * needing an explicit clear first.
	 *
	 * @Kind Observe
	 * @Covers TObjectPtr.opAssign
	 * @Inputs One pointer assigned First, then Second, then Third
	 * @Return true when only the last target remains
	 */
	UFUNCTION()
	bool LatestAssignWins()
	{
		UObject First = NewObject(GetTransientPackage(), UTObjectPtrSequenceObject::StaticClass(), n"TObjPtrSeq_Slot0", true);
		UObject Second = NewObject(GetTransientPackage(), UTObjectPtrSequenceObject::StaticClass(), n"TObjPtrSeq_Slot1", true);
		UObject Third = NewObject(GetTransientPackage(), UTObjectPtrSequenceObject::StaticClass(), n"TObjPtrSeq_Slot2", true);
		if (First == nullptr || Second == nullptr || Third == nullptr)
		{
			return false;
		}

		TObjectPtr<UObject> Ptr;
		Ptr = First;
		Ptr = Second;
		Ptr = Third;
		return Ptr.Get() == Third && Ptr.Get() != First;
	}

	/**
	 * Hand a pointer across a UFUNCTION boundary and resolve it back to the
	 * raw object handle on the receiving side.
	 *
	 * @Kind RoundTrip
	 * @Covers TObjectPtr.opImplConv
	 * @Param Value Pointer received as const TObjectPtr<UObject>&in
	 * @Inputs Value holds a live object
	 * @Return true when the pointer resolves to a non-null object
	 */
	UFUNCTION()
	bool ReadAndConvertBack(const TObjectPtr<UObject>&in Value)
	{
		UObject Resolved = Value;
		return Resolved != nullptr;
	}

	/**
	 * Out-only: publish a freshly created object through an &out pointer.
	 *
	 * @Kind RoundTrip
	 * @Covers TObjectPtr.opAssign
	 * @Param Result Destination received as TObjectPtr<UObject>&out
	 * @Inputs Empty &out TObjectPtr<UObject>
	 * @Return void; Result holds a live object
	 */
	UFUNCTION()
	void PublishNewObject(TObjectPtr<UObject>&out Result)
	{
		Result = NewObject(GetTransientPackage(), UTObjectPtrSequenceObject::StaticClass(), n"TObjPtrSeq_Publish", true);
	}

	/**
	 * Inout: clear a published pointer, returning it to null.
	 *
	 * @Kind RoundTrip
	 * @Covers TObjectPtr.opAssign
	 * @Param Value Pointer received as TObjectPtr<UObject>&inout, starts set
	 * @Inputs Value holds a live object
	 * @Return void; Value is null
	 */
	UFUNCTION()
	void WithdrawPublishedObject(TObjectPtr<UObject>&inout Value)
	{
		Value = nullptr;
	}
}
/** @end */
