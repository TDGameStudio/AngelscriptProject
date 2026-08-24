// Theme: Definitions.Meta. Positive: metadata strings may contain ')' without truncating the specifier list.
// C++: AngelscriptCompilerMetadataSpecifierTests.cpp::MacroMetadataStringsWithClosingParen
// Oracle: GetClosingParenText returns 7. Extra: enum Alpha is 0; Beta is the next value.
// DefaultSafe.

UCLASS(meta=(DisplayName="Do (Test)", ToolTip="Class accepts ) text"))
class UCompilerMetadataParenCarrier : UObject
{
	UFUNCTION(meta=(DisplayName="Run ) Now", ToolTip="Accepts ) in text"))
	int GetClosingParenText()
	{
		return 7;
	}
}

UENUM(meta=(ToolTip="Enum ) ToolTip"))
enum class ECompilerMetadataParenState : uint8
{
	Alpha UMETA(DisplayName="Alpha ) Value", ToolTip="Alpha ) ToolTip"),
	Beta
}

int Observe_ClosingParenText_Nominal()
{
	UCompilerMetadataParenCarrier Carrier = Cast<UCompilerMetadataParenCarrier>(NewObject(GetTransientPackage(), UCompilerMetadataParenCarrier::StaticClass()));
	if (Carrier == nullptr)
	{
		throw("TS-DEF-0005 setup: NewObject failed");
	}
	return Carrier.GetClosingParenText();
}

int Observe_ClosingParenState_AlphaDefault()
{
	return int(ECompilerMetadataParenState::Alpha);
}

int Observe_ClosingParenState_BetaBoundary()
{
	return int(ECompilerMetadataParenState::Beta);
}
