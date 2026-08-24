// Purpose: Observe FActorSpawnParameters declaration, assignment, deferred-
// construction and construction-script flags, and ESpawnActorNameMode.
// AS-facing API: struct FActorSpawnParameters; Params = Other;
// bool Params.GetbDeferConstruction() const; void Params.SetbDeferConstruction(bool Value);
// bool Params.GetbAllowDuringConstructionScript() const;
// void Params.SetbAllowDuringConstructionScript(bool Value);
// enum ESpawnActorNameMode;
// Inputs: Default Params, a copy with Name n"Assigned", defer true/false, and
// every ESpawnActorNameMode enumerator.
// Expected observations: Default construct is usable. Assignment copies Name.
// GetbDeferConstruction is false then true after Set. Construction-script
// allow flag is false then true. NameMode enumerators are distinct.
// Boundary/ownership: Deferred construction requires Actor::FinishSpawningActor.
// Assignment copies the parameter object. DefaultSafe.

namespace TS_FActorSpawnParameters_ConstructionAndAssignment_01
{
	// struct FActorSpawnParameters default-constructs with none name and no defer.
	// Inputs: default Params.
	// Oracle: Name is NAME_None and GetbDeferConstruction is false.
	// Ownership: value object; no actor spawn.
	bool Observe_Surface001_Nominal()
	{
		FActorSpawnParameters Params;
		return Params.Name == NAME_None && Params.GetbDeferConstruction() == false;
	}

	// Params = Other copies Name and NameMode independently of later source mutation.
	// Inputs: Source.Name n"Assigned", NameMode Requested.
	// Oracle: assigned Name and NameMode match Source; Source Name stays n"Assigned".
	// Ownership: assignment copies the parameter object.
	bool Observe_Assignment_Nominal()
	{
		FActorSpawnParameters Source;
		Source.Name = n"Assigned";
		Source.NameMode = ESpawnActorNameMode::Requested;
		FActorSpawnParameters Params;
		Params = Source;
		return Params.Name == n"Assigned" && Params.NameMode == ESpawnActorNameMode::Requested && Source.Name == n"Assigned";
	}

	// GetbDeferConstruction / SetbDeferConstruction round-trip false, true, false.
	// Inputs: default Params, Set true then false.
	// Oracle: default false, set true, restored false.
	// Ownership: flag on the parameter object; deferred spawn needs FinishSpawningActor.
	bool Observe_GetbDeferConstruction_Nominal()
	{
		FActorSpawnParameters Params;
		bool bDefaultDeferred = Params.GetbDeferConstruction();
		Params.SetbDeferConstruction(true);
		bool bSetTrue = Params.GetbDeferConstruction();
		Params.SetbDeferConstruction(false);
		bool bSetFalse = Params.GetbDeferConstruction();
		return !bDefaultDeferred && bSetTrue && !bSetFalse;
	}

	// GetbAllowDuringConstructionScript default is false.
	// Inputs: default Params.
	// Oracle: default allow flag is false.
	// Ownership: flag on the parameter object.
	bool Observe_GetbAllowDuringConstructionScript_Nominal()
	{
		FActorSpawnParameters Params;
		return !Params.GetbAllowDuringConstructionScript();
	}

	// SetbAllowDuringConstructionScript round-trips true then false.
	// Inputs: Set true then false.
	// Oracle: true after set, false after restore.
	// Ownership: flag on the parameter object.
	bool Observe_SetbAllowDuringConstructionScript_Nominal()
	{
		FActorSpawnParameters Params;
		Params.SetbAllowDuringConstructionScript(true);
		bool bSetTrue = Params.GetbAllowDuringConstructionScript();
		Params.SetbAllowDuringConstructionScript(false);
		bool bSetFalse = Params.GetbAllowDuringConstructionScript();
		return bSetTrue && !bSetFalse;
	}

	// ESpawnActorNameMode enumerators copy, assign, and stay distinct.
	// Inputs: Required_Fatal, Required_ErrorAndReturnNull, Required_ReturnNull, Requested.
	// Oracle: copy equals Fatal; assignment selects Requested; all four values differ.
	// Ownership: enum values; no actor spawn.
	bool Observe_Surface016_Nominal()
	{
		ESpawnActorNameMode Fatal = ESpawnActorNameMode::Required_Fatal;
		ESpawnActorNameMode ErrorAndReturnNull = ESpawnActorNameMode::Required_ErrorAndReturnNull;
		ESpawnActorNameMode ReturnNull = ESpawnActorNameMode::Required_ReturnNull;
		ESpawnActorNameMode Requested = ESpawnActorNameMode::Requested;
		ESpawnActorNameMode Copied = Fatal;
		bool bCopyEqualsFatal = Copied == Fatal;
		Copied = Requested;
		bool bEnumeratorsDistinct = Fatal != ErrorAndReturnNull && ErrorAndReturnNull != ReturnNull && ReturnNull != Requested;
		return bCopyEqualsFatal && Copied == Requested && bEnumeratorsDistinct;
	}
}
