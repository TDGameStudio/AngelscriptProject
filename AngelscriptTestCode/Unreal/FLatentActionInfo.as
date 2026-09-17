/**
 * @version v1
 * @summary FLatentActionInfo host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FLatentActionInfo
 *
 * info
 * info-linkage-0-assignment
 * info-uuid-0-assignment
 * info-executionfunction-name-none
 * info-callbacktarget-stores-cdo
 */
/**
 * @begin info
 * @summary FLatentActionInfo(Linkage, UUID, FunctionName, Target) stores every argument.
 * @topic Unreal
 */
/**
 * @function ObserveInfoNominal
 * @summary FLatentActionInfo(Linkage, UUID, FunctionName, Target) stores every argument.
 * @covers FLatentActionInfo.info
 * @inputs FLatentActionInfo values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveInfoNominal()
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
/** @end */
/**
 * @begin info-linkage-0-assignment
 * @summary Info.Linkage default is 0; assignment 7 round-trips.
 * @topic Unreal
 */
/**
 * @function ObserveSurface002Nominal
 * @summary Info.Linkage default is 0; assignment 7 round-trips.
 * @covers FLatentActionInfo.info-linkage-0-assignment
 * @inputs FLatentActionInfo values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface002Nominal()
{
	UObject Target;
	FLatentActionInfo Info(0, 0, NAME_None, Target);
	int32 DefaultLinkage = Info.Linkage;
	Info.Linkage = 7;
	return DefaultLinkage == 0 && Info.Linkage == 7;
}
/** @end */
/**
 * @begin info-uuid-0-assignment
 * @summary Info.UUID default is 0; assignment 99 round-trips.
 * @topic Unreal
 */
/**
 * @function ObserveSurface003Nominal
 * @summary Info.UUID default is 0; assignment 99 round-trips.
 * @covers FLatentActionInfo.info-uuid-0-assignment
 * @inputs FLatentActionInfo values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface003Nominal()
{
	UObject Target;
	FLatentActionInfo Info(0, 0, NAME_None, Target);
	int32 DefaultUUID = Info.UUID;
	Info.UUID = 99;
	return DefaultUUID == 0 && Info.UUID == 99;
}
/** @end */
/**
 * @begin info-executionfunction-name-none
 * @summary Info.ExecutionFunction default is NAME_None.
 * @topic Unreal
 */
/**
 * @function ObserveSurface004Nominal
 * @summary Info.ExecutionFunction default is NAME_None.
 * @covers FLatentActionInfo.info-executionfunction-name-none
 * @inputs FLatentActionInfo values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface004Nominal()
{
	UObject Target;
	FLatentActionInfo Info(0, 0, NAME_None, Target);
	FName DefaultFunction = Info.ExecutionFunction;
	Info.ExecutionFunction = n"OnLatentComplete";
	return DefaultFunction == NAME_None && Info.ExecutionFunction == n"OnLatentComplete";
}
/** @end */
/**
 * @begin info-callbacktarget-stores-cdo
 * @summary Info.CallbackTarget stores the CDO then accepts a null write-back.
 * @topic Unreal
 */
/**
 * @function ObserveSurface005Nominal
 * @summary Info.CallbackTarget stores the CDO then accepts a null write-back.
 * @covers FLatentActionInfo.info-callbacktarget-stores-cdo
 * @inputs FLatentActionInfo values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface005Nominal()
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
/** @end */
