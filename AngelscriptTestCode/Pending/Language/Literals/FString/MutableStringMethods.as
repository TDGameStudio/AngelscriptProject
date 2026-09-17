/**
 * @version v1
 * @summary In-place mutation methods on FString: Append, AppendInt, AppendChar, InsertAt, RemoveAt, RemoveSpacesInline, Empty, Reset, Reserve, Shrink and index assignment. Each helper isolates one mutation chain so a failure names.
 * @topic Language
 */
/**
 * @version root
 * @summary In-place mutation methods on FString: Append, AppendInt, AppendChar, InsertAt, RemoveAt, RemoveSpacesInline, Empty, Reset, Reserve, Shrink and index assignment. Each helper isolates one mutation chain so a failure names.
 * @topic Baseline
 */
namespace LiteralsTest
{
	/**
	 * Appends a separator then an integer.
	 *
	 * @Covers Literals.FString
	 * @Inputs "Score" extended with ": " and 42
	 * @Return "Score: 42"
	 */
	FString AppendAndAppendInt()
	{
		FString s = "Score";
		s.Append(": ");
		s.AppendInt(42);
		return s;
	}

	/**
	 * Inserts and appends characters around an existing string.
	 *
	 * @Covers Literals.FString
	 * @Inputs "AC" with an inserted 'B', an appended 'D' and a prefixed "Start-"
	 * @Return "Start-ABCD"
	 */
	FString AppendCharAndInsertAt()
	{
		FString s = "AC";
		s.InsertAt(1, 0x42);
		s.AppendChar(0x44);
		s.InsertAt(0, "Start-");
		return s;
	}

	/**
	 * Removes a two-character run from the middle of a string.
	 *
	 * @Covers Literals.FString
	 * @Inputs "ABCDEF" with two characters removed at index 2
	 * @Return "ABEF"
	 */
	FString RemoveAtMiddle()
	{
		FString s = "ABCDEF";
		s.RemoveAt(2, 2);
		return s;
	}

	/**
	 * Strips spaces from a string in place.
	 *
	 * @Covers Literals.FString
	 * @Inputs "A B  C"
	 * @Return "ABC"
	 */
	FString RemoveSpacesInline()
	{
		FString s = "A B  C";
		s.RemoveSpacesInline();
		return s;
	}

	/**
	 * Exercises the capacity methods and encodes three lengths as digits.
	 *
	 * @Covers Literals.FString
	 * @Inputs Empty, Reset, Reserve and Shrink over a short string
	 * @Return a three-digit encoding of the lengths after empty, reset and shrink
	 */
	int EmptyResetReserveShrink()
	{
		FString s = "abcdef";
		s.Reserve(64);
		s.Empty();
		int AfterEmpty = s.Len();

		s.Append("xy");
		s.Reset(32);
		int AfterReset = s.Len();

		s.Append("z");
		s.Shrink();
		return AfterEmpty * 100 + AfterReset * 10 + s.Len();
	}

	/**
	 * Mutates a character through index assignment and validates indices.
	 *
	 * @Covers Literals.FString
	 * @Inputs "ABC" with index 1 replaced by 'Z'
	 * @Return true when index validation holds and the mutation applies
	 */
	bool IndexMutationAndValidation()
	{
		FString s = "ABC";

		if (!s.IsValidIndex(2))
		{
			return false;
		}

		if (s.IsValidIndex(3))
		{
			return false;
		}

		s[1] = 0x5A;
		return s == "AZC";
	}

	/**
	 * Observe that every mutation chain produces its expected value.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs all mutation helpers
	 * @Return true when all six outcomes match
	 */
	UFUNCTION()
	bool MutableStringMethodsProduceExpectedValues()
	{
		if (AppendAndAppendInt() != "Score: 42")
		{
			return false;
		}

		if (AppendCharAndInsertAt() != "Start-ABCD")
		{
			return false;
		}

		if (RemoveAtMiddle() != "ABEF")
		{
			return false;
		}

		if (RemoveSpacesInline() != "ABC")
		{
			return false;
		}

		if (EmptyResetReserveShrink() != 1)
		{
			return false;
		}

		return IndexMutationAndValidation();
	}

	/**
	 * Observe that Empty() on a default string leaves it zero-length.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs Empty() over a default-constructed string
	 * @Return true when the length is 0
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool EmptyDefaultLengthBoundary()
	{
		FString s;
		s.Empty();
		return s.Len() == 0;
	}

	/**
	 * Observe that an out-of-range index is reported invalid.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs IsValidIndex(3) over "ABC"
	 * @Return true when the index is rejected
	 * @Boundary out-of-range index
	 */
	UFUNCTION()
	bool IsValidIndexFalseBoundary()
	{
		FString s = "ABC";
		return !s.IsValidIndex(3);
	}
}
/** @end */
