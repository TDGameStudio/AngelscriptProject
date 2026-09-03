/**
 * TWeakObjectPtr<T> as a UPROPERTY on a script UCLASS. The property starts
 * null and explicitly null, and its state is per-instance. A weak property
 * is the way a script class points back at an owner without keeping it
 * alive, which is what breaks a reference cycle between two UObjects.
 *
 * @Theme Containers.TWeakObjectPtr
 * @Subject TWeakObjectPtr.Property
 * @Harness UClass
 * @Tag Containers.TWeakObjectPtr.TWeakObjectPtrProperty
 * @Namespace TWeakObjectPtrTest
 */

UCLASS()
class UTWeakObjectPtrPropertyHolder : UObject
{
	UPROPERTY()
	TWeakObjectPtr<UObject> WeakRef;

	UPROPERTY()
	TWeakObjectPtr<AActor> WeakActor;
}

UCLASS()
class UTWeakObjectPtrPropertyOwner : UObject
{
	UPROPERTY()
	UObject StrongRef;

	/** Back-reference held weakly so the pair does not form a GC cycle. */
	UPROPERTY()
	TWeakObjectPtr<UObject> BackRef;
}

namespace TWeakObjectPtrTest
{
	/**
	 * Observe that weak UPROPERTYs start null and explicitly null on a fresh instance.
	 *
	 * @Kind Observe
	 * @Covers TWeakObjectPtr.Construct
	 * @Inputs NewObject of the holder class
	 * @Return true when both weak properties are null and explicitly null
	 */
	UFUNCTION()
	bool WeakPropertiesStartNull()
	{
		UTWeakObjectPtrPropertyHolder Holder = NewObject(GetTransientPackage(), UTWeakObjectPtrPropertyHolder::StaticClass(), n"TWeakObjProp_Unset", true);
		if (Holder == nullptr)
		{
			return false;
		}

		return !Holder.WeakRef.IsValid()
			&& Holder.WeakRef.Get() == nullptr
			&& Holder.WeakRef.IsExplicitlyNull()
			&& !Holder.WeakActor.IsValid()
			&& Holder.WeakActor.IsExplicitlyNull();
	}

	/**
	 * Observe that a weak UPROPERTY keeps its target on the instance.
	 *
	 * @Kind Observe
	 * @Covers TWeakObjectPtr.opAssign
	 * @Inputs NewObject of the holder class; assign an object to WeakRef
	 * @Return true when WeakRef is valid and returns that object
	 */
	UFUNCTION()
	bool WeakPropertyKeepsTarget()
	{
		UTWeakObjectPtrPropertyHolder Holder = NewObject(GetTransientPackage(), UTWeakObjectPtrPropertyHolder::StaticClass(), n"TWeakObjProp_Set", true);
		if (Holder == nullptr)
		{
			return false;
		}

		UObject Target = NewObject(GetTransientPackage(), UTWeakObjectPtrPropertyHolder::StaticClass(), n"TWeakObjProp_Target", true);
		if (Target == nullptr)
		{
			return false;
		}

		Holder.WeakRef = Target;
		return Holder.WeakRef.IsValid()
			&& Holder.WeakRef.Get() == Target
			&& !Holder.WeakRef.IsExplicitlyNull();
	}

	/**
	 * Observe that weak property state is per-instance: setting it on one
	 * holder leaves a second holder untouched.
	 *
	 * @Kind Observe
	 * @Covers TWeakObjectPtr.opAssign
	 * @Inputs Two holder instances; assign the weak property on the first only
	 * @Return true when the first is valid and the second stays null
	 */
	UFUNCTION()
	bool WeakPropertiesArePerInstance()
	{
		UTWeakObjectPtrPropertyHolder First = NewObject(GetTransientPackage(), UTWeakObjectPtrPropertyHolder::StaticClass(), n"TWeakObjProp_First", true);
		UTWeakObjectPtrPropertyHolder Second = NewObject(GetTransientPackage(), UTWeakObjectPtrPropertyHolder::StaticClass(), n"TWeakObjProp_Second", true);
		if (First == nullptr || Second == nullptr || First == Second)
		{
			return false;
		}

		First.WeakRef = NewObject(GetTransientPackage(), UTWeakObjectPtrPropertyHolder::StaticClass(), n"TWeakObjProp_Shared", true);
		return First.WeakRef.IsValid() && !Second.WeakRef.IsValid();
	}

	/**
	 * Observe the cycle-breaking shape: two owners reference each other, the
	 * forward direction strongly and the back direction weakly. Both forward
	 * references resolve, and the back reference resolves to its owner.
	 *
	 * @Kind Observe
	 * @Covers TWeakObjectPtr.Get
	 * @Inputs Two owner instances wired in a strong-forward / weak-back pair
	 * @Return true when each owner's back reference resolves to the other
	 */
	UFUNCTION()
	bool BackReferenceBreaksCycle()
	{
		UTWeakObjectPtrPropertyOwner First = NewObject(GetTransientPackage(), UTWeakObjectPtrPropertyOwner::StaticClass(), n"TWeakObjProp_OwnerA", true);
		UTWeakObjectPtrPropertyOwner Second = NewObject(GetTransientPackage(), UTWeakObjectPtrPropertyOwner::StaticClass(), n"TWeakObjProp_OwnerB", true);
		if (First == nullptr || Second == nullptr || First == Second)
		{
			return false;
		}

		First.StrongRef = Second;
		Second.BackRef = First;

		return First.StrongRef == Second
			&& Second.BackRef.IsValid()
			&& Second.BackRef.Get() == First;
	}

	/**
	 * Observe that clearing the strong side does not invalidate the weak side
	 * until the target is actually gone; explicitly clearing the weak
	 * property is what makes it null.
	 *
	 * @Kind Observe
	 * @Covers TWeakObjectPtr.IsValid
	 * @Inputs Owner pair wired as above; then clear the weak back reference
	 * @Return true when the weak property is null and explicitly null after clearing
	 */
	UFUNCTION()
	bool ClearingWeakPropertyMakesItExplicitlyNull()
	{
		UTWeakObjectPtrPropertyOwner First = NewObject(GetTransientPackage(), UTWeakObjectPtrPropertyOwner::StaticClass(), n"TWeakObjProp_ClearA", true);
		UTWeakObjectPtrPropertyOwner Second = NewObject(GetTransientPackage(), UTWeakObjectPtrPropertyOwner::StaticClass(), n"TWeakObjProp_ClearB", true);
		if (First == nullptr || Second == nullptr || First == Second)
		{
			return false;
		}

		Second.BackRef = First;
		if (!Second.BackRef.IsValid())
		{
			return false;
		}

		Second.BackRef = nullptr;
		return !Second.BackRef.IsValid()
			&& Second.BackRef.Get() == nullptr
			&& Second.BackRef.IsExplicitlyNull();
	}
}
