/**
 * A using directive that opens a whole namespace is rejected: this fork does
 * not support importing every symbol from a namespace. Callers must use
 * qualified names instead. This file is the illegal program itself.
 *
 * @Theme Language.Namespace
 * @Subject Namespace.UsingDirective
 * @Harness CompileReject
 * @Tag Language.Namespace.NamespaceUsingDirective
 * @Kind CompileReject
 * @Covers Namespace.Declaration
 * @Inputs namespace Math { int Add(int A, int B) } then `using namespace Math;` inside a function
 * @Return does not compile; diagnostic "Expected ';' / using namespace is not supported by this fork"
 * @Provenance C++: AngelscriptCoverageNamespaceTests.cpp::NamespaceUsing block 2.
 * @Provenance sha256=af1dc16abcfb92dada1ee427d288d95f92fba752c654407f93bcd75a5c47607d; lines 253-267.
 * @Provenance Expected diagnostic: Expected ';' / using namespace is not supported by this fork.
 * @Provenance CSV SourceShape is Positive; C++ uses AssertFailsWithError Expected ';'.
 */

namespace Math
{
/** */
	int Add(int A, int B)
	{
		return A + B;
	}
}

/** */
int UseNamespace()
{
	using namespace Math;
	return Add(10, 20);
}
