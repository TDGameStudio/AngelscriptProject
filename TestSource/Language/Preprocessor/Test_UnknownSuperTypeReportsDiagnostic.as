// Theme: Language.Preprocessor. Isolated compile-fail: unknown UCLASS super.
// C++: AngelscriptPreprocessorClassTests.cpp::UnknownSuperTypeReportsDiagnostic
// AssertPreprocessFailed; lines 48-53;
// sha256=c5769df6114047f43d254349e356574f2e257ddc3e2751b53bef619c8a2446ba.
// Expected diagnostic: "Class UUnknownSuperCarrier has an unknown super type UMissingBaseType."
// Module exists with 0 code sections and 0 class descriptors.
// Do not change the super type to UObject.
// DiagnosticOnly.

UCLASS()
class UUnknownSuperCarrier : UMissingBaseType
{
}
