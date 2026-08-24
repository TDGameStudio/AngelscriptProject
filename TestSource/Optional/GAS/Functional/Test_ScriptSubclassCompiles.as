// Theme: Optional.GAS. WorldStory: UTestCustomAbilityTask compiles as a
// UAngelscriptAbilityTask subclass with CustomDuration = 2.0f.
// C++: AngelscriptGASAbilityTaskTests.cpp::ScriptSubclassCompiles
// Oracle: IsChildOf(UAngelscriptAbilityTask); FindPropertyByName CustomDuration.
// Extra: nullptr handle; sibling CustomDuration 0.0f; two handles stay distinct.
// Isolation=none. Optional GAS plugin fixture. Runner owns NewObject.

UCLASS()
class UTestCustomAbilityTask : UAngelscriptAbilityTask
{
	UPROPERTY()
	float CustomDuration = 2.0f;
}

UCLASS()
class UTestCustomAbilityTaskEmpty : UAngelscriptAbilityTask
{
	UPROPERTY()
	float CustomDuration = 0.0f;
}

bool Observe_UTestCustomAbilityTask_DurationNominal(UTestCustomAbilityTask Task)
{
	return Task.CustomDuration == 2.0f;
}

bool Observe_UTestCustomAbilityTask_EmptySibling(UTestCustomAbilityTaskEmpty Task)
{
	return Task.CustomDuration == 0.0f;
}

bool Observe_UTestCustomAbilityTask_NullDefault()
{
	UTestCustomAbilityTask Task = nullptr;
	return Task == nullptr;
}

bool Observe_UTestCustomAbilityTask_CopyIndependent(UTestCustomAbilityTask First, UTestCustomAbilityTask Second)
{
	First.CustomDuration = 0.0f;
	return Second.CustomDuration == 2.0f;
}
