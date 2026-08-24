// Theme: Language.Syntax.EdgeCases. Positive CDO enum default.
// C++: AngelscriptCompilerPropertyDefaultMatrixTests.cpp::DefaultEnumPropertyApplied
// sha256=dac23d3d5209f41412b138de14c41e1de22f4e752a541002d78883365b0f5d5d; lines 102-125.
// Oracle: GetDirectionValue returns 3 (ETestDirection::Right). Extra: Up is
// the 0 default; a second instance stays Right after the first is set to Up.
// DefaultSafe.

enum ETestDirection
{
	Up,
	Down,
	Left,
	Right
}

UCLASS()
class UDefaultEnumCarrier : UObject
{
	UPROPERTY()
	ETestDirection Direction;

	default Direction = ETestDirection::Right;

	UFUNCTION()
	int GetDirectionValue()
	{
		return int(Direction);
	}
}

bool Observe_DefaultEnum_Nominal(UDefaultEnumCarrier Carrier)
{
	if (Carrier is null)
	{
		throw("Test_DefaultEnumPropertyApplied setup: required Carrier is null");
	}
	return Carrier.GetDirectionValue() == 3;
}

bool Observe_DefaultEnum_UpDefaultEmpty()
{
	return int(ETestDirection::Up) == 0;
}

bool Observe_DefaultEnum_InstanceIndependence(UDefaultEnumCarrier First, UDefaultEnumCarrier Second)
{
	if (First is null)
	{
		throw("Test_DefaultEnumPropertyApplied setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_DefaultEnumPropertyApplied setup: required Second is null");
	}
	First.Direction = ETestDirection::Up;
	return First.GetDirectionValue() == 0 && Second.GetDirectionValue() == 3;
}
