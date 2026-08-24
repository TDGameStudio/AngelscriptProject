// Theme: Feature.Access. WorldStory: UPROPERTY may be declared private.
// C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Access_Positive block 7 AssertCompiles.
// Oracle: Health stays private at 100; construction succeeds without exposing Health.
// Extra: empty construct; two instances are independent objects.
// FixtureIsolated. Keep UPROPERTY name Health.

class AActorUPropPriv : AActor
{
	UPROPERTY()
	private int Health = 100;
}

bool Observe_UPropPrivate_EmptyConstruct()
{
	AActorUPropPriv Actor;
	return Actor != nullptr;
}

bool Observe_UPropPrivate_CopyIndependence()
{
	AActorUPropPriv First;
	AActorUPropPriv Second;
	return First != nullptr && Second != nullptr && First != Second;
}
