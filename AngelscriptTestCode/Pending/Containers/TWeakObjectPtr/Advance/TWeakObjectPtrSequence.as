/**
 * @version v1
 * @summary Composite positive: multi-step weak-pointer lifecycles that the single-API Function entries do not cover on their own — repeated assign/clear cycles, handing a pointer across UFUNCTION boundaries, and using one pointer.
 * @topic Containers
 */
/**
 * @version root
 * @summary Composite positive: multi-step weak-pointer lifecycles that the single-API Function entries do not cover on their own — repeated assign/clear cycles, handing a pointer across UFUNCTION boundaries, and using one pointer.
 * @topic Baseline
 */
UCLASS()
class UTWeakObjectPtrSequenceObject : UObject
{
}

namespace TWeakObjectPtrTest
{
	/**
	 * Repeated assign/clear cycles keep the pointer usable and the state correct.
	 *
	 * @Kind Observe
	 * @Covers TWeakObjectPtr.opAssign
	 * @Inputs One pointer cycled through assign, clear, assign, clear, assign
	 * @Return true when the final state is valid and holds the third object
	 */
	UFUNCTION()
	bool RepeatedAssignClearCyclesKeepStateCorrect()
	{
		UObject First = NewObject(GetTransientPackage(), UTWeakObjectPtrSequenceObject::StaticClass(), n"TWeakObjSeq_0", true);
		UObject Second = NewObject(GetTransientPackage(), UTWeakObjectPtrSequenceObject::StaticClass(), n"TWeakObjSeq_1", true);
		UObject Third = NewObject(GetTransientPackage(), UTWeakObjectPtrSequenceObject::StaticClass(), n"TWeakObjSeq_2", true);
		if (First == nullptr || Second == nullptr || Third == nullptr)
		{
			return false;
		}

		TWeakObjectPtr<UObject> Weak;

		Weak = First;
		if (!Weak.IsValid() || Weak.Get() != First)
		{
			return false;
		}

		Weak = nullptr;
		if (Weak.IsValid() || !Weak.IsExplicitlyNull())
		{
			return false;
		}

		Weak = Second;
		if (!Weak.IsValid() || Weak.Get() != Second)
		{
			return false;
		}

		Weak = nullptr;
		if (Weak.IsValid())
		{
			return false;
		}

		Weak = Third;
		return Weak.IsValid() && Weak.Get() == Third;
	}

	/**
	 * "Current target" slot: reassigning replaces the previous target without
	 * needing an explicit clear first, and the pointer stays valid throughout.
	 *
	 * @Kind Observe
	 * @Covers TWeakObjectPtr.opAssign
	 * @Inputs One pointer assigned First, then Second, then Third
	 * @Return true when only the last target remains
	 */
	UFUNCTION()
	bool LatestAssignWins()
	{
		UObject First = NewObject(GetTransientPackage(), UTWeakObjectPtrSequenceObject::StaticClass(), n"TWeakObjSeq_Slot0", true);
		UObject Second = NewObject(GetTransientPackage(), UTWeakObjectPtrSequenceObject::StaticClass(), n"TWeakObjSeq_Slot1", true);
		UObject Third = NewObject(GetTransientPackage(), UTWeakObjectPtrSequenceObject::StaticClass(), n"TWeakObjSeq_Slot2", true);
		if (First == nullptr || Second == nullptr || Third == nullptr)
		{
			return false;
		}

		TWeakObjectPtr<UObject> Weak;
		Weak = First;
		Weak = Second;
		Weak = Third;
		return Weak.IsValid() && Weak.Get() == Third && Weak.Get() != First;
	}

	/**
	 * Hand a pointer across a UFUNCTION boundary and compare it back against
	 * the original object, exercising implicit conversion on the receiving side.
	 *
	 * @Kind RoundTrip
	 * @Covers TWeakObjectPtr.opImplConv
	 * @Param Value Pointer received as const TWeakObjectPtr<UObject>&in
	 * @Inputs Value holds a live object
	 * @Return true when the pointer is valid and resolves to a non-null object
	 */
	UFUNCTION()
	bool ReadAndConvertBack(const TWeakObjectPtr<UObject>&in Value)
	{
		if (!Value.IsValid())
		{
			return false;
		}

		UObject Resolved = Value;
		return Resolved != nullptr;
	}

	/**
	 * Out-only: publish a freshly created object through an &out pointer so
	 * the caller holds a weak handle to it.
	 *
	 * @Kind RoundTrip
	 * @Covers TWeakObjectPtr.opAssign
	 * @Param Result Destination received as TWeakObjectPtr<UObject>&out
	 * @Inputs Empty &out TWeakObjectPtr<UObject>
	 * @Return void; Result holds a live object
	 */
	UFUNCTION()
	void PublishNewObject(TWeakObjectPtr<UObject>&out Result)
	{
		Result = NewObject(GetTransientPackage(), UTWeakObjectPtrSequenceObject::StaticClass(), n"TWeakObjSeq_Publish", true);
	}

	/**
	 * Inout: clear a published pointer, returning it to the explicitly-null state.
	 *
	 * @Kind RoundTrip
	 * @Covers TWeakObjectPtr.IsExplicitlyNull
	 * @Param Value Pointer received as TWeakObjectPtr<UObject>&inout, starts valid
	 * @Inputs Value.IsValid() is true
	 * @Return void; Value is explicitly null
	 */
	UFUNCTION()
	void WithdrawPublishedObject(TWeakObjectPtr<UObject>&inout Value)
	{
		Value = nullptr;
	}
}
/** @end */
