/**
 * A UCLASS whose super type names a class that does not exist is rejected, and
 * the module is left with no code sections or class descriptors. This file is
 * the illegal program itself; do not change the super type to UObject, since
 * the unknown super is the point.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.UnknownSuperTypeOnClass
 * @Harness CompileReject
 * @Tag Language.Preprocessor.UnknownSuperTypeOnClass
 * @Kind CompileReject
 * @Covers Preprocessor.Classes
 * @Inputs a UCLASS deriving from UMissingBaseType
 * @Return does not preprocess; diagnostic names the class and its unknown super
 * @Provenance C++: AngelscriptPreprocessorClassTests.cpp::UnknownSuperTypeReportsDiagnostic
 * @Provenance AssertPreprocessFailed; lines 48-53;
 * @Provenance sha256=c5769df6114047f43d254349e356574f2e257ddc3e2751b53bef619c8a2446ba.
 * @Provenance Expected diagnostic: "Class UUnknownSuperCarrier has an unknown super type UMissingBaseType."
 * @Provenance Module exists with 0 code sections and 0 class descriptors.
 * @Provenance Do not change the super type to UObject.
 * @Provenance DiagnosticOnly.
 */

UCLASS()
class UUnknownSuperCarrier : UMissingBaseType
{
}
