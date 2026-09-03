/**
 * An access specifier at global scope is rejected. This file is the illegal
 * program itself; do not move the declaration into a class, since the global
 * specifier is the point.
 *
 * @Theme Feature.Access
 * @Subject Access.AccessSpecifierAtGlobalScope
 * @Harness CompileReject
 * @Tag Feature.Access.AccessSpecifierAtGlobalScope
 * @Kind CompileReject
 * @Covers Access.Specifier
 * @Inputs a private int at file scope
 * @Return does not compile; diagnostic "Access specifier at global scope"
 * @Provenance Theme: Feature.Access. NegativeDiagnostic: access specifier at global scope.
 * @Provenance C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Access_Negative block 7 AssertFailsToCompile.
 * @Provenance Expected compile failure: "Access specifier at global scope".
 * @Provenance Isolate the failing program. DiagnosticOnly. PlannedSymbols empty.
 */

private int GlobalVar = 5;
