// Theme: Language.Syntax.EdgeCases. NegativeDiagnostic: default outside class.
// C++: AngelscriptCompilerPropertyDefaultMatrixTests.cpp::DefaultOutsideClassScopeFails
// sha256=d4576fa074b4ab591f328d683b7c372a0835ba5623d2e0e357e15a443b9bcf69; lines 520-523.
// Expected diagnostic: default outside class scope should fail. Isolate this
// failing program; do not add a class wrapper that would compile it away.
// DiagnosticOnly.

int GlobalValue = 5;
default GlobalValue = 10;
