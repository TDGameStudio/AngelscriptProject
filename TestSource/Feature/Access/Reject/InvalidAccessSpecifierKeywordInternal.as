/**
 * An unrecognised access specifier keyword is rejected. This file is the
 * illegal program itself; do not replace internal with private or protected,
 * since the invalid keyword is the point.
 *
 * @Theme Feature.Access
 * @Subject Access.InvalidAccessSpecifierKeywordInternal
 * @Harness CompileReject
 * @Tag Feature.Access.InvalidAccessSpecifierKeywordInternal
 * @Kind CompileReject
 * @Covers Access.Specifier
 * @Inputs a class member marked internal
 * @Return does not compile; diagnostic "Invalid access specifier keyword internal"
 * @Provenance Theme: Feature.Access. NegativeDiagnostic: invalid access specifier keyword.
 * @Provenance C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Access_Negative block 6 AssertFailsToCompile.
 * @Provenance Expected compile failure: "Invalid access specifier keyword internal".
 * @Provenance Isolate the failing program. DiagnosticOnly.
 */

/**
 * An actor that uses the invalid specifier internal on a member.
 *
 * @Covers Access.Specifier
 * @Inputs none
 * @Return does not compile
 */
class AActorBadKeyword : AActor
{
	internal int X = 0;
}
