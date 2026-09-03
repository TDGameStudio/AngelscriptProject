/**
 * An abstract actor compiles but SpawnActor rejects it. AbstractValue defaults
 * to 19 on a concrete spawn; ConcreteValue defaults to 23.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.UClassAbstractActorSpawnIsRejected
 * @Harness UClass
 * @Tag Definitions.UClass.UClassAbstractActorSpawnIsRejected
 * @Provenance Theme: Definitions.UClass. WorldStory abstract actor compiles but SpawnActor rejects it.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassAbstractActorSpawnIsRejected
 * @Provenance CSV NegativeDiagnostic is wrong: the module compiles; spawn of the abstract class is the runtime boundary.
 * @Provenance Oracle: AbstractValue default 19 on concrete spawn; ConcreteValue default 23; abstract spawn is null.
 * @Provenance Extra: unset handles are null. FixtureIsolated.
 */

UCLASS(Abstract)
class ACoverageUClassUnspawnableAbstractActor : AActor
{
	UPROPERTY()
	int AbstractValue = 19;

	/**
	 * Observe that an unset abstract handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Abstract
	 * @Inputs an unset ACoverageUClassUnspawnableAbstractActor handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		ACoverageUClassUnspawnableAbstractActor Actor;
		return Actor == nullptr;
	}
}

UCLASS()
class ACoverageUClassSpawnableConcreteActor : ACoverageUClassUnspawnableAbstractActor
{
	UPROPERTY()
	int ConcreteValue = 0;

	default ConcreteValue = 23;

	/**
	 * Observe that an unset concrete handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Abstract
	 * @Inputs an unset ACoverageUClassSpawnableConcreteActor handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		ACoverageUClassSpawnableConcreteActor Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe the inherited AbstractValue default.
	 *
	 * @Kind Observe
	 * @Covers UClass.Abstract
	 * @Inputs a freshly constructed concrete actor
	 * @Return AbstractValue
	 */
	UFUNCTION()
	int AbstractValueDefault()
	{
		return AbstractValue;
	}

	/**
	 * Observe the ConcreteValue default.
	 *
	 * @Kind Observe
	 * @Covers UClass.Abstract
	 * @Inputs a freshly constructed concrete actor
	 * @Return ConcreteValue
	 */
	UFUNCTION()
	int ConcreteValueDefault()
	{
		return ConcreteValue;
	}

	/**
	 * Observe writing ConcreteValue to 0.
	 *
	 * @Kind Observe
	 * @Covers UClass.Abstract
	 * @Inputs ConcreteValue set to 0
	 * @Return ConcreteValue
	 * @Boundary zero
	 */
	UFUNCTION()
	int ConcreteValueZeroBoundary()
	{
		ConcreteValue = 0;
		return ConcreteValue;
	}
}
