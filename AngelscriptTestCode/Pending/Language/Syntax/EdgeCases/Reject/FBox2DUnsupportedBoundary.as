/**
 * @version v1
 * @summary FBox2D is not on the AngelScript binding surface, so any use of it is rejected. This file is the illegal program itself; do not add declarations that would compile it away, since the missing type is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary FBox2D is not on the AngelScript binding surface, so any use of it is rejected. This file is the illegal program itself; do not add declarations that would compile it away, since the missing type is the point.
 * @topic Negative
 */
/**
 * Attempt to construct and query an FBox2D.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 */
bool TriggerUnsupportedFBox2D()
{
	FBox2D Box = FBox2D(FVector2D(0, 0), FVector2D(100, 100));
	return Box.IsInside(FVector2D(50, 50));
}
/** @end */
