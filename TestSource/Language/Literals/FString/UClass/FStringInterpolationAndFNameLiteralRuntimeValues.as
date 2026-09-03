/**
 * An actor builds strings through f-string interpolation and compares n""
 * FName literals against constructor-built names. The observers confirm the
 * interpolated greeting and composite, the empty-name interpolation, and the
 * case-insensitive FName literal equality. The UPROPERTY names Greeting,
 * Composite, bFNameLiteralEqualsConstructor, and bFNameLiteralIsCaseInsensitive
 * are read by path from C++ and must not be renamed.
 *
 * @Theme Language.Literals
 * @Subject Literals.FStringInterpolationAndFNameLiteralRuntimeValues
 * @Harness UClass
 * @Tag Language.Literals.FStringInterpolationAndFNameLiteralRuntimeValues
 * @Provenance C++: AngelscriptTypesStringInterpolationAndFNameLiteralTests.cpp::FStringInterpolationAndFNameLiteralRuntimeValues
 * @Provenance sha256=eec08529df691009f1f2c9b3bfb8daf9ef92cc7abe9698cea041380b2ccc33f4; lines 32-63.
 * @Provenance Oracle: Greeting "Hello World!"; Composite "1 2 in 3s";
 * @Provenance n"Tag" == FName("Tag"); n"tag" == FName("TAG") (case-insensitive).
 * @Provenance Extra: empty WhoName interpolates to "Hello !"; NAME_None is not n"Tag".
 * @Provenance FixtureIsolated. Keep UPROPERTY names Greeting, Composite,
 * @Provenance bFNameLiteralEqualsConstructor, bFNameLiteralIsCaseInsensitive.
 */

UCLASS()
class AFunctionalStringInterpolationActor : AActor
{
	UPROPERTY()
	FString Greeting;

	UPROPERTY()
	FString Composite;

	UPROPERTY()
	bool bFNameLiteralEqualsConstructor = false;

	UPROPERTY()
	bool bFNameLiteralIsCaseInsensitive = false;

	/**
	 * Build the interpolated strings and evaluate the FName literal comparisons.
	 *
	 * @Covers Literals.FString
	 * @Inputs An interpolated greeting and composite, and n"" FName literals
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FString WhoName = "World";
		Greeting = f"Hello {WhoName}!";

		int32 A = 1;
		int32 B = 2;
		int32 C = 3;
		Composite = f"{A} {B} in {C}s";

		bFNameLiteralEqualsConstructor = (n"Tag" == FName("Tag"));
		bFNameLiteralIsCaseInsensitive = (n"tag" == FName("TAG"));
	}

	/**
	 * Confirm the interpolated values and the FName literal comparisons hold.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs Greeting, Composite, and the two FName literal flags
	 * @Return true when all four interpolated/literal expectations hold
	 */
	UFUNCTION()
	bool VerifyInterpolation()
	{
		if (Greeting != "Hello World!")
		{
			return false;
		}
		if (Composite != "1 2 in 3s")
		{
			return false;
		}
		if (!bFNameLiteralEqualsConstructor)
		{
			return false;
		}
		return bFNameLiteralIsCaseInsensitive;
	}

	/**
	 * Interpolate an empty name and return the result.
	 *
	 * @Covers Literals.FString
	 * @Inputs An empty WhoName
	 * @Return "Hello !" with the empty name in place
	 * @Boundary empty interpolation value
	 */
	UFUNCTION()
	FString InterpolateEmptyWhoName()
	{
		FString WhoName = "";
		return f"Hello {WhoName}!";
	}

	/**
	 * Confirm an n"" tag literal is not NAME_None.
	 *
	 * @Kind Observe
	 * @Covers Literals.FName
	 * @Inputs n"Tag" compared to NAME_None
	 * @Return true when n"Tag" differs from NAME_None
	 * @Boundary NAME_None sentinel
	 */
	UFUNCTION()
	bool VerifyFNameNoneNotTag()
	{
		return n"Tag" != NAME_None;
	}
}
