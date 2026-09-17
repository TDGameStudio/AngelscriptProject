/**
 * @version v1
 * @summary An f-string is expanded into concatenation, so an f-string built from a parameter interpolates that parameter's value. The oracle checks both the expanded length and the expanded text.
 * @topic Language
 */
/**
 * @version root
 * @summary An f-string is expanded into concatenation, so an f-string built from a parameter interpolates that parameter's value. The oracle checks both the expanded length and the expanded text.
 * @topic Baseline
 */
namespace PreprocessorTest
{
	/**
	 * Builds a greeting by interpolating a name into an f-string.
	 *
	 * @Covers Preprocessor.Literals
	 * @Inputs the name to greet
	 * @Param Name the name interpolated into the greeting
	 * @Return the expanded greeting
	 */
	FString BuildGreeting(const FString&in Name)
	{
		return f"Hello {Name}!";
	}

	/**
	 * Reports the length of the greeting built for "World".
	 *
	 * @Covers Preprocessor.Literals
	 * @Inputs the name "World"
	 * @Return 12
	 */
	int Entry()
	{
		return BuildGreeting("World").Len();
	}

	/**
	 * Observe the expanded length and text of the greeting.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Literals
	 * @Inputs BuildGreeting("World")
	 * @Return true when the length is 12 and the text matches
	 */
	UFUNCTION()
	bool FormatStringExpansionProducesExpectedValues()
	{
		if (Entry() != 12)
		{
			return false;
		}

		return BuildGreeting("World") == "Hello World!";
	}

	/**
	 * Observe the boundary where the interpolated name is empty.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Literals
	 * @Inputs BuildGreeting("")
	 * @Return true when the length is 8 and the text is "Hello !"
	 * @Boundary empty interpolation
	 */
	UFUNCTION()
	bool BuildGreetingEmptyDefault()
	{
		if (BuildGreeting("").Len() != 8)
		{
			return false;
		}

		return BuildGreeting("") == "Hello !";
	}

	/**
	 * Observe that a copied greeting is unaffected by rebuilding the source.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Literals
	 * @Inputs a copy of the "World" greeting, then the source rebuilt as "Other"
	 * @Return true when copy and rebuilt source both match, and Entry is 12
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool BuildGreetingCopyIndependence()
	{
		FString First = BuildGreeting("World");
		FString Second = First;
		First = BuildGreeting("Other");

		if (Second != "Hello World!")
		{
			return false;
		}

		if (First != "Hello Other!")
		{
			return false;
		}

		return Entry() == 12;
	}
}
/** @end */
