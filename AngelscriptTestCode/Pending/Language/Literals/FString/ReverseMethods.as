/**
 * @version v1
 * @summary The FString::Reverse method, covering a normal word, a palindrome which reverses to itself, and the empty and single-character boundaries.
 * @topic Language
 */
/**
 * @version root
 * @summary The FString::Reverse method, covering a normal word, a palindrome which reverses to itself, and the empty and single-character boundaries.
 * @topic Baseline
 */
namespace LiteralsTest
{
	/**
	 * Reverses an ordinary word.
	 *
	 * @Covers Literals.FString
	 * @Inputs "Hello"
	 * @Return "olleH"
	 */
	FString ReverseWord()
	{
		FString s = "Hello";
		return s.Reverse();
	}

	/**
	 * Reverses a palindrome, which must map to itself.
	 *
	 * @Covers Literals.FString
	 * @Inputs "racecar"
	 * @Return "racecar"
	 */
	FString ReversePalindrome()
	{
		FString s = "racecar";
		return s.Reverse();
	}

	/**
	 * Observe that both reversed forms match their expected values.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs ReverseWord() and ReversePalindrome()
	 * @Return true when both outcomes match
	 */
	UFUNCTION()
	bool ReverseMethodsProduceExpectedValues()
	{
		if (ReverseWord() != "olleH")
		{
			return false;
		}

		return ReversePalindrome() == "racecar";
	}

	/**
	 * Observe that reversing an empty string stays empty.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs Reverse() over an empty string
	 * @Return an empty string
	 * @Boundary empty string
	 */
	UFUNCTION()
	FString ReverseEmptyBoundary()
	{
		FString Empty;
		return Empty.Reverse();
	}

	/**
	 * Observe that reversing a single character is the identity.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs Reverse() over "x"
	 * @Return "x"
	 * @Boundary single character
	 */
	UFUNCTION()
	FString ReverseSingleCharBoundary()
	{
		FString s = "x";
		return s.Reverse();
	}
}
/** @end */
