// Purpose: Observe FActorSpawnParameters constructors and the spawn-option
// fields Name, Template, Owner, Instigator, OverrideLevel, collision, and
// NameMode.
// AS-facing API: FActorSpawnParameters Params();
// FActorSpawnParameters Params(const FActorSpawnParameters& Other);
// FName Params.Name; AActor Params.Template; AActor Params.Owner;
// APawn Params.Instigator; ULevel Params.OverrideLevel;
// ESpawnActorCollisionHandlingMethod Params.SpawnCollisionHandlingOverride;
// ESpawnActorNameMode Params.NameMode;
// Inputs: Default construct, copy of a named Params, n"TemplateActor",
// runner-owned Owner/Instigator/Template, null ULevel, AlwaysSpawn, and Requested.
// Expected observations: Default Name is NAME_None. Copy preserves Name.
// Template/Owner/Instigator/OverrideLevel accept null and live handles.
// Collision override and NameMode round-trip.
// Boundary/ownership: Template copies initial state from that actor instead
// of the class CDO. Null OverrideLevel lets the spawn helper resolve the
// level. NameMode controls name-collision behavior. SetupOwner=Runner for
// actor handles.

namespace TS_FActorSpawnParameters_Behavior_01
{
	// FActorSpawnParameters() default-constructs; copy constructor preserves Name.
	// Inputs: default Params, Name n"CopiedParams".
	// Oracle: default Name is NAME_None; copied Name equals n"CopiedParams".
	// Ownership: value copy; no actor spawn.
	bool Observe_Params_Nominal()
	{
		FActorSpawnParameters Params;
		bool bDefaultNameNone = Params.Name == NAME_None;
		Params.Name = n"CopiedParams";
		FActorSpawnParameters Copied(Params);
		return bDefaultNameNone && Copied.Name == n"CopiedParams" && Params.Name == n"CopiedParams";
	}

	// FName Params.Name round-trips requested and none.
	// Inputs: n"TemplateActor", then NAME_None.
	// Oracle: default is NAME_None; assigned name matches; restore is none.
	// Ownership: interned FName copy on the parameter object.
	bool Observe_Surface005_Nominal()
	{
		FActorSpawnParameters Params;
		FName DefaultName = Params.Name;
		Params.Name = n"TemplateActor";
		FName Assigned = Params.Name;
		Params.Name = NAME_None;
		return DefaultName == NAME_None && Assigned == n"TemplateActor" && Params.Name == NAME_None;
	}

	// AActor Params.Template accepts a live actor and null restore.
	// Inputs: runner-owned Template actor.
	// Oracle: default Template is null; assigned identity matches Template.
	// Ownership: borrowed actor handle; null Template throws.
	bool Observe_Surface006_Nominal(AActor Template)
	{
		if (Template is null)
		{
			throw("TS_FActorSpawnParameters_Behavior_01 setup: required Template is null");
		}
		FActorSpawnParameters Params;
		AActor DefaultTemplate = Params.Template;
		Params.Template = Template;
		AActor Assigned = Params.Template;
		Params.Template = DefaultTemplate;
		return DefaultTemplate is null && Assigned == Template && Params.Template is null;
	}

	// AActor Params.Owner accepts a live actor and null restore.
	// Inputs: runner-owned Owner actor.
	// Oracle: default Owner is null; assigned identity matches Owner.
	// Ownership: borrowed actor handle; null Owner throws.
	bool Observe_Surface007_Nominal(AActor Owner)
	{
		if (Owner is null)
		{
			throw("TS_FActorSpawnParameters_Behavior_01 setup: required Owner is null");
		}
		FActorSpawnParameters Params;
		AActor DefaultOwner = Params.Owner;
		Params.Owner = Owner;
		AActor Assigned = Params.Owner;
		Params.Owner = DefaultOwner;
		return DefaultOwner is null && Assigned == Owner && Params.Owner is null;
	}

	// APawn Params.Instigator accepts a live pawn and null restore.
	// Inputs: runner-owned Instigator pawn.
	// Oracle: default Instigator is null; assigned identity matches Instigator.
	// Ownership: borrowed pawn handle; null Instigator throws.
	bool Observe_Surface008_Nominal(APawn Instigator)
	{
		if (Instigator is null)
		{
			throw("TS_FActorSpawnParameters_Behavior_01 setup: required Instigator is null");
		}
		FActorSpawnParameters Params;
		APawn DefaultInstigator = Params.Instigator;
		Params.Instigator = Instigator;
		APawn Assigned = Params.Instigator;
		Params.Instigator = DefaultInstigator;
		return DefaultInstigator is null && Assigned == Instigator && Params.Instigator is null;
	}

	// ULevel Params.OverrideLevel accepts a null level.
	// Inputs: default Params and an explicit null ULevel.
	// Oracle: default and assigned OverrideLevel are both null.
	// Ownership: null OverrideLevel lets the spawn helper resolve the level.
	bool Observe_Surface009_Nominal()
	{
		FActorSpawnParameters Params;
		ULevel DefaultLevel = Params.OverrideLevel;
		ULevel NullLevel;
		Params.OverrideLevel = NullLevel;
		ULevel Assigned = Params.OverrideLevel;
		return DefaultLevel is null && Assigned is null;
	}

	// ESpawnActorCollisionHandlingMethod Params.SpawnCollisionHandlingOverride round-trips AlwaysSpawn.
	// Inputs: AlwaysSpawn then restore of the default method.
	// Oracle: assigned method equals AlwaysSpawn.
	// Ownership: enum stored on the parameter object; no spawn.
	bool Observe_Surface010_Nominal()
	{
		FActorSpawnParameters Params;
		ESpawnActorCollisionHandlingMethod DefaultMethod = Params.SpawnCollisionHandlingOverride;
		Params.SpawnCollisionHandlingOverride = ESpawnActorCollisionHandlingMethod::AlwaysSpawn;
		ESpawnActorCollisionHandlingMethod Assigned = Params.SpawnCollisionHandlingOverride;
		Params.SpawnCollisionHandlingOverride = DefaultMethod;
		return Assigned == ESpawnActorCollisionHandlingMethod::AlwaysSpawn;
	}

	// ESpawnActorNameMode Params.NameMode round-trips Requested then Required_ReturnNull.
	// Inputs: Requested, then Required_ReturnNull.
	// Oracle: assigned is Requested; restored is Required_ReturnNull; default differs from Requested.
	// Ownership: enum stored on the parameter object; no spawn.
	bool Observe_Surface011_Nominal()
	{
		FActorSpawnParameters Params;
		ESpawnActorNameMode DefaultMode = Params.NameMode;
		Params.NameMode = ESpawnActorNameMode::Requested;
		ESpawnActorNameMode Assigned = Params.NameMode;
		Params.NameMode = ESpawnActorNameMode::Required_ReturnNull;
		return Assigned == ESpawnActorNameMode::Requested && Params.NameMode == ESpawnActorNameMode::Required_ReturnNull && DefaultMode != Assigned;
	}
}
