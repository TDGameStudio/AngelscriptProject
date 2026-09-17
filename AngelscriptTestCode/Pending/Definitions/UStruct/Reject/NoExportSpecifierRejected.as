/**
 * @version v1
 * @summary USTRUCT(NoExport) is not a script-side specifier, so this program is rejected.
 * @topic Definitions
 */
/**
 * @version root
 * @summary USTRUCT(NoExport) is not a script-side specifier, so this program is rejected.
 * @topic Negative
 */
USTRUCT(NoExport)
struct FNoExportStruct
{
	UPROPERTY()
	int Value = 1;
}
/** @end */
