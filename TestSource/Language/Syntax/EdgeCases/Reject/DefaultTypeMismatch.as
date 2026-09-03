/**
 * A `default` statement whose value does not match the property type is rejected.
 * This file is the illegal program itself; do not change the value's type, since
 * the mismatch is the point.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.DefaultTypeMismatch
 * @Harness CompileReject
 * @Tag Language.Syntax.EdgeCases.DefaultTypeMismatch
 * @Kind CompileReject
 * @Covers Syntax.EdgeCases
 * @Inputs a string default assigned to an int property
 * @Return does not compile; diagnostic "type mismatch default"
 * @Provenance C++: AngelscriptCompilerPropertyDefaultMatrixTests.cpp::DefaultTypeMismatchFails
 * @Provenance sha256=b26a725297146cec421040201292c2d463d469dd00d4a6d1c4928e5f0c3b0ba4; lines 552-561.
 * @Provenance Expected diagnostic: type mismatch default should fail to compile.
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

UCLASS()
class UDefaultTypeMismatchCarrier : UObject
{
	UPROPERTY()
	int MyInt;

	default MyInt = "not an int";
}
