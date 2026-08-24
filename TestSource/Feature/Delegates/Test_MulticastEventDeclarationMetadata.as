// Theme: Feature.Delegates. WorldStory: event declarations register multicast metadata.
// C++: AngelscriptCoverageMulticastDelegateTests.cpp::MulticastEventDeclarationMetadata
// Compile + reflection oracle: FCoverageMetadataEvent / FCoverageMetadataValueEvent are multicast;
// OnNoParam / OnValue are FMulticastDelegateProperty.
// Extra: default actor non-null; nullptr assignment is the null boundary.
// FixtureIsolated.

event void FCoverageMetadataEvent();
event void FCoverageMetadataValueEvent(int Value);

UCLASS()
class ACoverageMulticastMetadataActor : AActor
{
	UPROPERTY()
	FCoverageMetadataEvent OnNoParam;

	UPROPERTY()
	FCoverageMetadataValueEvent OnValue;
}

bool Observe_MetadataActor_DefaultNonNull()
{
	ACoverageMulticastMetadataActor Actor;
	return Actor != nullptr;
}

bool Observe_MetadataActor_NullBoundary()
{
	ACoverageMulticastMetadataActor Actor = nullptr;
	return Actor == nullptr;
}
