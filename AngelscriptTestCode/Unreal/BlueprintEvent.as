/**
 * @version v1
 * @summary BlueprintEvent host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic BlueprintEvent
 *
 * evt-execute-delegate
 * event-name
 * broadcast
 * execute
 * execute-if-bound
 * BlueprintEvent-NamespaceAndGlobalFunctions_01-event-name
 */
/**
 * @begin evt-execute-delegate
 * @summary Ownership: delegates borrow Owner.
 * @topic Unreal
 */
/**
 * @function ObserveEvtExecuteDelegateNominal
 * @summary Ownership: delegates borrow Owner.
 * @covers BlueprintEvent.evt-execute-delegate
 * @inputs BlueprintEvent values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveEvtExecuteDelegateNominal()
{
	UTSBlueprintEventBehaviorOwner Owner;
	if (Owner is null)
	{
		throw("TS_BlueprintEvent_Behavior_01 setup: required Owner is null");
	}
	FTSBlueprintEventBehaviorDelegate SingleCast;
	SingleCast.BindUFunction(Owner, n"Store");
	__Evt_PushArgument__int(21);
	__Evt_ExecuteDelegate(SingleCast);
	int SingleCastResult = Owner.LastValue;

	FTSBlueprintEventBehaviorMulticast Multicast;
	Multicast.AddUFunction(Owner, n"Store");
	__Evt_PushArgument__int(7);
	__Evt_ExecuteDelegate(Multicast);
	int MulticastResult = Owner.LastValue;

	return SingleCastResult == 21 && MulticastResult == 7;
}
/** @end */
/**
 * @begin event-name
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveEventNameNominal
 * @summary Observe the container API.
 * @covers BlueprintEvent.event-name
 * @inputs BlueprintEvent values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 Inputs: Compute(21) then Compute(0).
// Oracle: 21 returns 42 with LastValue 21; 0 returns 21.
// Ownership: instance call mutates Owner; no new receiver is spawned.
bool ObserveEventNameNominal()
{
	UTSBlueprintEventBehaviorOwner Owner;
	if (Owner is null)
	{
		throw("TS_BlueprintEvent_Behavior_01 setup: required Owner is null");
	}
	int InstanceResult = Owner.Compute(21);
	int MixinStyleResult = Owner.Compute(0);
	return InstanceResult == 42 && Owner.LastValue == 0 && MixinStyleResult == 21;
}
/** @end */
/**
 * @begin broadcast
 * @summary mutated integer.
 * @topic Unreal
 */
/**
 * @function ObserveBroadcastNominal
 * @summary mutated integer.
 * @covers BlueprintEvent.broadcast
 * @inputs BlueprintEvent values exercised by this observe
 * @return true when the observe comparison holds
 */
event

bool ObserveBroadcastNominal()
{
	ATSBlueprintEventMutationReceiver Receiver;
	if (Receiver is null)
	{
		throw("TS_BlueprintEvent_MutationAndLifecycle_01 setup: required Receiver is null");
	}
	Receiver.ReceivedValue = -1;
	Receiver.InvocationCount = 0;
	Receiver.MutationEvent.AddUFunction(Receiver, n"OnMutation");

	Receiver.MutationEvent.Broadcast(41);
	bool bFirstDelivered = Receiver.ReceivedValue == 41 && Receiver.InvocationCount == 1;

	Receiver.MutationEvent.Broadcast(7);
	bool bRepeatedCallUpdated = Receiver.ReceivedValue == 7 && Receiver.InvocationCount == 2;

	Receiver.MutationEvent.Clear();
	int UnboundBefore = Receiver.ReceivedValue;
	Receiver.MutationEvent.Broadcast(99);
	int UnboundAfter = Receiver.ReceivedValue;
	bool bUnboundBroadcastIsNoOp = UnboundBefore == UnboundAfter;

	return bFirstDelivered && bRepeatedCallUpdated && bUnboundBroadcastIsNoOp;
}
/** @end */
/**
 * @begin execute
 * @summary mutated integer.
 * @topic Unreal
 */
/**
 * @function ObserveExecuteNominal
 * @summary mutated integer.
 * @covers BlueprintEvent.execute
 * @inputs BlueprintEvent values exercised by this observe
 * @return true when the observe comparison holds
 */
event

bool ObserveExecuteNominal()
{
	ATSBlueprintEventMutationReceiver Receiver;
	if (Receiver is null)
	{
		throw("TS_BlueprintEvent_MutationAndLifecycle_01 setup: required Receiver is null");
	}
	Receiver.ReceivedValue = 0;
	FTSBlueprintEventMutationDelegate Bound;
	Bound.BindUFunction(Receiver, n"OnMutation");

	Bound.Execute(41);
	bool bBoundExecuteDelivered = Receiver.ReceivedValue == 41;

	Bound.Execute(7);
	bool bRepeatedExecuteDelivered = Receiver.ReceivedValue == 7;

	return bBoundExecuteDelivered && bRepeatedExecuteDelivered;
}
/** @end */
/**
 * @begin execute-if-bound
 * @summary mutated integer.
 * @topic Unreal
 */
/**
 * @function ObserveExecuteIfBoundNominal
 * @summary mutated integer.
 * @covers BlueprintEvent.execute-if-bound
 * @inputs BlueprintEvent values exercised by this observe
 * @return true when the observe comparison holds
 */
event

bool ObserveExecuteIfBoundNominal()
{
	ATSBlueprintEventMutationReceiver Receiver;
	if (Receiver is null)
	{
		throw("TS_BlueprintEvent_MutationAndLifecycle_01 setup: required Receiver is null");
	}
	Receiver.ReceivedValue = 3;
	FTSBlueprintEventMutationDelegate Bound;
	Bound.BindUFunction(Receiver, n"OnMutation");

	Bound.ExecuteIfBound(41);
	bool bBoundPathInvoked = Receiver.ReceivedValue == 41;

	FTSBlueprintEventMutationDelegate Unbound;
	int UnboundBefore = Receiver.ReceivedValue;
	Unbound.ExecuteIfBound(99);
	int UnboundAfter = Receiver.ReceivedValue;
	bool bUnboundPathIsNoOp = UnboundBefore == UnboundAfter;

	return bBoundPathInvoked && bUnboundPathIsNoOp;
}
/** @end */
/**
 * @begin BlueprintEvent-NamespaceAndGlobalFunctions_01-event-name
 * @summary as a script-owned instance.
 * @topic Unreal
 */
/**
 * @function ObserveEventNameNominal
 * @summary as a script-owned instance.
 * @covers BlueprintEvent.event-name
 * @inputs BlueprintEvent values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSBlueprintEventNamespaceOwner : UObject
{
	UFUNCTION(BlueprintEvent)

bool ObserveEventNameNominal()
{
	int ExplicitResult = UTSBlueprintEventNamespaceOwner::Compute(21);
	int EmptyStateResult = UTSBlueprintEventNamespaceOwner::Compute(0);
	return ExplicitResult == 42 && EmptyStateResult == 21;
}
/** @end */
