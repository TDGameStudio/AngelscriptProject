// Purpose: Observe TSubclassOf.Set replacing the selected class, including
// repeated sets, null restoration, and subtype validation.
// AS-facing API: void TSubclassOf<T>.Set(UClass Class) const;
// Inputs: A seeded TSubclassOf<AActor> holding AActor::StaticClass(), then
// APawn::StaticClass() as the mutation argument, a repeated Set of the same
// pawn class, and nullptr as restoration input.
// Expected observations: After Set(APawn) Get() identity is APawn. A second
// identical Set leaves identity unchanged. Set(null) clears IsValid().
// Boundary/ownership: Class must derive from T or the call is a diagnostic
// failure. The wrapper does not own the UClass object; it only stores the
// selected class identity.

namespace TS_BlueprintType_MutationAndLifecycle_01
{
	bool Observe_Set_Nominal()
	{
		TSubclassOf<AActor> Subclass = AActor::StaticClass();
		UClass Before = Subclass.Get();
		Subclass.Set(APawn::StaticClass());
		UClass AfterFirst = Subclass.Get();
		bool bSetReplacedSelectedClass = Before == AActor::StaticClass() && AfterFirst == APawn::StaticClass();

		Subclass.Set(APawn::StaticClass());
		UClass AfterRepeat = Subclass.Get();
		bool bRepeatedSetIsStable = AfterRepeat == APawn::StaticClass();

		Subclass.Set(nullptr);
		UClass AfterNull = Subclass.Get();
		bool bNullSetClearsSelection = AfterNull is null && !Subclass.IsValid();

		return bSetReplacedSelectedClass && bRepeatedSetIsStable && bNullSetClearsSelection;
	}
}
