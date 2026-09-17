/**
 * @version v1
 * @summary UFUNCTION may not annotate a property. int X is a field, not a method, so the specifier is illegal. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary UFUNCTION may not annotate a property. int X is a field, not a method, so the specifier is illegal. This file is the illegal program itself.
 * @topic Negative
 */
class AUFuncOnPropActor : AActor
{
	UFUNCTION()
	int X = 0;
}
/** @end */
