/**
 * @version v1
 * @summary TWeakObjectPtr<T> default-constructs to null and reports not valid, not stale, and explicitly null. The three state predicates are independent axes: default is explicit-null; a live target is valid; a collected target is.
 * @topic Containers
 */
/**
 * @version root
 * @summary TWeakObjectPtr<T> default-constructs to null and reports not valid, not stale, and explicitly null. The three state predicates are independent axes: default is explicit-null; a live target is valid; a collected target is.
 * @topic Baseline
 */
UCLASS()
class UTWeakObjectPtrEmptyConstructionObject : UObject
{
}

namespace TWeakObjectPtrTest
{
	/**
	 * Observe default construction: a fresh weak pointer is null and invalid.
	 *
	 * @Kind Observe
	 * @Covers TWeakObjectPtr.Construct
	 * @Inputs Default-constructed TWeakObjectPtr<UObject>
	 * @Return true when Get() is nullptr and IsValid() is false
	 */
	UFUNCTION()
	bool DefaultConstructionIsNull()
	{
		TWeakObjectPtr<UObject> Weak;
		return Weak.Get() == nullptr && !Weak.IsValid();
	}

	/**
	 * Observe the three state predicates on a default-constructed pointer:
	 * it is explicitly null, and it is not stale because nothing was ever set.
	 *
	 * @Kind Observe
	 * @Covers TWeakObjectPtr.IsExplicitlyNull
	 * @Inputs Default-constructed TWeakObjectPtr<UObject>
	 * @Return true when IsExplicitlyNull() is true and IsStale() is false
	 */
	UFUNCTION()
	bool DefaultConstructionIsExplicitlyNullNotStale()
	{
		TWeakObjectPtr<UObject> Weak;
		return Weak.IsExplicitlyNull() && !Weak.IsStale();
	}

	/**
	 * Observe copy independence: constructing two weak pointers and setting
	 * only the first leaves the second null.
	 *
	 * @Kind Observe
	 * @Covers TWeakObjectPtr.Construct
	 * @Inputs Two default-constructed pointers; assign an object to the first
	 * @Return true when the first is valid and the second is still null
	 */
	UFUNCTION()
	bool DefaultConstructionCopyIndependence()
	{
		UObject Target = NewObject(GetTransientPackage(), UTWeakObjectPtrEmptyConstructionObject::StaticClass(), n"TWeakObjEmpty_First", true);
		if (Target == nullptr)
		{
			return false;
		}

		TWeakObjectPtr<UObject> First;
		TWeakObjectPtr<UObject> Second;
		First = Target;
		return First.IsValid() && !Second.IsValid();
	}

	/**
	 * In-only: read the state of a const&in TWeakObjectPtr<UObject>.
	 *
	 * @Kind RoundTrip
	 * @Covers TWeakObjectPtr.Construct
	 * @Param Value Source pointer received as const TWeakObjectPtr<UObject>&in
	 * @Inputs Value is default-constructed and therefore null
	 * @Return true when Get() is nullptr and IsValid() is false
	 */
	UFUNCTION()
	bool ReadDefaultConstructed(const TWeakObjectPtr<UObject>&in Value)
	{
		return Value.Get() == nullptr && !Value.IsValid();
	}

	/**
	 * Out-only: leave an &out TWeakObjectPtr<UObject> in its default null state.
	 *
	 * @Kind RoundTrip
	 * @Covers TWeakObjectPtr.Construct
	 * @Param Result Destination received as TWeakObjectPtr<UObject>&out
	 * @Inputs Empty &out TWeakObjectPtr<UObject>
	 * @Return void; Result stays null and explicitly null
	 */
	UFUNCTION()
	void LeaveDefaultConstructed(TWeakObjectPtr<UObject>&out Result)
	{
		Result = TWeakObjectPtr<UObject>();
	}

	/**
	 * Inout: reset a pointer back to the default null state.
	 *
	 * @Kind RoundTrip
	 * @Covers TWeakObjectPtr.Construct
	 * @Param Value Pointer received as TWeakObjectPtr<UObject>&inout, starts set
	 * @Inputs Value.IsValid() is true
	 * @Return void; Value is null and explicitly null again
	 */
	UFUNCTION()
	void ResetToDefaultState(TWeakObjectPtr<UObject>&inout Value)
	{
		Value = TWeakObjectPtr<UObject>();
	}
}
/** @end */
