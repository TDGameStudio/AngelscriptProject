/**
 * A global variable combined with a function that mutates it is rejected.
 * C++ originally expected this to compile, but the assertion is now #if 0
 * because the combination is unsupported. This file is the illegal program
 * itself; do not add declarations that would compile it away.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.GlobalPlusFunctionCombo
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.GlobalPlusFunctionCombo
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs a global variable and a function incrementing it
 * @Return does not compile; diagnostic "global plus function combination"
 * @Provenance C++: AngelscriptSyntaxMiscTests.cpp::EdgeCases_Positive block 6 was AssertCompiles
 * @Provenance but is #if 0 (feature-not-supported: global variable with function combo).
 * @Provenance sha256=d6a632564d08bde402d625de7362af3108302ce12c8d9f789373b73559005df3; lines 261-265.
 * @Provenance Expected diagnostic: compiling GlobalCounter together with Increment fails.
 * @Provenance Isolate this program. Do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly.
 */

int GlobalCounter = 0;

/**
 * Attempt to increment the global counter from a function.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile
 */
void Increment()
{
	++GlobalCounter;
}
