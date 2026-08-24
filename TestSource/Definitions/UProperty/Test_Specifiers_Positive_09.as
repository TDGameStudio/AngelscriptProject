// Theme: Definitions.UProperty. WorldStory: combined EditAnywhere, BlueprintReadWrite, Category.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Positive AssertCompiles
// UPropSP_Multiple; lines 141-147;
// sha256=ce224ceeb42331c30a7c254b858796ac23ed1c3c90241b96f248ffa4125ad396.
// Oracle: Damage default is 10.0f on the spawned actor.
// Extra: 0.0f empty/default write; restoring 10.0f is copy-independence.
// FixtureIsolated.

class AUPropMultiActor : AActor
{
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Combat")
	float Damage = 10.0f;
}

bool Observe_Damage_Nominal(AUPropMultiActor Actor)
{
	return Actor.Damage == 10.0f;
}

bool Observe_Damage_EmptyDefault(AUPropMultiActor Actor)
{
	float Saved = Actor.Damage;
	Actor.Damage = 0.0f;
	bool bEmpty = Actor.Damage == 0.0f;
	Actor.Damage = Saved;
	return bEmpty && Saved == 10.0f;
}

bool Observe_Damage_CopyIndependence(AUPropMultiActor Actor)
{
	float Original = Actor.Damage;
	float Copy = Original;
	Copy = 99.0f;
	return Actor.Damage == Original && Copy == 99.0f && Original == 10.0f;
}
