/**
 * A pawn whose SetupInput binds a chord, an axis key and a vector axis. C++ runs
 * SetupInput once and counts one binding of each kind. The observers cover the
 * local-construct default and copy independence.
 *
 * @Theme World.Component
 * @Subject Component.AdvancedInputComponentBindingCollections
 * @Harness UClass
 * @Tag World.Component.AdvancedInputComponentBindingCollections
 * @Provenance Theme: World.Component. WorldStory: BindChord / BindAxisKey / BindVectorAxis.
 * @Provenance C++: AngelscriptCoverageInputTests.cpp::AdvancedInputComponentBindingCollections
 * @Provenance sha256=20cde6facb94f07abbbcd5670ab48d1b845a33ad662062f2e7dd7a60e46a87bf; lines 1627-1649.
 * @Provenance Oracle: SetupInput runs once; C++ counts Key/AxisKey/VectorAxis bindings = 1.
 * @Provenance Extra: local construct SetupCallCount 0. FixtureIsolated.
 */

UCLASS()
class AAdvancedInputBindingPawn : APawn
{
	UPROPERTY()
	int SetupCallCount = 0;

	/**
	 * WorldStory: SetupInput runs once and installs one chord, one axis key and
	 * one vector axis binding.
	 *
	 * @Kind WorldStory
	 * @Covers Component.AdvancedInputComponentBindingCollections
	 * @Inputs a player input component
	 * @Return SetupCallCount == 1; C++ counts Key/AxisKey/VectorAxis bindings = 1
	 * @Param PlayerInputComponent the component to bind against
	 */
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

	/**
	 * Observe that a locally constructed pawn has not run SetupInput.
	 *
	 * @Kind Observe
	 * @Covers Component.AdvancedInputComponentBindingCollections
	 * @Inputs a pawn that has not been set up
	 * @Return the setup call count, expected to be 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	int DefaultCallCount()
	{
		return SetupCallCount;
	}

	/**
	 * Observe that writing this pawn leaves another pawn untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.AdvancedInputComponentBindingCollections
	 * @Inputs this pawn plus a second pawn
	 * @Return true when this counts 1 and the other still counts 0
	 * @Param Second the other pawn, expected to stay at 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(AAdvancedInputBindingPawn Second)
	{
		if (Second is null)
		{
			throw("AdvancedInputComponentBindingCollections setup: required Second is null");
		}
		SetupCallCount = 1;
		if (SetupCallCount != 1)
		{
			return false;
		}
		return Second.SetupCallCount == 0;
	}
}
