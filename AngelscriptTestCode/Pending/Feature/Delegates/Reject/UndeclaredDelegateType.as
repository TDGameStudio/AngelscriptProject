/**
 * @version v1
 * @summary A UPROPERTY whose type is an undeclared delegate is rejected. FNonExistentDelegate has no declaration, so the member cannot be formed.
 * @topic Feature
 */
/**
 * @version root
 * @summary A UPROPERTY whose type is an undeclared delegate is rejected. FNonExistentDelegate has no declaration, so the member cannot be formed.
 * @topic Negative
 */
class ADelUndeclaredActor : AActor
{
	UPROPERTY()
	FNonExistentDelegate OnAction;
}
/** @end */
