/**
 * @version v1
 * @summary USTRUCT(Immutable) is not a script-side specifier, so this program is rejected.
 * @topic Definitions
 */
/**
 * @version root
 * @summary USTRUCT(Immutable) is not a script-side specifier, so this program is rejected.
 * @topic Negative
 */
USTRUCT(Immutable)
struct FImmutableStruct
{
	UPROPERTY()
	int Value = 1;
}
/** @end */
