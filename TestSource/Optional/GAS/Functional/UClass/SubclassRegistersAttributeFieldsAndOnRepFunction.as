/**
 * A script attribute set subclass registering Health, MaxHealth and Stamina and
 * inheriting OnRep_Attribute. C++ owns the reflection checks; the observers cover
 * the unset handle, the three empty attribute data fields and copy independence.
 *
 * @Theme Optional.GAS
 * @Subject GAS.SubclassRegistersAttributeFieldsAndOnRep
 * @Harness UClass
 * @Tag Optional.GAS.SubclassRegistersAttributeFieldsAndOnRepFunction
 * @Provenance Theme: Optional.GAS. WorldStory: script UAngelscriptAttributeSet subclass registers
 * @Provenance Health, MaxHealth, Stamina and inherits OnRep_Attribute.
 * @Provenance C++: AngelscriptGASScriptAttributeSetTests.cpp::SubclassRegistersAttributeFieldsAndOnRepFunction
 * @Provenance sha256=34ccc9404e892ea0a225818650390ad766dfbd3c7272633fdcdf45b9a64d5157; lines 44-57.
 * @Provenance Oracle: class is a child of UAngelscriptAttributeSet; Health / MaxHealth / Stamina are
 * @Provenance FStructProperty holding FAngelscriptGameplayAttributeData; OnRep_Attribute is inherited.
 * @Provenance Extra: unset set handle is null; default FAngelscriptGameplayAttributeData AttributeName is None.
 * @Provenance FixtureIsolated. Runner owns module teardown. Do not spawn from script.
 */

UCLASS()
class UFunctionalCharacterAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Health;

	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData MaxHealth;

	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Stamina;

	/**
	 * Observe that an unset handle is null and all three fields are unnamed.
	 *
	 * @Kind Observe
	 * @Covers GAS.SubclassRegistersAttributeFieldsAndOnRep
	 * @Inputs an unset set handle and three default attribute data
	 * @Return true when the handle is null and all three names are none
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		UFunctionalCharacterAttributes Unset;
		FAngelscriptGameplayAttributeData EmptyHealth;
		FAngelscriptGameplayAttributeData EmptyMaxHealth;
		FAngelscriptGameplayAttributeData EmptyStamina;

		if (Unset != nullptr)
		{
			return false;
		}
		if (!EmptyHealth.AttributeName.IsNone())
		{
			return false;
		}
		if (!EmptyMaxHealth.AttributeName.IsNone())
		{
			return false;
		}
		return EmptyStamina.AttributeName.IsNone();
	}

	/**
	 * Observe that assigning one handle to another aliases them.
	 *
	 * @Kind Observe
	 * @Covers GAS.SubclassRegistersAttributeFieldsAndOnRep
	 * @Inputs two handles, one assigned from the other
	 * @Return true when both are null and the copied data has no name
	 * @Boundary copy aliasing
	 */
	UFUNCTION()
	bool CopyIndependence()
	{
		UFunctionalCharacterAttributes First;
		UFunctionalCharacterAttributes Second;
		FAngelscriptGameplayAttributeData Copied;
		First = Second;

		if (First != Second)
		{
			return false;
		}
		if (First != nullptr)
		{
			return false;
		}
		return Copied.AttributeName.IsNone();
	}
}
