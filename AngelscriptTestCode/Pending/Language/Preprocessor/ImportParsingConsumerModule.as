/**
 * @version v1
 * @summary The consumer half of a manual import: a module that imports the provider and calls into it. The import is resolved during preprocessing and then stripped, yet the authored source keeps the import line.
 * @topic Language
 */
/**
 * @version root
 * @summary The consumer half of a manual import: a module that imports the provider and calls into it. The import is resolved during preprocessing and then stripped, yet the authored source keeps the import line.
 * @topic Baseline
 */
import Tests.Preprocessor.Shared;

namespace PreprocessorTest
{
	/**
	 * Calls the imported provider and returns its value.
	 *
	 * @Covers Preprocessor.Imports
	 * @Inputs the imported SharedValue
	 * @Return 11
	 */
	int UseShared()
	{
		return SharedValue();
	}

	/**
	 * Observe that the import resolved and the value came through.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs UseShared()
	 * @Return true when the value is 11
	 */
	UFUNCTION()
	bool ImportResolvesToSharedValue()
	{
		return UseShared() == 11;
	}
}
/** @end */
