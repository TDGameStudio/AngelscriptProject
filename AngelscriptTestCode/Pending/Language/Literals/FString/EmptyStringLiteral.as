/**
 * @version v1
 * @summary Assigning the empty string literal to an FString produces an empty string: it reports empty, has length zero, differs from a non-empty string, and copies independently of the source.
 * @topic Language
 */
/**
 * @version root
 * @summary Assigning the empty string literal to an FString produces an empty string: it reports empty, has length zero, differs from a non-empty string, and copies independently of the source.
 * @topic Baseline
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
/** @end */
