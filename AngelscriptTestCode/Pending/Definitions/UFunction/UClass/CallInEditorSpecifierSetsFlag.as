/**
 * @version v1
 * @summary CallInEditor compiles and is callable. EditorOnlyAction exists so C++ can check CallInEditor metadata. A nullptr handle is the empty vector, and a second call remains a no-op.
 * @topic Definitions
 */
/**
 * @version root
 * @summary CallInEditor compiles and is callable. EditorOnlyAction exists so C++ can check CallInEditor metadata. A nullptr handle is the empty vector, and a second call remains a no-op.
 * @topic Baseline
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
/** @end */
