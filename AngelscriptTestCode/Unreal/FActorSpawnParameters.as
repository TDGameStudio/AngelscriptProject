/**
 * @version v1
 * @summary FActorSpawnParameters host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FActorSpawnParameters
 *
 * params
 * ownership-interned-fname-copy
 * ownership-borrowed-actor-handle
 * FActorSpawnParameters-Behavior_01-ownership-borrowed-actor-handle
 * ownership-borrowed-pawn-handle
 * ownership-null-overridelevel-lets
 * ownership-enum-stored-parameter
 * FActorSpawnParameters-Behavior_01-ownership-enum-stored-parameter
 * ownership-value-object
 * assignment
 * getb-defer-construction
 * getb-allow-during-construction-script
 * setb-allow-during-construction-script
 * ownership-enum-values
 * getb-no-fail
 */
/**
 * @begin params
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveParamsNominal
 * @summary Observe the container API.
 * @covers FActorSpawnParameters.params
 * @inputs FActorSpawnParameters values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 FActorSpawnParameters Params(const FActorSpawnParameters& Other);
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
// FActorSpawnParameters() default-constructs; copy constructor preserves Name.
// Inputs: default Params, Name n"CopiedParams".
// Oracle: default Name is NAME_None; copied Name equals n"CopiedParams".
// Ownership: value copy; no actor spawn.
bool ObserveParamsNominal()
{
	FActorSpawnParameters Params;
	bool bDefaultNameNone = Params.Name == NAME_None;
	Params.Name = n"CopiedParams";
	FActorSpawnParameters Copied(Params);
	return bDefaultNameNone && Copied.Name == n"CopiedParams" && Params.Name == n"CopiedParams";
}
/** @end */
/**
 * @begin ownership-interned-fname-copy
 * @summary Ownership: interned FName copy on the parameter object.
 * @topic Unreal
 */
/**
 * @function ObserveSurface005Nominal
 * @summary Ownership: interned FName copy on the parameter object.
 * @covers FActorSpawnParameters.ownership-interned-fname-copy
 * @inputs FActorSpawnParameters values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface005Nominal()
{
	FActorSpawnParameters Params;
	FName DefaultName = Params.Name;
	Params.Name = n"TemplateActor";
	FName Assigned = Params.Name;
	Params.Name = NAME_None;
	return DefaultName == NAME_None && Assigned == n"TemplateActor" && Params.Name == NAME_None;
}
/** @end */
/**
 * @begin ownership-borrowed-actor-handle
 * @summary Ownership: borrowed actor handle.
 * @topic Unreal
 */
/**
 * @function ObserveSurface006Nominal
 * @summary Ownership: borrowed actor handle.
 * @covers FActorSpawnParameters.ownership-borrowed-actor-handle
 * @inputs FActorSpawnParameters values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface006Nominal(AActor Template)
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
/** @end */
/**
 * @begin FActorSpawnParameters-Behavior_01-ownership-borrowed-actor-handle
 * @summary Ownership: borrowed actor handle.
 * @topic Unreal
 */
/**
 * @function ObserveSurface007Nominal
 * @summary Ownership: borrowed actor handle.
 * @covers FActorSpawnParameters.ownership-borrowed-actor-handle
 * @inputs FActorSpawnParameters values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface007Nominal(AActor Owner)
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
/** @end */
/**
 * @begin ownership-borrowed-pawn-handle
 * @summary Ownership: borrowed pawn handle.
 * @topic Unreal
 */
/**
 * @function ObserveSurface008Nominal
 * @summary Ownership: borrowed pawn handle.
 * @covers FActorSpawnParameters.ownership-borrowed-pawn-handle
 * @inputs FActorSpawnParameters values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface008Nominal(APawn Instigator)
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
/** @end */
/**
 * @begin ownership-null-overridelevel-lets
 * @summary Ownership: null OverrideLevel lets the spawn helper resolve the level.
 * @topic Unreal
 */
/**
 * @function ObserveSurface009Nominal
 * @summary Ownership: null OverrideLevel lets the spawn helper resolve the level.
 * @covers FActorSpawnParameters.ownership-null-overridelevel-lets
 * @inputs FActorSpawnParameters values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface009Nominal()
{
	FActorSpawnParameters Params;
	ULevel DefaultLevel = Params.OverrideLevel;
	ULevel NullLevel;
	Params.OverrideLevel = NullLevel;
	ULevel Assigned = Params.OverrideLevel;
	return DefaultLevel is null && Assigned is null;
}
/** @end */
/**
 * @begin ownership-enum-stored-parameter
 * @summary Ownership: enum stored on the parameter object.
 * @topic Unreal
 */
/**
 * @function ObserveSurface010Nominal
 * @summary Ownership: enum stored on the parameter object.
 * @covers FActorSpawnParameters.ownership-enum-stored-parameter
 * @inputs FActorSpawnParameters values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface010Nominal()
{
	FActorSpawnParameters Params;
	ESpawnActorCollisionHandlingMethod DefaultMethod = Params.SpawnCollisionHandlingOverride;
	Params.SpawnCollisionHandlingOverride = ESpawnActorCollisionHandlingMethod::AlwaysSpawn;
	ESpawnActorCollisionHandlingMethod Assigned = Params.SpawnCollisionHandlingOverride;
	Params.SpawnCollisionHandlingOverride = DefaultMethod;
	return Assigned == ESpawnActorCollisionHandlingMethod::AlwaysSpawn;
}
/** @end */
/**
 * @begin FActorSpawnParameters-Behavior_01-ownership-enum-stored-parameter
 * @summary Ownership: enum stored on the parameter object.
 * @topic Unreal
 */
/**
 * @function ObserveSurface011Nominal
 * @summary Ownership: enum stored on the parameter object.
 * @covers FActorSpawnParameters.ownership-enum-stored-parameter
 * @inputs FActorSpawnParameters values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface011Nominal()
{
	FActorSpawnParameters Params;
	ESpawnActorNameMode DefaultMode = Params.NameMode;
	Params.NameMode = ESpawnActorNameMode::Requested;
	ESpawnActorNameMode Assigned = Params.NameMode;
	Params.NameMode = ESpawnActorNameMode::Required_ReturnNull;
	return Assigned == ESpawnActorNameMode::Requested && Params.NameMode == ESpawnActorNameMode::Required_ReturnNull && DefaultMode != Assigned;
}
/** @end */
/**
 * @begin ownership-value-object
 * @summary Ownership: value object.
 * @topic Unreal
 */
/**
 * @function ObserveSurface001Nominal
 * @summary Ownership: value object.
 * @covers FActorSpawnParameters.ownership-value-object
 * @inputs FActorSpawnParameters values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface001Nominal()
{
	FActorSpawnParameters Params;
	return Params.Name == NAME_None && Params.GetbDeferConstruction() == false;
}
/** @end */
/**
 * @begin assignment
 * @summary Ownership: assignment copies the parameter object.
 * @topic Unreal
 */
/**
 * @function ObserveAssignmentNominal
 * @summary Ownership: assignment copies the parameter object.
 * @covers FActorSpawnParameters.assignment
 * @inputs FActorSpawnParameters values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAssignmentNominal()
{
	FActorSpawnParameters Source;
	Source.Name = n"Assigned";
	Source.NameMode = ESpawnActorNameMode::Requested;
	FActorSpawnParameters Params;
	Params = Source;
	return Params.Name == n"Assigned" && Params.NameMode == ESpawnActorNameMode::Requested && Source.Name == n"Assigned";
}
/** @end */
/**
 * @begin getb-defer-construction
 * @summary Ownership: flag on the parameter object.
 * @topic Unreal
 */
/**
 * @function ObserveGetbDeferConstructionNominal
 * @summary Ownership: flag on the parameter object.
 * @covers FActorSpawnParameters.getb-defer-construction
 * @inputs FActorSpawnParameters values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetbDeferConstructionNominal()
{
	FActorSpawnParameters Params;
	bool bDefaultDeferred = Params.GetbDeferConstruction();
	Params.SetbDeferConstruction(true);
	bool bSetTrue = Params.GetbDeferConstruction();
	Params.SetbDeferConstruction(false);
	bool bSetFalse = Params.GetbDeferConstruction();
	return !bDefaultDeferred && bSetTrue && !bSetFalse;
}
/** @end */
/**
 * @begin getb-allow-during-construction-script
 * @summary Ownership: flag on the parameter object.
 * @topic Unreal
 */
/**
 * @function ObserveGetbAllowDuringConstructionScriptNominal
 * @summary Ownership: flag on the parameter object.
 * @covers FActorSpawnParameters.getb-allow-during-construction-script
 * @inputs FActorSpawnParameters values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetbAllowDuringConstructionScriptNominal()
{
	FActorSpawnParameters Params;
	return !Params.GetbAllowDuringConstructionScript();
}
/** @end */
/**
 * @begin setb-allow-during-construction-script
 * @summary Ownership: flag on the parameter object.
 * @topic Unreal
 */
/**
 * @function ObserveSetbAllowDuringConstructionScriptNominal
 * @summary Ownership: flag on the parameter object.
 * @covers FActorSpawnParameters.setb-allow-during-construction-script
 * @inputs FActorSpawnParameters values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetbAllowDuringConstructionScriptNominal()
{
	FActorSpawnParameters Params;
	Params.SetbAllowDuringConstructionScript(true);
	bool bSetTrue = Params.GetbAllowDuringConstructionScript();
	Params.SetbAllowDuringConstructionScript(false);
	bool bSetFalse = Params.GetbAllowDuringConstructionScript();
	return bSetTrue && !bSetFalse;
}
/** @end */
/**
 * @begin ownership-enum-values
 * @summary Ownership: enum values.
 * @topic Unreal
 */
/**
 * @function ObserveSurface016Nominal
 * @summary Ownership: enum values.
 * @covers FActorSpawnParameters.ownership-enum-values
 * @inputs FActorSpawnParameters values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface016Nominal()
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
/** @end */
/**
 * @begin getb-no-fail
 * @summary object.
 * @topic Unreal
 */
/**
 * @function ObserveGetbNoFailNominal
 * @summary object.
 * @covers FActorSpawnParameters.getb-no-fail
 * @inputs FActorSpawnParameters values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetbNoFailNominal()
{
	FActorSpawnParameters Params;
	bool bDefaultNoFail = Params.GetbNoFail();
	Params.SetbNoFail(true);
	bool bSetTrue = Params.GetbNoFail();
	Params.SetbNoFail(false);
	bool bSetFalse = Params.GetbNoFail();
	return !bDefaultNoFail && bSetTrue && !bSetFalse;
}
/** @end */
