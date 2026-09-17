/**
 * @version v1
 * @summary Function-shape matrix for local/value/in/out/inout/return/array/map USTRUCT usage. C++ reads LocalResult through MapResult after BeginPlay. Keep those UPROPERTY names.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Function-shape matrix for local/value/in/out/inout/return/array/map USTRUCT usage. C++ reads LocalResult through MapResult after BeginPlay. Keep those UPROPERTY names.
 * @topic Baseline
 */
USTRUCT(BlueprintType)
struct FShapeStruct
{
	UPROPERTY()
	int Value = 0;

	UPROPERTY()
	FString Label;
}

UCLASS()
class ACoverageStructFunctionShapeActor : AActor
{
	UPROPERTY()
	FShapeStruct LocalResult;

	UPROPERTY()
	FShapeStruct ValueResult;

	UPROPERTY()
	FShapeStruct InResult;

	UPROPERTY()
	FShapeStruct OutResult;

	UPROPERTY()
	FShapeStruct InoutResult;

	UPROPERTY()
	FShapeStruct ReturnResult;

	UPROPERTY()
	TArray<FShapeStruct> ArrayResult;

	UPROPERTY()
	TMap<int, FShapeStruct> MapResult;

	/**
	 * Build a shape struct from a value and label.
	 *
	 * @Covers UStruct.UStructFunctionShapeMatrix
	 * @Inputs Value and Label
	 * @Return an FShapeStruct holding those fields
	 * @Param Value the value
	 * @Param Label the label
	 */
	FShapeStruct MakeStruct(int Value, FString Label)
	{
		FShapeStruct Result;
		Result.Value = Value;
		Result.Label = Label;
		return Result;
	}

	/**
	 * By-value UStruct params are immutable in this fork; mutate a local copy.
	 *
	 * @Covers UStruct.UStructFunctionShapeMatrix
	 * @Inputs a by-value FShapeStruct
	 * @Return a copy with Value+10 and Label suffixed _Value
	 * @Param Param the value copy
	 */
	FShapeStruct AcceptValue(FShapeStruct Param)
	{
		FShapeStruct Result = Param;
		Result.Value += 10;
		Result.Label += "_Value";
		return Result;
	}

	/**
	 * Build a result from a const-in struct.
	 *
	 * @Covers UStruct.UStructFunctionShapeMatrix
	 * @Inputs a const &in FShapeStruct
	 * @Return Value+20 and Label suffixed _In
	 * @Param Param the const-in struct
	 */
	FShapeStruct AcceptConstRef(const FShapeStruct&in Param)
	{
		FShapeStruct Result;
		Result.Value = Param.Value + 20;
		Result.Label = Param.Label + "_In";
		return Result;
	}

	/**
	 * Fill an out struct with Value 30 and Label Out.
	 *
	 * @Covers UStruct.UStructFunctionShapeMatrix
	 * @Inputs an &out FShapeStruct
	 * @Return Param set to 30/Out
	 * @Param Param the out struct
	 */
	void FillOut(FShapeStruct&out Param)
	{
		Param.Value = 30;
		Param.Label = "Out";
	}

	/**
	 * Mutate an inout struct by adding 40 and suffixing _Inout.
	 *
	 * @Covers UStruct.UStructFunctionShapeMatrix
	 * @Inputs an &inout FShapeStruct
	 * @Return Param.Value after the add
	 * @Param Param the inout struct
	 */
	int MutateInout(FShapeStruct&inout Param)
	{
		Param.Value += 40;
		Param.Label += "_Inout";
		return Param.Value;
	}

	/**
	 * Return an array of two shape structs.
	 *
	 * @Covers UStruct.UStructFunctionShapeMatrix
	 * @Inputs First by value and Second const-in
	 * @Return a TArray with First then Second
	 * @Param First the first item
	 * @Param Second the second item
	 */
	TArray<FShapeStruct> MakeArray(FShapeStruct First, const FShapeStruct&in Second)
	{
		TArray<FShapeStruct> Result;
		Result.Add(First);
		Result.Add(Second);
		return Result;
	}

	/**
	 * Return a map of two shape structs at keys 1 and 2.
	 *
	 * @Covers UStruct.UStructFunctionShapeMatrix
	 * @Inputs two const-in FShapeStruct values
	 * @Return a TMap with keys 1 and 2
	 * @Param First the first value
	 * @Param Second the second value
	 */
	TMap<int, FShapeStruct> MakeMap(const FShapeStruct&in First, const FShapeStruct&in Second)
	{
		TMap<int, FShapeStruct> Result;
		Result.Add(1, First);
		Result.Add(2, Second);
		return Result;
	}

	/**
	 * WorldStory: BeginPlay exercises local/value/in/out/inout/return/array/map shapes.
	 *
	 * @Kind WorldStory
	 * @Covers UStruct.UStructFunctionShapeMatrix
	 * @Inputs none
	 * @Return Local 1/Local, Value 11/Local_Value, In 21/Local_In, Out 30/Out, Inout 41/Local_Inout
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FShapeStruct Local;
		Local.Value = 1;
		Local.Label = "Local";
		LocalResult = Local;

		ValueResult = AcceptValue(Local);
		InResult = AcceptConstRef(Local);
		FillOut(OutResult);

		InoutResult = Local;
		MutateInout(InoutResult);

		ReturnResult = MakeStruct(50, "Return");
		ArrayResult = MakeArray(ValueResult, InResult);
		MapResult = MakeMap(OutResult, InoutResult);
	}

	/**
	 * Observe empty function-shape results before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructFunctionShapeMatrix
	 * @Inputs an actor that has not begun play
	 * @Return true when LocalResult.Value is 0 and ArrayResult/MapResult are empty
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool FunctionShapeDefaultEmpty()
	{
		if (LocalResult.Value != 0)
		{
			return false;
		}
		if (ArrayResult.Num() != 0)
		{
			return false;
		}
		return MapResult.Num() == 0;
	}

	/**
	 * Observe function-shape results after BeginPlay.
	 *
	 * @Kind WorldStory
	 * @Covers UStruct.UStructFunctionShapeMatrix
	 * @Inputs BeginPlay on this actor
	 * @Return true when local/value/in/out/inout/return/array/map oracles match
	 */
	UFUNCTION()
	bool FunctionShapeNominalBeginPlay()
	{
		BeginPlay();
		FShapeStruct MapOut;
		FShapeStruct MapInout;
		if (LocalResult.Value != 1)
		{
			return false;
		}
		if (LocalResult.Label != "Local")
		{
			return false;
		}
		if (ValueResult.Value != 11)
		{
			return false;
		}
		if (ValueResult.Label != "Local_Value")
		{
			return false;
		}
		if (InResult.Value != 21)
		{
			return false;
		}
		if (InResult.Label != "Local_In")
		{
			return false;
		}
		if (OutResult.Value != 30)
		{
			return false;
		}
		if (OutResult.Label != "Out")
		{
			return false;
		}
		if (InoutResult.Value != 41)
		{
			return false;
		}
		if (InoutResult.Label != "Local_Inout")
		{
			return false;
		}
		if (ReturnResult.Value != 50)
		{
			return false;
		}
		if (ReturnResult.Label != "Return")
		{
			return false;
		}
		if (ArrayResult.Num() != 2)
		{
			return false;
		}
		if (ArrayResult[0].Value != 11)
		{
			return false;
		}
		if (ArrayResult[1].Value != 21)
		{
			return false;
		}
		if (MapResult.Num() != 2)
		{
			return false;
		}
		if (!MapResult.Find(1, MapOut))
		{
			return false;
		}
		if (MapOut.Value != 30)
		{
			return false;
		}
		if (!MapResult.Find(2, MapInout))
		{
			return false;
		}
		return MapInout.Value == 41;
	}

	/**
	 * Observe MakeArray of two default structs.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructFunctionShapeMatrix
	 * @Inputs two default FShapeStruct values
	 * @Return 2
	 * @Boundary empty make-array
	 */
	UFUNCTION()
	int FunctionShapeEmptyMakeArray()
	{
		FShapeStruct First;
		FShapeStruct Second;
		TArray<FShapeStruct> Items = MakeArray(First, Second);
		return Items.Num();
	}
}
/** @end */
