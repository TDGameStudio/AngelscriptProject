/**
 * Protected member and method declarations compile. A derived type may read
 * ProtectedVal, call ProtectedFunc, and write the field. Two derived instances
 * stay independent after one of them is written.
 *
 * @Theme Feature.Access
 * @Subject Access.ProtectedDeclarationsCompile
 * @Harness UClass
 * @Tag Feature.Access.ProtectedDeclarationsCompile
 * @Provenance Theme: Feature.Access. WorldStory: protected member and method declarations compile.
 * @Provenance C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Access_Positive block 3 AssertCompiles.
 * @Provenance Oracle: ProtectedVal default 0 is readable from a derived type; ProtectedFunc is callable there.
 * @Provenance Extra: empty/default 0; copy independence of two derived instances.
 * @Provenance FixtureIsolated.
 */

class AActorProtDecl : AActor
{
	protected int ProtectedVal = 0;

	/**
	 * An empty protected method that a derived type may call.
	 *
	 * @Covers Access.ProtectedDeclarationsCompile
	 * @Inputs none
	 * @Return nothing
	 */
	protected void ProtectedFunc()
	{
	}
}

class AActorProtDeclDerived : AActorProtDecl
{
	/**
	 * Read the protected field from the derived type.
	 *
	 * @Covers Access.ProtectedDeclarationsCompile
	 * @Inputs none
	 * @Return the current ProtectedVal
	 */
	int ReadProtected()
	{
		return ProtectedVal;
	}

	/**
	 * Call the protected method from the derived type.
	 *
	 * @Covers Access.ProtectedDeclarationsCompile
	 * @Inputs none
	 * @Return nothing
	 */
	void CallProtected()
	{
		ProtectedFunc();
	}

	/**
	 * Write the protected field from the derived type.
	 *
	 * @Covers Access.ProtectedDeclarationsCompile
	 * @Inputs the value to store
	 * @Return nothing; ProtectedVal receives Val
	 * @Param Val the value to store
	 */
	void WriteProtected(int Val)
	{
		ProtectedVal = Val;
	}

	/**
	 * Observe that an untouched derived instance holds the protected default of 0.
	 *
	 * @Kind Observe
	 * @Covers Access.ProtectedDeclarationsCompile
	 * @Inputs none
	 * @Return 0, the default of ProtectedVal
	 * @Boundary empty default
	 */
	UFUNCTION()
	int ProtectedDefaultZero()
	{
		return ReadProtected();
	}

	/**
	 * Observe that calling the protected method leaves the default unchanged.
	 *
	 * @Kind Observe
	 * @Covers Access.ProtectedDeclarationsCompile
	 * @Inputs CallProtected()
	 * @Return 0 after the call
	 */
	UFUNCTION()
	int ProtectedFuncLeavesDefault()
	{
		CallProtected();
		return ReadProtected();
	}

	/**
	 * Observe that writing one derived instance leaves another at the default.
	 *
	 * @Kind Observe
	 * @Covers Access.ProtectedDeclarationsCompile
	 * @Inputs a second derived actor
	 * @Return true when this instance reads 0 and the other reads 4
	 * @Param Second the other actor, written to 4
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(AActorProtDeclDerived Second)
	{
		if (Second is null)
		{
			throw("ProtectedDeclarationsCompile setup: required Second is null");
		}
		Second.WriteProtected(4);
		if (ReadProtected() != 0)
		{
			return false;
		}
		return Second.ReadProtected() == 4;
	}
}
