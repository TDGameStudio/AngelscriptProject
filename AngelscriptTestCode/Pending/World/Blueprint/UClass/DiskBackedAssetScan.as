/**
 * @version v1
 * @summary A script parent that C++ locates through its on-disk Blueprint asset scan. The marker value is what the scan resolves the class by.
 * @topic World
 */
/**
 * @version root
 * @summary A script parent that C++ locates through its on-disk Blueprint asset scan. The marker value is what the scan resolves the class by.
 * @topic Baseline
 */
UCLASS()
class ATestBPImpactDiskBacked : AActor
{
	UPROPERTY()
	int Marker = 10;
}

/**
 * The sibling holding the zeroed marker, which C++ uses as the empty boundary. Its
 * UPROPERTY is part of the fixture and must be kept.
 *
 * @Covers Blueprint.DiskBackedAssetScan
 * @Inputs none
 * @Return an actor identical in shape but with Marker 0
 * @Boundary zeroed marker
 */
UCLASS()
class ATestBPImpactDiskBackedEmpty : AActor
{
	UPROPERTY()
	int Marker = 0;
}
/** @end */
