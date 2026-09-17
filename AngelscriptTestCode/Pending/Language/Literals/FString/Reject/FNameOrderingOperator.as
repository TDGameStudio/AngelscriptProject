/**
 * @version v1
 * @summary Ordering two FNames with the less-than operator is rejected: this fork exposes no ordering operator for names. This file is the illegal program itself; do not compare the underlying strings instead, since the missing.
 * @topic Language
 */
/**
 * @version root
 * @summary Ordering two FNames with the less-than operator is rejected: this fork exposes no ordering operator for names. This file is the illegal program itself; do not compare the underlying strings instead, since the missing.
 * @topic Negative
 */
/** */
bool TryNameOrdering()
{
	FName Left = n"Alpha";
	FName Right = n"Beta";
	return Left < Right;
}
/** @end */
