/**
 * A UENUM enum class declared with an explicit underlying type. The enumerators
 * mix an implicit zero start, an explicit value, and a sequential value after the
 * explicit one.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.EnumAvailability
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.EnumAvailability
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCompilerEndToEndTests.cpp::EnumAvailability
 * @Provenance sha256=9372f9ada7a50b92bec361b6f2a13c4cc6f6c9490c139e10a68c75aa45ba8726; lines 296-304.
 * @Provenance Oracle: three declared values; Beta has explicit value 4. Extra: Alpha is
 * @Provenance the 0 default; Gamma is the sequential boundary after 4. DefaultSafe.
 */

UENUM(BlueprintType)
enum class ECompilerAvailabilityState : uint16
{
	Alpha,
	Beta = 4,
	Gamma
}

namespace SyntaxTest
{
	/**
	 * Observe that the explicitly assigned value holds.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs ECompilerAvailabilityState::Beta
	 * @Return true when the value is 4
	 */
	UFUNCTION()
	bool AvailabilityBetaIsExplicitlyFour()
	{
		return int(ECompilerAvailabilityState::Beta) == 4;
	}

	/**
	 * Observe that the first enumerator defaults to zero.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs ECompilerAvailabilityState::Alpha
	 * @Return true when the value is 0
	 * @Boundary default first value
	 */
	UFUNCTION()
	bool AvailabilityAlphaDefaultsToZero()
	{
		return int(ECompilerAvailabilityState::Alpha) == 0;
	}

	/**
	 * Observe that the enumerator after the explicit value is sequential.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs ECompilerAvailabilityState::Gamma
	 * @Return true when the value is 5
	 * @Boundary sequential after explicit
	 */
	UFUNCTION()
	bool AvailabilityGammaIsSequentialAfterFour()
	{
		return int(ECompilerAvailabilityState::Gamma) == 5;
	}
}
