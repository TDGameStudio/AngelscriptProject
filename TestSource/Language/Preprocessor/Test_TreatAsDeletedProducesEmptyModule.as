// Theme: Language.Preprocessor. Positive C++ method: AddFile(..., bTreatAsDeleted=true)
// still succeeds and emits one empty module; this source is not compiled.
// C++: AngelscriptPreprocessorAsyncTests.cpp::TreatAsDeletedProducesEmptyModule
// lines 527-538;
// sha256=7c3b2e55b6d2067b3cb5c42cfd8b2eae38bd9ce9fc07bea9ac6dbf43fa0b9a24.
// Oracle: preprocess succeeds; module exists with no code/classes.
// The missing import is never resolved because the file is treated as deleted.
// Do not add a real provider that would make a live compile succeed.
// DefaultSafe. Keep UDeletedFileProbe and Entry declarations.

import Tests.Preprocessor.DeletedFile.MissingProvider;

UCLASS()
class UDeletedFileProbe : UObject
{
	UFUNCTION()
	int Entry()
	{
		return 7;
	}
}
