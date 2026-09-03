/**
 * TObjectPtr<T> default-constructs to null, and opAssign / the implicit
 * object constructor bind an object. Unlike a weak pointer, an object
 * pointer keeps its target reachable, and it has no stale state: a live
 * object stays valid for as long as the pointer holds it. Validity is
 * observed through Get and comparison, then through UFUNCTION in, out,
 * and inout directions.
 *
 * @Theme Containers.TObjectPtr
 * @Subject TObjectPtr.opAssign
 * @Harness Function
 * @Tag Containers.TObjectPtr.TObjectPtrAssign
 * @Namespace TObjectPtrTest
 */

UCLASS()
class UTObjectPtrAssignObject : UObject
{
}

namespace TObjectPtrTest
{
	/**
	 * Observe default construction: a fresh object pointer is null.
	 *
	 * @Kind Observe
	 * @Covers TObjectPtr.Construct
	 * @Inputs Default-constructed TObjectPtr<UObject>
	 * @Return true when Get() is nullptr
	 */
	UFUNCTION()
	bool DefaultConstructionIsNull()
	{
		TObjectPtr<UObject> Ptr;
		return Ptr.Get() == nullptr;
	}

	/**
	 * Observe opAssign from an object: the pointer holds it and Get() returns
	 * the same object back.
	 *
	 * @Kind Observe
	 * @Covers TObjectPtr.opAssign
	 * @Inputs Default-constructed TObjectPtr<UObject>; assign an object
	 * @Return true when Get() is that object and is non-null
	 */
	UFUNCTION()
	bool AssignObjectStoresTarget()
	{
		UObject Target = NewObject(GetTransientPackage(), UTObjectPtrAssignObject::StaticClass(), n"TObjPtrAssign_First", true);
		if (Target == nullptr)
		{
			return false;
		}

		TObjectPtr<UObject> Ptr;
		if (Ptr.Get() != nullptr)
		{
			return false;
		}

		Ptr = Target;
		return Ptr.Get() == Target && Ptr.Get() != nullptr;
	}

	/**
	 * Observe implicit conversion: a set pointer converts back to the raw
	 * object handle and compares equal against the original object.
	 *
	 * @Kind Observe
	 * @Covers TObjectPtr.opImplConv
	 * @Inputs Pointer set to an object; compare the pointer against that object
	 * @Return true when the pointer equals the object it was set from
	 */
	UFUNCTION()
	bool ImplicitConversionReturnsTarget()
	{
		UObject Target = NewObject(GetTransientPackage(), UTObjectPtrAssignObject::StaticClass(), n"TObjPtrAssign_Conv", true);
		if (Target == nullptr)
		{
			return false;
		}

		TObjectPtr<UObject> Ptr;
		Ptr = Target;
		return Ptr == Target;
	}

	/**
	 * Observe opAssign from another object pointer: the target is copied and
	 * the two pointers then compare equal, and stay independent afterwards.
	 *
	 * @Kind Observe
	 * @Covers TObjectPtr.opAssign
	 * @Inputs Source pointer set to First; copy onto a default target; then reassign the source
	 * @Return true when the copy holds First after the source moves to Second
	 */
	UFUNCTION()
	bool AssignPointerCopiesTargetAndStaysIndependent()
	{
		UObject First = NewObject(GetTransientPackage(), UTObjectPtrAssignObject::StaticClass(), n"TObjPtrAssign_Copy0", true);
		UObject Second = NewObject(GetTransientPackage(), UTObjectPtrAssignObject::StaticClass(), n"TObjPtrAssign_Copy1", true);
		if (First == nullptr || Second == nullptr || First == Second)
		{
			return false;
		}

		TObjectPtr<UObject> Source;
		Source = First;

		TObjectPtr<UObject> Dest;
		Dest = Source;
		if (Dest.Get() != First || Dest != Source)
		{
			return false;
		}

		Source = Second;
		return Dest.Get() == First && Source.Get() == Second && Dest != Source;
	}

	/**
	 * Observe that assigning nullptr clears the pointer back to null.
	 *
	 * @Kind Observe
	 * @Covers TObjectPtr.opAssign
	 * @Inputs Pointer set to an object; assign nullptr
	 * @Return true when Get() is nullptr after clearing
	 */
	UFUNCTION()
	bool AssignNullptrClearsTarget()
	{
		UObject Target = NewObject(GetTransientPackage(), UTObjectPtrAssignObject::StaticClass(), n"TObjPtrAssign_Clear", true);
		if (Target == nullptr)
		{
			return false;
		}

		TObjectPtr<UObject> Ptr;
		Ptr = Target;
		if (Ptr.Get() != Target)
		{
			return false;
		}

		Ptr = nullptr;
		return Ptr.Get() == nullptr;
	}

	/**
	 * Observe that reassigning replaces the target rather than accumulating it.
	 *
	 * @Kind Observe
	 * @Covers TObjectPtr.opAssign
	 * @Inputs Default-constructed pointer; assign First; reassign Second
	 * @Return true when Get() is Second and not First
	 */
	UFUNCTION()
	bool ReassignReplacesTarget()
	{
		UObject First = NewObject(GetTransientPackage(), UTObjectPtrAssignObject::StaticClass(), n"TObjPtrAssign_Re0", true);
		UObject Second = NewObject(GetTransientPackage(), UTObjectPtrAssignObject::StaticClass(), n"TObjPtrAssign_Re1", true);
		if (First == nullptr || Second == nullptr || First == Second)
		{
			return false;
		}

		TObjectPtr<UObject> Ptr;
		Ptr = First;
		if (Ptr.Get() != First)
		{
			return false;
		}

		Ptr = Second;
		return Ptr.Get() == Second && Ptr.Get() != First;
	}

	/**
	 * In-only: read the target out of a const&in TObjectPtr<UObject>.
	 *
	 * @Kind RoundTrip
	 * @Covers TObjectPtr.opAssign
	 * @Param Value Source pointer received as const TObjectPtr<UObject>&in
	 * @Inputs Value holds a live object
	 * @Return true when Get() is non-null
	 */
	UFUNCTION()
	bool ReadAssignedTarget(const TObjectPtr<UObject>&in Value)
	{
		return Value.Get() != nullptr;
	}

	/**
	 * Out-only: fill an empty &out TObjectPtr<UObject> with an object.
	 *
	 * @Kind RoundTrip
	 * @Covers TObjectPtr.opAssign
	 * @Param Result Destination received as TObjectPtr<UObject>&out
	 * @Inputs Empty &out TObjectPtr<UObject>
	 * @Return void; Result holds a non-null object
	 */
	UFUNCTION()
	void FillWithNewObject(TObjectPtr<UObject>&out Result)
	{
		Result = NewObject(GetTransientPackage(), UTObjectPtrAssignObject::StaticClass(), n"TObjPtrAssign_Fill", true);
	}

	/**
	 * Inout: replace the target of an already-set TObjectPtr<UObject>.
	 *
	 * @Kind RoundTrip
	 * @Covers TObjectPtr.opAssign
	 * @Param Value Pointer received as TObjectPtr<UObject>&inout, starts set
	 * @Inputs Value holds a live object
	 * @Return void; Value holds a different non-null object
	 */
	UFUNCTION()
	void ReplaceTarget(TObjectPtr<UObject>&inout Value)
	{
		Value = NewObject(GetTransientPackage(), UTObjectPtrAssignObject::StaticClass(), n"TObjPtrAssign_Replace", true);
	}
}
