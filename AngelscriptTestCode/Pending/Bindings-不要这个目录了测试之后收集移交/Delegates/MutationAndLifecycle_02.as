/**
 * @version v1
 * @summary Observe sparse add/unbind/broadcast and signature-erased bind/clear/add/unbind, including repeated calls and cleanup.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe sparse add/unbind/broadcast and signature-erased bind/clear/add/unbind, including repeated calls and cleanup.
 * @topic Baseline
 */
// Delegate.Unbind(UObject Object, const FName& FunctionName);
// Delegate.UnbindObject(UObject Object);
// Delegate.Broadcast(Arguments...);
// Delegate.Clear() const;
// Delegate.BindUFunction(UObject Object, const FName& FunctionName, UDelegateFunction Signature);
// Delegate.Clear();
// Delegate.AddUFunction(const UObject Object, const FName& FunctionName, UDelegateFunction Signature);
// Inputs: Sparse owner with OnBeginOverlap, Other actor for Broadcast,
// erased Signature from typed delegates, and n"OnNotify"/n"OnNotifyAlt".
// Expected observations: Sparse AddUFunction makes IsBound true. Broadcast
// increments OverlapCount. Unbind/UnbindObject and Clear leave storage empty.
// Erased BindUFunction/AddUFunction require Signature and then IsBound is true.
// Boundary/ownership: Sparse methods resolve the owner at the property. Do not
// copy a sparse delegate. Signature validates the target UFUNCTION; the erased
// delegate still only borrows Object.

delegate void FTSDelegatesErasedNotify(int Value);
event void FTSDelegatesErasedMulticast(int Value);

UCLASS()
class UTSDelegatesErasedReceiver : UObject
{
	int ReceivedValue = 0;
	int InvocationCount = 0;

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

class ATSDelegatesSparseMutationReceiver : AActor
{
	int OverlapCount = 0;

	UFUNCTION()
	void OnBeginOverlap(AActor OverlappedActor, AActor OtherActor)
	{
		OverlapCount += 1;
	}
}

namespace TS_Delegates_MutationAndLifecycle_02
{
	bool Observe_AddUFunction_Nominal()
	{
		ATSDelegatesSparseMutationReceiver SparseOwner;
		if (SparseOwner is null)
		{
			throw("TS_Delegates_MutationAndLifecycle_02 setup: required SparseOwner is null");
		}
		SparseOwner.OnActorBeginOverlap.AddUFunction(SparseOwner, n"OnBeginOverlap");
		bool bSparseAddBound = SparseOwner.OnActorBeginOverlap.IsBound();
		SparseOwner.OnActorBeginOverlap.AddUFunction(SparseOwner, n"OnBeginOverlap");
		bool bSparseRepeatedAddRemainsBound = SparseOwner.OnActorBeginOverlap.IsBound();

		UTSDelegatesErasedReceiver Receiver;
		if (Receiver is null)
		{
			throw("TS_Delegates_MutationAndLifecycle_02 setup: required Receiver is null");
		}
		FTSDelegatesErasedMulticast TypedMulti;
		UDelegateFunction Signature = __DelegateSignature(TypedMulti);
		_FMulticastScriptDelegate ErasedMulti;
		ErasedMulti.AddUFunction(Receiver, n"OnNotify", Signature);
		bool bErasedAddBound = ErasedMulti.IsBound();
		ErasedMulti.AddUFunction(Receiver, n"OnNotify", Signature);
		bool bErasedRepeatedAddRemainsBound = ErasedMulti.IsBound();

		return bSparseAddBound &&
			bSparseRepeatedAddRemainsBound &&
			bErasedAddBound &&
			bErasedRepeatedAddRemainsBound;
	}

	bool Observe_Unbind_Nominal()
	{
		ATSDelegatesSparseMutationReceiver SparseOwner;
		if (SparseOwner is null)
		{
			throw("TS_Delegates_MutationAndLifecycle_02 setup: required SparseOwner is null");
		}
		SparseOwner.OnActorBeginOverlap.AddUFunction(SparseOwner, n"OnBeginOverlap");
		SparseOwner.OnActorBeginOverlap.Unbind(SparseOwner, n"OnBeginOverlap");
		bool bSparseUnbindRemovedMatching = !SparseOwner.OnActorBeginOverlap.IsBound();

		UTSDelegatesErasedReceiver Receiver;
		if (Receiver is null)
		{
			throw("TS_Delegates_MutationAndLifecycle_02 setup: required Receiver is null");
		}
		FTSDelegatesErasedMulticast TypedMulti;
		UDelegateFunction Signature = __DelegateSignature(TypedMulti);
		_FMulticastScriptDelegate ErasedMulti;
		ErasedMulti.AddUFunction(Receiver, n"OnNotify", Signature);
		ErasedMulti.AddUFunction(Receiver, n"OnNotifyAlt", Signature);
		ErasedMulti.Unbind(Receiver, n"OnNotify");
		bool bErasedUnbindLeftRemaining = ErasedMulti.IsBound();
		ErasedMulti.Unbind(Receiver, n"OnNotifyAlt");
		bool bErasedUnbindRemovedLast = !ErasedMulti.IsBound();

		return bSparseUnbindRemovedMatching &&
			bErasedUnbindLeftRemaining &&
			bErasedUnbindRemovedLast;
	}

	bool Observe_UnbindObject_Nominal()
	{
		ATSDelegatesSparseMutationReceiver SparseOwner;
		if (SparseOwner is null)
		{
			throw("TS_Delegates_MutationAndLifecycle_02 setup: required SparseOwner is null");
		}
		SparseOwner.OnActorBeginOverlap.AddUFunction(SparseOwner, n"OnBeginOverlap");
		SparseOwner.OnActorBeginOverlap.UnbindObject(SparseOwner);
		bool bSparseUnbindObjectCleared = !SparseOwner.OnActorBeginOverlap.IsBound();

		UTSDelegatesErasedReceiver Receiver;
		if (Receiver is null)
		{
			throw("TS_Delegates_MutationAndLifecycle_02 setup: required Receiver is null");
		}
		FTSDelegatesErasedMulticast TypedMulti;
		UDelegateFunction Signature = __DelegateSignature(TypedMulti);
		_FMulticastScriptDelegate ErasedMulti;
		ErasedMulti.AddUFunction(Receiver, n"OnNotify", Signature);
		ErasedMulti.AddUFunction(Receiver, n"OnNotifyAlt", Signature);
		ErasedMulti.UnbindObject(Receiver);
		bool bErasedUnbindObjectCleared = !ErasedMulti.IsBound();

		return bSparseUnbindObjectCleared && bErasedUnbindObjectCleared;
	}

	bool Observe_Broadcast_Nominal()
	{
		ATSDelegatesSparseMutationReceiver SparseOwner;
		if (SparseOwner is null)
		{
			throw("TS_Delegates_MutationAndLifecycle_02 setup: required SparseOwner is null");
		}
		AActor Other;
		SparseOwner.OverlapCount = 0;
		SparseOwner.OnActorBeginOverlap.AddUFunction(SparseOwner, n"OnBeginOverlap");

		SparseOwner.OnActorBeginOverlap.Broadcast(SparseOwner, Other);
		bool bFirstSparseBroadcastDelivered = SparseOwner.OverlapCount == 1;

		SparseOwner.OnActorBeginOverlap.Broadcast(SparseOwner, Other);
		bool bRepeatedSparseBroadcastDelivered = SparseOwner.OverlapCount == 2;

		SparseOwner.OnActorBeginOverlap.Clear();
		int UnboundBefore = SparseOwner.OverlapCount;
		SparseOwner.OnActorBeginOverlap.Broadcast(SparseOwner, Other);
		int UnboundAfter = SparseOwner.OverlapCount;
		bool bUnboundSparseBroadcastIsNoOp = UnboundBefore == UnboundAfter;

		return bFirstSparseBroadcastDelivered &&
			bRepeatedSparseBroadcastDelivered &&
			bUnboundSparseBroadcastIsNoOp;
	}

	bool Observe_Clear_Nominal()
	{
		UTSDelegatesErasedReceiver Receiver;
		if (Receiver is null)
		{
			throw("TS_Delegates_MutationAndLifecycle_02 setup: required Receiver is null");
		}
		FTSDelegatesErasedNotify TypedSingle;
		UDelegateFunction SingleSignature = __DelegateSignature(TypedSingle);
		_FScriptDelegate ErasedSingle;
		ErasedSingle.BindUFunction(Receiver, n"OnNotify", SingleSignature);
		bool bErasedSingleBoundBeforeClear = ErasedSingle.IsBound();
		ErasedSingle.Clear();
		bool bErasedSingleCleared = !ErasedSingle.IsBound();

		FTSDelegatesErasedMulticast TypedMulti;
		UDelegateFunction MultiSignature = __DelegateSignature(TypedMulti);
		_FMulticastScriptDelegate ErasedMulti;
		ErasedMulti.AddUFunction(Receiver, n"OnNotify", MultiSignature);
		bool bErasedMultiBoundBeforeClear = ErasedMulti.IsBound();
		ErasedMulti.Clear();
		bool bErasedMultiCleared = !ErasedMulti.IsBound();

		return bErasedSingleBoundBeforeClear &&
			bErasedSingleCleared &&
			bErasedMultiBoundBeforeClear &&
			bErasedMultiCleared;
	}

	bool Observe_BindUFunction_Nominal()
	{
		UTSDelegatesErasedReceiver Receiver;
		if (Receiver is null)
		{
			throw("TS_Delegates_MutationAndLifecycle_02 setup: required Receiver is null");
		}
		FTSDelegatesErasedNotify TypedSingle;
		UDelegateFunction Signature = __DelegateSignature(TypedSingle);
		_FScriptDelegate Erased;
		Erased.BindUFunction(Receiver, n"OnNotify", Signature);
		UObject BoundObject = Erased.GetUObject();
		FName BoundName = Erased.GetFunctionName();
		bool bBindValidatedTarget =
			Erased.IsBound() &&
			BoundObject == Receiver &&
			BoundName.IsEqual(n"OnNotify");

		Erased.BindUFunction(Receiver, n"OnNotifyAlt", Signature);
		FName ReboundName = Erased.GetFunctionName();
		bool bRepeatedBindReplacedName = ReboundName.IsEqual(n"OnNotifyAlt");

		return bBindValidatedTarget && bRepeatedBindReplacedName;
	}
}
/** @end */
