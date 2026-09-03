/**
 * Assigning the empty string literal to an FString produces an empty string:
 * it reports empty, has length zero, differs from a non-empty string, and
 * copies independently of the source.
 *
 * @Theme Language.Literals
 * @Subject Literals.EmptyStringLiteral
 * @Harness Function
 * @Tag Language.Literals.EmptyStringLiteral
 * @Namespace LiteralsTest
 * @Provenance C++: AngelscriptSyntaxFStringTests.cpp::Literals_Positive block 2 AssertCompiles.
 * @Provenance sha256=ecc721446173a5f7fbc15395cdf3923fb8b5367e293905f5a95d62a108b8c27e; lines 57-59.
 * @Provenance Oracle: Test() assigns ""; Observe IsEmpty and Len 0.
 * @Provenance Extra: empty != "x"; empty copy stays empty after source write.
 * @Provenance DefaultSafe.
 */

namespace LiteralsTest
{
	/**
	 * Observe that the empty literal reports empty and length zero.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs FString S = ""
	 * @Return true when S is empty and has length 0
	 */
	UFUNCTION()
	bool EmptyLiteralReportsEmpty()
	{
		FString S = "";
		if (!S.IsEmpty())
		{
			return false;
		}
		return S.Len() == 0;
	}

	/**
	 * Observe the non-empty boundary: the empty literal differs from "x".
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs "" compared to "x"
	 * @Return true when they differ
	 * @Boundary non-empty string
	 */
	UFUNCTION()
	bool EmptyLiteralDiffersFromNonEmpty()
	{
		FString Empty = "";
		FString NonEmpty = "x";
		return Empty != NonEmpty;
	}

	/**
	 * Observe that copying the empty literal and mutating the source leaves the
	 * copy empty.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs A copy of "", then the source set to "filled"
	 * @Return true when the copy stays empty
	 */
	UFUNCTION()
	bool EmptyLiteralCopyIndependence()
	{
		FString S = "";
		FString Copy = S;
		S = "filled";
		return Copy.IsEmpty();
	}
}
