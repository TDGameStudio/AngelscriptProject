/**
 * @version v1
 * @summary Observe FLatentActionInfo construction and Linkage, UUID, ExecutionFunction, and unresolved CallbackTarget fields.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FLatentActionInfo construction and Linkage, UUID, ExecutionFunction, and unresolved CallbackTarget fields.
 * @topic Baseline
 */
// int32 Info.Linkage; int32 Info.UUID; FName Info.ExecutionFunction;
// UObject unresolved_object Info.CallbackTarget;
// Inputs: Linkage 7, UUID 99, function n"OnLatentComplete", a live UObject
// CDO, and a null callback target.
// Expected observations: Constructor stores every argument. Field writes
// round-trip. Null CallbackTarget remains null. ExecutionFunction is interned.
// Boundary/ownership: CallbackTarget is an unresolved object handle. UUID
// identifies the latent action for replace-or-find. Linkage selects the
// continuation.

namespace TS_FLatentActionInfo_Behavior_01
{
	// FLatentActionInfo(Linkage, UUID, FunctionName, Target) stores every argument. Null target remains null.
	bool Observe_Info_Nominal()
	{
		UObject Target = TSubclassOf<UObject>(UObject::StaticClass()).GetDefaultObject();
		if (Target is null)
		{
			throw("TS_FLatentActionInfo_Behavior_01 setup: required UObject CDO is null");
		}
		FLatentActionInfo Info(7, 99, n"OnLatentComplete", Target);
		UObject NullTarget;
		FLatentActionInfo NullInfo(0, 0, NAME_None, NullTarget);
		return Info.Linkage == 7 &&
			Info.UUID == 99 &&
			Info.ExecutionFunction == n"OnLatentComplete" &&
			Info.CallbackTarget == Target &&
			NullInfo.CallbackTarget is null &&
			NullInfo.ExecutionFunction == NAME_None;
	}

	// Info.Linkage default is 0; assignment 7 round-trips. Field write, no fixture.
	bool Observe_Surface002_Nominal()
	{
		UObject Target;
		FLatentActionInfo Info(0, 0, NAME_None, Target);
		int32 DefaultLinkage = Info.Linkage;
		Info.Linkage = 7;
		return DefaultLinkage == 0 && Info.Linkage == 7;
	}

	// Info.UUID default is 0; assignment 99 round-trips. Field write, no fixture.
	bool Observe_Surface003_Nominal()
	{
		UObject Target;
		FLatentActionInfo Info(0, 0, NAME_None, Target);
		int32 DefaultUUID = Info.UUID;
		Info.UUID = 99;
		return DefaultUUID == 0 && Info.UUID == 99;
	}

	// Info.ExecutionFunction default is NAME_None; n"OnLatentComplete" round-trips.
	bool Observe_Surface004_Nominal()
	{
		UObject Target;
		FLatentActionInfo Info(0, 0, NAME_None, Target);
		FName DefaultFunction = Info.ExecutionFunction;
		Info.ExecutionFunction = n"OnLatentComplete";
		return DefaultFunction == NAME_None && Info.ExecutionFunction == n"OnLatentComplete";
	}

	// Info.CallbackTarget stores the CDO then accepts a null write-back. Unresolved object handle.
	bool Observe_Surface005_Nominal()
	{
		UObject Target = TSubclassOf<UObject>(UObject::StaticClass()).GetDefaultObject();
		if (Target is null)
		{
			throw("TS_FLatentActionInfo_Behavior_01 setup: required UObject CDO is null");
		}
		FLatentActionInfo Info(0, 0, NAME_None, Target);
		UObject Stored = Info.CallbackTarget;
		UObject NullTarget;
		Info.CallbackTarget = NullTarget;
		return Stored == Target && Info.CallbackTarget is null;
	}
}
/** @end */
