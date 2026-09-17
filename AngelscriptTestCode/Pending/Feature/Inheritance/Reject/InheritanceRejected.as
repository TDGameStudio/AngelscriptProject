/**
 * @version v1
 * @summary A USTRUCT may not use inheritance syntax. This file is the illegal program itself; dropping ": FBaseStruct" would make it compile.
 * @topic Feature
 */
/**
 * @version root
 * @summary A USTRUCT may not use inheritance syntax. This file is the illegal program itself; dropping ": FBaseStruct" would make it compile.
 * @topic Negative
 */
USTRUCT()
struct FDerivedStruct : FBaseStruct
{
	UPROPERTY()
	int Value;
}
/** @end */
