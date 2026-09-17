/**
 * @version v1
 * @summary Replicated plus NotReplicated on a UCLASS member is rejected. NotReplicated is only allowed on structs. This file is the illegal program itself; do not drop either specifier.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Replicated plus NotReplicated on a UCLASS member is rejected. NotReplicated is only allowed on structs. This file is the illegal program itself; do not drop either specifier.
 * @topic Negative
 */
class AUPropConflictRepActor : AActor
{
	UPROPERTY(Replicated, NotReplicated)
	int X = 0;
}
/** @end */
