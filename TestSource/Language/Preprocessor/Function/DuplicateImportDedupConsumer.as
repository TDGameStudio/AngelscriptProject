/**
 * A consumer that imports the same module twice. The two identical import
 * statements collapse into a single dependency, so the module is still imported
 * exactly once and the value comes through unchanged.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.DuplicateImportDedupConsumer
 * @Harness Function
 * @Tag Language.Preprocessor.DuplicateImportDedupConsumer
 * @Namespace PreprocessorTest
 * @Provenance C++: AngelscriptPreprocessorImportTests.cpp::DuplicateStatementsDeduplicateDependency block 2
 * @Provenance sha256=b81a355d6ddd0924a7b1a802aa1f16fce7d3c411957b38768abac267f94e3374; lines 335-342.
 * @Provenance Oracle: Entry() == 17 through the deduplicated import of Tests.Preprocessor.ImportDedup.Shared.
 * @Provenance Extra: Entry matches SharedValue. DefaultSafe.
 */

import Tests.Preprocessor.ImportDedup.Shared;
import Tests.Preprocessor.ImportDedup.Shared;

namespace PreprocessorTest
{
	/**
	 * Returns the value imported through the duplicated statements.
	 *
	 * @Covers Preprocessor.Imports
	 * @Inputs the deduplicated SharedValue
	 * @Return 17
	 */
	int Entry()
	{
		return SharedValue();
	}

	/**
	 * Observe that the deduplicated import still supplies the value.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs Entry()
	 * @Return true when the value is 17
	 */
	UFUNCTION()
	bool DuplicateImportResolvesOnce()
	{
		return Entry() == 17;
	}

	/**
	 * Observe that the consumed value equals the provider's directly.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs Entry() and SharedValue()
	 * @Return true when the two agree
	 * @Boundary provider match
	 */
	UFUNCTION()
	bool DuplicateImportMatchesProvider()
	{
		return Entry() == SharedValue();
	}
}
