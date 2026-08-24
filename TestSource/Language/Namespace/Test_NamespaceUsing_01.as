// Theme: Language.Namespace. Compile-fail: using Namespace::Symbol is unsupported.
// CSV SourceShape is Positive; C++ uses AssertFailsWithError Expected ';'.
// C++: AngelscriptCoverageNamespaceTests.cpp::NamespaceUsing block 1.
// sha256=6acf4fab38d52657b2dc165f09787589fc3037538c620fc0e4a5a6be23313282; lines 230-244.
// Expected diagnostic: Expected ';' / using Namespace::Symbol is not supported by this fork.
// Isolate this failing construct; do not rewrite to Math::Add without using.
// DiagnosticOnly.

namespace Math
{
	int Add(int A, int B)
	{
		return A + B;
	}
}

int UseSpecificFunction()
{
	using Math::Add;
	return Add(10, 20);
}
