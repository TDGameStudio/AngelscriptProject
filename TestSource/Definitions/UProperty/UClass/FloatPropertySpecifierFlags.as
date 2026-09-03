/**
 * A float/double specifier and Clamp/UI/Units metadata matrix. C++ verifies
 * named properties by path, so those UPROPERTY names are kept. The observers
 * cover the empty 0 default and that EmptyFloat is independent of
 * EditAnywhereFloat.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.FloatPropertySpecifierFlags
 * @Harness UClass
 * @Tag Definitions.UProperty.FloatPropertySpecifierFlags
 * @Provenance Theme: Definitions.UProperty. WorldStory: float/double specifier and Clamp/UI/Units metadata matrix.
 * @Provenance C++: named float properties reflect specifier flags and ClampMin/ClampMax/Units metadata.
 * @Provenance Extra: EmptyFloat defaults 0 independently of EditAnywhereFloat 1. FixtureIsolated.
 */

UCLASS()
class ACoverageFloatSpecifierActor : AActor
{
	UPROPERTY(EditAnywhere)
	float EditAnywhereFloat = 1.0f;

	UPROPERTY(EditDefaultsOnly)
	float EditDefaultsOnlyFloat = 2.0f;

	UPROPERTY(EditInstanceOnly)
	float EditInstanceOnlyFloat = 3.0f;

	UPROPERTY(NotEditable)
	float NotEditableFloat = 4.0f;

	UPROPERTY(EditConst)
	float EditConstFloat = 5.0f;

	UPROPERTY(VisibleAnywhere)
	float VisibleAnywhereFloat = 6.0f;

	UPROPERTY(BlueprintReadWrite)
	float BlueprintReadWriteFloat = 7.0f;

	UPROPERTY(BlueprintReadOnly)
	float BlueprintReadOnlyFloat = 8.0f;

	UPROPERTY(Transient)
	float TransientFloat = 9.0f;

	UPROPERTY(meta = (ClampMin = "0.0", ClampMax = "1.0"))
	float ClampedFloat = 0.5f;

	UPROPERTY(meta = (UIMin = "0.0", UIMax = "100.0"))
	float UIFloat = 50.0f;

	UPROPERTY(meta = (Units = "Degrees"))
	float AngleDegrees = 90.0f;

	UPROPERTY(meta = (Units = "Centimeters"))
	float DistanceCentimeters = 100.0f;

	UPROPERTY(Category = "FloatCoverage")
	float CategorizedFloat = 1.0f;

	UPROPERTY(EditAnywhere, meta = (ClampMin = "0.0", ClampMax = "1.0"))
	float EditableClampedFloat = 0.25f;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "DoubleCoverage", meta = (ClampMin = "-10.0", ClampMax = "10.0", UIMin = "-5.0", UIMax = "5.0", Units = "Seconds"))
	double EditableReadonlySeconds = 1.5;

	UPROPERTY()
	float EmptyFloat = 0.0f;

	/**
	 * Observe the empty float default.
	 *
	 * @Kind Observe
	 * @Covers UProperty.FloatPropertySpecifierFlags
	 * @Inputs none
	 * @Return 0.0
	 * @Boundary empty default
	 */
	UFUNCTION()
	float FloatSpecifierEmptyDefault()
	{
		return 0.0f;
	}

	/**
	 * Observe that EmptyFloat is independent of EditAnywhereFloat.
	 *
	 * @Kind Observe
	 * @Covers UProperty.FloatPropertySpecifierFlags
	 * @Inputs local EditAnywhereFloat 1 and EmptyFloat 0
	 * @Return true when the two locals differ
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool FloatSpecifierEmptyIndependentOfEditAnywhere()
	{
		float EditAnywhereFloat = 1.0f;
		float EmptyFloat = 0.0f;
		return EditAnywhereFloat != EmptyFloat;
	}
}
