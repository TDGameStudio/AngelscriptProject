/**
 * @version v1
 * @summary Blueprint B, the non-impacted parent: changing the other filter must not mark this one impacted. C++ compiles this as the module TestBPImpactFilterB; its companion ImpactFilterA carries the impacted parent.
 * @topic World
 */
/**
 * @version root
 * @summary Blueprint B, the non-impacted parent: changing the other filter must not mark this one impacted. C++ compiles this as the module TestBPImpactFilterB; its companion ImpactFilterA carries the impacted parent.
 * @topic Baseline
 */
UCLASS()
class ATestBPImpactFilterB : AActor
{
	UPROPERTY()
	int Value = 2;
}

/**
 * The sibling holding the zeroed value, which C++ uses as the empty boundary. Its
 * UPROPERTY is part of the fixture and must be kept.
 *
 * @Covers Blueprint.ImpactFilterB
 * @Inputs none
 * @Return an actor identical in shape but with Value 0
 * @Boundary zeroed value
 */
UCLASS()
class ATestBPImpactFilterBEmpty : AActor
{
	UPROPERTY()
	int Value = 0;
}
/** @end */
