/**
 * @version v1
 * @summary Deriving one struct from another is rejected: structs may not inherit. This file is the illegal program itself; do not flatten FChild into FBase, since the inheritance is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary Deriving one struct from another is rejected: structs may not inherit. This file is the illegal program itself; do not flatten FChild into FBase, since the inheritance is the point.
 * @topic Negative
 */
/**
 * The base struct of the illegal derivation.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 */
struct FBase
{
	int X;
}

/**
 * The struct whose derivation from FBase is illegal.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 */
struct FChild : FBase
{
	int Y;
}
/** @end */
