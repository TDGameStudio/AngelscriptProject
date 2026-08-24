// Theme: Definitions.UFunction. WorldStory: Category specifier.
// C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Positive block 6 AssertCompiles.
// sha256=844e990a57e57dcc40c6bdfdb04003ceabbc9b97d6d5d7cef7065f1985a8e1ef; lines 108-114.
// Oracle: AUFuncCategoryActor.Attack() is a valid Category = "Combat" UFUNCTION.
// Extra: default handle is null; assigning aliases the same handle.
// FixtureIsolated.

class AUFuncCategoryActor : AActor
{
	UFUNCTION(Category = "Combat")
	void Attack()
	{
	}
}

int Observe_Attack_CallCompletes(AUFuncCategoryActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Specifiers_Positive_06 setup: required Actor is null");
	}
	Actor.Attack();
	return 0;
}

int Observe_Attack_EmptyDefaultIsNull()
{
	AUFuncCategoryActor Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}

bool Observe_Attack_AssignAliases()
{
	AUFuncCategoryActor First;
	AUFuncCategoryActor Second;
	First = Second;
	return First is Second;
}
