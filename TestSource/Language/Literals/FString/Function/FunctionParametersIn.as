/**
 * Read-only `&in` reference parameters across the string family. The callee
 * observes the caller's value without copying or writing back, so the oracle
 * checks the returned view rather than any mutation.
 *
 * @Theme Language.Literals
 * @Subject Literals.FunctionParametersIn
 * @Harness Function
 * @Tag Language.Literals.FunctionParametersIn
 * @Namespace LiteralsTest
 * @Provenance C++: AngelscriptCoverageFStringFunctionTests.cpp::FunctionParametersIn
 * @Provenance sha256=06ac536d14a9069319bd97588bc0cf704bd7c77c43d65fc48b873ceb181f2332; lines 131-146.
 * @Provenance Oracle: AcceptStringIn("Test") "Received: Test"; AcceptNameIn n"MyName"; AcceptTextIn "InputText".
 * @Provenance Extra: empty &in string; empty FText ToString.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace LiteralsTest
{
	/**
	 * Accepts a read-only string reference and prefixes it.
	 *
	 * @Covers Literals.FString
	 * @Param x read-only string reference
	 * @Return "Received: " followed by the value
	 */
	FString AcceptStringIn(const FString&in x)
	{
		return "Received: " + x;
	}

	/**
	 * Accepts a read-only name reference and returns it unchanged.
	 *
	 * @Covers Literals.FString
	 * @Param x read-only name reference
	 * @Return the same name
	 */
	FName AcceptNameIn(const FName&in x)
	{
		return x;
	}

	/**
	 * Accepts a read-only text reference and unwraps it.
	 *
	 * @Covers Literals.FString
	 * @Param x read-only text reference
	 * @Return the underlying string
	 */
	FString AcceptTextIn(const FText&in x)
	{
		return x.ToString();
	}

	/**
	 * Observe that all three `&in` overloads read their caller's value.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs local FString, FName and FText values
	 * @Return true when all three results match
	 */
	UFUNCTION()
	bool FunctionParametersInReadExpectedValues()
	{
		FString InputString = "Test";
		FName InputName = n"MyName";
		FText InputText = FText::FromString("InputText");

		if (AcceptStringIn(InputString) != "Received: Test")
		{
			return false;
		}

		if (AcceptNameIn(InputName) != n"MyName")
		{
			return false;
		}

		return AcceptTextIn(InputText) == "InputText";
	}

	/**
	 * Observe the empty-string boundary of the `&in` string overload.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs AcceptStringIn("")
	 * @Return true when the result is "Received: "
	 * @Boundary empty string
	 */
	UFUNCTION()
	bool AcceptStringInEmptyBoundary()
	{
		FString Empty = "";
		return AcceptStringIn(Empty) == "Received: ";
	}

	/**
	 * Observe the default-constructed boundary of the `&in` text overload.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs AcceptTextIn(FText())
	 * @Return true when the result is empty
	 * @Boundary default-constructed FText
	 */
	UFUNCTION()
	bool AcceptTextInEmptyBoundary()
	{
		FText Empty;
		return AcceptTextIn(Empty) == "";
	}
}
