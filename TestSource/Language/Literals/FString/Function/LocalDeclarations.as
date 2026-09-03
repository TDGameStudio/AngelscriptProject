/**
 * Local declaration forms for the string family: default initialization,
 * deferred assignment, const locals, default-constructed values, and the auto
 * keyword. Each form is a separate function so a failure names the form.
 *
 * @Theme Language.Literals
 * @Subject Literals.LocalDeclarations
 * @Harness Function
 * @Tag Language.Literals.LocalDeclarations
 * @Namespace LiteralsTest
 * @Provenance C++: AngelscriptCoverageFStringExpressionTests.cpp::LocalDeclarations
 * @Provenance sha256 from TS-LANG-0125; lines 85-164.
 * @Provenance Oracle: Hello/World/Const/empty/NAME_None/MyName/ConstName/Convert/Visible Text/empty/Const Text/AutoText.
 * @Provenance Extra: default FString empty; default FName NAME_None; default FText ToString empty.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace LiteralsTest
{
	/**
	 * Declares a local string with an initializer.
	 *
	 * @Covers Literals.FString
	 * @Inputs none
	 * @Return "Hello"
	 */
	FString LocalDefaultInit()
	{
		FString Value = "Hello";
		return Value;
	}

	/**
	 * Declares a local string then assigns it afterwards.
	 *
	 * @Covers Literals.FString
	 * @Inputs none
	 * @Return "World"
	 */
	FString LocalDeferredInit()
	{
		FString Value;
		Value = "World";
		return Value;
	}

	/**
	 * Declares a const local string.
	 *
	 * @Covers Literals.FString
	 * @Inputs none
	 * @Return "Const"
	 */
	FString LocalConst()
	{
		const FString Value = "Const";
		return Value;
	}

	/**
	 * Declares a local string initialized to empty.
	 *
	 * @Covers Literals.FString
	 * @Inputs none
	 * @Return an empty string
	 */
	FString LocalEmpty()
	{
		FString Value = "";
		return Value;
	}

	/**
	 * Declares a default-constructed local string.
	 *
	 * @Covers Literals.FString
	 * @Inputs none
	 * @Return a default-constructed empty string
	 */
	FString LocalDefaultString()
	{
		FString Value;
		return Value;
	}

	/**
	 * Declares a local name with an initializer.
	 *
	 * @Covers Literals.FString
	 * @Inputs none
	 * @Return n"MyName"
	 */
	FName LocalName()
	{
		FName Value = n"MyName";
		return Value;
	}

	/**
	 * Declares a default-constructed local name.
	 *
	 * @Covers Literals.FString
	 * @Inputs none
	 * @Return NAME_None
	 */
	FName LocalNameDefault()
	{
		FName Value;
		return Value;
	}

	/**
	 * Declares a const local name.
	 *
	 * @Covers Literals.FString
	 * @Inputs none
	 * @Return n"ConstName"
	 */
	FName LocalNameConst()
	{
		const FName Value = n"ConstName";
		return Value;
	}

	/**
	 * Converts a local name to a string.
	 *
	 * @Covers Literals.FString
	 * @Inputs n"Convert"
	 * @Return "Convert"
	 */
	FString LocalNameToString()
	{
		FName Value = n"Convert";
		return Value.ToString();
	}

	/**
	 * Converts initialized local text to a string.
	 *
	 * @Covers Literals.FString
	 * @Inputs FText wrapping "Visible Text"
	 * @Return "Visible Text"
	 */
	FString LocalTextToString()
	{
		FText Value = FText::FromString("Visible Text");
		return Value.ToString();
	}

	/**
	 * Converts a default-constructed local text to a string.
	 *
	 * @Covers Literals.FString
	 * @Inputs a default-constructed FText
	 * @Return an empty string
	 */
	FString LocalTextDefaultToString()
	{
		FText Value;
		return Value.ToString();
	}

	/**
	 * Converts a const local text to a string.
	 *
	 * @Covers Literals.FString
	 * @Inputs FText wrapping "Const Text"
	 * @Return "Const Text"
	 */
	FString LocalTextConstToString()
	{
		const FText Value = FText::FromString("Const Text");
		return Value.ToString();
	}

	/**
	 * Declares a local with the auto keyword inferred from a literal.
	 *
	 * @Covers Literals.FString
	 * @Inputs the literal "AutoText"
	 * @Return "AutoText"
	 */
	FString AutoStringLiteral()
	{
		auto Value = "AutoText";
		return Value;
	}

	/**
	 * Observe that every initialized declaration form yields its value.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs all initialized local declaration helpers
	 * @Return true when all nine values match
	 */
	UFUNCTION()
	bool LocalDeclarationsProduceExpectedValues()
	{
		if (LocalDefaultInit() != "Hello")
		{
			return false;
		}

		if (LocalDeferredInit() != "World")
		{
			return false;
		}

		if (LocalConst() != "Const")
		{
			return false;
		}

		if (LocalName() != n"MyName")
		{
			return false;
		}

		if (LocalNameConst() != n"ConstName")
		{
			return false;
		}

		if (LocalNameToString() != "Convert")
		{
			return false;
		}

		if (LocalTextToString() != "Visible Text")
		{
			return false;
		}

		if (LocalTextConstToString() != "Const Text")
		{
			return false;
		}

		return AutoStringLiteral() == "AutoText";
	}

	/**
	 * Observe that all default-constructed forms stringify as empty.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs empty, default string, and default text locals
	 * @Return true when all three are empty
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool LocalDeclarationsEmptyBoundary()
	{
		if (LocalEmpty() != "")
		{
			return false;
		}

		if (LocalDefaultString() != "")
		{
			return false;
		}

		return LocalTextDefaultToString() == "";
	}

	/**
	 * Observe that a default-constructed local name is NAME_None.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs a default-constructed FName local
	 * @Return true when the name is NAME_None
	 * @Boundary NAME_None
	 */
	UFUNCTION()
	bool LocalNameNoneBoundary()
	{
		return LocalNameDefault() == NAME_None;
	}
}
