/**
 * @version v1
 * @summary Write-only `&out` reference parameters across the string family. The callee assigns a fresh value regardless of what the caller held, so the oracle checks that prior contents are discarded.
 * @topic Language
 */
/**
 * @version root
 * @summary Write-only `&out` reference parameters across the string family. The callee assigns a fresh value regardless of what the caller held, so the oracle checks that prior contents are discarded.
 * @topic Baseline
 */
namespace LiteralsTest
{
	/**
	 * Assigns a fixed string to the caller's variable.
	 *
	 * @Covers Literals.FString
	 * @Param x write-only string reference
	 * @Return none; x becomes "Output"
	 */
	void WriteString(FString&out x)
	{
		x = "Output";
	}

	/**
	 * Assigns a fixed name to the caller's variable.
	 *
	 * @Covers Literals.FString
	 * @Param x write-only name reference
	 * @Return none; x becomes n"OutputName"
	 */
	void WriteName(FName&out x)
	{
		x = n"OutputName";
	}

	/**
	 * Assigns fixed text to the caller's variable.
	 *
	 * @Covers Literals.FString
	 * @Param x write-only text reference
	 * @Return none; x becomes "OutputText"
	 */
	void WriteText(FText&out x)
	{
		x = FText::FromString("OutputText");
	}

	/**
	 * Assigns two distinct strings through separate out parameters.
	 *
	 * @Covers Literals.FString
	 * @Param a write-only string reference, becomes "First"
	 * @Param b write-only string reference, becomes "Second"
	 * @Return none
	 */
	void WriteMultiple(FString&out a, FString&out b)
	{
		a = "First";
		b = "Second";
	}

	/**
	 * Observe that every `&out` parameter receives its assigned value.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs default-constructed locals passed as out parameters
	 * @Return true when all five assignments landed
	 */
	UFUNCTION()
	bool FunctionParametersOutAssignExpectedValues()
	{
		FString OutValue;
		WriteString(OutValue);

		FName OutName;
		WriteName(OutName);

		FText OutText;
		WriteText(OutText);

		FString OutA;
		FString OutB;
		WriteMultiple(OutA, OutB);

		if (OutValue != "Output")
		{
			return false;
		}

		if (OutName != n"OutputName")
		{
			return false;
		}

		if (OutText.ToString() != "OutputText")
		{
			return false;
		}

		if (OutA != "First")
		{
			return false;
		}

		return OutB == "Second";
	}

	/**
	 * Observe that an out parameter discards prior string contents.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs WriteString over a pre-initialized empty string
	 * @Return true when the result is "Output"
	 * @Boundary pre-initialized out parameter
	 */
	UFUNCTION()
	bool WriteStringOverwritesBoundary()
	{
		FString OutValue = "";
		WriteString(OutValue);
		return OutValue == "Output";
	}

	/**
	 * Observe that two out parameters are written independently.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs WriteMultiple over two identical pre-set strings
	 * @Return true when each parameter receives its own value
	 * @Boundary aliased prior values
	 */
	UFUNCTION()
	bool WriteMultipleIndependenceBoundary()
	{
		FString A = "Keep";
		FString B = "Keep";
		WriteMultiple(A, B);

		if (A != "First")
		{
			return false;
		}

		return B == "Second";
	}
}
/** @end */
