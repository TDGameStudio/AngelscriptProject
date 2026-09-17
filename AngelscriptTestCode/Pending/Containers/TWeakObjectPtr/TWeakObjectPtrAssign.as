/**
 * @version v1
 * @summary TWeakObjectPtr.Set / opAssign binds an object without keeping it alive. Both the pointer-to-pointer and object-to-pointer assignment paths are covered, plus the implicit conversion back to the raw object handle. Validity.
 * @topic Containers
 */
/**
 * @version root
 * @summary TWeakObjectPtr.Set / opAssign binds an object without keeping it alive. Both the pointer-to-pointer and object-to-pointer assignment paths are covered, plus the implicit conversion back to the raw object handle. Validity.
 * @topic Baseline
 */
UCLASS()
class UTWeakObjectPtrAssignObject : UObject
{
}

namespace TWeakObjectPtrTest
{
	/**
	 * Observe opAssign from an object: the pointer becomes valid and Get()
	 * returns the same object back.
	 *
	 * @Kind Observe
	 * @Covers TWeakObjectPtr.opAssign
	 * @Inputs Default-constructed TWeakObjectPtr<UObject>; assign an object
	 * @Return true when IsValid() is true and Get() is that object
	 */
	UFUNCTION()
	bool AssignObjectMakesValid()
	{
		UObject Target = NewObject(GetTransientPackage(), UTWeakObjectPtrAssignObject::StaticClass(), n"TWeakObjAssign_First", true);
		if (Target == nullptr)
		{
			return false;
		}

		TWeakObjectPtr<UObject> Weak;
		if (Weak.IsValid())
		{
			return false;
		}

		Weak = Target;
		return Weak.IsValid() && Weak.Get() == Target;
	}

	/**
	 * Observe opAssign from another weak pointer: validity and target are copied,
	 * and the two pointers then compare equal.
	 *
	 * @Kind Observe
	 * @Covers TWeakObjectPtr.opAssign
	 * @Inputs Source pointer set to an object; assign onto a default-constructed target
	 * @Return true when the target is valid, holds the same object, and equals the source
	 */
	UFUNCTION()
	bool AssignPointerCopiesTarget()
	{
		UObject Target = NewObject(GetTransientPackage(), UTWeakObjectPtrAssignObject::StaticClass(), n"TWeakObjAssign_Copy", true);
		if (Target == nullptr)
		{
			return false;
		}

		TWeakObjectPtr<UObject> Source;
		Source = Target;

		TWeakObjectPtr<UObject> Dest;
		Dest = Source;
		return Dest.IsValid()
			&& Dest.Get() == Target
			&& Dest == Source;
	}

	/**
	 * Observe implicit conversion: a valid weak pointer converts back to the
	 * raw object handle in a comparison against the original object.
	 *
	 * @Kind Observe
	 * @Covers TWeakObjectPtr.opImplConv
	 * @Inputs Pointer set to an object; compare the pointer against that object
	 * @Return true when the pointer equals the object it was set from
	 */
	UFUNCTION()
	bool ImplicitConversionReturnsTarget()
	{
		UObject Target = NewObject(GetTransientPackage(), UTWeakObjectPtrAssignObject::StaticClass(), n"TWeakObjAssign_Conv", true);
		if (Target == nullptr)
		{
			return false;
		}

		TWeakObjectPtr<UObject> Weak;
		Weak = Target;
		return Weak == Target;
	}

	/**
	 * Observe that reassigning replaces the target rather than accumulating it.
	 *
	 * @Kind Observe
	 * @Covers TWeakObjectPtr.opAssign
	 * @Inputs Default-constructed pointer; assign First; reassign Second
	 * @Return true when Get() is Second and not First
	 */
	UFUNCTION()
	bool ReassignReplacesTarget()
	{
		UObject First = NewObject(GetTransientPackage(), UTWeakObjectPtrAssignObject::StaticClass(), n"TWeakObjAssign_Re_0", true);
		UObject Second = NewObject(GetTransientPackage(), UTWeakObjectPtrAssignObject::StaticClass(), n"TWeakObjAssign_Re_1", true);
		if (First == nullptr || Second == nullptr || First == Second)
		{
			return false;
		}

		TWeakObjectPtr<UObject> Weak;
		Weak = First;
		if (Weak.Get() != First)
		{
			return false;
		}

		Weak = Second;
		return Weak.IsValid() && Weak.Get() == Second && Weak.Get() != First;
	}

	/**
	 * In-only: read the target out of a const&in TWeakObjectPtr<UObject>.
	 *
	 * @Kind RoundTrip
	 * @Covers TWeakObjectPtr.opAssign
	 * @Param Value Source pointer received as const TWeakObjectPtr<UObject>&in
	 * @Inputs Value holds a live object
	 * @Return true when IsValid() is true and Get() is non-null
	 */
	UFUNCTION()
	bool ReadAssignedTarget(const TWeakObjectPtr<UObject>&in Value)
	{
		return Value.IsValid() && Value.Get() != nullptr;
	}

	/**
	 * Out-only: fill an empty &out TWeakObjectPtr<UObject> with an object.
	 *
	 * @Kind RoundTrip
	 * @Covers TWeakObjectPtr.opAssign
	 * @Param Result Destination received as TWeakObjectPtr<UObject>&out
	 * @Inputs Empty &out TWeakObjectPtr<UObject>
	 * @Return void; Result holds a non-null object
	 */
	UFUNCTION()
	void FillWithNewObject(TWeakObjectPtr<UObject>&out Result)
	{
		Result = NewObject(GetTransientPackage(), UTWeakObjectPtrAssignObject::StaticClass(), n"TWeakObjAssign_Fill", true);
	}

	/**
	 * Inout: replace the target of an already-set TWeakObjectPtr<UObject>.
	 *
	 * @Kind RoundTrip
	 * @Covers TWeakObjectPtr.opAssign
	 * @Param Value Pointer received as TWeakObjectPtr<UObject>&inout, starts set
	 * @Inputs Value.IsValid() is true
	 * @Return void; Value holds a different non-null object
	 */
	UFUNCTION()
	void ReplaceTarget(TWeakObjectPtr<UObject>&inout Value)
	{
		Value = NewObject(GetTransientPackage(), UTWeakObjectPtrAssignObject::StaticClass(), n"TWeakObjAssign_Replace", true);
	}
}
/** @end */
