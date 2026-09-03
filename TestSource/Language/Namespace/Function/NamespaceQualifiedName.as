/**
 * Two namespaces may declare the same identifier without colliding, because
 * the qualified name carries the namespace and disambiguates them. The same
 * holds for constants and for functions with identical signatures: Alpha and
 * Beta each hold a Value and a GetValue, and NS1 and NS2 each hold a
 * Calculate with the same parameter list.
 *
 * @Theme Language.Namespace
 * @Subject Namespace.QualifiedName
 * @Harness Function
 * @Tag Language.Namespace.NamespaceQualifiedName
 * @Namespace NamespaceTest
 * @Provenance C++: AngelscriptCoverageNamespaceTests.cpp::NamespaceQualifiedName ExpectGlobalReturn.
 * @Provenance sha256=73c7ccc78a18b163329763ccb7313f8a7007f36540e6bba729597b784438bdc1; lines 285-345.
 * @Provenance Oracle: UseQualifiedNames() == 300; UseConstants() == 110; UseSameNameDifferentNamespace() == 50.
 * @Provenance Extra: Alpha::GetValue() == 100 vs Beta 200; NS1::Calculate(0) == 0 zero boundary.
 */

namespace Alpha
{
	const int Value = 100;

	/**
	 * One of two identically named functions, disambiguated by namespace.
	 */
	int GetValue()
	{
		return Value;
	}
}

namespace Beta
{
	const int Value = 200;

	/**
	 * The counterpart of Alpha::GetValue, same name but a different namespace.
	 */
	int GetValue()
	{
		return Value;
	}
}

/**
 * Adds two identically named functions from different namespaces.
 */
int UseQualifiedNames()
{
	return Alpha::GetValue() + Beta::GetValue();
}

namespace Constants
{
	const int MAX_SIZE = 100;
	const int MIN_SIZE = 10;
}

/**
 * Adds two constants held inside a namespace.
 */
int UseConstants()
{
	return Constants::MAX_SIZE + Constants::MIN_SIZE;
}

namespace NS1
{
	/**
	 * One of two Calculate functions with identical signatures.
	 */
	int Calculate(int X)
	{
		return X * 2;
	}
}

namespace NS2
{
	/**
	 * The counterpart of NS1::Calculate, same signature but a different factor.
	 */
	int Calculate(int X)
	{
		return X * 3;
	}
}

/**
 * Calls both Calculate functions with the same argument, selecting each by
 * namespace.
 */
int UseSameNameDifferentNamespace()
{
	return NS1::Calculate(10) + NS2::Calculate(10);
}

namespace NamespaceTest
{
	/**
	 * Observe that identically named functions in two namespaces each return
	 * their own value.
	 *
	 * @Kind Observe
	 * @Covers Namespace.QualifiedAccess
	 * @Inputs Call UseQualifiedNames(), which adds Alpha::GetValue and Beta::GetValue
	 * @Return 300 when both namespaces resolve without colliding
	 */
	UFUNCTION()
	int SameNameFunctionsDoNotCollide()
	{
		return UseQualifiedNames();
	}

	/**
	 * Observe that constants inside a namespace are read by qualified name.
	 *
	 * @Kind Observe
	 * @Covers Namespace.QualifiedAccess
	 * @Inputs Call UseConstants(), which adds Constants::MAX_SIZE and MIN_SIZE
	 * @Return 110 when both constants resolve
	 */
	UFUNCTION()
	int NamespacedConstantsResolve()
	{
		return UseConstants();
	}

	/**
	 * Observe that two functions with identical signatures in different
	 * namespaces are selected by the namespace part of the qualified name.
	 *
	 * @Kind Observe
	 * @Covers Namespace.QualifiedAccess
	 * @Inputs Call UseSameNameDifferentNamespace(), which calls NS1 and NS2 Calculate with 10
	 * @Return 50 when the namespace selects the right overload
	 */
	UFUNCTION()
	int SameSignatureResolvedByNamespace()
	{
		return UseSameNameDifferentNamespace();
	}

	/**
	 * Observe that each namespace keeps its own value for the same identifier.
	 *
	 * @Kind Observe
	 * @Covers Namespace.QualifiedAccess
	 * @Inputs Compare Alpha::GetValue against Beta::GetValue
	 * @Return true when Alpha gives 100 and Beta gives 200
	 */
	UFUNCTION()
	bool SameIdentifierKeepsSeparateValues()
	{
		if (Alpha::GetValue() != 100)
		{
			return false;
		}
		return Beta::GetValue() == 200;
	}

	/**
	 * Observe the zero boundary: both Calculate functions accept 0 and return 0.
	 *
	 * @Kind Observe
	 * @Covers Namespace.QualifiedAccess
	 * @Inputs Call NS1::Calculate(0) and NS2::Calculate(0)
	 * @Return 0 when both namespaces handle the zero input
	 * @Boundary zero input
	 */
	UFUNCTION()
	int ZeroBoundaryAcrossNamespaces()
	{
		return NS1::Calculate(0) + NS2::Calculate(0);
	}
}
