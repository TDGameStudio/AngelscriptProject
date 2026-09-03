/**
 * Exec compiles and is callable. ConsoleCommand exists so C++ can check
 * FUNC_Exec. A nullptr handle is the empty vector, and a second call remains
 * a no-op.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.ExecSpecifierSetsFlag
 * @Harness UClass
 * @Tag Definitions.UFunction.ExecSpecifierSetsFlag
 * @Provenance Theme: Definitions.UFunction. Positive Exec specifier compiles and is callable.
 * @Provenance C++: AngelscriptCompilerUFunctionSpecifierMatrixTests.cpp::ExecSpecifierSetsFlag
 * @Provenance Oracle: ConsoleCommand exists; C++ checks FUNC_Exec.
 * @Provenance Extra: nullptr handle is the empty vector; a second call remains a no-op.
 * @Provenance DefaultSafe.
 */

UCLASS()
class UExecTestObj : UObject
{
	/**
	 * Exec UFUNCTION used to prove the specifier compiles.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs none
	 * @Return void
	 */
	UFUNCTION(Exec)
	void ConsoleCommand()
	{
	}

	/**
	 * Observe that ConsoleCommand can be invoked once.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs ConsoleCommand()
	 * @Return 1
	 */
	UFUNCTION()
	int ConsoleCommandEmptyCall()
	{
		ConsoleCommand();
		return 1;
	}

	/**
	 * Observe that a null handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs UExecTestObj Object = nullptr
	 * @Return true when the handle is null
	 * @Boundary null handle
	 */
	UFUNCTION()
	bool NullDefaultIsNull()
	{
		UExecTestObj Object = nullptr;
		return Object == nullptr;
	}

	/**
	 * Observe that a second ConsoleCommand call remains a no-op.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs two ConsoleCommand calls
	 * @Return 1
	 */
	UFUNCTION()
	int ConsoleCommandRepeatCall()
	{
		ConsoleCommand();
		ConsoleCommand();
		return 1;
	}
}
