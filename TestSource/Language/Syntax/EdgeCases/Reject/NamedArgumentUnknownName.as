/**
 * Naming a parameter the function does not declare is rejected. This file is the
 * illegal program itself; do not add the missing parameter, since the unknown
 * name is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.NamedArgumentUnknownName
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.NamedArgumentUnknownName
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs a call naming the undeclared parameter D
 * @Return does not compile; diagnostic "Unknown parameter 'D'"
 * @Provenance C++: AngelscriptFunctionTests.cpp::NamedArguments_InvalidNameDiagnostics
 * @Provenance sha256=fa112150e55d0f7d9d99c9a0c4152599e8c4d2c62d9ab73180b79df212ed7680; lines 159-169.
 * @Provenance Expected diagnostic: "Unknown parameter 'D'".
 * @Provenance Isolate this failing program; do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly.
 */

/**
 * A function called with a parameter it never declared.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 * @Param A a declared parameter
 * @Param B a declared parameter
 * @Param C a declared parameter
 */
int Mix(int A, int B, int C)
{
	return 0;
}

/**
 * The call site naming the undeclared parameter.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return does not compile in this file
 */
int Run()
{
	return Mix(A: 1, D: 2, C: 3);
}
