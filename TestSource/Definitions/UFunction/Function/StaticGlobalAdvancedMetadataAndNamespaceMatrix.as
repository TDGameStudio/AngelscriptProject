/**
 * Static UFUNCTION metadata plus a helper namespace. StaticMetadataAction(20)
 * is 42, StaticPureAlias(30, 9) is 42, and StaticOutAction(16) writes 42.
 * Scale(0) is 0, Mix(0, 0) is 3, StaticPureAlias default Bias Mix(0, 1) is 4,
 * and StaticOutAction(0) writes 10.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.StaticGlobalAdvancedMetadataAndNamespaceMatrix
 * @Harness Function
 * @Tag Definitions.UFunction.StaticGlobalAdvancedMetadataAndNamespaceMatrix
 * @Namespace UFunctionTest
 * @Provenance Theme: Definitions.UFunction. Positive: static UFUNCTION metadata plus helper namespace.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::StaticGlobalAdvancedMetadataAndNamespaceMatrix
 * @Provenance Oracle: StaticMetadataAction(20)==42, StaticPureAlias(30,9)==42, StaticOutAction(16) writes 42.
 * @Provenance Extra: Scale(0)==0, Mix(0,0)==3, StaticPureAlias default Bias Mix(0,1)==4, StaticOutAction(0) writes 10.
 * @Provenance DefaultSafe.
 */

namespace CoverageUFunctionStaticHelpers
{
	/**
	 * Doubles the incoming value.
	 *
	 * @Covers UFunction.Specifier
	 * @Param Value Value to scale
	 * @Inputs Value
	 * @Return Value * 2
	 */
	int Scale(int Value)
	{
		return Value * 2;
	}

	/**
	 * Mixes two values with a constant offset of 3.
	 *
	 * @Covers UFunction.Specifier
	 * @Param A First addend
	 * @Param B Second addend
	 * @Inputs A and B
	 * @Return A + B + 3
	 */
	int Mix(int A, int B)
	{
		return A + B + 3;
	}
}

/**
 * Static metadata-rich UFUNCTION that scales Value and adds 2.
 *
 * @Kind Observe
 * @Covers UFunction.Specifier
 * @Param Value Value scaled then offset
 * @Inputs Value
 * @Return Scale(Value) + 2
 */
UFUNCTION(BlueprintCallable, Category="Coverage|StaticMeta", meta=(DisplayName="Static Meta Action", Keywords="static meta coverage", ToolTip="Static meta tooltip", ShortToolTip="Static short tooltip", CompactNodeTitle="SMA", DeprecatedFunction, DeprecationMessage="Use StaticMetaReplacement", DevelopmentOnly, BlueprintInternalUseOnly, CustomCoverageKey="StaticCustom"))
int StaticMetadataAction(int Value)
{
	return CoverageUFunctionStaticHelpers::Scale(Value) + 2;
}

/**
 * Static BlueprintPure UFUNCTION with a default Bias of 1.
 *
 * @Kind Observe
 * @Covers UFunction.Specifier
 * @Param Value First mix operand
 * @Param Bias Second mix operand, default 1
 * @Inputs Value and Bias
 * @Return Mix(Value, Bias)
 */
UFUNCTION(BlueprintPure, Category="Coverage|StaticMeta", meta=(ScriptName="StaticAliasName", ReturnDisplayName="Coverage Return", AdvancedDisplay="Bias"))
int StaticPureAlias(int Value, int Bias = 1)
{
	return CoverageUFunctionStaticHelpers::Mix(Value, Bias);
}

/**
 * Static UFUNCTION that writes Scale(Input) + 10 to an out parameter.
 *
 * @Kind Observe
 * @Covers UFunction.Parameter
 * @Param Input Value scaled then offset
 * @Param Output Destination received as int&out
 * @Inputs Input plus an empty out slot
 * @Return void; Output is Scale(Input) + 10
 */
UFUNCTION(BlueprintCallable, Category="Coverage|StaticMeta")
void StaticOutAction(int Input, int&out Output)
{
	Output = CoverageUFunctionStaticHelpers::Scale(Input) + 10;
}

namespace UFunctionTest
{
	/**
	 * Observe StaticMetadataAction(20).
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs StaticMetadataAction(20)
	 * @Return 42
	 */
	UFUNCTION()
	int MetadataActionTwenty()
	{
		return StaticMetadataAction(20);
	}

	/**
	 * Observe StaticPureAlias with an explicit Bias of 9.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs StaticPureAlias(30, 9)
	 * @Return 42
	 */
	UFUNCTION()
	int PureAliasExplicitBias()
	{
		return StaticPureAlias(30, 9);
	}

	/**
	 * Observe StaticOutAction writing 42 for Input 16.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs StaticOutAction(16, Output)
	 * @Return 42
	 */
	UFUNCTION()
	int OutActionSixteen()
	{
		int Output = 0;
		StaticOutAction(16, Output);
		return Output;
	}

	/**
	 * Observe Scale at the zero boundary.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs CoverageUFunctionStaticHelpers::Scale(0)
	 * @Return 0
	 * @Boundary zero
	 */
	UFUNCTION()
	int ScaleZero()
	{
		return CoverageUFunctionStaticHelpers::Scale(0);
	}

	/**
	 * Observe Mix of two zeros.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs CoverageUFunctionStaticHelpers::Mix(0, 0)
	 * @Return 3
	 * @Boundary zero operands
	 */
	UFUNCTION()
	int MixZeros()
	{
		return CoverageUFunctionStaticHelpers::Mix(0, 0);
	}

	/**
	 * Observe StaticPureAlias using the default Bias with Value 0.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs StaticPureAlias(0)
	 * @Return 4
	 * @Boundary default Bias
	 */
	UFUNCTION()
	int PureAliasDefaultBiasZeroValue()
	{
		return StaticPureAlias(0);
	}

	/**
	 * Observe StaticOutAction at the zero boundary.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs StaticOutAction(0, Output)
	 * @Return 10
	 * @Boundary zero input
	 */
	UFUNCTION()
	int OutActionZeroBoundary()
	{
		int Output = -1;
		StaticOutAction(0, Output);
		return Output;
	}
}
