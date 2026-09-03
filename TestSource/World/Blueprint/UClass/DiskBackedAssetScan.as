/**
 * A script parent that C++ locates through its on-disk Blueprint asset scan. The
 * marker value is what the scan resolves the class by.
 *
 * @Theme World.Blueprint
 * @Subject Blueprint.DiskBackedAssetScan
 * @Harness UClass
 * @Tag World.Blueprint.DiskBackedAssetScan
 * @Provenance Theme: World.Blueprint. WorldStory: disk-backed Blueprint impact scan parent.
 * @Provenance C++: AngelscriptBlueprintImpactTests.cpp::DiskBackedAssetScan
 * @Provenance Oracle: C++ finds this class from the on-disk Blueprint asset scan.
 * @Provenance Extra: Marker 10; empty sibling Marker 0. Do not spawn from script. FixtureIsolated.
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
