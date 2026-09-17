/**
 * @version v1
 * @summary Observe FSoftObjectPath/FSoftClassPath construction from strings and live handles, plus TryLoad/ResolveObject and TryLoadClass/ResolveClass.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FSoftObjectPath/FSoftClassPath construction from strings and live handles, plus TryLoad/ResolveObject and TryLoadClass/ResolveClass.
 * @topic Baseline
 */
// Each function returns the exact comparison for the C++ runner.
// AS-facing API: FSoftObjectPath Value(const FString& Path);
// FSoftObjectPath Value(const UObject InObject);
// UObject FSoftObjectPath.TryLoad() const;
// UObject FSoftObjectPath.ResolveObject() const;
// FSoftClassPath Value(const FString& Path);
// FSoftClassPath Value(const UClass InClass);
// UClass FSoftClassPath.ResolveClass() const;
// UClass FSoftClassPath.TryLoadClass() const;
// Inputs: Live actor CDO, AActor::StaticClass(), empty/null handles, a
// reconstructed string path from GetLongPackageName/GetAssetName, and a
// missing package path.
// Expected observations: Construction from a live object/class is non-null.
// Resolve/TryLoad of a live CDO returns that identity. Empty/null inputs
// produce null paths and null load results. Missing paths resolve to null.
// Boundary/ownership: ResolveObject/ResolveClass do not load. TryLoad may
// load; a missing path returns null rather than throwing.

namespace TS_SoftObjectPath_Behavior_01
{
	bool Observe_Value_Nominal()
	{
		FSoftObjectPath EmptyFromString("");
		AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
		if (LiveCdo is null)
		{
			throw("TS_SoftObjectPath_Behavior_01 setup: required Actor CDO is null");
		}
		FSoftObjectPath FromObject(LiveCdo);
		AActor NullObject = nullptr;
		FSoftObjectPath FromNullObject(NullObject);
		FString PackageName = FromObject.GetLongPackageName();
		FString AssetName = FromObject.GetAssetName();
		FSoftObjectPath FromString(PackageName + "." + AssetName);
		FSoftClassPath EmptyClassFromString("");
		FSoftClassPath FromClass(AActor::StaticClass());
		UClass NullClass = nullptr;
		FSoftClassPath FromNullClass(NullClass);
		return EmptyFromString.IsNull() && FromObject.IsValid() && !FromObject.IsNull() && FromNullObject.IsNull() && FromString.IsValid() && EmptyClassFromString.IsNull() && FromClass.IsValid() && FromNullClass.IsNull();
	}

	bool Observe_TryLoad_Nominal()
	{
		AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
		if (LiveCdo is null)
		{
			throw("TS_SoftObjectPath_Behavior_01 setup: required Actor CDO is null");
		}
		FSoftObjectPath FromObject(LiveCdo);
		UObject Loaded = FromObject.TryLoad();
		FSoftObjectPath Empty;
		UObject EmptyLoaded = Empty.TryLoad();
		FSoftObjectPath Missing("/Game/DoesNotExist.DoesNotExist");
		UObject MissingLoaded = Missing.TryLoad();
		return Loaded == LiveCdo && EmptyLoaded is null && MissingLoaded is null;
	}

	bool Observe_ResolveObject_Nominal()
	{
		AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
		if (LiveCdo is null)
		{
			throw("TS_SoftObjectPath_Behavior_01 setup: required Actor CDO is null");
		}
		FSoftObjectPath FromObject(LiveCdo);
		UObject Resolved = FromObject.ResolveObject();
		FSoftObjectPath Empty;
		UObject EmptyResolved = Empty.ResolveObject();
		FSoftObjectPath Missing("/Game/DoesNotExist.DoesNotExist");
		UObject MissingResolved = Missing.ResolveObject();
		return Resolved == LiveCdo && EmptyResolved is null && MissingResolved is null;
	}

	bool Observe_ResolveClass_Nominal()
	{
		UClass ActorClass = AActor::StaticClass();
		if (ActorClass is null)
		{
			throw("TS_SoftObjectPath_Behavior_01 setup: required Actor class is null");
		}
		FSoftClassPath FromClass(ActorClass);
		UClass Resolved = FromClass.ResolveClass();
		FSoftClassPath Empty;
		UClass EmptyResolved = Empty.ResolveClass();
		return Resolved == ActorClass && EmptyResolved is null;
	}

	bool Observe_TryLoadClass_Nominal()
	{
		UClass ActorClass = AActor::StaticClass();
		if (ActorClass is null)
		{
			throw("TS_SoftObjectPath_Behavior_01 setup: required Actor class is null");
		}
		FSoftClassPath FromClass(ActorClass);
		UClass Loaded = FromClass.TryLoadClass();
		FSoftClassPath Empty;
		UClass EmptyLoaded = Empty.TryLoadClass();
		FSoftClassPath Missing("/Game/DoesNotExist.DoesNotExist");
		UClass MissingLoaded = Missing.TryLoadClass();
		return Loaded == ActorClass && EmptyLoaded is null && MissingLoaded is null;
	}
}
/** @end */
