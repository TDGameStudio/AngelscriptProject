// Theme: Definitions.UFunction. WorldStory: UFUNCTION return types bool/double/FString/FVector/AActor.
// C++: AngelscriptCoverageUFunctionTests.cpp::ReturnTypeReflectionMatrix
// Oracle: true / 12.5 / "coverage" / FVector(1,2,3) / this.
// Extra: a second instance's ReturnSelfActor is not the first; default-constructed FVector is not that triple.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class ACoverageUFunctionReturnMatrixActor : AActor
{
	UFUNCTION()
	bool ReturnBool()
	{
		return true;
	}

	UFUNCTION()
	double ReturnNumber()
	{
		return 12.5;
	}

	UFUNCTION()
	FString ReturnString()
	{
		return "coverage";
	}

	UFUNCTION()
	FVector ReturnVector()
	{
		return FVector(1.0, 2.0, 3.0);
	}

	UFUNCTION()
	AActor ReturnSelfActor()
	{
		return this;
	}
}

bool Observe_ReturnMatrix_Bool(ACoverageUFunctionReturnMatrixActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ReturnTypeReflectionMatrix setup: required Actor is null");
	}
	return Actor.ReturnBool();
}

double Observe_ReturnMatrix_Number(ACoverageUFunctionReturnMatrixActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ReturnTypeReflectionMatrix setup: required Actor is null");
	}
	return Actor.ReturnNumber();
}

FString Observe_ReturnMatrix_String(ACoverageUFunctionReturnMatrixActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ReturnTypeReflectionMatrix setup: required Actor is null");
	}
	return Actor.ReturnString();
}

bool Observe_ReturnMatrix_Vector(ACoverageUFunctionReturnMatrixActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ReturnTypeReflectionMatrix setup: required Actor is null");
	}
	FVector Location = Actor.ReturnVector();
	return Location.X == 1.0 && Location.Y == 2.0 && Location.Z == 3.0;
}

bool Observe_ReturnMatrix_SelfAlias(ACoverageUFunctionReturnMatrixActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ReturnTypeReflectionMatrix setup: required Actor is null");
	}
	return Actor.ReturnSelfActor() == Actor;
}

bool Observe_ReturnMatrix_SecondInstanceNotFirst(ACoverageUFunctionReturnMatrixActor First, ACoverageUFunctionReturnMatrixActor Second)
{
	if (First is null)
	{
		throw("Test_ReturnTypeReflectionMatrix setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_ReturnTypeReflectionMatrix setup: required Second is null");
	}
	return First.ReturnSelfActor() != Second.ReturnSelfActor();
}

bool Observe_ReturnMatrix_EmptyVectorIsNotNominal(ACoverageUFunctionReturnMatrixActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ReturnTypeReflectionMatrix setup: required Actor is null");
	}
	FVector Empty = FVector::ZeroVector;
	FVector Location = Actor.ReturnVector();
	return Empty.X == 0.0 && Empty.Y == 0.0 && Empty.Z == 0.0
		&& (Location.X != Empty.X || Location.Y != Empty.Y || Location.Z != Empty.Z);
}
