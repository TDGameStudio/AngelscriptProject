/**
 * An enum declared inside a namespace is reached through its qualified name,
 * both for the type and for each enumerator. A namespaced function taking
 * that enum is called the same way. The runtime null-pointer boundary for a
 * namespaced script class lives in ../Exception/, because instantiating it
 * throws rather than failing to compile.
 *
 * @Theme Language.Namespace
 * @Subject Namespace.WithEnum
 * @Harness Function
 * @Tag Language.Namespace.NamespaceWithEnum
 * @Namespace NamespaceTest
 * @Provenance C++: AngelscriptCoverageNamespaceTests.cpp::NamespaceWithTypes
 * @Provenance sha256=a7147b327fb84f4eb918ab0055eb9079d651728b5aa169a1bb4391997b0d1f5a; lines 783-828.
 * @Provenance Oracle: UseNamespacedEnum() == 2. UseNamespacedClass remains the runtime null-pointer boundary.
 * @Provenance Extra: UseEnum First == 1, Third == 3.
 */

namespace Types
{
	enum MyEnum
	{
		First,
		Second,
		Third
	}

	/**
	 * Maps each enumerator to a distinct value, so the caller can tell which
	 * enumerator was actually passed.
	 */
	int UseEnum(MyEnum E)
	{
		switch (E)
		{
			case MyEnum::First:
				return 1;
			case MyEnum::Second:
				return 2;
			case MyEnum::Third:
				return 3;
		}
	}
}

/**
 * Passes a namespaced enumerator by qualified name from global scope.
 */
int UseNamespacedEnum()
{
	return Types::UseEnum(Types::MyEnum::Second);
}

namespace NamespaceTest
{
	/**
	 * Observe that a namespaced enum is passed by qualified name and selects
	 * the matching switch case.
	 *
	 * @Kind Observe
	 * @Covers Namespace.QualifiedAccess
	 * @Inputs Call UseNamespacedEnum(), which passes Types::MyEnum::Second
	 * @Return 2 when the enum resolves and the switch selects Second
	 */
	UFUNCTION()
	int NamespacedEnumResolves()
	{
		return UseNamespacedEnum();
	}

	/**
	 * Observe the first enumerator boundary.
	 *
	 * @Kind Observe
	 * @Covers Namespace.QualifiedAccess
	 * @Inputs Call Types::UseEnum with Types::MyEnum::First
	 * @Return 1 when the first enumerator selects its case
	 * @Boundary first enumerator
	 */
	UFUNCTION()
	int FirstEnumeratorBoundary()
	{
		return Types::UseEnum(Types::MyEnum::First);
	}

	/**
	 * Observe the last enumerator boundary.
	 *
	 * @Kind Observe
	 * @Covers Namespace.QualifiedAccess
	 * @Inputs Call Types::UseEnum with Types::MyEnum::Third
	 * @Return 3 when the last enumerator selects its case
	 * @Boundary last enumerator
	 */
	UFUNCTION()
	int LastEnumeratorBoundary()
	{
		return Types::UseEnum(Types::MyEnum::Third);
	}
}
