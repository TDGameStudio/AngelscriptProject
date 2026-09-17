/**
 * @version v1
 * @summary GetAssetName returns the asset part of the path and is empty when null.
 * @topic Containers
 * GetAssetNameFromPath
 */
/**
 * @begin GetAssetNameFromPath
 * @summary GetAssetName returns the asset part of the path and is empty when null.
 * @topic Containers
 */
bool GetAssetNameFromPath()
{
	TSoftObjectPtr<UObject> Empty;
	TSoftObjectPtr<UObject> Soft;
	Soft = FSoftObjectPath("/Game/AngelscriptTest/SomePackage.SomeAsset");
	return Empty.GetAssetName().IsEmpty() && Soft.GetAssetName() == "SomeAsset";
}
/** @end */
