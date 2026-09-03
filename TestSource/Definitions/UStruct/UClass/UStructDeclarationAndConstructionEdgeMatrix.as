/**
 * Empty USTRUCT, constructors, copy-init versus assign, and an empty-struct
 * delegate. C++ reads DefaultConstructed, ExplicitConstructed, CopyInitialized,
 * Assigned, and the empty-delegate counts after BeginPlay.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.UStructDeclarationAndConstructionEdgeMatrix
 * @Harness UClass
 * @Tag Definitions.UStruct.UStructDeclarationAndConstructionEdgeMatrix
 * @Provenance Theme: Definitions.UStruct. WorldStory: empty USTRUCT, constructors, copy-init vs assign.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructDeclarationAndConstructionEdgeMatrix
 * @Provenance lines 1802-1944;
 * @Provenance sha256=1242ca21ae714b1e159251b32419873208902c9d7d5370bb95b10088cde6aca2.
 * @Provenance Oracle after BeginPlay: DefaultConstructed.Value=7 Label=DefaultCtor,
 * @Provenance ExplicitConstructed.Value=21 Label=Explicit, CopyInitialized.Value=131
 * @Provenance Label=Source_CopyCtor, Assigned.Value=31 Label=Source, PlainDefaultSum=11,
 * @Provenance PlainExplicitSum=19, EmptyDelegateCallCount=1, EmptyDelegateResult=77.
 * @Provenance Extra: local default ctor / copy ctor / assign / empty FEmptyCoverageStruct.
 * @Provenance FixtureIsolated.
 */

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

	/**
	 * Default-construct Value 7 and Label DefaultCtor.
	 *
	 * @Covers UStruct.UStructDeclarationAndConstructionEdgeMatrix
	 * @Inputs none
	 * @Return a default-constructed FConstructedStruct
	 */
	FConstructedStruct()
	{
		Value = 7;
		Label = "DefaultCtor";
	}

	/**
	 * Construct from a value and label.
	 *
	 * @Covers UStruct.UStructDeclarationAndConstructionEdgeMatrix
	 * @Inputs InValue and InLabel
	 * @Return an FConstructedStruct holding those fields
	 * @Param InValue the value
	 * @Param InLabel the label
	 */
	FConstructedStruct(int InValue, FString InLabel)
	{
		Value = InValue;
		Label = InLabel;
	}

	/**
	 * Copy-construct with Value+100 and Label suffixed _CopyCtor.
	 *
	 * @Covers UStruct.UStructDeclarationAndConstructionEdgeMatrix
	 * @Inputs another FConstructedStruct
	 * @Return a copy with the copy-ctor offset
	 * @Param Other the source instance
	 */
	FConstructedStruct(const FConstructedStruct&in Other)
	{
		Value = Other.Value + 100;
		Label = Other.Label + "_CopyCtor";
	}
}

struct FPlainConstructionStruct
{
	int X = 2;
	int Y = 3;

	/**
	 * Default-construct X 5 and Y 6.
	 *
	 * @Covers UStruct.UStructDeclarationAndConstructionEdgeMatrix
	 * @Inputs none
	 * @Return a default-constructed FPlainConstructionStruct
	 */
	FPlainConstructionStruct()
	{
		X = 5;
		Y = 6;
	}

	/**
	 * Construct from X and Y.
	 *
	 * @Covers UStruct.UStructDeclarationAndConstructionEdgeMatrix
	 * @Inputs InX and InY
	 * @Return an FPlainConstructionStruct holding those fields
	 * @Param InX the X value
	 * @Param InY the Y value
	 */
	FPlainConstructionStruct(int InX, int InY)
	{
		X = InX;
		Y = InY;
	}
}

/**
 * A delegate that takes an empty coverage struct and returns an int.
 *
 * @Covers UStruct.UStructDeclarationAndConstructionEdgeMatrix
 * @Inputs FEmptyCoverageStruct Payload
 * @Return an int
 * @Param Payload the empty struct
 */
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

	/**
	 * Accept an empty struct by value and count the call.
	 *
	 * @Covers UStruct.UStructDeclarationAndConstructionEdgeMatrix
	 * @Inputs an FEmptyCoverageStruct
	 * @Return EmptyValueCallCount after incrementing by 1
	 * @Param Payload the empty struct
	 */
	UFUNCTION(BlueprintCallable)
	int AcceptEmptyValue(FEmptyCoverageStruct Payload)
	{
		EmptyValueCallCount += 1;
		return EmptyValueCallCount;
	}

	/**
	 * Fill an out empty struct and count the call by 10.
	 *
	 * @Covers UStruct.UStructDeclarationAndConstructionEdgeMatrix
	 * @Inputs an &out FEmptyCoverageStruct
	 * @Return EmptyValueCallCount increased by 10
	 * @Param Payload the out struct
	 */
	UFUNCTION(BlueprintCallable)
	void FillEmptyOut(FEmptyCoverageStruct&out Payload)
	{
		EmptyValueCallCount += 10;
	}

	/**
	 * Return an empty struct and count the call by 100.
	 *
	 * @Covers UStruct.UStructDeclarationAndConstructionEdgeMatrix
	 * @Inputs none
	 * @Return a default FEmptyCoverageStruct
	 */
	UFUNCTION(BlueprintCallable)
	FEmptyCoverageStruct ReturnEmpty()
	{
		EmptyValueCallCount += 100;
		FEmptyCoverageStruct Payload;
		return Payload;
	}

	/**
	 * Handle the empty-struct delegate.
	 *
	 * @Covers UStruct.UStructDeclarationAndConstructionEdgeMatrix
	 * @Inputs an FEmptyCoverageStruct
	 * @Return 77 after incrementing EmptyDelegateCallCount
	 * @Param Payload the empty struct
	 */
	UFUNCTION()
	int HandleEmpty(FEmptyCoverageStruct Payload)
	{
		EmptyDelegateCallCount += 1;
		return 77;
	}

	/**
	 * WorldStory: BeginPlay constructs, copy-inits, assigns, and executes the empty delegate.
	 *
	 * @Kind WorldStory
	 * @Covers UStruct.UStructDeclarationAndConstructionEdgeMatrix
	 * @Inputs none
	 * @Return DefaultConstructed 7/DefaultCtor, CopyInitialized 131/Source_CopyCtor, EmptyDelegateResult 77
	 */
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

	/**
	 * Observe the default constructor result.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructDeclarationAndConstructionEdgeMatrix
	 * @Inputs a default-constructed FConstructedStruct
	 * @Return true when Value is 7 and Label is DefaultCtor
	 * @Boundary default constructor
	 */
	UFUNCTION()
	bool ConstructedDefaultCtor()
	{
		FConstructedStruct LocalDefault;
		if (LocalDefault.Value != 7)
		{
			return false;
		}
		return LocalDefault.Label == "DefaultCtor";
	}

	/**
	 * Observe the explicit constructor result.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructDeclarationAndConstructionEdgeMatrix
	 * @Inputs FConstructedStruct(21, Explicit)
	 * @Return true when Value is 21 and Label is Explicit
	 */
	UFUNCTION()
	bool ConstructedExplicitCtor()
	{
		FConstructedStruct ExplicitLocal(21, "Explicit");
		if (ExplicitLocal.Value != 21)
		{
			return false;
		}
		return ExplicitLocal.Label == "Explicit";
	}

	/**
	 * Observe the copy constructor offset.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructDeclarationAndConstructionEdgeMatrix
	 * @Inputs a copy of Source(31, Source)
	 * @Return true when the copy is 131/Source_CopyCtor and Source stays 31
	 */
	UFUNCTION()
	bool ConstructedCopyCtor()
	{
		FConstructedStruct Source(31, "Source");
		FConstructedStruct Copy(Source);
		if (Copy.Value != 131)
		{
			return false;
		}
		if (Copy.Label != "Source_CopyCtor")
		{
			return false;
		}
		return Source.Value == 31;
	}

	/**
	 * Observe that assignment does not run the copy constructor.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructDeclarationAndConstructionEdgeMatrix
	 * @Inputs Assigned = Source(31, Source)
	 * @Return true when Assigned is 31/Source
	 */
	UFUNCTION()
	bool ConstructedAssignNoCopyCtor()
	{
		FConstructedStruct Source(31, "Source");
		FConstructedStruct AssignedLocal;
		AssignedLocal = Source;
		if (AssignedLocal.Value != 31)
		{
			return false;
		}
		return AssignedLocal.Label == "Source";
	}

	/**
	 * Observe the plain default-constructor sum.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructDeclarationAndConstructionEdgeMatrix
	 * @Inputs a default-constructed FPlainConstructionStruct
	 * @Return 11
	 */
	UFUNCTION()
	int PlainDefaultSumValue()
	{
		FPlainConstructionStruct PlainDefault;
		return PlainDefault.X + PlainDefault.Y;
	}

	/**
	 * Observe the plain explicit-constructor sum.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructDeclarationAndConstructionEdgeMatrix
	 * @Inputs FPlainConstructionStruct(9, 10)
	 * @Return 19
	 */
	UFUNCTION()
	int PlainExplicitSumValue()
	{
		FPlainConstructionStruct PlainExplicit(9, 10);
		return PlainExplicit.X + PlainExplicit.Y;
	}
}
