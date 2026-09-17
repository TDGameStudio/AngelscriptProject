/**
 * @version v1
 * @summary A builder integration compile referencing an undeclared GhostBuilderType is rejected. This file is the illegal program itself; do not declare the missing type, since the unknown name is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary A builder integration compile referencing an undeclared GhostBuilderType is rejected. This file is the illegal program itself; do not declare the missing type, since the unknown name is the point.
 * @topic Negative
 */
/**
 * The function whose local references the undeclared type.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 */
int Entry()
{
	GhostBuilderType Value;
	return 42;
}
/** @end */
