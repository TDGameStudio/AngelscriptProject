// Purpose: Observe GetbNoFail / SetbNoFail and the no-fail diagnostic
// companion used when a spawn is forced not to fail.
// AS-facing API: bool Params.GetbNoFail() const; void Params.SetbNoFail(bool Value);
// Inputs: Default Params (no-fail false), SetbNoFail(true), then false again.
// Expected observations: Default GetbNoFail is false. Set true then false
// round-trips. ExerciseExpectedFailure keeps the no-fail flag asserted as the
// negative-spawn companion.
// Boundary/ownership: The flag is Unreal's no-fail spawn bit on the parameter
// object. Assignment of the flag does not spawn an actor.

namespace TS_FActorSpawnParameters_Operators_01
{
	bool Observe_GetbNoFail_Nominal()
	{
		FActorSpawnParameters Params;
		bool bDefaultNoFail = Params.GetbNoFail();
		Params.SetbNoFail(true);
		bool bSetTrue = Params.GetbNoFail();
		Params.SetbNoFail(false);
		bool bSetFalse = Params.GetbNoFail();
		return !bDefaultNoFail && bSetTrue && !bSetFalse;
	}

	void ExerciseExpectedFailure()
	{
		FActorSpawnParameters Params;
		Params.SetbNoFail(true);
		Params.Name = n"TS_FActorSpawnParameters_NoFail";
		Params.NameMode = ESpawnActorNameMode::Required_ErrorAndReturnNull;
		AActor First = AActor::Spawn(FTransform(), Params);
		AActor Second = AActor::Spawn(FTransform(), Params);
		if (First != nullptr)
		{
			First.DestroyActor();
		}
		if (Second != nullptr)
		{
			Second.DestroyActor();
		}
	}
}
