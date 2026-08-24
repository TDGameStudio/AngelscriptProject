// Theme: Definitions.UEnum. WorldStory enum<->int conversion.
// C++: AngelscriptCoverageUEnumTests.cpp::UEnumConversion
// Oracle after BeginPlay: EnumToIntResult=20; IntToEnumResult ValueTen=10.
// Extra: ValueZero empty 0; nullptr actor is the empty handle.
// FixtureIsolated. Keep EnumToIntResult / IntToEnumResult names.

UENUM()
enum EConversionEnum
{
	ValueZero = 0,
	ValueTen = 10,
	ValueTwenty = 20
}

UCLASS()
class ACoverageUEnumConversionActor : AActor
{
	UPROPERTY()
	int EnumToIntResult = 0;

	UPROPERTY()
	EConversionEnum IntToEnumResult = EConversionEnum::ValueZero;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		EConversionEnum EnumVal = EConversionEnum::ValueTwenty;
		int IntVal = int(EnumVal);
		check(IntVal == 20);
		EnumToIntResult = IntVal;

		int SourceInt = 10;
		EConversionEnum ConvertedEnum = EConversionEnum(SourceInt);
		check(ConvertedEnum == EConversionEnum::ValueTen);
		IntToEnumResult = ConvertedEnum;
	}
}

bool Observe_Conversion_BeginPlayOracle(ACoverageUEnumConversionActor Actor)
{
	Actor.BeginPlay();
	return Actor.EnumToIntResult == 20 && Actor.IntToEnumResult == EConversionEnum::ValueTen;
}

bool Observe_Conversion_EmptyZero()
{
	return int(EConversionEnum::ValueZero) == 0
		&& EConversionEnum(0) == EConversionEnum::ValueZero;
}

bool Observe_Conversion_NullDefault()
{
	ACoverageUEnumConversionActor Actor = nullptr;
	return Actor == nullptr;
}

bool Observe_Conversion_TwentyBoundary()
{
	return int(EConversionEnum::ValueTwenty) == 20
		&& EConversionEnum(20) == EConversionEnum::ValueTwenty;
}
