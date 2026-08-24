// Theme: Language.Literals.FString. Compile-fail: FName construction from int.
// CSV SourceShape is Positive / DefaultSafe; C++ uses AssertFailsToCompile.
// C++: AngelscriptSyntaxFStringTests.cpp::FName_Mixed block 4.
// sha256=3cdb2b582dfd8991f1133bdc790f25639ce9bbcb5d4f265020ea02cc445785cc; lines 276-278.
// Expected diagnostic: FName construction from int.
// Isolate this failing construct; do not add declarations that would compile it away.
// DiagnosticOnly.

void Test()
{
	FName N = FName(42);
}
