/**
 * The second file of the conflicting hot-reload batch. Isolated, this empty
 * carrier would compile; C++ fails the batch because the first module already
 * published UDuplicateCarrier. Keep the class body empty — adding methods would
 * change the fixture the batch diagnostic is measured against.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.DuplicateClassNameSecondBatchFile
 * @Harness UClass
 * @Tag Language.Preprocessor.DuplicateClassNameSecondBatchFile
 * @Provenance C++: AngelscriptPreprocessorClassTests.cpp::DuplicateClassNameAcrossHotReloadBatchReportsConflict
 * @Provenance Second.as; lines 134-139;
 * @Provenance sha256=4d508e3f6dcfae6b06d31974bbea69529c66c76161cc579b81fa925f78cc9553.
 * @Provenance Expected batch diagnostic: "Cannot declare class UDuplicateCarrier in module
 * @Provenance Tests.Preprocessor.Second. A class with this name already exists in module
 * @Provenance Tests.Preprocessor.First." Second module must not keep the duplicate class.
 * @Provenance Do not add methods that would change the empty-class fixture.
 * @Provenance DiagnosticOnly for the batch; isolated file keeps the empty class body.
 */

UCLASS()
class UDuplicateCarrier : UObject
{
}
