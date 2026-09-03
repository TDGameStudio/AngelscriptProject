/**
 * By-value parameters across the string family. The callee receives a copy, so
 * mutation inside the callee is invisible to the caller; the oracle checks the
 * returned copy instead.
 *
 * @Theme Language.Literals
 * @Subject Literals.FunctionParametersValue
 * @Harness Function
 * @Tag Language.Literals.FunctionParametersValue
 * @Namespace LiteralsTest
 * @Provenance C++: AngelscriptCoverageFStringFunctionTests.cpp::FunctionParametersValue
 * @Provenance sha256=369fb8ae84f1857e1cd6b5dd9c00882c24f2e0f68d10caa7def61a996403a651; lines 53-68.
 * @Provenance Oracle: AcceptString("Hello") "Hello World"; AcceptName(n"Test") n"Test"; AcceptText FromString("Text") "Text".
 * @Provenance Extra: empty string concatenates " World"; empty FName stays NAME_None.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace LiteralsTest
{
	/**
	 * Accepts a string by value and appends a suffix to the copy.
	 *
	 * @Covers Literals.FString
	 * @Param x string passed by value
	 * @Return the copy with " World" appended
	 */
	FString AcceptString(FString x)
	{
		return x + " World";
	}

	/**
	 * Accepts a name by value and returns the copy.
	 *
	 * @Covers Literals.FString
	 * @Param x name passed by value
	 * @Return the copied name
	 */
	FName AcceptName(FName x)
	{
		return x;
	}

	/**
	 * Accepts text by value and unwraps the copy.
	 *
	 * @Covers Literals.FString
	 * @Param x text passed by value
	 * @Return the underlying string
	 */
	FString AcceptText(FText x)
	{
		return x.ToString();
	}

	/**
	 * Observe that all three by-value overloads read their argument.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs literal FString, FName and FText arguments
	 * @Return true when all three results match
	 */
	UFUNCTION()
	bool FunctionParametersValueReadExpectedValues()
	{
		if (AcceptString("Hello") != "Hello World")
		{
			return false;
		}

		if (AcceptName(n"Test") != n"Test")
		{
			return false;
		}

		return AcceptText(FText::FromString("Text")) == "Text";
	}

	/**
	 * Observe the empty-string boundary of the by-value string overload.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs AcceptString("")
	 * @Return true when the result is " World"
	 * @Boundary empty string
	 */
	UFUNCTION()
	bool AcceptStringEmptyBoundary()
	{
		return AcceptString("") == " World";
	}

	/**
	 * Observe that a default-constructed name round-trips as NAME_None.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs AcceptName(FName())
	 * @Return true when the copy equals NAME_None
	 * @Boundary NAME_None
	 */
	UFUNCTION()
	bool AcceptNameNoneBoundary()
	{
		FName Empty;
		return AcceptName(Empty) == Empty;
	}
}
