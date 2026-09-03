/**
 * A method marked `defaults` is only accessible from default statements.
 * Calling it from an ordinary UFUNCTION is rejected. This file is the illegal
 * program itself; do not call BuildDefaultValue from a default statement.
 *
 * @Theme Feature.Default
 * @Subject Default.DefaultsOnlyFromUFunction
 * @Harness CompileReject
 * @Tag Feature.Default.DefaultsOnlyFromUFunction
 * @Kind CompileReject
 * @Covers Default.DefaultsOnly
 * @Inputs UFUNCTION Entry() calling BuildDefaultValue() defaults
 * @Return does not compile; diagnostic "only accessible from default statements"
 * @Provenance Theme: Feature.Default. Isolated compile-fail: defaults-only method from ordinary UFUNCTION.
 * @Provenance C++: AngelscriptDefaultStatementSafetyTests.cpp::DefaultsOnlyAccess
 * @Provenance CompileSafetyScript(..., bExpectedCompile=false). Expected diagnostic: "only accessible from default statements".
 * @Provenance DiagnosticOnly. Do not call BuildDefaultValue from a default statement; that would compile.
 */

UCLASS()
class UDefaultsOnlyRejectTarget : UObject
{
	UPROPERTY()
	int Value = 0;

	/**
	 * A defaults-only helper that may not be called from ordinary functions.
	 *
	 * @Kind CompileReject
	 * @Covers Default.DefaultsOnly
	 * @Inputs none
	 * @Return 7 after writing Value
	 */
	int BuildDefaultValue() defaults
	{
		Value = 7;
		return Value;
	}

	/**
	 * Illegally calls the defaults-only helper from an ordinary UFUNCTION.
	 *
	 * @Kind CompileReject
	 * @Covers Default.DefaultsOnly
	 * @Inputs none
	 * @Return does not compile
	 */
	UFUNCTION()
	int Entry()
	{
		return BuildDefaultValue();
	}
}
