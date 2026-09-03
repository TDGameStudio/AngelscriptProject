/**
 * Preprocessor AddFile emits one game virtual-path code section whose entrypoint
 * returns 9. The observers cover the nominal return and a repeated call.
 *
 * @Theme Definitions.Meta
 * @Subject Meta.AddFileEmitsGameVirtualPathMetadata
 * @Harness Function
 * @Tag Definitions.Meta.AddFileEmitsGameVirtualPathMetadata
 * @Namespace MetaTest
 * @Provenance Theme: Definitions.Meta. Positive: preprocessor AddFile emits one game virtual-path code section.
 * @Provenance C++: AngelscriptVirtualScriptPathPreprocessorTests.cpp::AddFileEmitsGameVirtualPathMetadata
 * @Provenance Oracle: Entry() == 9. Extra: repeating Entry is stable. DefaultSafe.
 */

namespace MetaTest
{
	/**
	 * Return the constant that C++ records as the AddFile oracle.
	 *
	 * @Kind Observe
	 * @Covers Meta.AddFileEmitsGameVirtualPathMetadata
	 * @Inputs none
	 * @Return 9
	 */
	UFUNCTION()
	int Entry()
	{
		return 9;
	}

	/**
	 * Observe that Entry reports 9.
	 *
	 * @Kind Observe
	 * @Covers Meta.AddFileEmitsGameVirtualPathMetadata
	 * @Inputs none
	 * @Return 9
	 */
	UFUNCTION()
	int EntryNominal()
	{
		return Entry();
	}

	/**
	 * Observe that repeating Entry is stable.
	 *
	 * @Kind Observe
	 * @Covers Meta.AddFileEmitsGameVirtualPathMetadata
	 * @Inputs none
	 * @Return true when both calls report 9
	 * @Boundary repeated call
	 */
	UFUNCTION()
	bool RepeatCall()
	{
		if (Entry() != 9)
		{
			return false;
		}
		return Entry() == 9;
	}
}
