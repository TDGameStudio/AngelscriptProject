/**
 * An unknown UPROPERTY specifier is rejected. This file is the illegal program
 * itself; do not replace InvalidSpecifier with a known specifier.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.UnknownPropertySpecifier
 * @Harness CompileReject
 * @Tag Definitions.UProperty.UnknownPropertySpecifier
 * @Kind CompileReject
 * @Covers UProperty.UnknownPropertySpecifier
 * @Inputs UPROPERTY(InvalidSpecifier) int X
 * @Return does not compile; diagnostic "Unknown property specifier"
 * @Provenance Theme: Definitions.UProperty. Isolated compile-fail: unknown specifier.
 * @Provenance C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Negative AssertFailsToCompile
 * @Provenance UPropSN_Invalid; lines 194-200;
 * @Provenance sha256=413eef42ffa74a5548b10661bb81387ee0c20955d81166d8b7052d41631b0d19.
 * @Provenance Expected diagnostic: Unknown property specifier (method expects 3 occurrences).
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

class AUPropInvalidActor : AActor
{
	UPROPERTY(InvalidSpecifier)
	int X = 0;
}
