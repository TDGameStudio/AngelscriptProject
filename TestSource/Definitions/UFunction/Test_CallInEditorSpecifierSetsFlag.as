// Theme: Definitions.UFunction. Positive CallInEditor specifier compiles and is callable.
// C++: AngelscriptCompilerUFunctionSpecifierMatrixTests.cpp::CallInEditorSpecifierSetsFlag
// Oracle: EditorOnlyAction exists; C++ checks CallInEditor metadata/flags.
// Extra: nullptr handle is the empty vector; a second call remains a no-op.
// DefaultSafe.

UCLASS()
class UCallInEditorTestObj : UObject
{
	UFUNCTION(CallInEditor)
	void EditorOnlyAction()
	{
	}
}

int Observe_EditorOnlyAction_EmptyCall(UCallInEditorTestObj Object)
{
	Object.EditorOnlyAction();
	return 1;
}

bool Observe_EditorOnlyAction_NullDefault()
{
	UCallInEditorTestObj Object = nullptr;
	return Object == nullptr;
}

int Observe_EditorOnlyAction_RepeatCall(UCallInEditorTestObj Object)
{
	Object.EditorOnlyAction();
	Object.EditorOnlyAction();
	return 1;
}
