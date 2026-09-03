/**
 * A file registered with bTreatAsDeleted preprocesses successfully but emits an
 * empty module: its import is never resolved, because the file is never really
 * compiled. Adding a real provider would defeat the case, so the import must
 * keep pointing at a module that does not exist.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.TreatAsDeletedProducesEmptyModule
 * @Harness CompileReject
 * @Tag Language.Preprocessor.TreatAsDeletedProducesEmptyModule
 * @Kind CompileReject
 * @Covers Preprocessor.Imports
 * @Inputs an import of a module that is never provided
 * @Return no code and no classes; the import is never resolved
 * @Provenance C++: AngelscriptPreprocessorAsyncTests.cpp::TreatAsDeletedProducesEmptyModule
 * @Provenance lines 527-538;
 * @Provenance sha256=7c3b2e55b6d2067b3cb5c42cfd8b2eae38bd9ce9fc07bea9ac6dbf43fa0b9a24.
 * @Provenance Oracle: preprocess succeeds; module exists with no code/classes.
 * @Provenance The missing import is never resolved because the file is treated as deleted.
 * @Provenance Do not add a real provider that would make a live compile succeed.
 * @Provenance DefaultSafe. Keep UDeletedFileProbe and Entry declarations.
 */

import Tests.Preprocessor.DeletedFile.MissingProvider;

UCLASS()
class UDeletedFileProbe : UObject
{
	/**
	 * An entry point that would return 7 if the module were ever compiled. It
	 * never runs, because the file is treated as deleted.
	 *
	 * @Covers Preprocessor.Imports
	 * @Inputs none
	 * @Return 7, never reached
	 */
	UFUNCTION()
	int Entry()
	{
		return 7;
	}
}
