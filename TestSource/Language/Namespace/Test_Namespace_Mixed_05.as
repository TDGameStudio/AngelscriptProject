// Theme: Language.Namespace. Compile-fail: non-existent namespaced member.
// CSV SourceShape is Positive / DefaultSafe; C++ uses AssertFailsToCompile.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Namespace_Mixed block 5.
// sha256=eaef48fa2595e7e0ea5775d40e4760f480694426dff8e9059d0cf3b45f94d91c; lines 525-528.
// Expected diagnostic: NonExistent is not a member of MySpaceBadAcc.
// Isolate this failing construct; do not add NonExistent to make it compile.
// DiagnosticOnly.

namespace MySpaceBadAcc
{
	int X = 1;
}

void Test()
{
	int Y = MySpaceBadAcc::NonExistent;
}
