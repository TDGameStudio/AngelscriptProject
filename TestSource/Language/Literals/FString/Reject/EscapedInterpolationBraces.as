/**
 * Doubling the braces in an interpolated string is not an escape: this fork
 * reads the doubled brace as malformed rather than as a literal brace. This
 * file is the illegal program itself; do not collapse the braces, since the
 * doubled form is the point.
 *
 * @Theme Language.Literals
 * @Subject Literals.EscapedInterpolationBraces
 * @Harness CompileReject
 * @Tag Language.Literals.EscapedInterpolationBraces
 * @Kind CompileReject
 * @Covers Literals.FString
 * @Inputs f"Value is {{X}}" with doubled interpolation braces
 * @Return does not compile; diagnostic "malformed interpolation braces"
 */

/** */
void Test()
{
	int X = 5;
	FString S = f"Value is {{X}}";
}
