/**
 * @version v1
 * @summary &out and const &in parameter matrix. ProcessWithOutParam(7,5) returns 37 with Adjusted 35 and LastResult 37. SplitWithRefs(41) writes 20 and 21. TransformString("Input") writes "Input:processed" to LastOutput.
 * @topic Definitions
 */
/**
 * @version root
 * @summary &out and const &in parameter matrix. ProcessWithOutParam(7,5) returns 37 with Adjusted 35 and LastResult 37. SplitWithRefs(41) writes 20 and 21. TransformString("Input") writes "Input:processed" to LastOutput.
 * @topic Baseline
 */
UCLASS()
class ACoverageUFunctionParamRefActor : AActor
{
	UPROPERTY()
	int LastResult = 0;

	UPROPERTY()
	FString LastOutput;

	/**
	 * Multiply Input by Scale into Adjusted and return Adjusted + 2.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param Input Left operand
	 * @Param Scale Right operand
	 * @Param Adjusted Destination received as int&out
	 * @Inputs Input, Scale, and Adjusted
	 * @Return Adjusted + 2 after writing LastResult
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|ParamRef")
	int ProcessWithOutParam(int Input, int Scale, int&out Adjusted)
	{
		Adjusted = Input * Scale;
		LastResult = Adjusted + 2;
		return LastResult;
	}

	/**
	 * Split Source into Left and Right by truncated integer division.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param Source Value to split
	 * @Param Left Destination received as int&out
	 * @Param Right Destination received as int&out
	 * @Inputs Source plus two out slots
	 * @Return void
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|ParamRef")
	void SplitWithRefs(int Source, int&out Left, int&out Right)
	{
		Left = Math::IntegerDivisionTrunc(Source, 2);
		Right = Source - Left;
	}

	/**
	 * Append ":processed" onto Input and write both Output and LastOutput.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param Input Source received as const FString&in
	 * @Param Output Destination received as FString&out
	 * @Inputs Input and Output
	 * @Return void
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|ParamRef")
	void TransformString(const FString&in Input, FString&out Output)
	{
		Output = Input + ":processed";
		LastOutput = Output;
	}

	/**
	 * Observe the live out-parameter matrix.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs ProcessWithOutParam(7,5), SplitWithRefs(41), TransformString("Input")
	 * @Return true when Adjusted, LastResult, split halves, and LastOutput match the oracle
	 */
	UFUNCTION()
	bool ParamRefLiveMatrix()
	{
		int Adjusted = 0;
		int Returned = ProcessWithOutParam(7, 5, Adjusted);
		int Left = 0;
		int Right = 0;
		SplitWithRefs(41, Left, Right);
		FString Output = "";
		TransformString("Input", Output);
		if (Returned != 37)
		{
			return false;
		}
		if (Adjusted != 35)
		{
			return false;
		}
		if (LastResult != 37)
		{
			return false;
		}
		if (Left != 20)
		{
			return false;
		}
		if (Right != 21)
		{
			return false;
		}
		if (Output != "Input:processed")
		{
			return false;
		}
		return LastOutput == "Input:processed";
	}

	/**
	 * Observe the zero and empty boundary of the out-parameter matrix.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs ProcessWithOutParam(0,0), SplitWithRefs(0), TransformString("")
	 * @Return true when Adjusted, halves, and LastOutput match the empty oracle
	 * @Boundary zero and empty string
	 */
	UFUNCTION()
	bool ParamRefZeroEmpty()
	{
		int Adjusted = -1;
		int Returned = ProcessWithOutParam(0, 0, Adjusted);
		int Left = -1;
		int Right = -1;
		SplitWithRefs(0, Left, Right);
		FString Output = "stale";
		TransformString("", Output);
		if (Returned != 2)
		{
			return false;
		}
		if (Adjusted != 0)
		{
			return false;
		}
		if (LastResult != 2)
		{
			return false;
		}
		if (Left != 0)
		{
			return false;
		}
		if (Right != 0)
		{
			return false;
		}
		if (Output != ":processed")
		{
			return false;
		}
		return LastOutput == ":processed";
	}

	/**
	 * Observe that a null handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs ACoverageUFunctionParamRefActor Actor = nullptr
	 * @Return true when the handle is null
	 * @Boundary null handle
	 */
	UFUNCTION()
	bool NullDefaultIsNull()
	{
		ACoverageUFunctionParamRefActor Actor = nullptr;
		return Actor == nullptr;
	}
}
/** @end */
