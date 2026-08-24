// Theme: World.Component. WorldStory: BindChord / BindAxisKey / BindVectorAxis.
// C++: AngelscriptCoverageInputTests.cpp::AdvancedInputComponentBindingCollections
// sha256=20cde6facb94f07abbbcd5670ab48d1b845a33ad662062f2e7dd7a60e46a87bf; lines 1627-1649.
// Oracle: SetupInput runs once; C++ counts Key/AxisKey/VectorAxis bindings = 1.
// Extra: local construct SetupCallCount 0. FixtureIsolated.

UCLASS()
class AAdvancedInputBindingPawn : APawn
{
	UPROPERTY()
	int SetupCallCount = 0;

	UFUNCTION()
	void SetupInput(UInputComponent PlayerInputComponent)
	{
		SetupCallCount++;

		FInputActionHandlerDynamicSignature ChordDelegate;
		PlayerInputComponent.BindChord(FInputChord(EKeys::LeftMouseButton, true, false, false, false), EInputEvent::IE_Pressed, ChordDelegate);

		FInputAxisHandlerDynamicSignature AxisKeyDelegate;
		PlayerInputComponent.BindAxisKey(n"MouseX", AxisKeyDelegate);

		FInputVectorAxisHandlerDynamicSignature VectorAxisDelegate;
		PlayerInputComponent.BindVectorAxis(EKeys::Tilt, VectorAxisDelegate);
	}
}

int Observe_AdvancedInputBindings_DefaultEmpty(AAdvancedInputBindingPawn Pawn)
{
	if (Pawn is null)
	{
		throw("Test_AdvancedInputComponentBindingCollections setup: required Pawn is null");
	}
	return Pawn.SetupCallCount;
}

bool Observe_AdvancedInputBindings_CopyIndependence(AAdvancedInputBindingPawn First, AAdvancedInputBindingPawn Second)
{
	if (First is null)
	{
		throw("Test_AdvancedInputComponentBindingCollections setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_AdvancedInputComponentBindingCollections setup: required Second is null");
	}
	First.SetupCallCount = 1;
	return First.SetupCallCount == 1 && Second.SetupCallCount == 0;
}
