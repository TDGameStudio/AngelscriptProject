/**
 * @version v1
 * @summary Ordering two vectors with the less-than operator is rejected: vectors have no ordering. This file is the illegal program itself; do not compare component-wise, since the unsupported operator is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary Ordering two vectors with the less-than operator is rejected: vectors have no ordering. This file is the illegal program itself; do not compare component-wise, since the unsupported operator is the point.
 * @topic Negative
 */
/** */
void Test()
{
	bool X = FVector(1,0,0) < FVector(0,1,0);
}
/** @end */
