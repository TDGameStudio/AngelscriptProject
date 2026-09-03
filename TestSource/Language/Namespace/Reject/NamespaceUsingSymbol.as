/**
 * A using declaration that names a single symbol is rejected: this fork does
 * not support pulling one symbol out of a namespace. Callers must use the
 * qualified name instead. This file is the illegal program itself.
 *
 * @Theme Language.Namespace
 * @Subject Namespace.UsingSymbol
 * @Harness CompileReject
 * @Tag Language.Namespace.NamespaceUsingSymbol
 * @Kind CompileReject
 * @Covers Namespace.Declaration
 * @Inputs namespace Math { int Add(int A, int B) } then `using Math::Add;` inside a function
 * @Return does not compile; diagnostic "Expected ';' / using Namespace::Symbol is not supported by this fork"
 * @Provenance C++: AngelscriptCoverageNamespaceTests.cpp::NamespaceUsing block 1.
 * @Provenance sha256=6acf4fab38d52657b2dc165f09787589fc3037538c620fc0e4a5a6be23313282; lines 230-244.
 * @Provenance Expected diagnostic: Expected ';' / using Namespace::Symbol is not supported by this fork.
 * @Provenance CSV SourceShape is Positive; C++ uses AssertFailsWithError Expected ';'.
 */

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
