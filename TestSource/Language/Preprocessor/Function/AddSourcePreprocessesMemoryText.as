/**
 * Source supplied purely in memory, with no physical filename, still
 * preprocesses into a single code section and executes.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.AddSourcePreprocessesMemoryText
 * @Harness Function
 * @Tag Language.Preprocessor.AddSourcePreprocessesMemoryText
 * @Namespace PreprocessorTest
 * @Provenance C++: AngelscriptVirtualScriptPathPreprocessorTests.cpp::AddSourcePreprocessesMemoryText
 * @Provenance sha256=b10539ba99493915949dad58b49fb3976634be5221106d35fdc21b78a2c5bfbb; lines 72-77.
 * @Provenance Oracle: Entry() == 11; module Angelscript.Memory.Immediate.Snippet_001, one code section.
 * @Provenance Extra: repeat stays 11. DefaultSafe.
 */

namespace PreprocessorTest
{
	/**
	 * A constant entry point in a memory-only module.
	 *
	 * @Covers Preprocessor.RoundTrip
	 * @Inputs none
	 * @Return 11
	 */
	int Entry()
	{
		return 11;
	}

	/**
	 * Observe that the memory-only module reports 11.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.RoundTrip
	 * @Inputs Entry()
	 * @Return true when the value is 11
	 */
	UFUNCTION()
	bool MemoryTextPreprocessesToEleven()
	{
		return Entry() == 11;
	}

	/**
	 * Observe that repeated calls agree.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.RoundTrip
	 * @Inputs two calls to Entry()
	 * @Return true when both report 11
	 * @Boundary repeat
	 */
	UFUNCTION()
	bool MemoryTextRepeatsConsistently()
	{
		if (Entry() != 11)
		{
			return false;
		}

		return Entry() == 11;
	}
}
