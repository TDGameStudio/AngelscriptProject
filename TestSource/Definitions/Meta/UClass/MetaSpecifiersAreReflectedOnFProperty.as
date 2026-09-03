/**
 * A property specifier matrix reflected on FProperty: Category, NotEditable,
 * EditConst, BlueprintReadOnly, EditDefaultsOnly, InlineEditConditionToggle,
 * EditCondition, Clamp, UI range, EditConditionHides and MakeEditWidget.
 *
 * @Theme Definitions.Meta
 * @Subject Meta.MetaSpecifiersAreReflectedOnFProperty
 * @Harness UClass
 * @Tag Definitions.Meta.MetaSpecifiersAreReflectedOnFProperty
 * @Provenance Theme: Definitions.Meta. WorldStory: property specifier matrix reflected on FProperty.
 * @Provenance C++: AngelscriptPropertyMetaMatrixTests.cpp::MetaSpecifiersAreReflectedOnFProperty
 * @Provenance Oracle defaults: CategorizedFloat 0, toggles false, DefaultsOnlyValue 0, bEnableHealth true,
 * @Provenance Health 50, HealthRegenLevel 1, EditableLocation ZeroVector.
 * @Provenance Extra: Health 0 / bEnableHealth false. FixtureIsolated.
 */

UCLASS()
class AFunctionalPropertyMetaMatrixActor : AActor
{
	UPROPERTY(Category = "Coverage|Property")
	float CategorizedFloat = 0.0;

	UPROPERTY(NotEditable)
	bool bHiddenToggle = false;

	UPROPERTY(EditConst)
	bool bLockedToggle = false;

	UPROPERTY(BlueprintReadOnly)
	bool bBlueprintReadable = false;

	UPROPERTY(EditDefaultsOnly)
	int DefaultsOnlyValue = 0;

	UPROPERTY(EditAnywhere, meta = (InlineEditConditionToggle))
	bool bEnableHealth = true;

	UPROPERTY(EditAnywhere, meta = (EditCondition = "bEnableHealth", ClampMin = "0.0", ClampMax = "100.0", UIMin = "0.0", UIMax = "100.0"))
	float Health = 50.0;

	UPROPERTY(EditAnywhere, meta = (EditCondition = "bEnableHealth", EditConditionHides))
	int32 HealthRegenLevel = 1;

	UPROPERTY(EditAnywhere, meta = (MakeEditWidget))
	FVector EditableLocation = FVector::ZeroVector;

	/**
	 * Observe the Health default.
	 *
	 * @Kind Observe
	 * @Covers Meta.MetaSpecifiersAreReflectedOnFProperty
	 * @Inputs none
	 * @Return 50
	 */
	UFUNCTION()
	float HealthDefault()
	{
		return Health;
	}

	/**
	 * Observe the HealthRegenLevel default.
	 *
	 * @Kind Observe
	 * @Covers Meta.MetaSpecifiersAreReflectedOnFProperty
	 * @Inputs none
	 * @Return 1
	 */
	UFUNCTION()
	int HealthRegenDefault()
	{
		return HealthRegenLevel;
	}

	/**
	 * Observe the bEnableHealth default.
	 *
	 * @Kind Observe
	 * @Covers Meta.MetaSpecifiersAreReflectedOnFProperty
	 * @Inputs none
	 * @Return true
	 */
	UFUNCTION()
	bool EnableHealthDefault()
	{
		return bEnableHealth;
	}

	/**
	 * Observe the bHiddenToggle default.
	 *
	 * @Kind Observe
	 * @Covers Meta.MetaSpecifiersAreReflectedOnFProperty
	 * @Inputs none
	 * @Return false
	 */
	UFUNCTION()
	bool HiddenToggleDefault()
	{
		return bHiddenToggle;
	}

	/**
	 * Observe that disabling health and writing zero is accepted.
	 *
	 * @Kind Observe
	 * @Covers Meta.MetaSpecifiersAreReflectedOnFProperty
	 * @Inputs none
	 * @Return 0
	 * @Boundary zero health
	 */
	UFUNCTION()
	float ZeroHealthBoundary()
	{
		bEnableHealth = false;
		Health = 0.0;
		return Health;
	}

	/**
	 * Observe that EditableLocation defaults to nearly zero.
	 *
	 * @Kind Observe
	 * @Covers Meta.MetaSpecifiersAreReflectedOnFProperty
	 * @Inputs none
	 * @Return true when EditableLocation is nearly zero
	 * @Boundary zero vector
	 */
	UFUNCTION()
	bool ZeroVectorDefault()
	{
		return EditableLocation.IsNearlyZero();
	}
}
