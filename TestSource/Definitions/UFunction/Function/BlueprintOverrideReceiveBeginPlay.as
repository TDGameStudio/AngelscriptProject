/**
 * BlueprintOverride of ReceiveBeginPlay on an actor. The class is an AActor
 * subclass, a default handle is null, and assigning one handle to another
 * aliases the same object.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.BlueprintOverrideReceiveBeginPlay
 * @Harness Function
 * @Tag Definitions.UFunction.BlueprintOverrideReceiveBeginPlay
 * @Namespace UFunctionTest
 * @Provenance Theme: Definitions.UFunction. WorldStory: BlueprintOverride ReceiveBeginPlay.
 * @Provenance C++: AngelscriptSyntaxUFunctionTests.cpp::Specifiers_Positive block 5 AssertCompiles.
 * @Provenance sha256=733f71da2f15523ed8850dd846a0f6c73d94cfe156e4f67b720ec1c826d8a03a; lines 96-102.
 * @Provenance C++ currently wraps this AssertCompiles in #if 0 (#as-engine-behavior BlueprintOverride).
 * @Provenance Oracle: AUFuncBPOverrideActor is an AActor subclass with ReceiveBeginPlay override.
 * @Provenance Extra: default handle is null; assigning aliases the same handle.
 * @Provenance FixtureIsolated.
 */

class AUFuncBPOverrideActor : AActor
{
	/**
	 * BlueprintOverride of ReceiveBeginPlay.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs none
	 * @Return void
	 */
	UFUNCTION(BlueprintOverride)
	void ReceiveBeginPlay()
	{
	}
}

namespace UFunctionTest
{
	/**
	 * Observe that a constructed override actor is an AActor.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs a default-constructed AUFuncBPOverrideActor
	 * @Return 1 when the handle is an AActor, otherwise 0
	 */
	UFUNCTION()
	int OverrideActorIsAActorWhenSet()
	{
		AUFuncBPOverrideActor Actor;
		if (Actor is AActor)
		{
			return 1;
		}
		return 0;
	}

	/**
	 * Observe that a default actor handle is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs a default-constructed AUFuncBPOverrideActor
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default handle
	 */
	UFUNCTION()
	int EmptyHandleIsNull()
	{
		AUFuncBPOverrideActor Unset;
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
		AUFuncBPOverrideActor First;
		AUFuncBPOverrideActor Second;
		First = Second;
		return First is Second;
	}
}
