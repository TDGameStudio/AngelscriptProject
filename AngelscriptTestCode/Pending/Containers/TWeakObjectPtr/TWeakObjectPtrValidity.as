/**
 * @version v1
 * @summary TWeakObjectPtr.IsValid / IsStale / IsExplicitlyNull are three independent axes of one state, not three spellings of the same question. Valid means a live target; stale means a target that was set and then went away.
 * @topic Containers
 */
/**
 * @version root
 * @summary TWeakObjectPtr.IsValid / IsStale / IsExplicitlyNull are three independent axes of one state, not three spellings of the same question. Valid means a live target; stale means a target that was set and then went away.
 * @topic Baseline
 */
UCLASS()
class UTWeakObjectPtrValidityObject : UObject
{
}

namespace TWeakObjectPtrTest
{
	/**
	 * Observe the state of a pointer holding a live object: valid, not stale,
	 * and not explicitly null.
	 *
	 * @Kind Observe
	 * @Covers TWeakObjectPtr.IsValid
	 * @Inputs Default-constructed pointer; assign a live object
	 * @Return true when IsValid() is true, IsStale() is false, IsExplicitlyNull() is false
	 */
	UFUNCTION()
	bool LiveTargetIsValidNotStale()
	{
		UObject Target = NewObject(GetTransientPackage(), UTWeakObjectPtrValidityObject::StaticClass(), n"TWeakObjValid_Live", true);
		if (Target == nullptr)
		{
			return false;
		}

		TWeakObjectPtr<UObject> Weak;
		Weak = Target;
		return Weak.IsValid()
			&& !Weak.IsStale()
			&& !Weak.IsExplicitlyNull();
	}

	/**
	 * Observe that a pointer set to nullptr is explicitly null rather than stale.
	 *
	 * @Kind Observe
	 * @Covers TWeakObjectPtr.opAssign
	 * @Inputs Default-constructed pointer; assign nullptr
	 * @Return true when IsValid() is false and IsExplicitlyNull() is true
	 */
	UFUNCTION()
	bool AssigningNullptrIsExplicitlyNull()
	{
		TWeakObjectPtr<UObject> Weak;
		Weak = nullptr;
		return !Weak.IsValid() && Weak.IsExplicitlyNull();
	}

	/**
	 * Observe that assigning nullptr over a live target clears validity and
	 * returns the pointer to the explicitly-null state.
	 *
	 * @Kind Observe
	 * @Covers TWeakObjectPtr.opAssign
	 * @Inputs Pointer set to a live object; assign nullptr
	 * @Return true when IsValid() is false, Get() is null, and IsExplicitlyNull() is true
	 */
	UFUNCTION()
	bool ClearingLiveTargetReturnsToExplicitNull()
	{
		UObject Target = NewObject(GetTransientPackage(), UTWeakObjectPtrValidityObject::StaticClass(), n"TWeakObjValid_Clear", true);
		if (Target == nullptr)
		{
			return false;
		}

		TWeakObjectPtr<UObject> Weak;
		Weak = Target;
		if (!Weak.IsValid())
		{
			return false;
		}

		Weak = nullptr;
		return !Weak.IsValid()
			&& Weak.Get() == nullptr
			&& Weak.IsExplicitlyNull();
	}

	/**
	 * Observe that two pointers to the same object are equal, and that
	 * clearing one leaves the other valid.
	 *
	 * @Kind Observe
	 * @Covers TWeakObjectPtr.opEquals
	 * @Inputs Two pointers set to the same object; then clear the second
	 * @Return true when they were equal and the first survives clearing the second
	 */
	UFUNCTION()
	bool PointersToSameTargetAreEqualAndIndependent()
	{
		UObject Target = NewObject(GetTransientPackage(), UTWeakObjectPtrValidityObject::StaticClass(), n"TWeakObjValid_Shared", true);
		if (Target == nullptr)
		{
			return false;
		}

		TWeakObjectPtr<UObject> First;
		TWeakObjectPtr<UObject> Second;
		First = Target;
		Second = Target;
		if (First != Second)
		{
			return false;
		}

		Second = nullptr;
		return First.IsValid() && !Second.IsValid() && First != Second;
	}

	/**
	 * In-only: read validity out of a const&in TWeakObjectPtr<UObject>.
	 *
	 * @Kind RoundTrip
	 * @Covers TWeakObjectPtr.IsValid
	 * @Param Value Source pointer received as const TWeakObjectPtr<UObject>&in
	 * @Inputs Value holds a live object
	 * @Return true when IsValid() is true and IsStale() is false
	 */
	UFUNCTION()
	bool ReadValidity(const TWeakObjectPtr<UObject>&in Value)
	{
		return Value.IsValid() && !Value.IsStale();
	}

	/**
	 * Out-only: fill an &out pointer and then clear it, leaving it explicitly null.
	 *
	 * @Kind RoundTrip
	 * @Covers TWeakObjectPtr.IsValid
	 * @Param Result Destination received as TWeakObjectPtr<UObject>&out
	 * @Inputs Empty &out TWeakObjectPtr<UObject>
	 * @Return void; Result is valid and then cleared back to explicitly null
	 */
	UFUNCTION()
	void FillThenClear(TWeakObjectPtr<UObject>&out Result)
	{
		Result = NewObject(GetTransientPackage(), UTWeakObjectPtrValidityObject::StaticClass(), n"TWeakObjValid_FillClear", true);
		Result = nullptr;
	}

	/**
	 * Inout: clear an already-valid TWeakObjectPtr<UObject>.
	 *
	 * @Kind RoundTrip
	 * @Covers TWeakObjectPtr.IsValid
	 * @Param Value Pointer received as TWeakObjectPtr<UObject>&inout, starts valid
	 * @Inputs Value.IsValid() is true
	 * @Return void; Value is explicitly null
	 */
	UFUNCTION()
	void ClearValidity(TWeakObjectPtr<UObject>&inout Value)
	{
		Value = nullptr;
	}
}
/** @end */
