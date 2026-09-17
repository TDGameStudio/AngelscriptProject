/**
 * @version v1
 * @summary Declaring the same struct name twice is rejected. This file is the illegal program itself; do not rename the second struct, since the collision is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary Declaring the same struct name twice is rejected. This file is the illegal program itself; do not rename the second struct, since the collision is the point.
 * @topic Negative
 */
/**
 * The first declaration of the duplicated struct.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 */
struct FDup
{
	int X;
}

/**
 * The second declaration of the same struct name.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 */
struct FDup
{
	int Y;
}
/** @end */
