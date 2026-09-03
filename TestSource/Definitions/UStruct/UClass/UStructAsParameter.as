/**
 * Value, const &in, &out, and &inout USTRUCT parameters. C++ reads the four
 * result fields after BeginPlay. Keep the UPROPERTY names ValueParam, InParam,
 * OutParam, and InoutParam.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.UStructAsParameter
 * @Harness UClass
 * @Tag Definitions.UStruct.UStructAsParameter
 * @Provenance Theme: Definitions.UStruct. WorldStory: value / &in / &out / &inout struct parameters.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructAsParameter spawn + BeginPlay.
 * @Provenance Oracle: ValueParam 100/Original, InParam 200/Source, OutParam 777/Modified, InoutParam 633/Mutable_Inout.
 * @Provenance Extra: empty Name and Value 0 before BeginPlay. FixtureIsolated.
 */

USTRUCT()
struct FParamStruct
{
	UPROPERTY()
	int Value = 0;

	UPROPERTY()
	FString Name;
}

UCLASS()
class ACoverageStructParamActor : AActor
{
	UPROPERTY()
	FParamStruct ValueParam;

	UPROPERTY()
	FParamStruct InParam;

	UPROPERTY()
	FParamStruct OutParam;

	UPROPERTY()
	FParamStruct InoutParam;

	/**
	 * By-value UStruct params are immutable in this fork; mutating a local copy
	 * still demonstrates that the caller's struct is unaffected.
	 *
	 * @Covers UStruct.UStructAsParameter
	 * @Inputs a by-value FParamStruct
	 * @Return none; the caller is unchanged
	 * @Param Param the value copy
	 */
	void ModifyByValue(FParamStruct Param)
	{
		FParamStruct Local = Param;
		Local.Value = 999;
	}

	/**
	 * Read a const-ref struct into InParam.
	 *
	 * @Covers UStruct.UStructAsParameter
	 * @Inputs a const &in FParamStruct
	 * @Return InParam copied from Param
	 * @Param Param the source struct
	 */
	void ReadByConstRef(const FParamStruct&in Param)
	{
		InParam.Value = Param.Value;
		InParam.Name = Param.Name;
	}

	/**
	 * Write a struct through an &out parameter.
	 *
	 * @Covers UStruct.UStructAsParameter
	 * @Inputs an &out FParamStruct
	 * @Return Param.Value 777 and Name Modified
	 * @Param Param the out struct
	 */
	void WriteByRef(FParamStruct&out Param)
	{
		Param.Value = 777;
		Param.Name = "Modified";
	}

	/**
	 * Mutate a struct through an &inout parameter.
	 *
	 * @Covers UStruct.UStructAsParameter
	 * @Inputs an &inout FParamStruct
	 * @Return Param.Value increased by 333 and Name suffixed with _Inout
	 * @Param Param the inout struct
	 */
	void MutateInout(FParamStruct&inout Param)
	{
		Param.Value += 333;
		Param.Name += "_Inout";
	}

	/**
	 * WorldStory: BeginPlay exercises value, in, out, and inout struct parameters.
	 *
	 * @Kind WorldStory
	 * @Covers UStruct.UStructAsParameter
	 * @Inputs none
	 * @Return ValueParam 100/Original, InParam 200/Source, OutParam 777/Modified, InoutParam 633/Mutable_Inout
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ValueParam.Value = 100;
		ValueParam.Name = "Original";
		ModifyByValue(ValueParam);

		FParamStruct Source;
		Source.Value = 200;
		Source.Name = "Source";
		ReadByConstRef(Source);

		WriteByRef(OutParam);

		InoutParam.Value = 300;
		InoutParam.Name = "Mutable";
		MutateInout(InoutParam);
	}

	/**
	 * Observe empty parameter structs before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructAsParameter
	 * @Inputs an actor that has not begun play
	 * @Return true when Value/Out/Inout are 0 and Name is empty
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool ParamDefaultEmpty()
	{
		if (ValueParam.Value != 0)
		{
			return false;
		}
		if (ValueParam.Name.Len() != 0)
		{
			return false;
		}
		if (OutParam.Value != 0)
		{
			return false;
		}
		return InoutParam.Value == 0;
	}

	/**
	 * Observe value/in/out/inout results after BeginPlay.
	 *
	 * @Kind WorldStory
	 * @Covers UStruct.UStructAsParameter
	 * @Inputs BeginPlay on this actor
	 * @Return true when the four parameter oracles match
	 */
	UFUNCTION()
	bool ParamNominalBeginPlay()
	{
		BeginPlay();
		if (ValueParam.Value != 100)
		{
			return false;
		}
		if (ValueParam.Name != "Original")
		{
			return false;
		}
		if (InParam.Value != 200)
		{
			return false;
		}
		if (InParam.Name != "Source")
		{
			return false;
		}
		if (OutParam.Value != 777)
		{
			return false;
		}
		if (OutParam.Name != "Modified")
		{
			return false;
		}
		if (InoutParam.Value != 633)
		{
			return false;
		}
		return InoutParam.Name == "Mutable_Inout";
	}

	/**
	 * Observe that ModifyByValue does not rewrite the caller.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructAsParameter
	 * @Inputs ModifyByValue of a zeroed source
	 * @Return true when the source stays 0 and empty
	 * @Boundary by-value copy independence
	 */
	UFUNCTION()
	bool ParamValueCopyIndependence()
	{
		FParamStruct Source;
		Source.Value = 0;
		Source.Name = "";
		ModifyByValue(Source);
		if (Source.Value != 0)
		{
			return false;
		}
		return Source.Name.Len() == 0;
	}
}
