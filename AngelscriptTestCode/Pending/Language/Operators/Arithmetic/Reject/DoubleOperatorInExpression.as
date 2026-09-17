/**
 * @version v1
 * @summary Two adjacent plus operators are rejected: the parser cannot separate an addition from an increment here. This file is the illegal program itself; do not insert a separator, since the doubled operator is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary Two adjacent plus operators are rejected: the parser cannot separate an addition from an increment here. This file is the illegal program itself; do not insert a separator, since the doubled operator is the point.
 * @topic Negative
 */
/** */
void Test()
{
	int X = 1 ++ 2;
}
/** @end */
