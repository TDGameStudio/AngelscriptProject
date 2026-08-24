// Theme: Definitions.UFunction. Positive BlueprintAuthorityOnly specifier compiles and is callable.
// C++: AngelscriptCompilerUFunctionSpecifierMatrixTests.cpp::BlueprintAuthorityOnlySpecifierSetsFlag
// Oracle: AuthorityAction exists; C++ checks FUNC_BlueprintAuthorityOnly.
// Extra: nullptr handle is the empty vector; a second call remains a no-op.
// DefaultSafe.

UCLASS()
class UAuthorityOnlyTestObj : UObject
{
	UFUNCTION(BlueprintAuthorityOnly)
	void AuthorityAction()
	{
	}
}

int Observe_AuthorityAction_EmptyCall(UAuthorityOnlyTestObj Object)
{
	Object.AuthorityAction();
	return 1;
}

bool Observe_AuthorityAction_NullDefault()
{
	UAuthorityOnlyTestObj Object = nullptr;
	return Object == nullptr;
}

int Observe_AuthorityAction_RepeatCall(UAuthorityOnlyTestObj Object)
{
	Object.AuthorityAction();
	Object.AuthorityAction();
	return 1;
}
