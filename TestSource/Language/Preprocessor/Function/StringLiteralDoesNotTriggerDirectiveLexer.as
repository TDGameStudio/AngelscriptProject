/**
 * Directive-looking text inside a string literal or a comment is not a
 * directive. The lexer must leave such text alone, so the literal keeps the
 * exact directive text it contains.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.StringLiteralDoesNotTriggerDirectiveLexer
 * @Harness Function
 * @Tag Language.Preprocessor.StringLiteralDoesNotTriggerDirectiveLexer
 * @Namespace PreprocessorTest
 * @Provenance C++: AngelscriptPreprocessorDirectiveTests.cpp::StringLiteralDoesNotTriggerDirectiveLexer
 * @Provenance Compile + ExecuteIntFunction; lines 342-351;
 * @Provenance sha256=ca1aaf735fd4e9d269079c4f2376776b5588f50a7b821454827b88ae71d770f1.
 * @Provenance Oracle: Entry() == 42; BuildMarker equals "debug #if RELEASE #else keep".
 * @Provenance Extra: a mismatched compare would return 0; two BuildMarker calls match.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace PreprocessorTest
{
	/**
	 * Returns a string containing text that looks like directives.
	 *
	 * @Covers Preprocessor.Directives
	 * @Inputs none
	 * @Return "debug #if RELEASE #else keep"
	 */
	FString BuildMarker()
	{
		return "debug #if RELEASE #else keep";
	}

	/**
	 * Compares the marker against the literal it was built from.
	 *
	 * @Covers Preprocessor.Directives
	 * @Inputs BuildMarker()
	 * @Return 42 when the directive-looking text survived intact, else 0
	 */
	int Entry()
	{
		if (BuildMarker() != "debug #if RELEASE #else keep")
		{
			return 0;
		}

		return 42;
	}

	/**
	 * Observe that the literal was not treated as a directive.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Directives
	 * @Inputs Entry()
	 * @Return true when Entry reports 42
	 */
	UFUNCTION()
	bool StringLiteralNotDirective()
	{
		return Entry() == 42;
	}

	/**
	 * Observe that two calls to the builder agree.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Directives
	 * @Inputs two calls to BuildMarker()
	 * @Return true when both match the literal and each other
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool BuildMarkerCopyIndependence()
	{
		FString First = BuildMarker();
		FString Second = BuildMarker();

		if (First != "debug #if RELEASE #else keep")
		{
			return false;
		}

		return First == Second;
	}
}
