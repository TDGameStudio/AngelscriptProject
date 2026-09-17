/**
 * @version v1
 * @summary Observe package/asset/subobject queries on FSoftObjectPath and FSoftClassPath, including empty and subobject-suffix receivers. Each function returns the exact comparison for the C++ runner.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe package/asset/subobject queries on FSoftObjectPath and FSoftClassPath, including empty and subobject-suffix receivers. Each function returns the exact comparison for the C++ runner.
 * @topic Baseline
 */
// FString FSoftObjectPath.GetAssetName() const;
// FTopLevelAssetPath FSoftObjectPath.GetAssetPath() const;
// bool FSoftObjectPath.IsValid() const; bool FSoftObjectPath.IsNull() const;
// bool FSoftObjectPath.IsAsset() const; bool FSoftObjectPath.IsSubobject() const;
// FString FSoftClassPath.GetLongPackageName() const;
// FString FSoftClassPath.GetAssetName() const;
// FTopLevelAssetPath FSoftClassPath.GetAssetPath() const;
// Inputs: Default-empty paths, paths from a live actor CDO / AActor class,
// and a string path with a :Subobject suffix as the boundary.
// Expected observations: Empty IsNull is true and names are empty. CDO paths
// are valid assets with non-empty package and asset names. Subobject suffix
// reports IsSubobject true and IsAsset false.
// Boundary/ownership: Queries do not load the referenced object. Invalid
// index-style access is not part of this bind; the diagnostic companion
// re-reads a malformed string path.

namespace TS_SoftObjectPath_Queries_01
{
	bool Observe_GetLongPackageName_Nominal()
	{
		FSoftObjectPath Empty;
		AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
		if (LiveCdo is null)
		{
			throw("TS_SoftObjectPath_Queries_01 setup: required Actor CDO is null");
		}
		FSoftObjectPath ObjectPath(LiveCdo);
		FSoftClassPath EmptyClass;
		FSoftClassPath ClassPath(AActor::StaticClass());
		return Empty.GetLongPackageName().IsEmpty() && ObjectPath.GetLongPackageName().Len() > 0 && EmptyClass.GetLongPackageName().IsEmpty() && ClassPath.GetLongPackageName().Len() > 0;
	}

	bool Observe_GetAssetName_Nominal()
	{
		FSoftObjectPath Empty;
		AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
		if (LiveCdo is null)
		{
			throw("TS_SoftObjectPath_Queries_01 setup: required Actor CDO is null");
		}
		FSoftObjectPath ObjectPath(LiveCdo);
		FSoftClassPath EmptyClass;
		FSoftClassPath ClassPath(AActor::StaticClass());
		return Empty.GetAssetName().IsEmpty() && ObjectPath.GetAssetName().Len() > 0 && EmptyClass.GetAssetName().IsEmpty() && ClassPath.GetAssetName().Len() > 0;
	}

	bool Observe_GetAssetPath_Nominal()
	{
		FSoftObjectPath Empty;
		AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
		if (LiveCdo is null)
		{
			throw("TS_SoftObjectPath_Queries_01 setup: required Actor CDO is null");
		}
		FSoftObjectPath ObjectPath(LiveCdo);
		FSoftClassPath EmptyClass;
		FSoftClassPath ClassPath(AActor::StaticClass());
		return Empty.GetAssetPath().IsNull() && ObjectPath.GetAssetPath().IsValid() && EmptyClass.GetAssetPath().IsNull() && ClassPath.GetAssetPath().IsValid();
	}

	bool Observe_IsValid_Nominal()
	{
		FSoftObjectPath Empty;
		AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
		if (LiveCdo is null)
		{
			throw("TS_SoftObjectPath_Queries_01 setup: required Actor CDO is null");
		}
		FSoftObjectPath ObjectPath(LiveCdo);
		return !Empty.IsValid() && ObjectPath.IsValid();
	}

	bool Observe_IsNull_Nominal()
	{
		FSoftObjectPath Empty;
		AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
		if (LiveCdo is null)
		{
			throw("TS_SoftObjectPath_Queries_01 setup: required Actor CDO is null");
		}
		FSoftObjectPath ObjectPath(LiveCdo);
		return Empty.IsNull() && !ObjectPath.IsNull();
	}

	bool Observe_IsAsset_Nominal()
	{
		AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
		if (LiveCdo is null)
		{
			throw("TS_SoftObjectPath_Queries_01 setup: required Actor CDO is null");
		}
		FSoftObjectPath ObjectPath(LiveCdo);
		FSoftObjectPath SubobjectPath("/Engine/Transient.Default__Actor:Root");
		FSoftObjectPath Empty;
		return ObjectPath.IsAsset() && !SubobjectPath.IsAsset() && !Empty.IsAsset();
	}

	bool Observe_IsSubobject_Nominal()
	{
		AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
		if (LiveCdo is null)
		{
			throw("TS_SoftObjectPath_Queries_01 setup: required Actor CDO is null");
		}
		FSoftObjectPath ObjectPath(LiveCdo);
		FSoftObjectPath SubobjectPath("/Engine/Transient.Default__Actor:Root");
		FSoftObjectPath Empty;
		return !ObjectPath.IsSubobject() && SubobjectPath.IsSubobject() && !Empty.IsSubobject();
	}

	void ExerciseExpectedFailure()
	{
		FSoftObjectPath Malformed("::::");
		bool bMalformedValid = Malformed.IsValid();
		FString MalformedName = Malformed.GetAssetName();
		FSoftClassPath MalformedClass("::::");
		FString MalformedClassName = MalformedClass.GetAssetName();
	}
}
/** @end */
