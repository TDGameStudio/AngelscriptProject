/**
 * @version v1
 * @summary auto is not a UPROPERTY type. This file is the illegal program itself; do not replace auto with an explicit type.
 * @topic Definitions
 */
/**
 * @version root
 * @summary auto is not a UPROPERTY type. This file is the illegal program itself; do not replace auto with an explicit type.
 * @topic Negative
 */
class AUPropAutoActor : AActor
{
	UPROPERTY()
	auto X = 5;
}
/** @end */
