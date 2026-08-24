// Theme: Definitions.UFunction. WorldStory: default conversion for bool/name/string/enum/object/struct.
// C++: AngelscriptCoverageUFunctionTests.cpp::DefaultArgumentTypeConversionMatrix
// Oracle: ApplyDefaultTypeMatrix(false, RuntimeName, RuntimeLabel, Third, this, class) == 56
// LastSummary RuntimeName:RuntimeLabel; ApplyStructDefaultMatrix((10,20,5),(1,2,3,1)) == 42.
// Extra: all defaults (true, DefaultName, DefaultLabel, Second, null, null) score 1+11+12+2=26;
// struct defaults FVector(1,2,3)+Red score 8; LastSummary empty by default.
// FixtureIsolated. Runner owns World teardown.

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

	UFUNCTION(BlueprintCallable, Category="Coverage|Defaults")
	int ApplyStructDefaultMatrix(FVector Location = FVector(1.0, 2.0, 3.0), FLinearColor Color = FLinearColor::Red)
	{
		LastScore = int(Location.X + Location.Y + Location.Z + Color.R + Color.G + Color.B + Color.A);
		return LastScore;
	}
}

int Observe_DefaultType_Runtime56(ACoverageUFunctionDefaultTypeActor Actor)
{
	if (Actor is null)
	{
		throw("Test_DefaultArgumentTypeConversionMatrix setup: required Actor is null");
	}
	return Actor.ApplyDefaultTypeMatrix(
		false,
		n"RuntimeName",
		"RuntimeLabel",
		EUFunctionDefaultChoice::Third,
		Actor,
		ACoverageUFunctionDefaultTypeActor::StaticClass());
}

FString Observe_DefaultType_RuntimeSummary(ACoverageUFunctionDefaultTypeActor Actor)
{
	if (Actor is null)
	{
		throw("Test_DefaultArgumentTypeConversionMatrix setup: required Actor is null");
	}
	Actor.ApplyDefaultTypeMatrix(
		false,
		n"RuntimeName",
		"RuntimeLabel",
		EUFunctionDefaultChoice::Third,
		Actor,
		ACoverageUFunctionDefaultTypeActor::StaticClass());
	return Actor.LastSummary;
}

int Observe_DefaultType_OmittedDefaults(ACoverageUFunctionDefaultTypeActor Actor)
{
	if (Actor is null)
	{
		throw("Test_DefaultArgumentTypeConversionMatrix setup: required Actor is null");
	}
	return Actor.ApplyDefaultTypeMatrix();
}

int Observe_DefaultType_StructExplicit42(ACoverageUFunctionDefaultTypeActor Actor)
{
	if (Actor is null)
	{
		throw("Test_DefaultArgumentTypeConversionMatrix setup: required Actor is null");
	}
	return Actor.ApplyStructDefaultMatrix(FVector(10.0, 20.0, 5.0), FLinearColor(1.0f, 2.0f, 3.0f, 1.0f));
}

int Observe_DefaultType_StructOmittedDefaults(ACoverageUFunctionDefaultTypeActor Actor)
{
	if (Actor is null)
	{
		throw("Test_DefaultArgumentTypeConversionMatrix setup: required Actor is null");
	}
	return Actor.ApplyStructDefaultMatrix();
}

FString Observe_DefaultType_EmptySummary(ACoverageUFunctionDefaultTypeActor Actor)
{
	if (Actor is null)
	{
		throw("Test_DefaultArgumentTypeConversionMatrix setup: required Actor is null");
	}
	return Actor.LastSummary;
}
