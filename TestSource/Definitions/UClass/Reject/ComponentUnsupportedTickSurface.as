/**
 * Direct TickComponent override plus PrimaryComponentTick.bCanEverTick is
 * rejected. ELevelTick is not a script data type and bCanEverTick is not a
 * member of FActorComponentTickFunction.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.ComponentUnsupportedTickSurface
 * @Harness CompileReject
 * @Tag Definitions.UClass.ComponentUnsupportedTickSurface
 * @Kind CompileReject
 * @Covers UClass.BlueprintOverride
 * @Inputs default PrimaryComponentTick.bCanEverTick and TickComponent(float, ELevelTick, FActorComponentTickFunction&in)
 * @Return does not compile; diagnostic "Identifier 'ELevelTick' is not a data type" / "'bCanEverTick' is not a member of 'FActorComponentTickFunction'"
 * @Provenance Theme: Definitions.UClass. NegativeDiagnostic: TickComponent + PrimaryComponentTick.bCanEverTick.
 * @Provenance C++: AngelscriptCoverageClassLifecycleTests.cpp::ComponentLifecycle CompileAndExpectFailure.
 * @Provenance Expected diagnostic: Identifier 'ELevelTick' is not a data type;
 * @Provenance 'bCanEverTick' is not a member of 'FActorComponentTickFunction'.
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

UCLASS()
class ULifecycleComponentUnsupportedTickSurface : UActorComponent
{
	default PrimaryComponentTick.bCanEverTick = true;

	/**
	 * Illegal BlueprintOverride of TickComponent using ELevelTick.
	 *
	 * @Kind CompileReject
	 * @Covers UClass.BlueprintOverride
	 * @Param DeltaSeconds Tick delta
	 * @Param TickType Unsupported ELevelTick
	 * @Param ThisTickFunction Tick function
	 * @Inputs TickComponent override on UActorComponent
	 * @Return does not compile
	 */
	UFUNCTION(BlueprintOverride)
	void TickComponent(float DeltaSeconds, ELevelTick TickType, FActorComponentTickFunction&in ThisTickFunction)
	{
	}
}
