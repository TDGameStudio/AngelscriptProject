/**
 * @version v1
 * @summary An actor builds strings through f-string interpolation and compares n"" FName literals against constructor-built names. The observers confirm the interpolated greeting and composite, the empty-name interpolation, and the.
 * @topic Language
 */
/**
 * @version root
 * @summary An actor builds strings through f-string interpolation and compares n"" FName literals against constructor-built names. The observers confirm the interpolated greeting and composite, the empty-name interpolation, and the.
 * @topic Baseline
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
/** @end */
