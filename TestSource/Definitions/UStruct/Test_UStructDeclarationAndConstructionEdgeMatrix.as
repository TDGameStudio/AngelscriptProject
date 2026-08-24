// Theme: Definitions.UStruct. WorldStory: empty USTRUCT, constructors, copy-init vs assign.
// C++: AngelscriptCoverageUStructTests.cpp::UStructDeclarationAndConstructionEdgeMatrix
// lines 1802-1944;
// sha256=1242ca21ae714b1e159251b32419873208902c9d7d5370bb95b10088cde6aca2.
// Oracle after BeginPlay: DefaultConstructed.Value=7 Label=DefaultCtor,
// ExplicitConstructed.Value=21 Label=Explicit, CopyInitialized.Value=131
// Label=Source_CopyCtor, Assigned.Value=31 Label=Source, PlainDefaultSum=11,
// PlainExplicitSum=19, EmptyDelegateCallCount=1, EmptyDelegateResult=77.
// Extra: local default ctor / copy ctor / assign / empty FEmptyCoverageStruct.
// FixtureIsolated.

USTRUCT(BlueprintType)
struct FEmptyCoverageStruct
{
}

USTRUCT(BlueprintType)
struct FConstructedStruct
{
	UPROPERTY()
	int Value = 1;

	UPROPERTY()
	FString Label = "Default";

	FConstructedStruct()
	{
		Value = 7;
		Label = "DefaultCtor";
	}

	FConstructedStruct(int InValue, FString InLabel)
	{
		Value = InValue;
		Label = InLabel;
	}

	FConstructedStruct(const FConstructedStruct& Other)
	{
		Value = Other.Value + 100;
		Label = Other.Label + "_CopyCtor";
	}
}

struct FPlainConstructionStruct
{
	int X = 2;
	int Y = 3;

	FPlainConstructionStruct()
	{
		X = 5;
		Y = 6;
	}

	FPlainConstructionStruct(int InX, int InY)
	{
		X = InX;
		Y = InY;
	}
}

delegate int FEmptyStructSignal(FEmptyCoverageStruct Payload);

UCLASS()
class ACoverageStructConstructionEdgeActor : AActor
{
	UPROPERTY()
	FEmptyCoverageStruct EmptyProperty;

	UPROPERTY()
	FConstructedStruct DefaultConstructed;

	UPROPERTY()
	FConstructedStruct ExplicitConstructed;

	UPROPERTY()
	FConstructedStruct CopyInitialized;

	UPROPERTY()
	FConstructedStruct Assigned;

	UPROPERTY()
	int PlainDefaultSum = 0;

	UPROPERTY()
	int PlainExplicitSum = 0;

	UPROPERTY()
	int EmptyValueCallCount = 0;

	UPROPERTY()
	int EmptyDelegateCallCount = 0;

	UPROPERTY()
	int EmptyDelegateResult = 0;

	UPROPERTY()
	FEmptyStructSignal EmptySignal;

	UFUNCTION(BlueprintCallable)
	int AcceptEmptyValue(FEmptyCoverageStruct Payload)
	{
		EmptyValueCallCount += 1;
		return EmptyValueCallCount;
	}

	UFUNCTION(BlueprintCallable)
	void FillEmptyOut(FEmptyCoverageStruct&out Payload)
	{
		EmptyValueCallCount += 10;
	}

	UFUNCTION(BlueprintCallable)
	FEmptyCoverageStruct ReturnEmpty()
	{
		EmptyValueCallCount += 100;
		FEmptyCoverageStruct Payload;
		return Payload;
	}

	UFUNCTION()
	int HandleEmpty(FEmptyCoverageStruct Payload)
	{
		EmptyDelegateCallCount += 1;
		return 77;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FConstructedStruct LocalDefault;
		DefaultConstructed = LocalDefault;

		ExplicitConstructed = FConstructedStruct(21, "Explicit");

		FConstructedStruct Source(31, "Source");
		FConstructedStruct Copy(Source);
		CopyInitialized = Copy;

		Assigned = Source;

		FPlainConstructionStruct PlainDefault;
		PlainDefaultSum = PlainDefault.X + PlainDefault.Y;

		FPlainConstructionStruct PlainExplicit(9, 10);
		PlainExplicitSum = PlainExplicit.X + PlainExplicit.Y;

		EmptySignal.BindUFunction(this, n"HandleEmpty");
		EmptyDelegateResult = EmptySignal.Execute(EmptyProperty);
	}
}

bool Observe_Constructed_DefaultCtor()
{
	FConstructedStruct LocalDefault;
	return LocalDefault.Value == 7 && LocalDefault.Label == "DefaultCtor";
}

bool Observe_Constructed_ExplicitCtor()
{
	FConstructedStruct ExplicitConstructed(21, "Explicit");
	return ExplicitConstructed.Value == 21 && ExplicitConstructed.Label == "Explicit";
}

bool Observe_Constructed_CopyCtor()
{
	FConstructedStruct Source(31, "Source");
	FConstructedStruct Copy(Source);
	return Copy.Value == 131 && Copy.Label == "Source_CopyCtor" && Source.Value == 31;
}

bool Observe_Constructed_AssignNoCopyCtor()
{
	FConstructedStruct Source(31, "Source");
	FConstructedStruct Assigned;
	Assigned = Source;
	return Assigned.Value == 31 && Assigned.Label == "Source";
}

int Observe_Plain_DefaultSum()
{
	FPlainConstructionStruct PlainDefault;
	return PlainDefault.X + PlainDefault.Y;
}

int Observe_Plain_ExplicitSum()
{
	FPlainConstructionStruct PlainExplicit(9, 10);
	return PlainExplicit.X + PlainExplicit.Y;
}
