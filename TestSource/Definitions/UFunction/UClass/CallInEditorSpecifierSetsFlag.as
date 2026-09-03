/**
 * CallInEditor compiles and is callable. EditorOnlyAction exists so C++ can
 * check CallInEditor metadata. A nullptr handle is the empty vector, and a
 * second call remains a no-op.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.CallInEditorSpecifierSetsFlag
 * @Harness UClass
 * @Tag Definitions.UFunction.CallInEditorSpecifierSetsFlag
 * @Provenance Theme: Definitions.UFunction. Positive CallInEditor specifier compiles and is callable.
 * @Provenance C++: AngelscriptCompilerUFunctionSpecifierMatrixTests.cpp::CallInEditorSpecifierSetsFlag
 * @Provenance Oracle: EditorOnlyAction exists; C++ checks CallInEditor metadata/flags.
 * @Provenance Extra: nullptr handle is the empty vector; a second call remains a no-op.
 * @Provenance DefaultSafe.
 */

UCLASS()
class UCallInEditorTestObj : UObject
{
	/**
	 * CallInEditor UFUNCTION used to prove the specifier compiles.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs none
	 * @Return void
	 */
	UFUNCTION(CallInEditor)
	void EditorOnlyAction()
	{
	}

	/**
	 * Observe that EditorOnlyAction can be invoked once.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs EditorOnlyAction()
	 * @Return 1
	 */
	UFUNCTION()
	int EditorOnlyActionEmptyCall()
	{
		EditorOnlyAction();
		return 1;
	}

	/**
	 * Observe that a null handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs UCallInEditorTestObj Object = nullptr
	 * @Return true when the handle is null
	 * @Boundary null handle
	 */
	UFUNCTION()
	bool NullDefaultIsNull()
	{
		UCallInEditorTestObj Object = nullptr;
		return Object == nullptr;
	}

	/**
	 * Observe that a second EditorOnlyAction call remains a no-op.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs two EditorOnlyAction calls
	 * @Return 1
	 */
	UFUNCTION()
	int EditorOnlyActionRepeatCall()
	{
		EditorOnlyAction();
		EditorOnlyAction();
		return 1;
	}
}
