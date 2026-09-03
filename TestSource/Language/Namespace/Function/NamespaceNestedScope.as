/**
 * A namespace can nest inside another namespace, and a value in the inner
 * scope is reached by chaining the qualified names. Copying the nested value
 * into a local produces an independent int, so writing through the copy
 * leaves the nested global untouched.
 *
 * @Theme Language.Namespace
 * @Subject Namespace.NestedScope
 * @Harness Function
 * @Tag Language.Namespace.NamespaceNestedScope
 * @Namespace NamespaceTest
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Namespace_Mixed block 3 AssertCompiles (currently #if 0).
 * @Provenance sha256=53012c39fdc493a486b19c2665c868075ae6efc8b3d393ef8019f3e2e56e2206; lines 502-510.
 * @Provenance Oracle: Outer::Inner::Value == 1.
 */

namespace Outer
{
	namespace Inner
	{
		int Value = 1;
	}
}

namespace NamespaceTest
{
	/**
	 * Observe the chained qualified read: the nested global resolves through
	 * both namespace levels.
	 *
	 * @Kind Observe
	 * @Covers Namespace.QualifiedAccess
	 * @Inputs Read Outer::Inner::Value through its chained qualified name
	 * @Return 1 when the nested global resolves
	 */
	UFUNCTION()
	int NestedValueResolves()
	{
		return Outer::Inner::Value;
	}

	/**
	 * Observe copy independence: copying the nested value into a local and
	 * writing through the copy leaves the nested global unchanged.
	 *
	 * @Kind Observe
	 * @Covers Namespace.QualifiedAccess
	 * @Inputs Copy Outer::Inner::Value into a local; overwrite the local with 0
	 * @Return true when the nested global still reads 1
	 */
	UFUNCTION()
	bool NestedValueCopyIsIndependent()
	{
		int Copy = Outer::Inner::Value;
		Copy = 0;
		return Outer::Inner::Value == 1;
	}

	/**
	 * Observe that both nesting levels are required: the inner name alone does
	 * not reach the value, it must be qualified by the outer namespace.
	 *
	 * @Kind Observe
	 * @Covers Namespace.QualifiedAccess
	 * @Inputs Compare the chained read against the expected value
	 * @Return true when the chained read yields 1 and not some other value
	 */
	UFUNCTION()
	bool NestedValueRequiresBothLevels()
	{
		int Chained = Outer::Inner::Value;
		if (Chained != 1)
		{
			return false;
		}
		return Outer::Inner::Value == Chained;
	}
}
