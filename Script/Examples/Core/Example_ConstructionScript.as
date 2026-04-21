/*
 * This is an example on how to use construction scripts
 * for angelscript classes. This class creates a root component
 * for itself using a construction script instead of a DefaultComponent,
 * and calculates a derived property.
 */
class AExampleConstructionScript : AActor
{
	UPROPERTY(NotVisible)
	UBillboardComponent Billboard;

	UPROPERTY(Category = "Calculation")
	int ValueA = 3;

	UPROPERTY(Category = "Calculation")
	int ValueB = 3;

	/* This will be set by the construction script to the value of (ValueA * ValueB) */
	UPROPERTY(BlueprintReadOnly, NotEditable, Category = "Calculation")
	int Product;

	/* The overridden construction script will run when needed. */
	UFUNCTION()
	void ConstructionScript()
	{
		// Create a component dynamically from construction script
		Billboard = UBillboardComponent::Create(this, n"Billboard");

		// Set the derived property
		Product = ValueA * ValueB;
	}
};
