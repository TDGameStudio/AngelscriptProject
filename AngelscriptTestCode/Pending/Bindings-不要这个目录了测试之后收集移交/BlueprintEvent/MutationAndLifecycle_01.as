/**
 * @version v1
 * @summary Observe multicast, sparse, and single-cast Blueprint event invocation from seeded receivers, including repeated calls and unbound cleanup.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe multicast, sparse, and single-cast Blueprint event invocation from seeded receivers, including repeated calls and unbound cleanup.
 * @topic Baseline
 */
// ReturnType SparseDelegate.Broadcast(Arguments...);
// ReturnType Delegate.Execute(Arguments...);
// ReturnType Delegate.ExecuteIfBound(Arguments...);
// Inputs: A bound multicast event, a bound single-cast delegate, the exact
// mutation argument 41, a second call with 7, and an unbound delegate left
// after Unbind for cleanup comparison.
// Expected observations: Bound Broadcast and Execute deliver 41 then 7.
// Unbound Broadcast is a no-op. ExecuteIfBound returns without changing state.
// Boundary/ownership: Broadcast is a no-op when unbound. Sparse Broadcast
// resolves the sparse owner and backing multicast at invocation time.
// Execute raises when unbound; ExecuteIfBound does not. The receiver owns the
// mutated integer; the delegate does not take ownership of the UObject.

event void FTSBlueprintEventMutationMulticast(int Value);
delegate void FTSBlueprintEventMutationDelegate(int Value);

class ATSBlueprintEventMutationReceiver : AActor
{
	int ReceivedValue = 0;
	int InvocationCount = 0;

	UPROPERTY()
	FTSBlueprintEventMutationMulticast MutationEvent;

	UFUNCTION()
	void OnMutation(int Value)
	{
		ReceivedValue = Value;
		InvocationCount += 1;
	}
}

namespace TS_BlueprintEvent_MutationAndLifecycle_01
{
	bool Observe_Broadcast_Nominal()
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

	bool Observe_Execute_Nominal()
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

	bool Observe_ExecuteIfBound_Nominal()
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
}
/** @end */
