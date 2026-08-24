// Theme: Gameplay.FVector. Positive default-specifier FVector property oracle.
// C++: AngelscriptCompilerPropertyDefaultMatrixTests.cpp::DefaultFVectorPropertyApplied
// Oracle: VerifyVector == 42 after default MyVector = FVector(1.0f, 2.0f, 3.0f).
// Mismatch codes: X 1, Y 2, Z 3. Extra: empty FVector() is (0,0,0) and would
// return 1 from the X check. DefaultSafe.

UCLASS()
class UDefaultVectorCarrier : UObject
{
	UPROPERTY()
	FVector MyVector;

	default MyVector = FVector(1.0f, 2.0f, 3.0f);

	UFUNCTION()
	int VerifyVector()
	{
		if (MyVector.X < 0.9f || MyVector.X > 1.1f)
			return 1;
		if (MyVector.Y < 1.9f || MyVector.Y > 2.1f)
			return 2;
		if (MyVector.Z < 2.9f || MyVector.Z > 3.1f)
			return 3;
		return 42;
	}
}

bool Observe_VerifyVector_Nominal(UDefaultVectorCarrier Carrier)
{
	if (Carrier is null)
	{
		throw("Test_DefaultFVectorPropertyApplied setup: required Carrier is null");
	}
	return Carrier.VerifyVector() == 42;
}

int Observe_VerifyVector_EmptyWouldReturnXMismatch()
{
	FVector Empty = FVector();
	if (Empty.X < 0.9f || Empty.X > 1.1f)
	{
		return 1;
	}
	return 0;
}

bool Observe_VerifyVector_CopyIndependence(UDefaultVectorCarrier First, UDefaultVectorCarrier Second)
{
	if (First is null)
	{
		throw("Test_DefaultFVectorPropertyApplied setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_DefaultFVectorPropertyApplied setup: required Second is null");
	}
	First.MyVector = FVector::ZeroVector;
	return First.VerifyVector() == 1
		&& Second.VerifyVector() == 42;
}
