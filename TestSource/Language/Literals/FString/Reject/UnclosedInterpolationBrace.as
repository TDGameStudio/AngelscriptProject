/**
 * An interpolated string whose brace is never closed is rejected: the
 * interpolation needs a matching closing brace. This file is the illegal
 * program itself; do not add the brace, since the unclosed interpolation is
 * the point.
 *
 * @Theme Language.Literals
 * @Subject Literals.UnclosedInterpolationBrace
 * @Harness CompileReject
 * @Tag Language.Literals.UnclosedInterpolationBrace
 * @Kind CompileReject
 * @Covers Literals.FString
 * @Inputs f"Value is {X" with no closing brace
 * @Return does not compile; diagnostic "unterminated interpolation"
 */

/** */
void Test()
{
	int X = 5;
	FString S = f"Value is {X";
}
