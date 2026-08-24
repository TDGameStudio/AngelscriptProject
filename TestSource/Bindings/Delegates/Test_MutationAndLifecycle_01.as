// Purpose: Observe typed single-cast bind/clear/execute, multicast
// add/unbind/broadcast, and sparse Clear from seeded receivers.
// AS-facing API: Delegate.Clear();
// Delegate.BindUFunction(UObject Object, const FName& FunctionName);
// ReturnType Result = Delegate.Execute(Arguments...);
// ReturnType Result = Delegate.ExecuteIfBound(Arguments...);
// Delegate.AddUFunction(const UObject Object, const FName& FunctionName);
// Delegate.Unbind(UObject Object, const FName& FunctionName);
// Delegate.UnbindObject(UObject Object);
// Delegate.Broadcast(Arguments...);
// Inputs: Receiver with OnCompute/OnNotify/OnNotifyAlt/OnBeginOverlap,
// Execute arguments 41 then 7, unbound ExecuteIfBound argument 99, and
// sparse Clear after AddUFunction.
// Expected observations: BindUFunction makes IsBound true. Execute(41)
// returns 62 and Execute(7) returns 28. ExecuteIfBound on unbound leaves
// state unchanged. Multicast Broadcast delivers 41 then 7. Unbind removes
// one matching binding; UnbindObject removes every binding for the object.
// Sparse Clear leaves OnActorBeginOverlap unbound.
// Boundary/ownership: Unbound Execute raises; that path is not in this
// Positive file. ExecuteIfBound on unbound is a no-op. Broadcast on unbound
// is a no-op. Bindings borrow the UObject; Clear does not destroy it.

delegate int FTSDelegatesMutationCompute(int Value);
event void FTSDelegatesMutationNotify(int Value);

UCLASS()
class UTSDelegatesMutationReceiver : UObject
{
	int ReceivedValue = 0;
	int InvocationCount = 0;

	UFUNCTION()
	int OnCompute(int Value)
	{
		ReceivedValue = Value;
		InvocationCount += 1;
		return Value + 21;
	}

	UFUNCTION()
	void OnNotify(int Value)
	{
		ReceivedValue = Value;
		InvocationCount += 1;
	}

	UFUNCTION()
	void OnNotifyAlt(int Value)
	{
		ReceivedValue = Value;
		InvocationCount += 1;
	}
}

class ATSDelegatesMutationSparseReceiver : AActor
{
	int OverlapCount = 0;

	UFUNCTION()
	void OnBeginOverlap(AActor OverlappedActor, AActor OtherActor)
	{
		OverlapCount += 1;
	}
}

namespace TS_Delegates_MutationAndLifecycle_01
{
	bool Observe_Clear_Nominal()
	{
		UTSDelegatesMutationReceiver Receiver;
		if (Receiver is null)
		{
			throw("TS_Delegates_MutationAndLifecycle_01 setup: required Receiver is null");
		}
		FTSDelegatesMutationCompute Single;
		Single.BindUFunction(Receiver, n"OnCompute");
		bool bSingleBoundBeforeClear = Single.IsBound();
		Single.Clear();
		bool bSingleUnboundAfterClear = !Single.IsBound();

		FTSDelegatesMutationNotify Multi;
		Multi.AddUFunction(Receiver, n"OnNotify");
		bool bMultiBoundBeforeClear = Multi.IsBound();
		Multi.Clear();
		bool bMultiUnboundAfterClear = !Multi.IsBound();

		ATSDelegatesMutationSparseReceiver SparseOwner;
		if (SparseOwner is null)
		{
			throw("TS_Delegates_MutationAndLifecycle_01 setup: required SparseOwner is null");
		}
		SparseOwner.OnActorBeginOverlap.AddUFunction(SparseOwner, n"OnBeginOverlap");
		bool bSparseBoundBeforeClear = SparseOwner.OnActorBeginOverlap.IsBound();
		SparseOwner.OnActorBeginOverlap.Clear();
		bool bSparseUnboundAfterClear = !SparseOwner.OnActorBeginOverlap.IsBound();

		return bSingleBoundBeforeClear &&
			bSingleUnboundAfterClear &&
			bMultiBoundBeforeClear &&
			bMultiUnboundAfterClear &&
			bSparseBoundBeforeClear &&
			bSparseUnboundAfterClear;
	}

	bool Observe_BindUFunction_Nominal()
	{
		UTSDelegatesMutationReceiver Receiver;
		if (Receiver is null)
		{
			throw("TS_Delegates_MutationAndLifecycle_01 setup: required Receiver is null");
		}
		FTSDelegatesMutationCompute Single;
		Single.BindUFunction(Receiver, n"OnCompute");
		UObject BoundObject = Single.GetUObject();
		FName BoundName = Single.GetFunctionName();
		bool bFirstBindTook =
			Single.IsBound() &&
			BoundObject == Receiver &&
			BoundName.IsEqual(n"OnCompute");

		Single.BindUFunction(Receiver, n"OnCompute");
		bool bRepeatedBindRemainsBound = Single.IsBound();

		return bFirstBindTook && bRepeatedBindRemainsBound;
	}

	bool Observe_Execute_Nominal()
	{
		UTSDelegatesMutationReceiver Receiver;
		if (Receiver is null)
		{
			throw("TS_Delegates_MutationAndLifecycle_01 setup: required Receiver is null");
		}
		Receiver.ReceivedValue = 0;
		FTSDelegatesMutationCompute Bound;
		Bound.BindUFunction(Receiver, n"OnCompute");

		int FirstResult = Bound.Execute(41);
		bool bFirstExecuteDelivered = FirstResult == 62 && Receiver.ReceivedValue == 41;

		int SecondResult = Bound.Execute(7);
		bool bRepeatedExecuteDelivered = SecondResult == 28 && Receiver.ReceivedValue == 7;

		return bFirstExecuteDelivered && bRepeatedExecuteDelivered;
	}

	bool Observe_ExecuteIfBound_Nominal()
	{
		UTSDelegatesMutationReceiver Receiver;
		if (Receiver is null)
		{
			throw("TS_Delegates_MutationAndLifecycle_01 setup: required Receiver is null");
		}
		Receiver.ReceivedValue = 3;
		FTSDelegatesMutationCompute Bound;
		Bound.BindUFunction(Receiver, n"OnCompute");

		int BoundResult = Bound.ExecuteIfBound(41);
		bool bBoundPathInvoked = BoundResult == 62 && Receiver.ReceivedValue == 41;

		FTSDelegatesMutationCompute Unbound;
		int UnboundBefore = Receiver.ReceivedValue;
		int UnboundResult = Unbound.ExecuteIfBound(99);
		int UnboundAfter = Receiver.ReceivedValue;
		bool bUnboundPathIsNoOp = UnboundResult == 0 && UnboundBefore == UnboundAfter;

		return bBoundPathInvoked && bUnboundPathIsNoOp;
	}

	bool Observe_AddUFunction_Nominal()
	{
		UTSDelegatesMutationReceiver Receiver;
		if (Receiver is null)
		{
			throw("TS_Delegates_MutationAndLifecycle_01 setup: required Receiver is null");
		}
		Receiver.ReceivedValue = 0;
		Receiver.InvocationCount = 0;
		FTSDelegatesMutationNotify Multi;
		Multi.AddUFunction(Receiver, n"OnNotify");
		bool bFirstAddBound = Multi.IsBound();

		Multi.AddUFunction(Receiver, n"OnNotify");
		Multi.Broadcast(41);
		bool bUniqueAddDidNotDuplicate = Receiver.InvocationCount == 1 && Receiver.ReceivedValue == 41;

		return bFirstAddBound && bUniqueAddDidNotDuplicate;
	}

	bool Observe_Unbind_Nominal()
	{
		UTSDelegatesMutationReceiver Receiver;
		if (Receiver is null)
		{
			throw("TS_Delegates_MutationAndLifecycle_01 setup: required Receiver is null");
		}
		Receiver.InvocationCount = 0;
		FTSDelegatesMutationNotify Multi;
		Multi.AddUFunction(Receiver, n"OnNotify");
		Multi.AddUFunction(Receiver, n"OnNotifyAlt");
		bool bBothBound = Multi.IsBound();

		Multi.Unbind(Receiver, n"OnNotify");
		Multi.Broadcast(7);
		bool bMatchingBindingRemoved = Multi.IsBound() && Receiver.ReceivedValue == 7;

		Multi.Unbind(Receiver, n"OnNotifyAlt");
		bool bLastMatchingBindingRemoved = !Multi.IsBound();

		return bBothBound && bMatchingBindingRemoved && bLastMatchingBindingRemoved;
	}

	bool Observe_UnbindObject_Nominal()
	{
		UTSDelegatesMutationReceiver Receiver;
		if (Receiver is null)
		{
			throw("TS_Delegates_MutationAndLifecycle_01 setup: required Receiver is null");
		}
		FTSDelegatesMutationNotify Multi;
		Multi.AddUFunction(Receiver, n"OnNotify");
		Multi.AddUFunction(Receiver, n"OnNotifyAlt");
		bool bBoundBefore = Multi.IsBound();

		Multi.UnbindObject(Receiver);
		bool bAllObjectBindingsRemoved = !Multi.IsBound();

		return bBoundBefore && bAllObjectBindingsRemoved;
	}

	bool Observe_Broadcast_Nominal()
	{
		UTSDelegatesMutationReceiver Receiver;
		if (Receiver is null)
		{
			throw("TS_Delegates_MutationAndLifecycle_01 setup: required Receiver is null");
		}
		Receiver.ReceivedValue = -1;
		Receiver.InvocationCount = 0;
		FTSDelegatesMutationNotify Multi;
		Multi.AddUFunction(Receiver, n"OnNotify");

		Multi.Broadcast(41);
		bool bFirstDelivered = Receiver.ReceivedValue == 41 && Receiver.InvocationCount == 1;

		Multi.Broadcast(7);
		bool bRepeatedCallUpdated = Receiver.ReceivedValue == 7 && Receiver.InvocationCount == 2;

		Multi.Clear();
		int UnboundBefore = Receiver.ReceivedValue;
		Multi.Broadcast(99);
		int UnboundAfter = Receiver.ReceivedValue;
		bool bUnboundBroadcastIsNoOp = UnboundBefore == UnboundAfter;

		return bFirstDelivered && bRepeatedCallUpdated && bUnboundBroadcastIsNoOp;
	}
}
