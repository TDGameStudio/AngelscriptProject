/**
 * A namespaced USTRUCT used as a property, parameter, and return. C++ reads
 * Data and LastAccepted after BeginPlay. Keep CoverageStructNS::FNamespacedStruct.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.UStructNamespacedDeclarationAndReflection
 * @Harness UClass
 * @Tag Definitions.UStruct.UStructNamespacedDeclarationAndReflection
 * @Provenance Theme: Definitions.UStruct. WorldStory: namespaced USTRUCT property, param, and return.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructNamespacedDeclarationAndReflection
 * @Provenance lines 3088-3133;
 * @Provenance sha256=6c89fa47ced01424b9d116ae54cfeb5f96b58dc60587b7c928ce06a0169835e5.
 * @Provenance Oracle after BeginPlay: Data.Count=31 Data.Label=Namespaced,
 * @Provenance LastAccepted.Count=31 LastAccepted.Label=Namespaced.
 * @Provenance Extra: default Count=0 and empty Label; copy-independence after mutating the copy.
 * @Provenance FixtureIsolated.
 */

namespace CoverageStructNS
{
	USTRUCT(BlueprintType)
	struct FNamespacedStruct
	{
		UPROPERTY()
		int Count = 0;

		UPROPERTY()
		FString Label;
	}
}

UCLASS()
class ACoverageStructNamespacedActor : AActor
{
	UPROPERTY()
	CoverageStructNS::FNamespacedStruct Data;

	UPROPERTY()
	CoverageStructNS::FNamespacedStruct LastAccepted;

	/**
	 * Accept a namespaced struct into LastAccepted.
	 *
	 * @Covers UStruct.UStructNamespacedDeclarationAndReflection
	 * @Inputs a FNamespacedStruct payload
	 * @Return LastAccepted copied from Payload
	 * @Param Payload the accepted struct
	 */
	UFUNCTION(BlueprintCallable)
	void Accept(CoverageStructNS::FNamespacedStruct Payload)
	{
		LastAccepted = Payload;
	}

	/**
	 * Build a namespaced payload from a count and label.
	 *
	 * @Covers UStruct.UStructNamespacedDeclarationAndReflection
	 * @Inputs InCount and InLabel
	 * @Return a FNamespacedStruct holding those fields
	 * @Param InCount the count
	 * @Param InLabel the label
	 */
	UFUNCTION(BlueprintCallable)
	CoverageStructNS::FNamespacedStruct MakePayload(int InCount, const FString&in InLabel)
	{
		CoverageStructNS::FNamespacedStruct Result;
		Result.Count = InCount;
		Result.Label = InLabel;
		return Result;
	}

	/**
	 * WorldStory: BeginPlay stores MakePayload(31, Namespaced) and Accepts it.
	 *
	 * @Kind WorldStory
	 * @Covers UStruct.UStructNamespacedDeclarationAndReflection
	 * @Inputs none
	 * @Return Data and LastAccepted hold 31/Namespaced
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Data = MakePayload(31, "Namespaced");
		Accept(Data);
	}

	/**
	 * Observe namespaced struct defaults.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructNamespacedDeclarationAndReflection
	 * @Inputs a default-constructed FNamespacedStruct
	 * @Return true when Count is 0 and Label is empty
	 * @Boundary default empty
	 */
	UFUNCTION()
	bool NamespacedDefaultEmpty()
	{
		CoverageStructNS::FNamespacedStruct LocalData;
		if (LocalData.Count != 0)
		{
			return false;
		}
		return LocalData.Label.IsEmpty();
	}

	/**
	 * Observe a locally filled namespaced payload.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructNamespacedDeclarationAndReflection
	 * @Inputs Count 31 and Label Namespaced
	 * @Return true when those fields match
	 */
	UFUNCTION()
	bool NamespacedMakePayload()
	{
		CoverageStructNS::FNamespacedStruct LocalData;
		LocalData.Count = 31;
		LocalData.Label = "Namespaced";
		if (LocalData.Count != 31)
		{
			return false;
		}
		return LocalData.Label == "Namespaced";
	}

	/**
	 * Observe that copying the namespaced struct does not alias it.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructNamespacedDeclarationAndReflection
	 * @Inputs a copy whose Count and Label were cleared
	 * @Return true when the original keeps 31/Namespaced and the copy is empty
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool NamespacedCopyIndependence()
	{
		CoverageStructNS::FNamespacedStruct Original;
		Original.Count = 31;
		Original.Label = "Namespaced";
		CoverageStructNS::FNamespacedStruct Copy = Original;
		Copy.Count = 0;
		Copy.Label = "";
		if (Original.Count != 31)
		{
			return false;
		}
		if (Original.Label != "Namespaced")
		{
			return false;
		}
		if (Copy.Count != 0)
		{
			return false;
		}
		return Copy.Label.IsEmpty();
	}
}
