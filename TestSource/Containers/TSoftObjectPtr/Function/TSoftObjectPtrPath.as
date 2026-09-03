/**
 * TSoftObjectPtr<T> holds a path rather than a live object. The path
 * accessors — ToSoftObjectPath, ToString, GetLongPackageName, GetAssetName —
 * describe the reference without loading it, and IsValid / IsPending /
 * IsNull report which state the reference is in. A default-constructed
 * pointer is null; a path-only pointer is pending until the asset loads.
 *
 * @Theme Containers.TSoftObjectPtr
 * @Subject TSoftObjectPtr.Path
 * @Harness Function
 * @Tag Containers.TSoftObjectPtr.TSoftObjectPtrPath
 * @Namespace TSoftObjectPtrTest
 */

UCLASS()
class UTSoftObjectPtrPathObject : UObject
{
}

namespace TSoftObjectPtrTest
{
	/**
	 * Observe default construction: a fresh soft pointer is null.
	 *
	 * @Kind Observe
	 * @Covers TSoftObjectPtr.IsNull
	 * @Inputs Default-constructed TSoftObjectPtr<UObject>
	 * @Return true when IsNull() is true and IsValid() is false
	 */
	UFUNCTION()
	bool DefaultConstructionIsNull()
	{
		TSoftObjectPtr<UObject> Soft;
		return Soft.IsNull() && !Soft.IsValid();
	}

	/**
	 * Observe that a default-constructed pointer is not pending: pending
	 * means a path was set but the asset has not resolved yet, which is a
	 * different state from having no path at all.
	 *
	 * @Kind Observe
	 * @Covers TSoftObjectPtr.IsPending
	 * @Inputs Default-constructed TSoftObjectPtr<UObject>
	 * @Return true when IsPending() is false
	 */
	UFUNCTION()
	bool DefaultConstructionIsNotPending()
	{
		TSoftObjectPtr<UObject> Soft;
		return !Soft.IsPending();
	}

	/**
	 * Observe the path accessors on a default-constructed pointer: the path is
	 * empty and the name accessors return empty strings rather than throwing.
	 *
	 * @Kind Observe
	 * @Covers TSoftObjectPtr.ToSoftObjectPath
	 * @Inputs Default-constructed TSoftObjectPtr<UObject>
	 * @Return true when ToString() and GetAssetName() are both empty
	 */
	UFUNCTION()
	bool DefaultConstructionHasEmptyPath()
	{
		TSoftObjectPtr<UObject> Soft;
		return Soft.ToString() == "" && Soft.GetAssetName() == "";
	}

	/**
	 * Observe ToSoftObjectPath round-trip: constructing from a path and asking
	 * for the path back yields an equal path.
	 *
	 * @Kind Observe
	 * @Covers TSoftObjectPtr.ToSoftObjectPath
	 * @Inputs FSoftObjectPath built from a package/asset pair; construct a pointer from it
	 * @Return true when ToSoftObjectPath() equals the source path
	 */
	UFUNCTION()
	bool PathRoundTripsThroughPointer()
	{
		FSoftObjectPath Source("/Game/AngelscriptTest/SomePackage.SomeAsset");

		TSoftObjectPtr<UObject> Soft;
		Soft = Source;

		return Soft.ToSoftObjectPath() == Source;
	}

	/**
	 * Observe GetAssetName: it returns the asset part of the path, not the package.
	 *
	 * @Kind Observe
	 * @Covers TSoftObjectPtr.GetAssetName
	 * @Inputs Pointer constructed from "/Game/AngelscriptTest/SomePackage.SomeAsset"
	 * @Return true when GetAssetName() is the asset part
	 */
	UFUNCTION()
	bool GetAssetNameReturnsAssetPart()
	{
		TSoftObjectPtr<UObject> Soft;
		Soft = FSoftObjectPath("/Game/AngelscriptTest/SomePackage.SomeAsset");

		return Soft.GetAssetName() == "SomeAsset";
	}

	/**
	 * Observe GetLongPackageName: it returns the package part of the path,
	 * not the asset.
	 *
	 * @Kind Observe
	 * @Covers TSoftObjectPtr.GetLongPackageName
	 * @Inputs Pointer constructed from "/Game/AngelscriptTest/SomePackage.SomeAsset"
	 * @Return true when GetLongPackageName() is the package part
	 */
	UFUNCTION()
	bool GetLongPackageNameReturnsPackagePart()
	{
		TSoftObjectPtr<UObject> Soft;
		Soft = FSoftObjectPath("/Game/AngelscriptTest/SomePackage.SomeAsset");

		return Soft.GetLongPackageName() == "/Game/AngelscriptTest/SomePackage";
	}

	/**
	 * Observe that a path-only pointer is pending: the path is set but the
	 * asset it names has not been resolved.
	 *
	 * @Kind Observe
	 * @Covers TSoftObjectPtr.IsPending
	 * @Inputs Pointer constructed from a path that names no loaded asset
	 * @Return true when IsPending() is true, IsNull() is false, IsValid() is false
	 */
	UFUNCTION()
	bool PathOnlyPointerIsPending()
	{
		TSoftObjectPtr<UObject> Soft;
		Soft = FSoftObjectPath("/Game/AngelscriptTest/NotLoaded.Never");

		return Soft.IsPending() && !Soft.IsNull() && !Soft.IsValid();
	}

	/**
	 * Observe Reset: it clears the path and returns the pointer to null.
	 *
	 * @Kind Observe
	 * @Covers TSoftObjectPtr.Reset
	 * @Inputs Pointer constructed from a path; Reset()
	 * @Return true when IsNull() is true and the path string is empty afterwards
	 */
	UFUNCTION()
	bool ResetClearsPath()
	{
		TSoftObjectPtr<UObject> Soft;
		Soft = FSoftObjectPath("/Game/AngelscriptTest/SomePackage.SomeAsset");
		if (Soft.IsNull())
		{
			return false;
		}

		Soft.Reset();
		return Soft.IsNull() && Soft.ToString() == "";
	}

	/**
	 * In-only: read the path out of a const&in TSoftObjectPtr<UObject>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSoftObjectPtr.ToSoftObjectPath
	 * @Param Value Source pointer received as const TSoftObjectPtr<UObject>&in
	 * @Inputs Value was constructed from the canonical path
	 * @Return true when ToSoftObjectPath() equals that path
	 */
	UFUNCTION()
	bool ReadPath(const TSoftObjectPtr<UObject>&in Value)
	{
		FSoftObjectPath Expected("/Game/AngelscriptTest/SomePackage.SomeAsset");
		return Value.ToSoftObjectPath() == Expected;
	}

	/**
	 * Out-only: fill an empty &out TSoftObjectPtr<UObject> with a path.
	 *
	 * @Kind RoundTrip
	 * @Covers TSoftObjectPtr.opAssign
	 * @Param Result Destination received as TSoftObjectPtr<UObject>&out
	 * @Inputs Empty &out TSoftObjectPtr<UObject>
	 * @Return void; Result holds the canonical path
	 */
	UFUNCTION()
	void FillWithPath(TSoftObjectPtr<UObject>&out Result)
	{
		Result = FSoftObjectPath("/Game/AngelscriptTest/SomePackage.SomeAsset");
	}

	/**
	 * Inout: reset an already-populated TSoftObjectPtr<UObject>.
	 *
	 * @Kind RoundTrip
	 * @Covers TSoftObjectPtr.Reset
	 * @Param Value Pointer received as TSoftObjectPtr<UObject>&inout, starts holding a path
	 * @Inputs Value.IsNull() is false
	 * @Return void; Value is null again
	 */
	UFUNCTION()
	void ResetPath(TSoftObjectPtr<UObject>&inout Value)
	{
		Value.Reset();
	}
}
