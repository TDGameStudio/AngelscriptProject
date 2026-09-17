/**
 * @version v1
 * @summary USTRUCT(Atomic) is not a script-side specifier, so this program is rejected.
 * @topic Definitions
 */
/**
 * @version root
 * @summary USTRUCT(Atomic) is not a script-side specifier, so this program is rejected.
 * @topic Negative
 */
USTRUCT(Atomic)
struct FAtomicStruct
{
	UPROPERTY()
	int Value = 1;
}
/** @end */
