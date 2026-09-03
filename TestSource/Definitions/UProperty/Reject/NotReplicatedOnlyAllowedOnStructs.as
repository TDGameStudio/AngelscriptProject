/**
 * Replicated plus NotReplicated on a UCLASS member is rejected. NotReplicated is
 * only allowed on structs. This file is the illegal program itself; do not drop
 * either specifier.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.NotReplicatedOnlyAllowedOnStructs
 * @Harness CompileReject
 * @Tag Definitions.UProperty.NotReplicatedOnlyAllowedOnStructs
 * @Kind CompileReject
 * @Covers UProperty.NotReplicatedOnlyAllowedOnStructs
 * @Inputs UPROPERTY(Replicated, NotReplicated) int X
 * @Return does not compile; diagnostic "NotReplicated specifier is only allowed structs"
 * @Provenance Theme: Definitions.UProperty. Isolated compile-fail: Replicated plus NotReplicated.
 * @Provenance C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Negative AssertFailsToCompile
 * @Provenance UPropSN_ConflictRepNotRep; lines 218-224;
 * @Provenance sha256=db29ac0b5480be845c916ac3cfab07eaacad846bc8df15a5d38b0009da6286a7.
 * @Provenance Expected diagnostic: NotReplicated specifier is only allowed structs.
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

class AUPropConflictRepActor : AActor
{
	UPROPERTY(Replicated, NotReplicated)
	int X = 0;
}
