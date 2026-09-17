/**
 * @version v1
 * @summary ToString of a live Actor CDO path is nonempty and matches package plus asset name.
 * @topic Containers
 *
 * ToStringLiveCdo
 */
/**
 * @begin ToStringLiveCdo
 * @summary ToString of a live Actor CDO path is nonempty and matches package plus asset name.
 * @topic Containers
 */
bool ToStringLiveCdo()
{
	AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
	if (LiveCdo is null)
	{
		throw("ToStringLiveCdo setup: required Actor CDO is null");
	}
	FSoftObjectPath ObjectPath(LiveCdo);
	FString Text = ObjectPath.ToString();
	FString Rebuilt = ObjectPath.GetLongPackageName() + "." + ObjectPath.GetAssetName();
	return ObjectPath.IsValid() && Text.Len() > 0 && Text == Rebuilt;
}
/** @end */
