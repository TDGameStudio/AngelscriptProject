/**
 * A mutable FString at module level is rejected: only const globals are
 * supported. This file is the illegal program itself; do not add const, since
 * the mutable global is the point.
 *
 * @Theme Language.Literals
 * @Subject Literals.MutableGlobalFString
 * @Harness CompileReject
 * @Tag Language.Literals.MutableGlobalFString
 * @Kind CompileReject
 * @Covers Literals.FString
 * @Inputs FString GMutable = "Mutable"; at module scope, read by a function
 * @Return does not compile; diagnostic "Global variable 'GMutable' must be const"
 * @Provenance C++: AngelscriptCoverageFStringExpressionTests.cpp::UnsupportedStringExpressionBoundaries block 1
 * @Provenance sha256 from TS-LANG-0131; lines 619-626.
 */

FString GMutable = "Mutable";
/** */
FString ReadMutable()
{
	return GMutable;
}
