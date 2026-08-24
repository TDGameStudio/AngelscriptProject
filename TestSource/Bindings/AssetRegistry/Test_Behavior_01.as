// Purpose: Observe FTopLevelAssetPath constructors from object, string, and
// package/asset names.
// AS-facing API: FTopLevelAssetPath Path(const UObject AssetObject);
// FTopLevelAssetPath Path(const FString& AssetPath);
// FTopLevelAssetPath Path(const FName& PackageName, const FName& AssetName);
// Inputs: AActor::StaticClass() as the object, "/Script/Engine.Actor" as the
// string, n"/Script/Engine" plus n"Actor" as names, nullptr as the empty
// object, and "" / NAME_None as empty name inputs.
// Expected observations: Object, string, and name constructors of Actor
// compare equal and IsValid. Null object and empty names produce a null or
// invalid path.
// Boundary/ownership: Constructors copy path names. They do not keep the
// source UObject alive.

namespace TS_AssetRegistry_Behavior_01
{
	bool Observe_Path_Nominal()
	{
		FTopLevelAssetPath FromObject(AActor::StaticClass());
		FTopLevelAssetPath FromString("/Script/Engine.Actor");
		FTopLevelAssetPath FromNames(n"/Script/Engine", n"Actor");

		UObject NullObject = nullptr;
		FTopLevelAssetPath FromNull(NullObject);
		FTopLevelAssetPath FromEmptyString("");
		FTopLevelAssetPath FromNoneNames(NAME_None, NAME_None);

		return FromObject.IsValid() &&
			FromString.IsValid() &&
			FromString == FromObject &&
			FromNames.IsValid() &&
			FromNames == FromObject &&
			(FromNull.IsNull() || !FromNull.IsValid()) &&
			(FromEmptyString.IsNull() || !FromEmptyString.IsValid()) &&
			(FromNoneNames.IsNull() || !FromNoneNames.IsValid());
	}
}
