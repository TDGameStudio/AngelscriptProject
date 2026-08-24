// Theme: Language.Namespace. Compile-fail: non-existent namespace.
// CSV SourceShape is Positive / DefaultSafe; C++ uses AssertFailsToCompile.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Namespace_Mixed block 6.
// sha256=f29a4b140b5febb4187ded16a177256e0a2a1c9850b4db2c473e408a1e3a0e98; lines 532-534.
// Expected diagnostic: FakeNamespace does not exist.
// Isolate this failing construct; do not declare FakeNamespace.
// DiagnosticOnly.

void Test()
{
	int X = FakeNamespace::Value;
}
