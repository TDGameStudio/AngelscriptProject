/**
 * An assignment statement at module scope is rejected. This file is the illegal
 * program itself; do not move the assignment into a function, since being at
 * module scope is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.TopLevelAssignment
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.TopLevelAssignment
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs an assignment statement outside any function
 * @Return does not compile; diagnostic "assignment not valid at module scope"
 * @Provenance C++: AngelscriptSyntaxMiscTests.cpp::EdgeCases_Negative block 6 AssertFailsToCompile.
 * @Provenance sha256=0c5d977d44891a00296ff2c0aa39788ae2ca62e6bbdf530281ce90822d7697a4; lines 310-313.
 * @Provenance Expected diagnostic: assignment statement X = 10 is not valid at module scope.
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

int X = 5;
X = 10;
