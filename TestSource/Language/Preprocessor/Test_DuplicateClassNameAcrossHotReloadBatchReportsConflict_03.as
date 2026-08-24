// Theme: Language.Preprocessor. Second file in the conflicting hot-reload batch.
// Isolated, this empty UDuplicateCarrier would compile; C++ fails the batch
// because Tests.Preprocessor.First already published UDuplicateCarrier.
// C++: AngelscriptPreprocessorClassTests.cpp::DuplicateClassNameAcrossHotReloadBatchReportsConflict
// Second.as; lines 134-139;
// sha256=4d508e3f6dcfae6b06d31974bbea69529c66c76161cc579b81fa925f78cc9553.
// Expected batch diagnostic: "Cannot declare class UDuplicateCarrier in module
// Tests.Preprocessor.Second. A class with this name already exists in module
// Tests.Preprocessor.First." Second module must not keep the duplicate class.
// Do not add methods that would change the empty-class fixture.
// DiagnosticOnly for the batch; isolated file keeps the empty class body.

UCLASS()
class UDuplicateCarrier : UObject
{
}
