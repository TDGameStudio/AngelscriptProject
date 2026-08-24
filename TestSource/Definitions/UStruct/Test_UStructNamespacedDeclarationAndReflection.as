// Theme: Definitions.UStruct. WorldStory: namespaced USTRUCT property, param, and return.
// C++: AngelscriptCoverageUStructTests.cpp::UStructNamespacedDeclarationAndReflection
// lines 3088-3133;
// sha256=6c89fa47ced01424b9d116ae54cfeb5f96b58dc60587b7c928ce06a0169835e5.
// Oracle after BeginPlay: Data.Count=31 Data.Label=Namespaced,
// LastAccepted.Count=31 LastAccepted.Label=Namespaced.
// Extra: default Count=0 and empty Label; copy-independence after mutating the copy.
// FixtureIsolated.

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

	UFUNCTION(BlueprintCallable)
	void Accept(CoverageStructNS::FNamespacedStruct Payload)
	{
		LastAccepted = Payload;
	}

	UFUNCTION(BlueprintCallable)
	CoverageStructNS::FNamespacedStruct MakePayload(int InCount, const FString&in InLabel)
	{
		CoverageStructNS::FNamespacedStruct Result;
		Result.Count = InCount;
		Result.Label = InLabel;
		return Result;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Data = MakePayload(31, "Namespaced");
		Accept(Data);
	}
}

bool Observe_Namespaced_DefaultEmpty()
{
	CoverageStructNS::FNamespacedStruct Data;
	return Data.Count == 0 && Data.Label.IsEmpty();
}

bool Observe_Namespaced_MakePayload()
{
	CoverageStructNS::FNamespacedStruct Data;
	Data.Count = 31;
	Data.Label = "Namespaced";
	return Data.Count == 31 && Data.Label == "Namespaced";
}

bool Observe_Namespaced_CopyIndependence()
{
	CoverageStructNS::FNamespacedStruct Original;
	Original.Count = 31;
	Original.Label = "Namespaced";
	CoverageStructNS::FNamespacedStruct Copy = Original;
	Copy.Count = 0;
	Copy.Label = "";
	return Original.Count == 31 && Original.Label == "Namespaced"
		&& Copy.Count == 0 && Copy.Label.IsEmpty();
}
