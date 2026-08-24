// Theme: World.Blueprint. WorldStory: disk-backed Blueprint impact scan parent.
// C++: AngelscriptBlueprintImpactTests.cpp::DiskBackedAssetScan
// Oracle: C++ finds this class from the on-disk Blueprint asset scan.
// Extra: Marker 10; empty sibling Marker 0. Do not spawn from script. FixtureIsolated.

UCLASS()
class ATestBPImpactDiskBacked : AActor
{
	UPROPERTY()
	int Marker = 10;
}

UCLASS()
class ATestBPImpactDiskBackedEmpty : AActor
{
	UPROPERTY()
	int Marker = 0;
}
