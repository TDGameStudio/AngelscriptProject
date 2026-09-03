/**
 * Default conversion for bool, name, string, enum, object, and struct.
 * ApplyDefaultTypeMatrix(false, RuntimeName, RuntimeLabel, Third, this,
 * class) is 56 and LastSummary RuntimeName:RuntimeLabel.
 * ApplyStructDefaultMatrix((10,20,5),(1,2,3,1)) is 42. All defaults score
 * 26. Struct defaults FVector(1,2,3)+Red score 8. LastSummary is empty by
 * default.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.DefaultArgumentTypeConversionMatrix
 * @Harness UClass
 * @Tag Definitions.UFunction.DefaultArgumentTypeConversionMatrix
 * @Provenance Theme: Definitions.UFunction. WorldStory: default conversion for bool/name/string/enum/object/struct.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::DefaultArgumentTypeConversionMatrix
 * @Provenance Oracle: ApplyDefaultTypeMatrix(false, RuntimeName, RuntimeLabel, Third, this, class) == 56
 * @Provenance LastSummary RuntimeName:RuntimeLabel; ApplyStructDefaultMatrix((10,20,5),(1,2,3,1)) == 42.
 * @Provenance Extra: all defaults (true, DefaultName, DefaultLabel, Second, null, null) score 1+11+12+2=26;
 * @Provenance struct defaults FVector(1,2,3)+Red score 8; LastSummary empty by default.
 * @Provenance FixtureIsolated. Runner owns World teardown.
 */

UENUM(BlueprintType)
enum EUFunctionDefaultChoice
{
	First = 1,
	Second = 2,
	Third = 3,
}

UCLASS()
class ACoverageUFunctionDefaultTypeActor : AActor
{
	UPROPERTY()
	FString LastSummary;

	UPROPERTY()
	int LastScore = 0;

	/**
	 * Score default-converted bool, name, string, enum, object, and subclass arguments.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param bEnabled Live flag, default true
	 * @Param NameValue Name, default DefaultName
	 * @Param Label String, default DefaultLabel
	 * @Param Choice Enum, default Second
	 * @Param ObjectValue Object, default nullptr
	 * @Param ActorClass Actor subclass, default nullptr
	 * @Inputs the six defaulted arguments
	 * @Return LastScore after writing LastSummary
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|Defaults")
	int ApplyDefaultTypeMatrix(bool bEnabled = true, FName NameValue = n"DefaultName", FString Label = "DefaultLabel", EUFunctionDefaultChoice Choice = EUFunctionDefaultChoice::Second, UObject ObjectValue = nullptr, TSubclassOf<AActor> ActorClass = nullptr)
	{
		LastScore = (bEnabled ? 1 : 0)
			+ NameValue.ToString().Len()
			+ Label.Len()
			+ int(Choice)
			+ (ObjectValue != nullptr ? 10 : 0)
			+ (ActorClass != nullptr ? 20 : 0);
		LastSummary = NameValue.ToString() + ":" + Label;
		return LastScore;
	}

	/**
	 * Score default-converted FVector and FLinearColor arguments.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param Location Vector, default (1,2,3)
	 * @Param Color Linear color, default Red
	 * @Inputs Location and Color
	 * @Return LastScore of the summed components
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|Defaults")
	int ApplyStructDefaultMatrix(FVector Location = FVector(1.0, 2.0, 3.0), FLinearColor Color = FLinearColor::Red)
	{
		LastScore = int(Location.X + Location.Y + Location.Z + Color.R + Color.G + Color.B + Color.A);
		return LastScore;
	}

	/**
	 * Observe ApplyDefaultTypeMatrix of runtime values scoring 56.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs ApplyDefaultTypeMatrix(false, RuntimeName, RuntimeLabel, Third, this, class)
	 * @Return 56
	 */
	UFUNCTION()
	int RuntimeFiftySix()
	{
		return ApplyDefaultTypeMatrix(
			false,
			n"RuntimeName",
			"RuntimeLabel",
			EUFunctionDefaultChoice::Third,
			this,
			ACoverageUFunctionDefaultTypeActor::StaticClass());
	}

	/**
	 * Observe LastSummary after the runtime ApplyDefaultTypeMatrix.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs ApplyDefaultTypeMatrix of runtime values
	 * @Return "RuntimeName:RuntimeLabel"
	 */
	UFUNCTION()
	FString RuntimeSummary()
	{
		ApplyDefaultTypeMatrix(
			false,
			n"RuntimeName",
			"RuntimeLabel",
			EUFunctionDefaultChoice::Third,
			this,
			ACoverageUFunctionDefaultTypeActor::StaticClass());
		return LastSummary;
	}

	/**
	 * Observe ApplyDefaultTypeMatrix with omitted defaults.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs ApplyDefaultTypeMatrix()
	 * @Return 26
	 * @Boundary omitted defaults
	 */
	UFUNCTION()
	int OmittedDefaults()
	{
		return ApplyDefaultTypeMatrix();
	}

	/**
	 * Observe ApplyStructDefaultMatrix of (10,20,5) and (1,2,3,1).
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs ApplyStructDefaultMatrix((10,20,5), (1,2,3,1))
	 * @Return 42
	 */
	UFUNCTION()
	int StructExplicitFortyTwo()
	{
		return ApplyStructDefaultMatrix(FVector(10.0, 20.0, 5.0), FLinearColor(1.0f, 2.0f, 3.0f, 1.0f));
	}

	/**
	 * Observe ApplyStructDefaultMatrix with omitted defaults.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs ApplyStructDefaultMatrix()
	 * @Return 8
	 * @Boundary omitted struct defaults
	 */
	UFUNCTION()
	int StructOmittedDefaults()
	{
		return ApplyStructDefaultMatrix();
	}

	/**
	 * Observe the default empty LastSummary.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs a freshly constructed actor
	 * @Return the empty LastSummary
	 * @Boundary default summary
	 */
	UFUNCTION()
	FString EmptySummary()
	{
		return LastSummary;
	}
}
