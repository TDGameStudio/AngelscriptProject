/**
 * A UPROPERTY carrying no explicit access specifier inherits the default
 * Blueprint access from project settings, while one marked BlueprintReadWrite
 * opts out of that default. The observers construct carriers and check that
 * both fields start at zero and copy independently.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.DefaultBlueprintAccessUsesSettings
 * @Harness UClass
 * @Tag Language.Preprocessor.DefaultBlueprintAccessUsesSettings
 * @Provenance C++: AngelscriptPreprocessorPropertyTests.cpp::DefaultBlueprintAccessUsesSettings
 * @Provenance sha256=2d5e421212debcc2a270ee1ba3431827286680e4f3ba5a095ddea5e32ec19d97; lines 177-184.
 * @Provenance Oracle: ImplicitAccess readable not writable; ExplicitAccess BlueprintReadWrite. Keep those UPROPERTY names.
 * @Provenance Extra: default ints are 0. DefaultSafe.
 */

UCLASS()
class UBlueprintAccessDefaultSpecifierCarrier : UObject
{
	UPROPERTY() int ImplicitAccess;
	UPROPERTY(BlueprintReadWrite) int ExplicitAccess;

	/**
	 * Observe that the implicit-access field defaults to zero.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Properties
	 * @Inputs a freshly constructed carrier
	 * @Return true when ImplicitAccess is 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool ImplicitAccessDefaultsToZero()
	{
		return ImplicitAccess == 0;
	}

	/**
	 * Observe that the explicit-access field defaults to zero.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Properties
	 * @Inputs a freshly constructed carrier
	 * @Return true when ExplicitAccess is 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool ExplicitAccessDefaultsToZero()
	{
		return ExplicitAccess == 0;
	}

	/**
	 * Observe that writing to this carrier leaves a sibling untouched.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Properties
	 * @Inputs this carrier written to, compared against a second carrier
	 * @Return true when this carrier holds the writes and the other stays zero
	 * @Boundary instance independence
	 */
	UFUNCTION()
	bool AccessFieldsAreIndependentAcrossInstances()
	{
		UBlueprintAccessDefaultSpecifierCarrier Other =
			Cast<UBlueprintAccessDefaultSpecifierCarrier>(
				NewObject(GetTransientPackage(), UBlueprintAccessDefaultSpecifierCarrier::StaticClass(), n"BlueprintAccessDefaultSpecifierCarrierOther"));
		if (Other == nullptr)
		{
			throw("TS-LANG-0351 setup: NewObject returned null");
		}

		ImplicitAccess = 7;
		ExplicitAccess = 9;

		if (ImplicitAccess != 7)
		{
			return false;
		}

		if (ExplicitAccess != 9)
		{
			return false;
		}

		if (Other.ImplicitAccess != 0)
		{
			return false;
		}

		return Other.ExplicitAccess == 0;
	}
}
