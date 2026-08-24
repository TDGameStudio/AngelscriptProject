// Theme: Language.Namespace. Compile-fail: anonymous namespace.
// CSV SourceShape is Positive; C++ uses AssertFailsToCompile (currently #if 0: compile still succeeds with an error log).
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Namespace_Mixed block 4.
// sha256=76b5afd15f61c26f4b5c44741781c967457d76be72992181b5a8554966ea2d22; lines 518-520.
// Expected diagnostic: anonymous namespace.
// Isolate this failing construct; do not add declarations that would compile it away.
// DiagnosticOnly.

namespace
{
	int X;
}
