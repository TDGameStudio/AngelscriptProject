/**
 * AttachSocket without Attach is rejected. Socket names only apply to an
 * attachment, so this DefaultComponent is illegal. Do not add Attach.
 *
 * @Theme Feature.Attach
 * @Subject Attach.Negative_AttachSocketWithoutAttach
 * @Harness CompileReject
 * @Tag Feature.Attach.Negative_AttachSocketWithoutAttach
 * @Kind CompileReject
 * @Covers Attach.Negative_AttachSocketWithoutAttach
 * @Inputs UPROPERTY(DefaultComponent, AttachSocket = "Socket1") USceneComponent Child
 * @Return does not compile; diagnostic "AttachSocket without Attach should fail"
 * @Provenance Theme: Feature.Attach. NegativeDiagnostic: AttachSocket without Attach.
 * @Provenance C++: AngelscriptSyntaxDefaultComponentTests.cpp::Negative_AttachSocketWithoutAttach.
 * @Provenance AssertFailsToCompile is currently #if 0 (#as-engine-behavior structural-validation-absent).
 * @Provenance Expected diagnostic: "AttachSocket without Attach should fail".
 * @Provenance Isolate the failing program. DiagnosticOnly.
 */

class ADefCompSocketNoAttachActor : AActor
{
	UPROPERTY(DefaultComponent, AttachSocket = "Socket1")
	USceneComponent Child;
}
