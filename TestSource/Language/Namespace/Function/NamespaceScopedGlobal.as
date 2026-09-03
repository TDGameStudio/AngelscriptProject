/**
 * A namespace-scoped global int is read through its qualified name and keeps
 * its value on repeated reads. Copying the value into a local produces an
 * independent int, so writing through the copy leaves the namespace global
 * untouched. This file is the namespace-global template: the declaration
 * lives in MySpaceBasic and the observations reach into it by qualified name.
 *
 * @Theme Language.Namespace
 * @Subject Namespace.ScopedGlobal
 * @Harness Function
 * @Tag Language.Namespace.NamespaceScopedGlobal
 * @Namespace NamespaceTest
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Namespace_Mixed block 1 AssertCompiles (currently #if 0).
 * @Provenance sha256=810334f2a1d1aa24f0994d0f0a78344ca363c7b0337f03cf54dea263ac93011d; lines 479-481.
 * @Provenance Oracle: MySpaceBasic::GlobalVal == 42.
 */

namespace MySpaceBasic
{
	int GlobalVal = 42;
}

namespace NamespaceTest
{
	/**
	 * Observe the qualified read: the namespace global resolves to its value.
	 *
	 * @Kind Observe
	 * @Covers Namespace.QualifiedAccess
	 * @Inputs Read MySpaceBasic::GlobalVal through its qualified name
	 * @Return 42 when the global resolves
	 */
	UFUNCTION()
	int GlobalValResolves()
	{
		return MySpaceBasic::GlobalVal;
	}

	/**
	 * Observe copy independence: copying the global into a local and writing
	 * through the copy leaves the namespace global unchanged.
	 *
	 * @Kind Observe
	 * @Covers Namespace.QualifiedAccess
	 * @Inputs Copy MySpaceBasic::GlobalVal into a local; overwrite the local with 0
	 * @Return true when the namespace global still reads 42
	 */
	UFUNCTION()
	bool GlobalValCopyIsIndependent()
	{
		int Copy = MySpaceBasic::GlobalVal;
		Copy = 0;
		return MySpaceBasic::GlobalVal == 42;
	}

	/**
	 * Observe that repeated qualified reads return the same value.
	 *
	 * @Kind Observe
	 * @Covers Namespace.QualifiedAccess
	 * @Inputs Read MySpaceBasic::GlobalVal twice
	 * @Return true when both reads return 42
	 */
	UFUNCTION()
	bool GlobalValRepeatedReadsAgree()
	{
		int First = MySpaceBasic::GlobalVal;
		int Second = MySpaceBasic::GlobalVal;
		if (First != 42)
		{
			return false;
		}
		return Second == 42;
	}
}
