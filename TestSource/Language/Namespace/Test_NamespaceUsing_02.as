// Theme: Language.Namespace. Compile-fail: using namespace is unsupported.
// CSV SourceShape is Positive; C++ uses AssertFailsWithError Expected ';'.
// C++: AngelscriptCoverageNamespaceTests.cpp::NamespaceUsing block 2.
// sha256=af1dc16abcfb92dada1ee427d288d95f92fba752c654407f93bcd75a5c47607d; lines 253-267.
// Expected diagnostic: Expected ';' / using namespace is not supported by this fork.
// Isolate this failing construct; do not rewrite to Math::Add without using.
// DiagnosticOnly.

namespace Math
{
	int Add(int A, int B)
	{
		return A + B;
	}
}

int UseNamespace()
{
	using namespace Math;
	return Add(10, 20);
}
