/**
 * A USTRUCT may not declare UFUNCTION members. Structs are value types and
 * do not generate UFunction objects. This file is the illegal program itself.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.StructMemberUFunction
 * @Harness CompileReject
 * @Tag Definitions.UFunction.StructMemberUFunction
 * @Kind CompileReject
 * @Covers UFunction.Specifier
 * @Inputs USTRUCT FBadFunctionStruct with UFUNCTION() int BadMember()
 * @Return does not compile; diagnostic "Structs may not have any UFUNCTION()s."
 * @Provenance Theme: Definitions.UFunction. NegativeDiagnostic: USTRUCT members may not be UFUNCTION.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case USTRUCT member UFUNCTION.
 * @Provenance Expected compile failure: "Structs may not have any UFUNCTION()s."
 */

USTRUCT()
struct FBadFunctionStruct
{
	/**
	 * Illegal UFUNCTION on a USTRUCT member.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION() int BadMember()
	 * @Return does not compile
	 */
	UFUNCTION()
	int BadMember()
	{
		return 1;
	}
}
