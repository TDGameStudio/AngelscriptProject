// Purpose: Observe Get/IsValid/IsChildOf/GetDefaultObject queries on
// TSubclassOf plus Get/IsValid/IsStale/IsExplicitlyNull on pointer wrappers.
// AS-facing API: UClass TSubclassOf<T>.Get() const;
// bool TSubclassOf<T>.IsValid() const;
// bool TSubclassOf<T>.IsChildOf(UClass Other) const;
// T TSubclassOf<T>.GetDefaultObject() const;
// T TObjectPtr<T>.Get() const;
// T TWeakObjectPtr<T>.Get() const;
// bool TWeakObjectPtr<T>.IsValid() const;
// bool TWeakObjectPtr<T>.IsStale() const;
// bool TWeakObjectPtr<T>.IsExplicitlyNull() const;
// Inputs: Empty subclass, APawn class as a child of AActor, actor CDO as a
// live handle, and an explicitly null weak pointer.
// Expected observations: Empty Get() is null and IsValid() is false. Pawn
// IsChildOf(AActor) is true. Live Get() returns the same CDO identity.
// Explicitly null weak pointers report IsExplicitlyNull true and IsStale false.
// Boundary/ownership: GetDefaultObject returns the class CDO without transferring
// ownership. Weak Get() returns null when the object is gone. Assigning an
// incompatible UClass is the expected-failure path.

namespace TS_BlueprintType_Queries_01
{
	bool Observe_Get_Nominal()
	{
		TSubclassOf<AActor> EmptySubclass;
		UClass EmptyClass = EmptySubclass.Get();
		bool bEmptyGetIsNull = EmptyClass is null;

		TSubclassOf<AActor> ActorSubclass = AActor::StaticClass();
		UClass SelectedClass = ActorSubclass.Get();
		bool bSelectedGetMatches = SelectedClass == AActor::StaticClass();

		AActor LiveCdo = ActorSubclass.GetDefaultObject();
		if (LiveCdo is null)
		{
			throw("TS_BlueprintType_Queries_01 setup: required Actor CDO is null");
		}
		TObjectPtr<AActor> ObjectPtr = LiveCdo;
		AActor FromObjectPtr = ObjectPtr.Get();
		bool bObjectPtrGetMatches = FromObjectPtr == LiveCdo;

		TObjectPtr<AActor> NullPtr;
		AActor FromNullPtr = NullPtr.Get();
		bool bNullObjectPtrGetIsNull = FromNullPtr is null;

		TWeakObjectPtr<AActor> WeakPtr = LiveCdo;
		AActor FromWeak = WeakPtr.Get();
		bool bWeakGetMatches = FromWeak == LiveCdo;

		TWeakObjectPtr<AActor> NullWeak;
		AActor FromNullWeak = NullWeak.Get();
		bool bNullWeakGetIsNull = FromNullWeak is null;

		return bEmptyGetIsNull &&
			bSelectedGetMatches &&
			bObjectPtrGetMatches &&
			bNullObjectPtrGetIsNull &&
			bWeakGetMatches &&
			bNullWeakGetIsNull;
	}

	bool Observe_IsValid_Nominal()
	{
		TSubclassOf<AActor> EmptySubclass;
		bool bEmptySubclassInvalid = EmptySubclass.IsValid();
		TSubclassOf<AActor> ActorSubclass = AActor::StaticClass();
		bool bActorSubclassValid = ActorSubclass.IsValid();

		AActor LiveCdo = ActorSubclass.GetDefaultObject();
		if (LiveCdo is null)
		{
			throw("TS_BlueprintType_Queries_01 setup: required Actor CDO is null");
		}
		TWeakObjectPtr<AActor> LiveWeak = LiveCdo;
		bool bLiveWeakValid = LiveWeak.IsValid();
		TWeakObjectPtr<AActor> NullWeak;
		bool bNullWeakValid = NullWeak.IsValid();

		return !bEmptySubclassInvalid && bActorSubclassValid && bLiveWeakValid && !bNullWeakValid;
	}

	bool Observe_IsChildOf_Nominal()
	{
		TSubclassOf<AActor> PawnSubclass = APawn::StaticClass();
		bool bPawnIsChildOfActor = PawnSubclass.IsChildOf(AActor::StaticClass());
		bool bPawnIsChildOfPawn = PawnSubclass.IsChildOf(APawn::StaticClass());
		bool bPawnIsChildOfObject = PawnSubclass.IsChildOf(UObject::StaticClass());
		bool bPawnIsChildOfPlayerController = PawnSubclass.IsChildOf(APlayerController::StaticClass());
		return bPawnIsChildOfActor && bPawnIsChildOfPawn && bPawnIsChildOfObject && !bPawnIsChildOfPlayerController;
	}

	bool Observe_GetDefaultObject_Nominal()
	{
		TSubclassOf<AActor> EmptySubclass;
		AActor EmptyCdo = EmptySubclass.GetDefaultObject();
		bool bEmptyCdoIsNull = EmptyCdo is null;

		TSubclassOf<AActor> ActorSubclass = AActor::StaticClass();
		AActor ActorCdo = ActorSubclass.GetDefaultObject();
		bool bActorCdoIsLive = ActorCdo != nullptr;
		return bEmptyCdoIsNull && bActorCdoIsLive;
	}

	bool Observe_IsStale_Nominal()
	{
		AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
		if (LiveCdo is null)
		{
			throw("TS_BlueprintType_Queries_01 setup: required Actor CDO is null");
		}
		TWeakObjectPtr<AActor> LiveWeak = LiveCdo;
		bool bLiveIsStale = LiveWeak.IsStale();
		TWeakObjectPtr<AActor> NullWeak;
		bool bExplicitNullIsStale = NullWeak.IsStale();
		return !bLiveIsStale && !bExplicitNullIsStale;
	}

	bool Observe_IsExplicitlyNull_Nominal()
	{
		AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
		if (LiveCdo is null)
		{
			throw("TS_BlueprintType_Queries_01 setup: required Actor CDO is null");
		}
		TWeakObjectPtr<AActor> LiveWeak = LiveCdo;
		bool bLiveIsExplicitlyNull = LiveWeak.IsExplicitlyNull();
		TWeakObjectPtr<AActor> NullWeak;
		bool bNullIsExplicitlyNull = NullWeak.IsExplicitlyNull();
		return !bLiveIsExplicitlyNull && bNullIsExplicitlyNull;
	}

	void ExerciseExpectedFailure()
	{
		TSubclassOf<AActor> ActorSubclass = AActor::StaticClass();
		UClass Incompatible = UObject::StaticClass();
		ActorSubclass.Set(Incompatible);
	}
}
