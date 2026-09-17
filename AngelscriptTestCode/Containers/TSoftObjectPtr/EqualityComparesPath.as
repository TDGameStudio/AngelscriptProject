/**
 * @version v1
 * @summary Equality compares soft pointers by path, not by a later reset of one copy.
 * @topic Containers
 * EqualityComparesPath
 */
/**
 * @begin EqualityComparesPath
 * @summary Equality compares soft pointers by path, not by a later reset of one copy.
 * @topic Containers
 */
bool EqualityComparesPath()
{
	FSoftObjectPath Path("/Game/AngelscriptTest/PackageA.AssetA");
	TSoftObjectPtr<UObject> First;
	TSoftObjectPtr<UObject> Second;
	First = Path;
	Second = Path;
	TSoftObjectPtr<UObject> Other;
	Other = FSoftObjectPath("/Game/AngelscriptTest/PackageB.AssetB");
	TSoftObjectPtr<UObject> Empty;
	return First == Second && !(First == Other) && !(First == Empty);
}
/** @end */
