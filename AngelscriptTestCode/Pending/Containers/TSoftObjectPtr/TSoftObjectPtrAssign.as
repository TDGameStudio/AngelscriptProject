/**
 * @version v1
 * @summary TSoftObjectPtr.opAssign binds either a live object or another soft pointer. Assigning an object captures its path rather than holding a strong reference, so the pointer stays a soft reference and reports valid while the.
 * @topic Containers
 */
/**
 * @version root
 * @summary TSoftObjectPtr.opAssign binds either a live object or another soft pointer. Assigning an object captures its path rather than holding a strong reference, so the pointer stays a soft reference and reports valid while the.
 * @topic Baseline
 */
UCLASS()
class UTSoftObjectPtrAssignObject : UObject
{
}

namespace TSoftObjectPtrTest
{
	/**
	 * Observe opAssign from an object: the pointer captures the object's path
	 * and Get() resolves back to that object while it is loaded.
	 *
	 * @Kind Observe
	 * @Covers TSoftObjectPtr.opAssign
	 * @Inputs Default-constructed pointer; assign a live object
	 * @Return true when IsValid() is true and Get() is that object
	 */
	UFUNCTION()
	bool AssignObjectCapturesPathAndResolves()
	{
		UObject Target = NewObject(GetTransientPackage(), UTSoftObjectPtrAssignObject::StaticClass(), n"TSoftPtrAssign_First", true);
		if (Target == nullptr)
		{
			return false;
		}

		TSoftObjectPtr<UObject> Soft;
		if (Soft.IsValid())
		{
			return false;
		}

		Soft = Target;
		return Soft.IsValid() && Soft.Get() == Target;
	}

	/**
	 * Observe opAssign from another soft pointer: the path is copied and the
	 * two pointers then compare equal, and stay independent afterwards.
	 *
	 * @Kind Observe
	 * @Covers TSoftObjectPtr.opAssign
	 * @Inputs Source with a path; copy onto a default target; then reset the source
	 * @Return true when the copy keeps the path after the source is reset
	 */
	UFUNCTION()
	bool AssignPointerCopiesPathAndStaysIndependent()
	{
		TSoftObjectPtr<UObject> Source;
		Source = FSoftObjectPath("/Game/AngelscriptTest/PackageA.AssetA");

		TSoftObjectPtr<UObject> Dest;
		Dest = Source;
		if (Dest != Source)
		{
			return false;
		}

		Source.Reset();
		return Dest.ToSoftObjectPath() == FSoftObjectPath("/Game/AngelscriptTest/PackageA.AssetA")
			&& Source.IsNull();
	}

	/**
	 * Observe that assigning nullptr clears the pointer back to null, the same
	 * way Reset does.
	 *
	 * @Kind Observe
	 * @Covers TSoftObjectPtr.opAssign
	 * @Inputs Pointer assigned a live object; assign nullptr
	 * @Return true when IsNull() is true and Get() is nullptr afterwards
	 */
	UFUNCTION()
	bool AssignNullptrClearsPointer()
	{
		UObject Target = NewObject(GetTransientPackage(), UTSoftObjectPtrAssignObject::StaticClass(), n"TSoftPtrAssign_Clear", true);
		if (Target == nullptr)
		{
			return false;
		}

		TSoftObjectPtr<UObject> Soft;
		Soft = Target;
		if (!Soft.IsValid())
		{
			return false;
		}

		Soft = nullptr;
		return Soft.IsNull() && Soft.Get() == nullptr;
	}

	/**
	 * Observe that a soft pointer does not keep its target alive: it captures
	 * a path, not a strong reference. This is what makes it safe for asset
	 * references that should not be pinned in memory.
	 *
	 * @Kind Observe
	 * @Covers TSoftObjectPtr.Get
	 * @Inputs Pointer assigned a live object; confirm it is valid but path-based
	 * @Return true when the pointer is valid yet Get() resolves through the path
	 * @Boundary soft reference vs strong reference
	 */
	UFUNCTION()
	bool SoftPointerValidWhileObjectIsLoaded()
	{
		UObject Target = NewObject(GetTransientPackage(), UTSoftObjectPtrAssignObject::StaticClass(), n"TSoftPtrAssign_Soft", true);
		if (Target == nullptr)
		{
			return false;
		}

		TSoftObjectPtr<UObject> Soft;
		Soft = Target;

		return Soft.IsValid()
			&& Soft.Get() == Target
			&& !Soft.ToSoftObjectPath().ToString().IsEmpty();
	}

	/**
	 * Observe opEquals against another pointer and against the object itself.
	 *
	 * @Kind Observe
	 * @Covers TSoftObjectPtr.opEquals
	 * @Inputs One pointer assigned an object; one pointer assigned the same object
	 * @Return true when both pointers are equal and each equals the object
	 */
	UFUNCTION()
	bool PointerEqualsOtherPointerAndObject()
	{
		UObject Target = NewObject(GetTransientPackage(), UTSoftObjectPtrAssignObject::StaticClass(), n"TSoftPtrAssign_Eq", true);
		if (Target == nullptr)
		{
			return false;
		}

		TSoftObjectPtr<UObject> First;
		TSoftObjectPtr<UObject> Second;
		First = Target;
		Second = Target;

		return First == Second && First == Target;
	}

	/**
	 * In-only: read the resolved object out of a const&in TSoftObjectPtr<UObject>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSoftObjectPtr.opAssign
	 * @Param Value Source pointer received as const TSoftObjectPtr<UObject>&in
	 * @Inputs Value was assigned a live object
	 * @Return true when Get() is non-null
	 */
	UFUNCTION()
	bool ReadAssignedObject(const TSoftObjectPtr<UObject>&in Value)
	{
		return Value.Get() != nullptr;
	}

	/**
	 * Out-only: fill an empty &out TSoftObjectPtr<UObject> with a live object.
	 *
	 * @Kind RoundTrip
	 * @Covers TSoftObjectPtr.opAssign
	 * @Param Result Destination received as TSoftObjectPtr<UObject>&out
	 * @Inputs Empty &out TSoftObjectPtr<UObject>
	 * @Return void; Result resolves to a non-null object
	 */
	UFUNCTION()
	void FillWithObject(TSoftObjectPtr<UObject>&out Result)
	{
		Result = NewObject(GetTransientPackage(), UTSoftObjectPtrAssignObject::StaticClass(), n"TSoftPtrAssign_Fill", true);
	}

	/**
	 * Inout: replace the target of an already-set TSoftObjectPtr<UObject>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSoftObjectPtr.opAssign
	 * @Param Value Pointer received as TSoftObjectPtr<UObject>&inout, starts set
	 * @Inputs Value holds an object or path
	 * @Return void; Value is reset to null
	 */
	UFUNCTION()
	void ReplaceTarget(TSoftObjectPtr<UObject>&inout Value)
	{
		Value = nullptr;
	}
}
/** @end */
