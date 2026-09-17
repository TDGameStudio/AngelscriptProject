/**
 * @version v1
 * @summary Default parameter values for FString and FName parameters, covering both explicit arguments and calls that omit the argument. The FText overload takes no default because FText has no literal form in this fork.
 * @topic Language
 */
/**
 * @version root
 * @summary Default parameter values for FString and FName parameters, covering both explicit arguments and calls that omit the argument. The FText overload takes no default because FText has no literal form in this fork.
 * @topic Baseline
 */
namespace LiteralsTest
{
	/**
	 * Concatenates two strings, the second defaulting to " Default".
	 *
	 * @Covers Literals.FString
	 * @Param a leading string
	 * @Param b trailing string, defaulting to " Default"
	 * @Return the concatenation
	 */
	FString ConcatWithDefault(FString a, FString b = " Default")
	{
		return a + b;
	}

	/**
	 * Calls ConcatWithDefault omitting the defaulted argument.
	 *
	 * @Covers Literals.FString
	 * @Param a leading string
	 * @Return the concatenation using the default
	 */
	FString ConcatWithImplicitDefault(FString a)
	{
		return ConcatWithDefault(a);
	}

	/**
	 * Greets a name that defaults to "World".
	 *
	 * @Covers Literals.FString
	 * @Param name the greeted name, defaulting to "World"
	 * @Return the greeting
	 */
	FString GreetWithDefault(FString name = "World")
	{
		return "Hello " + name;
	}

	/**
	 * Calls GreetWithDefault omitting the defaulted argument.
	 *
	 * @Covers Literals.FString
	 * @Inputs none
	 * @Return the greeting using the default name
	 */
	FString GreetWithImplicitDefault()
	{
		return GreetWithDefault();
	}

	/**
	 * Unwraps an FText argument to its string form.
	 *
	 * @Covers Literals.FString
	 * @Param text the text to unwrap
	 * @Return the underlying string
	 */
	FString TextWithDefault(FText text)
	{
		return text.ToString();
	}

	/**
	 * Unwraps an FName argument that defaults to n"DefaultName".
	 *
	 * @Covers Literals.FString
	 * @Param name the name to unwrap, defaulting to n"DefaultName"
	 * @Return the underlying string
	 */
	FString NameWithDefault(FName name = n"DefaultName")
	{
		return name.ToString();
	}

	/**
	 * Calls NameWithDefault omitting the defaulted argument.
	 *
	 * @Covers Literals.FString
	 * @Inputs none
	 * @Return the string using the default name
	 */
	FString NameWithImplicitDefault()
	{
		return NameWithDefault();
	}

	/**
	 * Observe that every defaulted and explicit call path matches its oracle.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs defaulted FString/FName/FText parameter calls
	 * @Return true when all five outcomes match
	 */
	UFUNCTION()
	bool FunctionDefaultParametersProduceExpectedValues()
	{
		if (ConcatWithDefault("Test", " Custom") != "Test Custom")
		{
			return false;
		}

		if (ConcatWithImplicitDefault("Test") != "Test Default")
		{
			return false;
		}

		if (GreetWithImplicitDefault() != "Hello World")
		{
			return false;
		}

		if (TextWithDefault(FText::FromString("DefaultText")) != "DefaultText")
		{
			return false;
		}

		return NameWithImplicitDefault() == "DefaultName";
	}

	/**
	 * Observe the empty-name boundary of the defaulted greeting.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs GreetWithDefault("")
	 * @Return true when the greeting is "Hello "
	 * @Boundary empty name
	 */
	UFUNCTION()
	bool GreetEmptyNameBoundary()
	{
		return GreetWithDefault("") == "Hello ";
	}

	/**
	 * Observe the empty-pair boundary of the defaulted concatenation.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs ConcatWithDefault("", "")
	 * @Return true when the result is empty
	 * @Boundary empty operands
	 */
	UFUNCTION()
	bool ConcatEmptyPairBoundary()
	{
		return ConcatWithDefault("", "") == "";
	}
}
/** @end */
