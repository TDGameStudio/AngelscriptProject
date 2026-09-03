/**
 * The script text for the invalid-descriptor case. The script itself is valid
 * and would execute; the failure this case records is in the C++ AddSource API,
 * which rejects the descriptor before the text is ever compiled. CSV marks the
 * row DiagnosticOnly for the API, not for any AngelScript syntax error.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.AddSourceRejectsInvalidVirtualPathDescriptor
 * @Harness Function
 * @Tag Language.Preprocessor.AddSourceRejectsInvalidVirtualPathDescriptor
 * @Namespace PreprocessorTest
 * @Provenance C++: AngelscriptVirtualScriptPathPreprocessorTests.cpp::AddSourceRejectsInvalidVirtualPathDescriptor
 * @Provenance sha256=e2d74870cc365e51c9da322bea84692cbc90391356ae8ea2f52d83e605d40abe; lines 118-123.
 * @Provenance Expected diagnostic: "Invalid Angelscript source descriptor" before source text is compiled.
 * @Provenance CSV DiagnosticOnly is the AddSource API, not an AngelScript syntax error. Entry() == 13 if compiled.
 * @Provenance Extra: repeat stays 13.
 */

namespace PreprocessorTest
{
	/**
	 * A constant entry point in the rejected-descriptor script.
	 *
	 * @Covers Preprocessor.RoundTrip
	 * @Inputs none
	 * @Return 13
	 */
	int Entry()
	{
		return 13;
	}

	/**
	 * Observe that the script text itself is a valid program.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.RoundTrip
	 * @Inputs Entry()
	 * @Return true when the value is 13
	 */
	UFUNCTION()
	bool DescriptorScriptTextIsValid()
	{
		return Entry() == 13;
	}

	/**
	 * Observe that repeated calls agree.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.RoundTrip
	 * @Inputs two calls to Entry()
	 * @Return true when both report 13
	 * @Boundary repeat
	 */
	UFUNCTION()
	bool DescriptorScriptRepeatsConsistently()
	{
		if (Entry() != 13)
		{
			return false;
		}

		return Entry() == 13;
	}
}
