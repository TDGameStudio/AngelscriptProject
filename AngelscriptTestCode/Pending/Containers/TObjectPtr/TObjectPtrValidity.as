/**
 * @version v1
 * @summary TObjectPtr.Get / opEquals answer questions about the held object without mutating the pointer. An object pointer has no stale state: unlike a weak pointer it keeps its target reachable, so a target that was set stays.
 * @topic Containers
 */
/**
 * @version root
 * @summary TObjectPtr.Get / opEquals answer questions about the held object without mutating the pointer. An object pointer has no stale state: unlike a weak pointer it keeps its target reachable, so a target that was set stays.
 * @topic Baseline
 */
UCLASS()
class UTObjectPtrValidityObject : UObject
{
}

namespace TObjectPtrTest
{
	/**
	 * Observe Get: it returns the object that was assigned, not a copy.
	 *
	 * @Kind Observe
	 * @Covers TObjectPtr.Get
	 * @Inputs Pointer set to an object; Get() twice
	 * @Return true when both reads return the same non-null object
	 */
	UFUNCTION()
	bool GetReturnsTheAssignedObject()
	{
		UObject Target = NewObject(GetTransientPackage(), UTObjectPtrValidityObject::StaticClass(), n"TObjPtrValid_Get", true);
		if (Target == nullptr)
		{
			return false;
		}

		TObjectPtr<UObject> Ptr;
		Ptr = Target;
		return Ptr.Get() == Target && Ptr.Get() == Ptr.Get();
	}

	/**
	 * Observe pointer-to-pointer equality: two pointers to the same object
	 * are equal, and clearing one leaves the other intact.
	 *
	 * @Kind Observe
	 * @Covers TObjectPtr.opEquals
	 * @Inputs Two pointers set to the same object; then clear the second
	 * @Return true when they were equal and the first survives clearing the second
	 */
	UFUNCTION()
	bool PointersToSameTargetAreEqualAndIndependent()
	{
		UObject Target = NewObject(GetTransientPackage(), UTObjectPtrValidityObject::StaticClass(), n"TObjPtrValid_Shared", true);
		if (Target == nullptr)
		{
			return false;
		}

		TObjectPtr<UObject> First;
		TObjectPtr<UObject> Second;
		First = Target;
		Second = Target;
		if (First != Second)
		{
			return false;
		}

		Second = nullptr;
		return First.Get() == Target && Second.Get() == nullptr && First != Second;
	}

	/**
	 * Observe pointer-to-object equality: a set pointer equals the object it
	 * holds, and a null pointer does not equal any object.
	 *
	 * @Kind Observe
	 * @Covers TObjectPtr.opEquals
	 * @Inputs One null pointer and one pointer set to an object
	 * @Return true when the set pointer equals its object and the null one does not
	 */
	UFUNCTION()
	bool PointerEqualsHeldObjectOnlyWhenSet()
	{
		UObject Target = NewObject(GetTransientPackage(), UTObjectPtrValidityObject::StaticClass(), n"TObjPtrValid_Eq", true);
		if (Target == nullptr)
		{
			return false;
		}

		TObjectPtr<UObject> Null;
		TObjectPtr<UObject> Set;
		Set = Target;

		return !(Null == Target) && Set == Target;
	}

	/**
	 * Observe that two pointers to different objects are unequal.
	 *
	 * @Kind Observe
	 * @Covers TObjectPtr.opEquals
	 * @Inputs Two pointers set to two distinct objects
	 * @Return true when the two pointers compare unequal
	 */
	UFUNCTION()
	bool PointersToDifferentTargetsAreUnequal()
	{
		UObject First = NewObject(GetTransientPackage(), UTObjectPtrValidityObject::StaticClass(), n"TObjPtrValid_Diff0", true);
		UObject Second = NewObject(GetTransientPackage(), UTObjectPtrValidityObject::StaticClass(), n"TObjPtrValid_Diff1", true);
		if (First == nullptr || Second == nullptr || First == Second)
		{
			return false;
		}

		TObjectPtr<UObject> Left;
		TObjectPtr<UObject> Right;
		Left = First;
		Right = Second;
		return Left != Right;
	}

	/**
	 * In-only: read and compare a const&in TObjectPtr<UObject>.
	 *
	 * @Kind RoundTrip
	 * @Covers TObjectPtr.Get
	 * @Param Value Source pointer received as const TObjectPtr<UObject>&in
	 * @Inputs Value holds a live object
	 * @Return true when Get() is non-null
	 */
	UFUNCTION()
	bool ReadAndResolve(const TObjectPtr<UObject>&in Value)
	{
		return Value.Get() != nullptr;
	}

	/**
	 * Out-only: fill an &out pointer and then clear it, leaving it null.
	 *
	 * @Kind RoundTrip
	 * @Covers TObjectPtr.Get
	 * @Param Result Destination received as TObjectPtr<UObject>&out
	 * @Inputs Empty &out TObjectPtr<UObject>
	 * @Return void; Result is set and then cleared back to null
	 */
	UFUNCTION()
	void FillThenClear(TObjectPtr<UObject>&out Result)
	{
		Result = NewObject(GetTransientPackage(), UTObjectPtrValidityObject::StaticClass(), n"TObjPtrValid_FillClear", true);
		Result = nullptr;
	}

	/**
	 * Inout: clear an already-set TObjectPtr<UObject>.
	 *
	 * @Kind RoundTrip
	 * @Covers TObjectPtr.opAssign
	 * @Param Value Pointer received as TObjectPtr<UObject>&inout, starts set
	 * @Inputs Value holds a live object
	 * @Return void; Value is null
	 */
	UFUNCTION()
	void ClearTarget(TObjectPtr<UObject>&inout Value)
	{
		Value = nullptr;
	}
}
/** @end */
