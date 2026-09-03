/**
 * A `default` statement at global scope is rejected. This file is the illegal
 * program itself; do not add a class wrapper, since being outside any class is
 * the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.DefaultOutsideClassScope
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.DefaultOutsideClassScope
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs a default statement applied to a global variable
 * @Return does not compile; diagnostic "default outside class scope"
 * @Provenance C++: AngelscriptCompilerPropertyDefaultMatrixTests.cpp::DefaultOutsideClassScopeFails
 * @Provenance sha256=d4576fa074b4ab591f328d683b7c372a0835ba5623d2e0e357e15a443b9bcf69; lines 520-523.
 * @Provenance Expected diagnostic: default outside class scope should fail. Isolate this
 * @Provenance failing program; do not add a class wrapper that would compile it away.
 * @Provenance DiagnosticOnly.
 */

int GlobalValue = 5;
default GlobalValue = 10;
