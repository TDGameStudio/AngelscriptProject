// Theme: Definitions.UProperty. WorldStory: UPROPERTY FString.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Types_Positive AssertCompiles
// UPropTP_FString; lines 409-415;
// sha256=0e70dc3b83caf18dee04aec4c733f35731c24f3b446ea6655bf4b7c197d25734.
// Oracle: Name default is "Default" on the spawned actor.
// Extra: empty string write; copy-independence of a local snapshot.
// FixtureIsolated.

class AUPropStrActor : AActor
{
	UPROPERTY()
	FString Name = "Default";
}

bool Observe_Name_Nominal(AUPropStrActor Actor)
{
	return Actor.Name == "Default";
}

bool Observe_Name_EmptyDefault(AUPropStrActor Actor)
{
	FString Saved = Actor.Name;
	Actor.Name = "";
	bool bEmpty = Actor.Name.IsEmpty();
	Actor.Name = Saved;
	return bEmpty && Saved == "Default";
}

bool Observe_Name_CopyIndependence(AUPropStrActor Actor)
{
	FString Original = Actor.Name;
	FString Copy = Original;
	Copy = "Mutated";
	return Actor.Name == Original && Copy == "Mutated" && Original == "Default";
}
