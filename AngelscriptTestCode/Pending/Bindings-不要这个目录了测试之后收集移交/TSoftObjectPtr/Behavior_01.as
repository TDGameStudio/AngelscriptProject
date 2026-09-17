/**
 * @version v1
 * @summary Observe TSoftObjectPtr/TSoftClassPtr declarations and constructors, plus editor-only synchronous load of a non-actor UObject.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe TSoftObjectPtr/TSoftClassPtr declarations and constructors, plus editor-only synchronous load of a non-actor UObject.
 * @topic Baseline
 */
// TSoftObjectPtr<T> Value(); TSoftObjectPtr<T> Value(const FSoftObjectPath& Path);
// TSoftObjectPtr<T> Value(T Object); TSoftObjectPtr<T> Value(const TSoftObjectPtr<T>& Other);
// T TSoftObjectPtr<T>.EditorOnlyLoadSynchronous() const;
// TSoftClassPtr<T> Value(); TSoftClassPtr<T> Value(const FSoftObjectPath& Path);
// TSoftClassPtr<T> Value(UClass Object);
// Inputs: Empty declarations, FSoftObjectPath from a live UObject CDO, that
// CDO as T Object, a copied pointer, AActor::StaticClass() as UClass, and
// EditorOnlyLoadSynchronous on the UObject CDO.
// Expected observations: Empty constructors are null. Path/object
// constructors Get the live CDO. Copy constructor preserves identity.
// Class constructors from UClass are valid. EditorOnlyLoadSynchronous
// returns the already-loaded UObject CDO.
// Boundary/ownership: Constructors store a path without forcing a load.
// EditorOnlyLoadSynchronous is editor-only and throws for actor/component
// types.

namespace TS_TSoftObjectPtr_Behavior_01
{
	// Default TSoftObjectPtr<UObject> is null and Get() is nullptr.
	bool Observe_Surface001_Nominal()
	{
		TSoftObjectPtr<UObject> ObjectRef;
		return ObjectRef.IsNull() && ObjectRef.Get() == nullptr;
	}

	// Default TSoftClassPtr<AActor> is null and Get() is invalid.
	bool Observe_Surface002_Nominal()
	{
		TSoftClassPtr<AActor> ClassRef;
		return ClassRef.IsNull() && !ClassRef.Get().IsValid();
	}

	// Path/object/copy constructors preserve CDO identity; empty class ctor is null.
	bool Observe_Value_Nominal()
	{
		TSoftObjectPtr<UObject> Empty = TSoftObjectPtr<UObject>();
		UObject LiveCdo = TSubclassOf<UObject>(UObject::StaticClass()).GetDefaultObject();
		if (LiveCdo is null)
		{
			throw("TS_TSoftObjectPtr_Behavior_01 setup: required UObject CDO is null");
		}
		FSoftObjectPath Path(LiveCdo);
		TSoftObjectPtr<UObject> FromPath(Path);
		TSoftObjectPtr<UObject> FromObject(LiveCdo);
		TSoftObjectPtr<UObject> Copied(FromObject);
		TSoftClassPtr<AActor> EmptyClass = TSoftClassPtr<AActor>();
		TSoftClassPtr<AActor> FromClassPath(TSoftClassPtr<AActor>(AActor::StaticClass()).ToSoftObjectPath());
		TSoftClassPtr<AActor> FromClass(AActor::StaticClass());
		return Empty.IsNull() &&
			FromPath.Get() == LiveCdo &&
			FromPath.ToSoftObjectPath() == Path &&
			FromObject.Get() == LiveCdo &&
			Copied.Get() == LiveCdo &&
			Copied == FromObject &&
			EmptyClass.IsNull() &&
			FromClassPath.Get().Get() == AActor::StaticClass() &&
			FromClass.Get().Get() == AActor::StaticClass();
	}

	// EditorOnlyLoadSynchronous of a live UObject CDO returns that CDO; empty is null.
	bool Observe_EditorOnlyLoadSynchronous_Nominal()
	{
		UObject LiveCdo = TSubclassOf<UObject>(UObject::StaticClass()).GetDefaultObject();
		if (LiveCdo is null)
		{
			throw("TS_TSoftObjectPtr_Behavior_01 setup: required UObject CDO is null");
		}
		TSoftObjectPtr<UObject> ObjectRef = LiveCdo;
		UObject Loaded = ObjectRef.EditorOnlyLoadSynchronous();
		TSoftObjectPtr<UObject> Empty;
		UObject EmptyLoaded = Empty.EditorOnlyLoadSynchronous();
		return Loaded == LiveCdo && EmptyLoaded == nullptr;
	}
}
/** @end */
