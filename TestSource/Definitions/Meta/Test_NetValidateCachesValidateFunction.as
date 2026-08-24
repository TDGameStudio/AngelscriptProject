// Theme: Definitions.Meta. WorldStory: Server WithValidation caches the companion validate function.
// C++: AngelscriptASFunctionMetadataTests.cpp::NetValidateCachesValidateFunction
// Oracle: Server_SetValue_Validate(0) true; Validate(-1) false. Extra: empty default handle is null.
// FixtureIsolated.

UCLASS()
class AASFunctionNetValidateCache : AActor
{
	UFUNCTION(Server, WithValidation)
	void Server_SetValue(int Value)
	{
	}

	UFUNCTION()
	bool Server_SetValue_Validate(int Value)
	{
		return Value >= 0;
	}
}

bool Observe_NetValidate_ZeroBoundary(AASFunctionNetValidateCache Actor)
{
	return Actor.Server_SetValue_Validate(0);
}

bool Observe_NetValidate_NegativeBoundary(AASFunctionNetValidateCache Actor)
{
	return Actor.Server_SetValue_Validate(-1);
}

bool Observe_NetValidate_PositiveNominal(AASFunctionNetValidateCache Actor)
{
	return Actor.Server_SetValue_Validate(12);
}

int Observe_NetValidate_EmptyDefaultIsNull()
{
	AASFunctionNetValidateCache Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}
