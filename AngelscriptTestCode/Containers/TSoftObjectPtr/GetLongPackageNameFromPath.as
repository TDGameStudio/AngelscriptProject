/**
 * @version v1
 * @summary GetLongPackageName returns the package part of the path and is empty when null.
 * @topic Containers
 * GetLongPackageNameFromPath
 */
/**
 * @begin GetLongPackageNameFromPath
 * @summary GetLongPackageName returns the package part of the path and is empty when null.
 * @topic Containers
 */
bool GetLongPackageNameFromPath()
{
	TSoftObjectPtr<UObject> Empty;
	TSoftObjectPtr<UObject> Soft;
	Soft = FSoftObjectPath("/Game/AngelscriptTest/SomePackage.SomeAsset");
	return Empty.GetLongPackageName().IsEmpty()
		&& Soft.GetLongPackageName() == "/Game/AngelscriptTest/SomePackage";
}
/** @end */
