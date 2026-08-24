// Theme: Definitions.UFunction. NegativeDiagnostic: USTRUCT members may not be UFUNCTION.
// C++: AngelscriptCoverageUFunctionTests.cpp::UnsupportedUFunctionShapeDiagnostics case USTRUCT member UFUNCTION.
// Expected diagnostic: "Structs may not have any UFUNCTION()s."
// Isolate this failing program. DiagnosticOnly.

USTRUCT()
struct FBadFunctionStruct
{
	UFUNCTION()
	int BadMember()
	{
		return 1;
	}
}
