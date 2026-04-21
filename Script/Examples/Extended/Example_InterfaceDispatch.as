/**
 * Interface-like polymorphism example using BlueprintEvent.
 *
 * This example demonstrates how to achieve polymorphic dispatch
 * in AngelScript using base class BlueprintEvents that derived
 * classes can override — the most stable pattern for cross-class
 * dispatch in the current plugin version.
 */

/**
 * A base actor class that defines an overridable "damageable" contract.
 */
class AExampleDamageableBase : AActor
{
	UPROPERTY(Category = "Health")
	float MaxHealth = 100.0;

	UPROPERTY(BlueprintReadOnly, Category = "Health")
	float CurrentHealth = 100.0;

	/**
	 * Override this in derived classes to handle damage.
	 * Returns the remaining health.
	 */
	UFUNCTION(BlueprintEvent)
	float ApplyDamage(float Amount)
	{
		CurrentHealth = Math::Max(CurrentHealth - Amount, 0.0);
		Print(f"{GetName()} took {Amount} damage, health: {CurrentHealth}");
		return CurrentHealth;
	}

	UFUNCTION(BlueprintEvent)
	bool IsAlive()
	{
		return CurrentHealth > 0.0;
	}
};

/**
 * A concrete damageable actor with custom death behavior.
 */
class AExampleDamageableActor : AExampleDamageableBase
{
	UFUNCTION(BlueprintOverride)
	float ApplyDamage(float Amount)
	{
		CurrentHealth = Math::Max(CurrentHealth - Amount, 0.0);
		Print(f"[Custom] {GetName()} received {Amount} damage!");

		if (CurrentHealth <= 0.0)
		{
			Print(f"{GetName()} has been destroyed!");
		}
		return CurrentHealth;
	}
};

/**
 * A global function demonstrating polymorphic dispatch:
 * any AExampleDamageableBase (or subclass) can be passed in.
 */
UFUNCTION(Category = "Example Dispatch")
void ApplyDamageToTarget(AExampleDamageableBase Target, float Damage)
{
	if (Target == nullptr)
		return;

	float Remaining = Target.ApplyDamage(Damage);
	if (!Target.IsAlive())
	{
		Print(f"{Target.GetName()} is dead!");
	}
}
