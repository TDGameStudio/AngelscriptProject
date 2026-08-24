// Theme: Definitions.Meta. WorldStory: property specifier matrix reflected on FProperty.
// C++: AngelscriptPropertyMetaMatrixTests.cpp::MetaSpecifiersAreReflectedOnFProperty
// Oracle defaults: CategorizedFloat 0, toggles false, DefaultsOnlyValue 0, bEnableHealth true,
// Health 50, HealthRegenLevel 1, EditableLocation ZeroVector.
// Extra: Health 0 / bEnableHealth false. FixtureIsolated.

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
}

float Observe_PropertyMetaMatrix_HealthDefault(AFunctionalPropertyMetaMatrixActor Actor)
{
	return Actor.Health;
}

int Observe_PropertyMetaMatrix_HealthRegenDefault(AFunctionalPropertyMetaMatrixActor Actor)
{
	return Actor.HealthRegenLevel;
}

bool Observe_PropertyMetaMatrix_EnableHealthDefault(AFunctionalPropertyMetaMatrixActor Actor)
{
	return Actor.bEnableHealth;
}

bool Observe_PropertyMetaMatrix_HiddenToggleDefault(AFunctionalPropertyMetaMatrixActor Actor)
{
	return Actor.bHiddenToggle;
}

float Observe_PropertyMetaMatrix_ZeroHealthBoundary(AFunctionalPropertyMetaMatrixActor Actor)
{
	Actor.bEnableHealth = false;
	Actor.Health = 0.0;
	return Actor.Health;
}

bool Observe_PropertyMetaMatrix_ZeroVectorDefault(AFunctionalPropertyMetaMatrixActor Actor)
{
	return Actor.EditableLocation.IsNearlyZero();
}
