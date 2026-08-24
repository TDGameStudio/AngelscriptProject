// Theme: Language.Syntax.EdgeCases. Positive UENUM class availability.
// C++: AngelscriptCompilerEndToEndTests.cpp::EnumAvailability
// sha256=9372f9ada7a50b92bec361b6f2a13c4cc6f6c9490c139e10a68c75aa45ba8726; lines 296-304.
// Oracle: three declared values; Beta has explicit value 4. Extra: Alpha is
// the 0 default; Gamma is the sequential boundary after 4. DefaultSafe.

UENUM(BlueprintType)
enum class ECompilerAvailabilityState : uint16
{
	Alpha,
	Beta = 4,
	Gamma
}

bool Observe_EnumAvailability_Nominal()
{
	return int(ECompilerAvailabilityState::Beta) == 4;
}

bool Observe_EnumAvailability_AlphaDefaultEmpty()
{
	return int(ECompilerAvailabilityState::Alpha) == 0;
}

bool Observe_EnumAvailability_GammaBoundary()
{
	return int(ECompilerAvailabilityState::Gamma) == 5;
}
