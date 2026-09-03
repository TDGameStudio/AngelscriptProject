/**
 * The consumer half of a manual import: a module that imports the provider and
 * calls into it. The import is resolved during preprocessing and then stripped,
 * yet the authored source keeps the import line.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.ImportParsingConsumerModule
 * @Harness Function
 * @Tag Language.Preprocessor.ImportParsingConsumerModule
 * @Namespace PreprocessorTest
 * @Provenance C++: AngelscriptPreprocessorBasicTests.cpp::ImportParsing UsesImport.as
 * @Provenance lines 128-134;
 * @Provenance sha256=d40909a8f6892292773a5e9ba8ee0fc7dfae54b8219605f5cae74cfdf7a5cd.
 * @Provenance Oracle: UseShared() == 11 via SharedValue().
 * @Provenance Extra: 11 is the provider return; import line stays in authored source.
 * @Provenance DefaultSafe. Import identity: Tests.Preprocessor.Shared.
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
