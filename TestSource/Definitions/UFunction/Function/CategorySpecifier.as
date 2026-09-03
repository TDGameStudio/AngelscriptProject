/**
 * Category on an actor method. Attack is a valid Category = "Combat"
 * UFUNCTION, a default handle is null, and assigning one handle to another
 * aliases the same object.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.CategorySpecifier
 * @Harness Function
 * @Tag Definitions.UFunction.CategorySpecifier
 * @Namespace UFunctionTest
 * @Provenance Theme: Definitions.UFunction. WorldStory: Category specifier.
 * @Provenance C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Positive block 6 AssertCompiles.
 * @Provenance sha256=844e990a57e57dcc40c6bdfdb04003ceabbc9b97d6d5d7cef7065f1985a8e1ef; lines 108-114.
 * @Provenance Oracle: AUFuncCategoryActor.Attack() is a valid Category = "Combat" UFUNCTION.
 * @Provenance Extra: default handle is null; assigning aliases the same handle.
 * @Provenance FixtureIsolated.
 */

class AUFuncCategoryActor : AActor
{
	/**
	 * Category UFUNCTION used to prove the specifier compiles.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs none
	 * @Return void
	 */
	UFUNCTION(Category = "Combat")
	void Attack()
	{
	}
}

namespace UFunctionTest
{
	/**
	 * Observe that Attack can be invoked on a live actor handle.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Actor Actor whose Attack is invoked, runner-owned when non-null
	 * @Inputs Actor.Attack()
	 * @Return 0 when the call completes; -1 when Actor is null
	 */
	UFUNCTION()
	int AttackCallCompletes(AUFuncCategoryActor Actor)
	{
		if (Actor == nullptr)
		{
			return -1;
		}
		Actor.Attack();
		return 0;
	}

	/**
	 * Observe that a default actor handle is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs a default-constructed AUFuncCategoryActor
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default handle
	 */
	UFUNCTION()
	int EmptyHandleIsNull()
	{
		AUFuncCategoryActor Unset;
		if (Unset == nullptr)
		{
			return 1;
		}
		return 0;
	}

	/**
	 * Observe that assigning one handle to another aliases the same object.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs two default handles; First = Second
	 * @Return true when First is Second
	 */
	UFUNCTION()
	bool AssignAliasesHandle()
	{
		AUFuncCategoryActor First;
		AUFuncCategoryActor Second;
		First = Second;
		return First is Second;
	}
}
