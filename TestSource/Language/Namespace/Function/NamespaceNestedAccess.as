/**
 * Namespaces nest to arbitrary depth, and an inner scope can reach outward by
 * qualifying the outer name while an outer scope reaches inward by naming the
 * inner namespace. Constants declared at each level are read the same way as
 * functions. This file nests three levels to show that the chained qualified
 * name keeps working as depth grows.
 *
 * @Theme Language.Namespace
 * @Subject Namespace.NestedAccess
 * @Harness Function
 * @Tag Language.Namespace.NamespaceNestedAccess
 * @Namespace NamespaceTest
 * @Provenance C++: AngelscriptCoverageNamespaceTests.cpp::NamespaceNested ExpectGlobalReturn.
 * @Provenance sha256=8b3704e73ff92f1c65fd592e796ed01e69bd890a14fb8cf87d455f4ee9274dc9; lines 150-209.
 * @Provenance Oracle: AccessNested() == 300; AccessDeepNested() == 999.
 * @Provenance Extra: Inner::AccessOuter() == 100; Outer::AccessInner() == 200.
 */

namespace Outer
{
	const int OuterValue = 10;

	/**
	 * A function in the outer namespace, reachable from the inner one.
	 */
	int OuterFunction()
	{
		return 100;
	}

	namespace Inner
	{
		const int InnerValue = 20;

		/**
		 * A function in the inner namespace, reachable from the outer one.
		 */
		int InnerFunction()
		{
			return 200;
		}

		/**
		 * Reaches outward by qualifying the enclosing namespace.
		 */
		int AccessOuter()
		{
			return Outer::OuterFunction();
		}
	}

	/**
	 * Reaches inward by naming the nested namespace.
	 */
	int AccessInner()
	{
		return Inner::InnerFunction();
	}
}

/**
 * Combines an inner and an outer call from global scope.
 */
int AccessNested()
{
	return Outer::Inner::InnerFunction() + Outer::OuterFunction();
}

namespace Level1
{
	namespace Level2
	{
		namespace Level3
		{
			/**
			 * A function three levels deep, reached by a chained qualified name.
			 */
			int DeepFunction()
			{
				return 999;
			}
		}
	}
}

/**
 * Reaches a function three namespaces deep from global scope.
 */
int AccessDeepNested()
{
	return Level1::Level2::Level3::DeepFunction();
}

namespace NamespaceTest
{
	/**
	 * Observe a two-level chained call: the inner function and the outer
	 * function combine through their qualified names.
	 *
	 * @Kind Observe
	 * @Covers Namespace.QualifiedAccess
	 * @Inputs Call AccessNested(), which adds Inner::InnerFunction and Outer::OuterFunction
	 * @Return 300 when both levels resolve
	 */
	UFUNCTION()
	int TwoLevelChainedCallResolves()
	{
		return AccessNested();
	}

	/**
	 * Observe a three-level chained call: the qualified name keeps resolving
	 * as depth grows.
	 *
	 * @Kind Observe
	 * @Covers Namespace.QualifiedAccess
	 * @Inputs Call AccessDeepNested(), which reaches Level1::Level2::Level3::DeepFunction
	 * @Return 999 when all three levels resolve
	 */
	UFUNCTION()
	int ThreeLevelChainedCallResolves()
	{
		return AccessDeepNested();
	}

	/**
	 * Observe that an inner scope reaches outward by qualifying the outer name,
	 * and an outer scope reaches inward by naming the inner namespace.
	 *
	 * @Kind Observe
	 * @Covers Namespace.QualifiedAccess
	 * @Inputs Call Outer::Inner::AccessOuter() and Outer::AccessInner()
	 * @Return true when the outward call gives 100 and the inward call gives 200
	 */
	UFUNCTION()
	bool InnerAndOuterReachEachOther()
	{
		if (Outer::Inner::AccessOuter() != 100)
		{
			return false;
		}
		return Outer::AccessInner() == 200;
	}

	/**
	 * Observe that constants declared at each nesting level are read through
	 * their qualified names.
	 *
	 * @Kind Observe
	 * @Covers Namespace.QualifiedAccess
	 * @Inputs Add Outer::OuterValue and Outer::Inner::InnerValue
	 * @Return 30 when both constants resolve
	 */
	UFUNCTION()
	int NestedConstantsResolve()
	{
		return Outer::OuterValue + Outer::Inner::InnerValue;
	}
}
