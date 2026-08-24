// Purpose: Observe TSoftClassPtr IsNull and Get as TSubclassOf, including
// empty, live, and pending class references.
// AS-facing API: bool TSoftClassPtr<T>.IsNull() const;
// TSubclassOf<T> TSoftClassPtr<T>.Get() const;
// Inputs: Empty class ptr, AActor::StaticClass(), and a missing class path.
// Expected observations: Empty IsNull true and Get invalid. Live class Get
// matches AActor::StaticClass(). Missing path IsNull false and Get invalid.
// Boundary/ownership: Get does not load. Editor-only synchronous load of an
// actor soft pointer is the diagnostic throw.

namespace TS_TSoftObjectPtr_Queries_02
{
	bool Observe_IsNull_Nominal()
	{
		TSoftClassPtr<AActor> Empty;
		TSoftClassPtr<AActor> ClassRef = AActor::StaticClass();
		TSoftClassPtr<AActor> Missing(FSoftObjectPath("/Game/DoesNotExist.DoesNotExist"));
		return Empty.IsNull() && !ClassRef.IsNull() && !Missing.IsNull();
	}

	bool Observe_Get_Nominal()
	{
		TSoftClassPtr<AActor> Empty;
		TSubclassOf<AActor> EmptyClass = Empty.Get();
		TSoftClassPtr<AActor> ClassRef = AActor::StaticClass();
		TSubclassOf<AActor> LoadedClass = ClassRef.Get();
		TSoftClassPtr<AActor> Missing(FSoftObjectPath("/Game/DoesNotExist.DoesNotExist"));
		TSubclassOf<AActor> MissingClass = Missing.Get();
		return !EmptyClass.IsValid() &&
			LoadedClass.Get() == AActor::StaticClass() &&
			!MissingClass.IsValid();
	}

	void ExerciseExpectedFailure()
	{
		AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
		TSoftObjectPtr<AActor> ActorRef = LiveCdo;
		AActor Loaded = ActorRef.EditorOnlyLoadSynchronous();
	}
}
