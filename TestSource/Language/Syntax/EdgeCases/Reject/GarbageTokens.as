/**
 * Random garbage tokens at module scope are rejected. This file is the illegal
 * program itself; do not wrap the tokens in a valid function, since the
 * undeclared garbage is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.GarbageTokens
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.GarbageTokens
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs non-declaration tokens at module scope
 * @Return does not compile; diagnostic "unexpected tokens"
 * @Provenance C++: AngelscriptSyntaxMiscTests.cpp::EdgeCases_Negative block 5 AssertFailsToCompile.
 * @Provenance sha256=3f0a481ee93fc7d7eec5ecb0091655aefa3c4b6f678a4690b44af032f7c59818; lines 304-306.
 * @Provenance Expected diagnostic: unexpected tokens / garbage is not a declaration.
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

asdfgh jklmn @#$%
