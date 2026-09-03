/**
 * Calling a method marked `unsafe_during_construction` from a default
 * statement is rejected. This file is the illegal program itself; do not
 * move UnsafeValue off the default statement.
 *
 * @Theme Feature.Default
 * @Subject Default.UnsafeDuringConstructionInDefault
 * @Harness CompileReject
 * @Tag Feature.Default.UnsafeDuringConstructionInDefault
 * @Kind CompileReject
 * @Covers Default.UnsafeDuringConstruction
 * @Inputs default Value = UnsafeValue() on UUnsafeDefaultTarget
 * @Return does not compile; diagnostic "unsafe during construction"
 * @Provenance Theme: Feature.Default. Isolated compile-fail: unsafe_during_construction in a default statement.
 * @Provenance C++: AngelscriptDefaultStatementSafetyTests.cpp::UnsafeDuringConstructionRejectsDefaultAndConstructor
 * @Provenance CompileSafetyScript(..., bExpectedCompile=false). Module TEXT("ASUnsafeDefault").
 * @Provenance Expected diagnostic: "unsafe during construction".
 * @Provenance DiagnosticOnly. Do not move UnsafeValue off the default statement.
 */

UCLASS()
class UUnsafeDefaultTarget : UObject
{
	UPROPERTY()
	int Value = 0;

	/**
	 * A method that is unsafe to call while the object is being constructed.
	 *
	 * @Kind CompileReject
	 * @Covers Default.UnsafeDuringConstruction
	 * @Inputs none
	 * @Return 7
	 */
	int UnsafeValue() unsafe_during_construction
	{
		return 7;
	}

	default Value = UnsafeValue();
}
