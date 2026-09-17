/**
 * @version v1
 * @summary Const BlueprintPure override dispatch. C++ verifies ComputePureValue(4,4)==42 and DispatchPureValue(5,-3)==42 with StoredValue default 7. Default Bias and zero Scale are the extra boundaries.
 * @topic Feature
 */
/**
 * @version root
 * @summary Const BlueprintPure override dispatch. C++ verifies ComputePureValue(4,4)==42 and DispatchPureValue(5,-3)==42 with StoredValue default 7. Default Bias and zero Scale are the extra boundaries.
 * @topic Baseline
 */
UCLASS()
class ACoverageUFunctionPureOverrideBase : AActor
{
	UPROPERTY()
	int StoredValue = 7;

	/**
	 * Parent const BlueprintPure event: StoredValue * Scale + Bias.
	 *
	 * @Kind Action
	 * @Covers Inheritance.ConstBlueprintPureOverrideMatrix
	 * @Inputs Scale and optional Bias defaulting to 1
	 * @Return StoredValue * Scale + Bias
	 * @Param Scale the multiplier
	 * @Param Bias the addend, default 1
	 */
	UFUNCTION(BlueprintPure, BlueprintEvent, Category="Coverage|PureOverride", meta=(DisplayName="Compute Pure Value", CompactNodeTitle="PURE", AdvancedDisplay="Bias"))
	int ComputePureValue(int Scale, int Bias = 1) const
	{
		return StoredValue * Scale + Bias;
	}

	/**
	 * Dispatch through the virtual ComputePureValue so the child override is hit.
	 *
	 * @Kind Action
	 * @Covers Inheritance.ConstBlueprintPureOverrideMatrix
	 * @Inputs Scale and optional Bias defaulting to 1
	 * @Return ComputePureValue(Scale, Bias)
	 * @Param Scale the multiplier
	 * @Param Bias forwarded to ComputePureValue
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|PureOverride")
	int DispatchPureValue(int Scale, int Bias = 1) const
	{
		return ComputePureValue(Scale, Bias);
	}
}

UCLASS()
class ACoverageUFunctionPureOverrideChild : ACoverageUFunctionPureOverrideBase
{
	/**
	 * Child const BlueprintOverride that adds 10 to the parent formula.
	 *
	 * @Kind Action
	 * @Covers Inheritance.ConstBlueprintPureOverrideMatrix
	 * @Inputs Scale and optional Bias defaulting to 1
	 * @Return StoredValue * Scale + Bias + 10
	 * @Param Scale the multiplier
	 * @Param Bias the addend, default 1
	 */
	UFUNCTION(BlueprintOverride)
	int ComputePureValue(int Scale, int Bias = 1) const
	{
		return StoredValue * Scale + Bias + 10;
	}

	/**
	 * Observe ComputePureValue(4, 4) on the child.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.ConstBlueprintPureOverrideMatrix
	 * @Inputs ComputePureValue(4, 4)
	 * @Return 42
	 */
	UFUNCTION()
	int Direct()
	{
		return ComputePureValue(4, 4);
	}

	/**
	 * Observe DispatchPureValue(5, -3) on the child.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.ConstBlueprintPureOverrideMatrix
	 * @Inputs DispatchPureValue(5, -3)
	 * @Return 42
	 */
	UFUNCTION()
	int Dispatch()
	{
		return DispatchPureValue(5, -3);
	}

	/**
	 * Observe ComputePureValue(4) using the default Bias.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.ConstBlueprintPureOverrideMatrix
	 * @Inputs ComputePureValue(4)
	 * @Return StoredValue * 4 + 1 + 10
	 * @Boundary default Bias
	 */
	UFUNCTION()
	int DefaultBias()
	{
		return ComputePureValue(4);
	}

	/**
	 * Observe ComputePureValue(0, 0) at the zero Scale boundary.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.ConstBlueprintPureOverrideMatrix
	 * @Inputs ComputePureValue(0, 0)
	 * @Return 10
	 * @Boundary zero Scale
	 */
	UFUNCTION()
	int ZeroScaleBoundary()
	{
		return ComputePureValue(0, 0);
	}
}
/** @end */
