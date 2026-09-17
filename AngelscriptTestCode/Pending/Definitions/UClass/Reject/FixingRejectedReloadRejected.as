/**
 * @version v1
 * @summary SoftReload of a UCLASS module into a USTRUCT is rejected. The type-kind swap requires a full reload instead of publishing the struct.
 * @topic Definitions
 */
/**
 * @version root
 * @summary SoftReload of a UCLASS module into a USTRUCT is rejected. The type-kind swap requires a full reload instead of publishing the struct.
 * @topic Negative
 */
USTRUCT()
struct FClassGeneratorNameConflictRecovery
{
	UPROPERTY()
	int Value = 2;
}
/** @end */
