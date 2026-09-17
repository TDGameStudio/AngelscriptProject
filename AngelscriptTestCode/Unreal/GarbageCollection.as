/**
 * @version v1
 * @summary UObject reachability, weak pointers, and collectability.
 * @topic Unreal
 * @topic GarbageCollection
 *
 * g-c-basic-reclaim
 * g-c-collection-methods
 * g-c-container-protection
 * g-c-cross-frame-hold
 * g-c-is-valid-check
 * g-c-new-object-outer-and-collection
 * g-c-root-reachability
 * g-c-strong-cycle-reclaim
 * g-c-weak-ptr-invalidation
 * g-c-local-variable-no-protection
 */
/**
 * @begin g-c-basic-reclaim
 * @summary A basic GC reclaim: a UObject held only by a local variable, whose reference is cleared before collection, must be collected and its weak reference invalidated.
 * @topic GarbageCollection
 */
UCLASS()
class ACoverageGCBasicReclaimActor : AActor
{
	UPROPERTY()
	bool WeakRefInvalidatedAfterGC = false;

	/**
	 * Creates an object, drops the only reference, and collects it.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the flag records whether the weak reference died
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Create a local object that has no strong references
		UObject TempObject = NewObject(GetTransientPackage(), UTexture2D::StaticClass());

		// Create weak reference to track it
		TWeakObjectPtr<UObject> WeakRef = TempObject;

		// At this point, only the local variable holds it
		// Local variables do not protect from GC in AngelScript

		// Clear the local reference
		TempObject = nullptr;

		// Force garbage collection
		CoverageGC::ForceGarbageCollectionNow();

		// After GC, the weak reference should be invalid
		if (!WeakRef.IsValid())
		{
			WeakRefInvalidatedAfterGC = true;
		}
	}

	/**
	 * Observe that a locally constructed actor has not run the probe.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when the flag is still false
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool GCBasicReclaimFlagDefaultsToFalse()
	{
		return WeakRefInvalidatedAfterGC == false;
	}
}
/** @end */
/**
 * @begin g-c-collection-methods
 * @summary The two GC entry points, CollectGarbageNow and ForceGarbageCollectionNow, both reclaim an object whose only reference was a cleared local. The flags record each outcome separately.
 * @topic GarbageCollection
 */
UCLASS()
class ACoverageGCCollectionMethodsActor : AActor
{
	UPROPERTY()
	bool CollectGarbageWorked = false;

	UPROPERTY()
	bool ForceGarbageCollectionWorked = false;

	/**
	 * Runs both collection entry points over dropped locals.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; both flags record their outcome
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Test CollectGarbage()
		{
			UObject TempObject = NewObject(GetTransientPackage(), UTexture2D::StaticClass());
			TWeakObjectPtr<UObject> WeakRef = TempObject;
			TempObject = nullptr;

			CoverageGC::CollectGarbageNow();

			if (!WeakRef.IsValid())
			{
				CollectGarbageWorked = true;
			}
		}

		// Test ForceGarbageCollection()
		{
			UObject TempObject2 = NewObject(GetTransientPackage(), UTexture2D::StaticClass());
			TWeakObjectPtr<UObject> WeakRef2 = TempObject2;
			TempObject2 = nullptr;

			CoverageGC::ForceGarbageCollectionNow();

			if (!WeakRef2.IsValid())
			{
				ForceGarbageCollectionWorked = true;
			}
		}
	}

	/**
	 * Observe that a locally constructed actor has run neither collection.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when both flags are still false
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool GCCollectionMethodsFlagsDefaultToFalse()
	{
		if (CollectGarbageWorked)
		{
			return false;
		}

		return !ForceGarbageCollectionWorked;
	}
}
/** @end */
/**
 * @begin g-c-container-protection
 * @summary UPROPERTY containers keep UObjects alive across collection: one object held in a TArray and one in a TMap both survive a forced GC after their locals are cleared.
 * @topic GarbageCollection
 */
UCLASS()
class ACoverageGCContainerProtectionActor : AActor
{
	UPROPERTY()
	TArray<UObject> ObjectArray;

	UPROPERTY()
	TMap<int32, UObject> ObjectMap;

	UPROPERTY()
	bool ArrayObjectSurvivedGC = false;

	UPROPERTY()
	bool MapObjectSurvivedGC = false;

	/**
	 * Stores two objects in the containers and forces collection.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the flags record survival
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Create objects and store in containers
		UObject ArrayObject = NewObject(GetTransientPackage(), UTexture2D::StaticClass());
		ObjectArray.Add(ArrayObject);

		UObject MapObject = NewObject(GetTransientPackage(), UTexture2D::StaticClass());
		ObjectMap.Add(1, MapObject);

		// Create weak references to verify survival
		TWeakObjectPtr<UObject> WeakArrayRef = ArrayObject;
		TWeakObjectPtr<UObject> WeakMapRef = MapObject;

		// Clear local references
		ArrayObject = nullptr;
		MapObject = nullptr;

		// Force GC
		CoverageGC::ForceGarbageCollectionNow();

		// Container members should protect objects from GC
		if (WeakArrayRef.IsValid() && IsValid(ObjectArray[0]))
		{
			ArrayObjectSurvivedGC = true;
		}

		UObject RetrievedMapObject = ObjectMap[1];
		if (WeakMapRef.IsValid() && IsValid(RetrievedMapObject))
		{
			MapObjectSurvivedGC = true;
		}
	}

	/**
	 * Observe that a locally constructed actor starts with empty containers.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when both containers are empty and both flags are false
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool GCContainerProtectionDefaultEmpty()
	{
		if (ObjectArray.Num() != 0)
		{
			return false;
		}

		if (ObjectMap.Num() != 0)
		{
			return false;
		}

		if (ArrayObjectSurvivedGC)
		{
			return false;
		}

		return !MapObjectSurvivedGC;
	}
}
/** @end */
/**
 * @begin g-c-cross-frame-hold
 * @summary A UPROPERTY hold surviving multi-frame collection: the object is held in BeginPlay and verified alive after three ticks and a forced GC at the third.
 * @topic GarbageCollection
 */
UCLASS()
class ACoverageGCCrossFrameHoldActor : AActor
{
	UPROPERTY()
	UObject HeldObject;

	UPROPERTY()
	TWeakObjectPtr<UObject> WeakRef;

	UPROPERTY()
	int32 FrameCount = 0;

	UPROPERTY()
	bool ObjectValidAfterMultipleFrames = false;

	/**
	 * Creates the object and holds it in a UPROPERTY.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; HeldObject and WeakRef are populated
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Create object and hold it
		HeldObject = NewObject(GetTransientPackage(), UTexture2D::StaticClass());
		WeakRef = HeldObject;
	}

	/**
	 * Counts ticks and verifies the hold on the third frame.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the frame delta
	 * @Return nothing; the flag records survival after the third tick
	 * @Param DeltaSeconds the seconds since the last tick
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		FrameCount++;

		// After 3 frames, force GC and verify object still exists
		if (FrameCount == 3)
		{
			CoverageGC::ForceGarbageCollectionNow();

			if (WeakRef.IsValid() && IsValid(HeldObject))
			{
				ObjectValidAfterMultipleFrames = true;
			}
		}
	}

	/**
	 * Observe that a locally constructed actor holds nothing yet.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when the hold is null, the count is 0 and the flag is false
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool GCCrossFrameHoldDefaultEmpty()
	{
		if (HeldObject != nullptr)
		{
			return false;
		}

		if (FrameCount != 0)
		{
			return false;
		}

		return !ObjectValidAfterMultipleFrames;
	}
}
/** @end */
/**
 * @begin g-c-is-valid-check
 * @summary IsValid behaviour across a collection cycle: it reports true for a live object before GC, and reports false once the object has been collected and retrieved through a weak reference.
 * @topic GarbageCollection
 */
UCLASS()
class ACoverageGCIsValidCheckActor : AActor
{
	UPROPERTY()
	bool IsValidReturnedTrueBeforeGC = false;

	UPROPERTY()
	bool IsValidDetectedInvalidObject = false;

	/**
	 * Checks IsValid before and after a forced collection.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the flags record both outcomes
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Create object
		UObject TempObject = NewObject(GetTransientPackage(), UTexture2D::StaticClass());

		// IsValid should return true for live object
		if (IsValid(TempObject))
		{
			IsValidReturnedTrueBeforeGC = true;
		}

		// Get weak reference, then clear strong ref
		TWeakObjectPtr<UObject> WeakRef = TempObject;
		TempObject = nullptr;

		// Force GC
		CoverageGC::ForceGarbageCollectionNow();

		// Try to get object from weak ref
		UObject RetrievedObject = WeakRef.Get();

		// IsValid should return false (or RetrievedObject is nullptr)
		if (RetrievedObject == nullptr || !IsValid(RetrievedObject))
		{
			IsValidDetectedInvalidObject = true;
		}
	}

	/**
	 * Observe that a locally constructed actor has run neither check.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when both flags are still false
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool GCIsValidCheckFlagsDefaultToFalse()
	{
		if (IsValidReturnedTrueBeforeGC)
		{
			return false;
		}

		return !IsValidDetectedInvalidObject;
	}
}
/** @end */
/**
 * @begin g-c-new-object-outer-and-collection
 * @summary NewObject with a named outer plus the reclaim of the unreferenced result: the object is created with GetTransientPackage as outer, verified, then collected once its only reference is cleared.
 * @topic GarbageCollection
 */
UCLASS()
class ACoverageGCNewObjectOuterActor : AActor
{
	UPROPERTY()
	bool NewObjectCreatedWithOuter = false;

	UPROPERTY()
	bool UnreferencedNewObjectCollected = false;

	/**
	 * Creates the object, verifies its outer, then collects it.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; both flags record their outcome
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UObject CreatedObject = NewObject(GetTransientPackage(), UTexture2D::StaticClass(), n"CoverageGCNewObjectOuter");
		TWeakObjectPtr<UObject> WeakCreatedObject = CreatedObject;

		NewObjectCreatedWithOuter = CreatedObject != nullptr &&
			CreatedObject.GetOuter() == GetTransientPackage() &&
			CreatedObject.IsA(UTexture2D::StaticClass());

		CreatedObject = nullptr;
		CoverageGC::ForceGarbageCollectionNow();

		UnreferencedNewObjectCollected = !WeakCreatedObject.IsValid() && WeakCreatedObject.Get() == nullptr;
	}

	/**
	 * Observe that a locally constructed actor has run neither step.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when both flags are still false
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool GCNewObjectOuterFlagsDefaultToFalse()
	{
		if (NewObjectCreatedWithOuter)
		{
			return false;
		}

		return !UnreferencedNewObjectCollected;
	}
}
/** @end */
/**
 * @begin g-c-root-reachability
 * @summary GC root reachability: an object added to the root set survives collection, and removing it from the root set allows collection again.
 * @topic GarbageCollection
 */
UCLASS()
class ACoverageGCRootReachabilityActor : AActor
{
	UPROPERTY()
	bool RootedObjectSurvivedGC = false;

	UPROPERTY()
	bool RemovedRootAllowedCollection = false;

	/**
	 * Roots an object, collects, unroots it, and collects again.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; both flags record their outcome
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UObject RootedObject = NewObject(GetTransientPackage(), UTexture2D::StaticClass(), n"CoverageGCRootedObject");
		RootedObject.AddToRoot();

		TWeakObjectPtr<UObject> WeakRootedObject = RootedObject;
		RootedObject = nullptr;

		CoverageGC::ForceGarbageCollectionNow();
		RootedObjectSurvivedGC = WeakRootedObject.IsValid();

		UObject UnrootedObject = WeakRootedObject.Get();
		if (UnrootedObject != nullptr)
		{
			UnrootedObject.RemoveFromRoot();
		}
		UnrootedObject = nullptr;

		CoverageGC::ForceGarbageCollectionNow();
		RemovedRootAllowedCollection = !WeakRootedObject.IsValid() && WeakRootedObject.Get() == nullptr;
	}

	/**
	 * Observe that a locally constructed actor has run neither phase.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when both flags are still false
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool GCRootReachabilityFlagsDefaultToFalse()
	{
		if (RootedObjectSurvivedGC)
		{
			return false;
		}

		return !RemovedRootAllowedCollection;
	}
}
/** @end */
/**
 * @begin g-c-strong-cycle-reclaim
 * @summary A two-node UObject cycle held only by its own UPROPERTY edges is collected once the external locals are cleared, because the GC resolves reference cycles.
 * @topic GarbageCollection
 */
/**
 * A cycle node whose single edge points back at its partner.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs the node's Other reference
 * @Return nothing; the edge is a plain UPROPERTY
 */
UCLASS()
class UCoverageGCCycleNode : UObject
{
	UPROPERTY()
	UObject Other;
}

UCLASS()
class ACoverageGCStrongCycleActor : AActor
{
	UPROPERTY()
	bool StrongCycleCreated = false;

	UPROPERTY()
	bool StrongCycleCollected = false;

	/**
	 * Builds the cycle, then clears the locals and collects.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; both flags record their outcome
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UCoverageGCCycleNode NodeA = Cast<UCoverageGCCycleNode>(
			NewObject(GetTransientPackage(), UCoverageGCCycleNode::StaticClass(), n"CoverageGCCycleA"));
		UCoverageGCCycleNode NodeB = Cast<UCoverageGCCycleNode>(
			NewObject(GetTransientPackage(), UCoverageGCCycleNode::StaticClass(), n"CoverageGCCycleB"));

		NodeA.Other = NodeB;
		NodeB.Other = NodeA;

		TWeakObjectPtr<UObject> WeakA = NodeA;
		TWeakObjectPtr<UObject> WeakB = NodeB;
		StrongCycleCreated = WeakA.IsValid() && WeakB.IsValid();

		NodeA = nullptr;
		NodeB = nullptr;

		CoverageGC::ForceGarbageCollectionNow();
		StrongCycleCollected = !WeakA.IsValid() && !WeakB.IsValid();
	}

	/**
	 * Observe that a locally constructed actor has built no cycle.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when both flags are still false
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool GCStrongCycleFlagsDefaultToFalse()
	{
		if (StrongCycleCreated)
		{
			return false;
		}

		return !StrongCycleCollected;
	}
}
/** @end */
/**
 * @begin g-c-weak-ptr-invalidation
 * @summary Weak pointer invalidation across collection: the weak reference is valid while a strong local exists and becomes invalid once that local is cleared and GC runs.
 * @topic GarbageCollection
 */
UCLASS()
class ACoverageGCWeakPtrInvalidationActor : AActor
{
	UPROPERTY()
	bool WeakPtrValidBeforeGC = false;

	UPROPERTY()
	bool WeakPtrInvalidAfterGC = false;

	/**
	 * Checks the weak reference before and after collection.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; both flags record their outcome
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Create an object with no strong references
		UObject TempObject = NewObject(GetTransientPackage(), UTexture2D::StaticClass());

		// Create weak reference
		TWeakObjectPtr<UObject> WeakRef = TempObject;

		// Verify weak ref is initially valid
		if (WeakRef.IsValid())
		{
			WeakPtrValidBeforeGC = true;
		}

		// Clear strong reference
		TempObject = nullptr;

		// Force GC
		CoverageGC::ForceGarbageCollectionNow();

		// Weak reference should now be invalid
		if (!WeakRef.IsValid())
		{
			WeakPtrInvalidAfterGC = true;
		}
	}

	/**
	 * Observe that a locally constructed actor has run neither check.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when both flags are still false
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool GCWeakPtrFlagsDefaultToFalse()
	{
		if (WeakPtrValidBeforeGC)
		{
			return false;
		}

		return !WeakPtrInvalidAfterGC;
	}
}
/** @end */
/**
 * @begin g-c-local-variable-no-protection
 * @summary A local variable in AngelScript does not keep a UObject alive across garbage collection, unlike a C++ stack variable. BeginPlay holds an object only in a local, forces collection, and records whether a weak reference to.
 * @topic GarbageCollection
 */
UCLASS()
class ACoverageGCLocalVariableNoProtectionActor : AActor
{
	UPROPERTY()
	bool LocalVariableDidNotProtect = false;

	/**
	 * Holds an object only in a local, then forces collection.
	 *
	 * @Covers Syntax.Variable
	 * @Inputs none
	 * @Return nothing; LocalVariableDidNotProtect records the outcome
	 */
	void TestLocalScope()
	{
		// Create object in local scope
		UObject LocalObject = NewObject(GetTransientPackage(), UTexture2D::StaticClass());

		// Create weak reference to track it
		TWeakObjectPtr<UObject> WeakRef = LocalObject;

		// Force GC while local variable still exists
		CoverageGC::ForceGarbageCollectionNow();

		// Local variables in AngelScript do NOT protect from GC
		// (Unlike C++ stack variables which do protect)
		if (!WeakRef.IsValid())
		{
			LocalVariableDidNotProtect = true;
		}
	}

	/**
	 * Runs the local-scope probe during play.
	 *
	 * @Covers Syntax.Variable
	 * @Inputs none
	 * @Return nothing; the flag is set by TestLocalScope
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TestLocalScope();
	}

	/**
	 * Observe the state of a locally constructed actor before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Variable
	 * @Inputs a locally constructed actor
	 * @Return true when the flag is still false
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool GCLocalFlagDefaultsToFalse()
	{
		return LocalVariableDidNotProtect == false;
	}
}
/** @end */
