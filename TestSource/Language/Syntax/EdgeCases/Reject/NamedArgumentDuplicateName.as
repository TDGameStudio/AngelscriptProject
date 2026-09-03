/**
 * Naming the same parameter twice in one call is rejected. This file is the
 * illegal program itself; do not rename one of the duplicate arguments, since the
 * collision is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.NamedArgumentDuplicateName
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.NamedArgumentDuplicateName
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs a call naming A twice
 * @Return does not compile; diagnostic "Duplicate named argument"
 * @Provenance C++: AngelscriptFunctionTests.cpp::NamedArguments_InvalidNameDiagnostics
 * @Provenance sha256=7b58f79627af51154fd6aa89b0ffb34ac49738dc530e318833e573a62fe2915c; lines 142-152.
 * @Provenance Expected diagnostic: "Duplicate named argument".
 * @Provenance Isolate this failing program; do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly.
 */

/**
 * A function whose call site names one parameter twice.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 * @Param A the duplicated parameter name
 * @Param B an unused parameter
 * @Param C a parameter bound after the duplicate
 */
int Mix(int A, int B, int C)
{
	return 0;
}

/**
 * The call site carrying the duplicated name.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 */
int Run()
{
	return Mix(A: 1, A: 2, C: 3);
}
