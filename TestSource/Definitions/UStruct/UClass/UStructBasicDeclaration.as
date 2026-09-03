/**
 * A USTRUCT, a plain script struct, and a nested USTRUCT on an actor. C++
 * reads SimpleData and NestedData by path after BeginPlay.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.UStructBasicDeclaration
 * @Harness UClass
 * @Tag Definitions.UStruct.UStructBasicDeclaration
 * @Provenance Theme: Definitions.UStruct. WorldStory: USTRUCT, plain struct, nested USTRUCT.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructBasicDeclaration
 * @Provenance lines 1710-1758;
 * @Provenance sha256=925768351410941224246d4a6d956dd5c2e159e3c0c33ee124cbb7909f18763b.
 * @Provenance Oracle after BeginPlay: SimpleData.Value=99, NestedData.OuterValue=200,
 * @Provenance NestedData.InnerStruct.Value=300.
 * @Provenance Extra: FSimpleStruct default 42; FPlainStruct empty defaults 10/20; copy-independence.
 * @Provenance FixtureIsolated.
 */

USTRUCT()
struct FSimpleStruct
{
	UPROPERTY()
	int Value = 42;
}

struct FPlainStruct
{
	int X = 10;
	int Y = 20;
}

USTRUCT()
struct FNestedOuter
{
	UPROPERTY()
	int OuterValue = 100;

	UPROPERTY()
	FSimpleStruct InnerStruct;
}

UCLASS()
class ACoverageStructBasicActor : AActor
{
	UPROPERTY()
	FSimpleStruct SimpleData;

	UPROPERTY()
	FNestedOuter NestedData;

	FPlainStruct PlainData;

	/**
	 * WorldStory: BeginPlay writes the reflected nested values C++ reads by path.
	 *
	 * @Kind WorldStory
	 * @Covers UStruct.UStructBasicDeclaration
	 * @Inputs none
	 * @Return SimpleData.Value 99, NestedData.OuterValue 200, NestedData.InnerStruct.Value 300
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		SimpleData.Value = 99;
		NestedData.OuterValue = 200;
		NestedData.InnerStruct.Value = 300;
		PlainData.X = 50;
		PlainData.Y = 75;
	}

	/**
	 * Observe the FSimpleStruct default.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructBasicDeclaration
	 * @Inputs a default-constructed FSimpleStruct
	 * @Return true when Value is 42
	 * @Boundary default value
	 */
	UFUNCTION()
	bool SimpleDefaultEmpty()
	{
		FSimpleStruct LocalSimple;
		return LocalSimple.Value == 42;
	}

	/**
	 * Observe the plain script struct defaults.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructBasicDeclaration
	 * @Inputs a default-constructed FPlainStruct
	 * @Return true when X is 10 and Y is 20
	 * @Boundary default values
	 */
	UFUNCTION()
	bool PlainDefaultEmpty()
	{
		FPlainStruct LocalPlain;
		if (LocalPlain.X != 10)
		{
			return false;
		}
		return LocalPlain.Y == 20;
	}

	/**
	 * Observe nested defaults including the inner USTRUCT default.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructBasicDeclaration
	 * @Inputs a default-constructed FNestedOuter
	 * @Return true when OuterValue is 100 and InnerStruct.Value is 42
	 * @Boundary nested default
	 */
	UFUNCTION()
	bool NestedDefaultInner()
	{
		FNestedOuter LocalNested;
		if (LocalNested.OuterValue != 100)
		{
			return false;
		}
		return LocalNested.InnerStruct.Value == 42;
	}

	/**
	 * Observe that copying FSimpleStruct does not alias it.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructBasicDeclaration
	 * @Inputs a copy whose Value was set to 0
	 * @Return true when the original stays 42 and the copy is 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool SimpleCopyIndependence()
	{
		FSimpleStruct Original;
		FSimpleStruct Copy = Original;
		Copy.Value = 0;
		if (Original.Value != 42)
		{
			return false;
		}
		return Copy.Value == 0;
	}
}
