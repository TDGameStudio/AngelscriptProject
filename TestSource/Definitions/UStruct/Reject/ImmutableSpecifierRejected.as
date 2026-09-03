/**
 * USTRUCT(Immutable) is not a script-side specifier, so this program is rejected.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.ImmutableSpecifierRejected
 * @Harness CompileReject
 * @Tag Definitions.UStruct.ImmutableSpecifierRejected
 * @Kind CompileReject
 * @Covers UStruct.ImmutableSpecifierRejected
 * @Inputs USTRUCT(Immutable) on FImmutableStruct
 * @Return does not compile; diagnostic "Unknown class specifier Immutable"
 * @Provenance Theme: Definitions.UStruct. Isolated compile-fail: USTRUCT(Immutable) is unsupported.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedSpecifiers CompileAndExpectFailure
 * @Provenance lines 3434-3441;
 * @Provenance sha256=9688106c7cc3ec695e2caff2c316b719f2a6734c0ad7e9dd24a78e2476009fd9.
 * @Provenance Expected diagnostic: Unknown class specifier Immutable.
 * @Provenance DiagnosticOnly. Isolated failing program.
 */

USTRUCT(Immutable)
struct FImmutableStruct
{
	UPROPERTY()
	int Value = 1;
}
