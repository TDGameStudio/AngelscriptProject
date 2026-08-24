// Theme: Language.Literals.FString. WorldStory: f-string interpolation and n"" FName literals.
// C++: AngelscriptTypesStringInterpolationAndFNameLiteralTests.cpp::FStringInterpolationAndFNameLiteralRuntimeValues
// sha256=eec08529df691009f1f2c9b3bfb8daf9ef92cc7abe9698cea041380b2ccc33f4; lines 32-63.
// Oracle: Greeting "Hello World!"; Composite "1 2 in 3s";
// n"Tag" == FName("Tag"); n"tag" == FName("TAG") (case-insensitive).
// Extra: empty WhoName interpolates to "Hello !"; NAME_None is not n"Tag".
// FixtureIsolated. Keep UPROPERTY names Greeting, Composite,
// bFNameLiteralEqualsConstructor, bFNameLiteralIsCaseInsensitive.

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

	UFUNCTION()
	bool Observe_Interpolation_Nominal()
	{
		return Greeting == "Hello World!"
			&& Composite == "1 2 in 3s"
			&& bFNameLiteralEqualsConstructor
			&& bFNameLiteralIsCaseInsensitive;
	}

	UFUNCTION()
	FString Observe_EmptyWhoNameInterpolation()
	{
		FString WhoName = "";
		return f"Hello {WhoName}!";
	}

	UFUNCTION()
	bool Observe_FNameNoneNotTagBoundary()
	{
		return n"Tag" != NAME_None;
	}
}
