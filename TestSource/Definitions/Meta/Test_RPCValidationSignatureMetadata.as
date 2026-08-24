// Theme: Definitions.Meta. WorldStory: WithValidation companion shares the RPC parameter list.
// C++: AngelscriptCoverageNetworkingTests.cpp::RPCValidationSignatureMetadata
// Oracle: ServerValidatedPayload_Validate(0, 0.0, ZeroVector, live Target) is true;
// Damage < 0, Scale < 0, or null Target is false. Extra: empty/null Target. FixtureIsolated.

UCLASS()
class ACoverageNetworkingRPCValidationSignatureActor : AActor
{
	default SetReplicates(true);

	UFUNCTION(Server, WithValidation)
	void ServerValidatedPayload(int Damage, float Scale, FVector HitLocation, AActor Target)
	{
	}

	UFUNCTION()
	bool ServerValidatedPayload_Validate(int Damage, float Scale, FVector HitLocation, AActor Target)
	{
		return Damage >= 0 && Scale >= 0.0f && Target != nullptr;
	}
}

bool Observe_RPCValidation_Nominal(ACoverageNetworkingRPCValidationSignatureActor Actor, AActor Target)
{
	return Actor.ServerValidatedPayload_Validate(0, 0.0f, FVector::ZeroVector, Target);
}

bool Observe_RPCValidation_NegativeDamageBoundary(ACoverageNetworkingRPCValidationSignatureActor Actor, AActor Target)
{
	return Actor.ServerValidatedPayload_Validate(-1, 1.0f, FVector::ZeroVector, Target);
}

bool Observe_RPCValidation_NegativeScaleBoundary(ACoverageNetworkingRPCValidationSignatureActor Actor, AActor Target)
{
	return Actor.ServerValidatedPayload_Validate(1, -0.5f, FVector::ZeroVector, Target);
}

bool Observe_RPCValidation_NullTargetBoundary(ACoverageNetworkingRPCValidationSignatureActor Actor)
{
	AActor Missing;
	return Actor.ServerValidatedPayload_Validate(1, 1.0f, FVector::ZeroVector, Missing);
}
