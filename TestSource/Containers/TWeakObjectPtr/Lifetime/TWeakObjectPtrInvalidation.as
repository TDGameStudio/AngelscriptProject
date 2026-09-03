/**
 * A weak pointer does not keep its target alive, so once the target is gone
 * the pointer reports invalid. Invalidation is only observable through GC,
 * so this file uses a scope-boundary pattern: the target is created inside a
 * nested scope and dropped before the pointer is re-examined. CollectGarbage
 * is the explicit trigger; the observation is the state transition, not the
 * timing of the collection itself.
 *
 * @Theme Containers.TWeakObjectPtr
 * @Subject TWeakObjectPtr.Invalidation
 * @Harness Lifetime
 * @Tag Containers.TWeakObjectPtr.TWeakObjectPtrInvalidation
 * @Namespace TWeakObjectPtrTest
 */

UCLASS()
class UTWeakObjectPtrInvalidationObject : UObject
{
}

namespace TWeakObjectPtrTest
{
	/**
	 * Observe that a weak pointer to an object that has been released stops
	 * reporting valid, and that Get() returns nullptr instead of throwing.
	 *
	 * @Kind Observe
	 * @Covers TWeakObjectPtr.IsValid
	 * @Inputs Pointer set to a UObject; drop all strong references; CollectGarbage
	 * @Return true when the pointer was valid before and is invalid after,
	 *         and Get() is nullptr rather than throwing
	 */
	UFUNCTION()
	bool ReleasedTargetBecomesInvalid()
	{
		TWeakObjectPtr<UObject> Weak;

		{
			UObject Target = NewObject(GetTransientPackage(), UTWeakObjectPtrInvalidationObject::StaticClass(), n"TWeakObjInvalid_Target", true);
			if (Target == nullptr)
			{
				return false;
			}

			Weak = Target;
			if (!Weak.IsValid() || Weak.Get() != Target)
			{
				return false;
			}
		}

		CollectGarbage();

		return !Weak.IsValid() && Weak.Get() == nullptr;
	}

	/**
	 * Observe that an invalidated pointer is not explicitly null: it once held
	 * a target that has since gone away. Explicit-null is reserved for a
	 * pointer that was never assigned or was cleared by hand.
	 *
	 * @Kind Observe
	 * @Covers TWeakObjectPtr.IsExplicitlyNull
	 * @Inputs Pointer set to a UObject; release the target; CollectGarbage
	 * @Return true when IsExplicitlyNull() is false after invalidation
	 * @Boundary invalidated vs explicitly-null are different states
	 */
	UFUNCTION()
	bool InvalidatedIsNotExplicitlyNull()
	{
		TWeakObjectPtr<UObject> Weak;

		{
			UObject Target = NewObject(GetTransientPackage(), UTWeakObjectPtrInvalidationObject::StaticClass(), n"TWeakObjInvalid_Stale", true);
			if (Target == nullptr)
			{
				return false;
			}

			Weak = Target;
		}

		CollectGarbage();

		return !Weak.IsValid() && !Weak.IsExplicitlyNull();
	}

	/**
	 * Observe that a pointer cleared by hand is explicitly null, which
	 * distinguishes it from a pointer invalidated by collection.
	 *
	 * @Kind Observe
	 * @Covers TWeakObjectPtr.IsExplicitlyNull
	 * @Inputs Pointer set to a live object; assign nullptr
	 * @Return true when IsExplicitlyNull() is true and IsValid() is false
	 * @Boundary hand-cleared vs collected
	 */
	UFUNCTION()
	bool HandClearedIsExplicitlyNull()
	{
		UObject Target = NewObject(GetTransientPackage(), UTWeakObjectPtrInvalidationObject::StaticClass(), n"TWeakObjInvalid_Cleared", true);
		if (Target == nullptr)
		{
			return false;
		}

		TWeakObjectPtr<UObject> Weak;
		Weak = Target;
		Weak = nullptr;

		return !Weak.IsValid() && Weak.IsExplicitlyNull();
	}

	/**
	 * Observe that a weak pointer does not keep its target alive: the target
	 * is collectable while only a weak reference to it exists. This is the
	 * property that makes a weak back-reference cycle-safe.
	 *
	 * @Kind Observe
	 * @Covers TWeakObjectPtr.Get
	 * @Inputs Pointer set to a UObject inside a scope; release; CollectGarbage
	 * @Return true when the pointer no longer resolves after collection
	 * @Boundary GC reachability
	 */
	UFUNCTION()
	bool WeakReferenceDoesNotKeepTargetAlive()
	{
		TWeakObjectPtr<UObject> Weak;

		{
			UObject Target = NewObject(GetTransientPackage(), UTWeakObjectPtrInvalidationObject::StaticClass(), n"TWeakObjInvalid_Reach", true);
			if (Target == nullptr)
			{
				return false;
			}

			Weak = Target;
		}

		CollectGarbage();

		return Weak.Get() == nullptr && !Weak.IsValid();
	}
}
