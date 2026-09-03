/**
 * A function declared inside a namespace is called through its qualified
 * name. The call does not depend on a using directive, and repeated calls
 * return the same value independently. The namespace here is the subject
 * under test, so the observations live in a separate namespace rather than
 * being nested inside MySpaceAccess.
 *
 * @Theme Language.Namespace
 * @Subject Namespace.QualifiedCall
 * @Harness Function
 * @Tag Language.Namespace.NamespaceQualifiedCall
 * @Namespace NamespaceTest
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Namespace_Mixed block 2 AssertCompiles.
 * @Provenance sha256=27c17694fca0d0543388d121b63934cbb96f07b42d6696c6d656b48df0c958d7; lines 486-496.
 * @Provenance Oracle: MySpaceAccess::GetVal() == 42.
 */

namespace MySpaceAccess
{
	/**
	 * A function held inside a namespace, called through its qualified name.
	 */
	int GetVal()
	{
		return 42;
	}
}

namespace NamespaceTest
{
	/**
	 * Observe the qualified call: the namespaced function is reachable through
	 * its qualified name and returns its value.
	 *
	 * @Kind Observe
	 * @Covers Namespace.QualifiedAccess
	 * @Inputs Call MySpaceAccess::GetVal() through its qualified name
	 * @Return 42 when the call resolves
	 */
	UFUNCTION()
	int QualifiedCallResolves()
	{
		return MySpaceAccess::GetVal();
	}

	/**
	 * Observe that repeated qualified calls return the same value independently.
	 *
	 * @Kind Observe
	 * @Covers Namespace.QualifiedAccess
	 * @Inputs Call MySpaceAccess::GetVal() twice
	 * @Return true when both calls return 42
	 */
	UFUNCTION()
	bool QualifiedCallsAreIndependent()
	{
		int First = MySpaceAccess::GetVal();
		int Second = MySpaceAccess::GetVal();
		if (First != 42)
		{
			return false;
		}
		return Second == 42;
	}

	/**
	 * Observe that the call result can be bound to a local without affecting
	 * later calls.
	 *
	 * @Kind Observe
	 * @Covers Namespace.QualifiedAccess
	 * @Inputs Bind the call result to a local; overwrite the local; call again
	 * @Return true when the later call still returns 42
	 */
	UFUNCTION()
	bool QualifiedCallSurvivesLocalWrite()
	{
		int Bound = MySpaceAccess::GetVal();
		Bound = 0;
		return MySpaceAccess::GetVal() == 42;
	}
}
