// Theme: Definitions.UFunction. Positive: static UFUNCTION metadata plus helper namespace.
// C++: AngelscriptCoverageUFunctionTests.cpp::StaticGlobalAdvancedMetadataAndNamespaceMatrix
// Oracle: StaticMetadataAction(20)==42, StaticPureAlias(30,9)==42, StaticOutAction(16) writes 42.
// Extra: Scale(0)==0, Mix(0,0)==3, StaticPureAlias default Bias Mix(0,1)==4, StaticOutAction(0) writes 10.
// DefaultSafe.

namespace CoverageUFunctionStaticHelpers
{
	int Scale(int Value)
	{
		return Value * 2;
	}

	int Mix(int A, int B)
	{
		return A + B + 3;
	}
}

UFUNCTION(BlueprintCallable, Category="Coverage|StaticMeta", meta=(DisplayName="Static Meta Action", Keywords="static meta coverage", ToolTip="Static meta tooltip", ShortToolTip="Static short tooltip", CompactNodeTitle="SMA", DeprecatedFunction, DeprecationMessage="Use StaticMetaReplacement", DevelopmentOnly, BlueprintInternalUseOnly, CustomCoverageKey="StaticCustom"))
int StaticMetadataAction(int Value)
{
	return CoverageUFunctionStaticHelpers::Scale(Value) + 2;
}

UFUNCTION(BlueprintPure, Category="Coverage|StaticMeta", meta=(ScriptName="StaticAliasName", ReturnDisplayName="Coverage Return", AdvancedDisplay="Bias"))
int StaticPureAlias(int Value, int Bias = 1)
{
	return CoverageUFunctionStaticHelpers::Mix(Value, Bias);
}

UFUNCTION(BlueprintCallable, Category="Coverage|StaticMeta")
void StaticOutAction(int Input, int&out Output)
{
	Output = CoverageUFunctionStaticHelpers::Scale(Input) + 10;
}

int Observe_StaticMeta_ActionNominal()
{
	return StaticMetadataAction(20);
}

int Observe_StaticMeta_PureExplicitBias()
{
	return StaticPureAlias(30, 9);
}

int Observe_StaticMeta_OutNominal()
{
	int Output = 0;
	StaticOutAction(16, Output);
	return Output;
}

int Observe_StaticMeta_ScaleZero()
{
	return CoverageUFunctionStaticHelpers::Scale(0);
}

int Observe_StaticMeta_MixZeros()
{
	return CoverageUFunctionStaticHelpers::Mix(0, 0);
}

int Observe_StaticMeta_PureDefaultBiasZeroValue()
{
	return StaticPureAlias(0);
}

int Observe_StaticMeta_OutZeroBoundary()
{
	int Output = -1;
	StaticOutAction(0, Output);
	return Output;
}
