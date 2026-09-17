/**
 * @version v1
 * @summary Delegates host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic Delegates
 *
 * delegate
 * Delegates-Behavior_02-delegate
 * delegate-signature
 * assignment
 * clear
 * bind-u-function
 * execute
 * execute-if-bound
 * add-u-function
 * unbind
 * unbind-object
 * broadcast
 * Delegates-MutationAndLifecycle_02-add-u-function
 * Delegates-MutationAndLifecycle_02-unbind
 * Delegates-MutationAndLifecycle_02-unbind-object
 * Delegates-MutationAndLifecycle_02-broadcast
 * Delegates-MutationAndLifecycle_02-clear
 * Delegates-MutationAndLifecycle_02-bind-u-function
 * is-bound
 * get-u-object
 * get-function-name
 */
/**
 * @begin delegate
 * @summary storage is owner-resolved and is not copied.
 * @topic Unreal
 */
/**
 * @function ObserveDelegateNominal
 * @summary storage is owner-resolved and is not copied.
 * @covers Delegates.delegate
 * @inputs Delegates values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveDelegateNominal()
{
	UTSDelegatesBehaviorReceiver Receiver;
	if (Receiver is null)
	{
		throw("TS_Delegates_Behavior_01 setup: required Receiver is null");
	}
	ATSDelegatesBehaviorSparseReceiver SparseOwner;
	if (SparseOwner is null)
	{
		throw("TS_Delegates_Behavior_01 setup: required SparseOwner is null");
	}

	FTSDelegatesBehaviorCompute EmptySingle;
	bool bEmptySingleUnbound = !EmptySingle.IsBound();

	FTSDelegatesBehaviorCompute BoundSingle;
	BoundSingle.BindUFunction(Receiver, n"OnCompute");
	FTSDelegatesBehaviorCompute CopiedSingle(BoundSingle);
	UObject CopiedSingleObject = CopiedSingle.GetUObject();
	bool bCopiedSingleBinding =
		CopiedSingle.IsBound() &&
		CopiedSingleObject == Receiver &&
		CopiedSingle.GetFunctionName().IsEqual(n"OnCompute");
	BoundSingle.Clear();
	bool bCopiedSingleIndependent = CopiedSingle.IsBound() && !BoundSingle.IsBound();
	int CopiedResult = CopiedSingle.Execute(21);
	bool bCopiedSingleDispatches = CopiedResult == 42;

	FTSDelegatesBehaviorCompute ConstructedSingle(Receiver, n"OnCompute");
	UObject ConstructedObject = ConstructedSingle.GetUObject();
	bool bConstructedSingleBound =
		ConstructedSingle.IsBound() &&
		ConstructedObject == Receiver &&
		ConstructedSingle.GetFunctionName().IsEqual(n"OnCompute");

	FTSDelegatesBehaviorNotify EmptyMulti;
	bool bEmptyMultiUnbound = !EmptyMulti.IsBound();

	FTSDelegatesBehaviorNotify BoundMulti;
	BoundMulti.AddUFunction(Receiver, n"OnNotify");
	FTSDelegatesBehaviorNotify CopiedMulti(BoundMulti);
	bool bCopiedMultiBinding = CopiedMulti.IsBound();
	BoundMulti.Clear();
	bool bCopiedMultiIndependent = CopiedMulti.IsBound() && !BoundMulti.IsBound();

	bool bEmptySparseUnbound = !SparseOwner.OnActorBeginOverlap.IsBound();

	_FScriptDelegate EmptyErasedSingle;
	bool bEmptyErasedSingleUnbound = !EmptyErasedSingle.IsBound();

	UDelegateFunction Signature = __DelegateSignature(EmptySingle);
	_FScriptDelegate BoundErasedSingle;
	BoundErasedSingle.BindUFunction(Receiver, n"OnCompute", Signature);
	_FScriptDelegate CopiedErasedSingle(BoundErasedSingle);
	UObject CopiedErasedObject = CopiedErasedSingle.GetUObject();
	bool bCopiedErasedSingleBinding =
		CopiedErasedSingle.IsBound() &&
		CopiedErasedObject == Receiver &&
		CopiedErasedSingle.GetFunctionName().IsEqual(n"OnCompute");
	BoundErasedSingle.Clear();
	bool bCopiedErasedSingleIndependent = CopiedErasedSingle.IsBound() && !BoundErasedSingle.IsBound();

	_FScriptDelegate ConstructedErasedSingle(Receiver, n"OnCompute", Signature);
	UObject ConstructedErasedObject = ConstructedErasedSingle.GetUObject();
	bool bConstructedErasedSingleBound =
		ConstructedErasedSingle.IsBound() &&
		ConstructedErasedObject == Receiver &&
		ConstructedErasedSingle.GetFunctionName().IsEqual(n"OnCompute");

	_FMulticastScriptDelegate EmptyErasedMulti;
	bool bEmptyErasedMultiUnbound = !EmptyErasedMulti.IsBound();

	return bEmptySingleUnbound &&
		bCopiedSingleBinding &&
		bCopiedSingleIndependent &&
		bCopiedSingleDispatches &&
		bConstructedSingleBound &&
		bEmptyMultiUnbound &&
		bCopiedMultiBinding &&
		bCopiedMultiIndependent &&
		bEmptySparseUnbound &&
		bEmptyErasedSingleUnbound &&
		bCopiedErasedSingleBinding &&
		bCopiedErasedSingleIndependent &&
		bConstructedErasedSingleBound &&
		bEmptyErasedMultiUnbound;
}
/** @end */
/**
 * @begin Delegates-Behavior_02-delegate
 * @summary not bind or execute the value.
 * @topic Unreal
 */
/**
 * @function ObserveDelegateNominal
 * @summary not bind or execute the value.
 * @covers Delegates.delegate
 * @inputs Delegates values exercised by this observe
 * @return true when the observe comparison holds
 */
delegate

bool ObserveDelegateNominal()
{
	_FMulticastScriptDelegate Empty;
	_FMulticastScriptDelegate CopiedEmpty(Empty);
	bool bCopiedEmptyUnbound = !CopiedEmpty.IsBound();

	UTSDelegatesSignatureReceiver Receiver;
	if (Receiver is null)
	{
		throw("TS_Delegates_Behavior_02 setup: required Receiver is null");
	}
	FTSDelegatesSignatureMulticast TypedMulti;
	UDelegateFunction Signature = __DelegateSignature(TypedMulti);
	if (Signature is null)
	{
		throw("TS_Delegates_Behavior_02 setup: required Signature is null");
	}
	_FMulticastScriptDelegate Bound;
	Bound.AddUFunction(Receiver, n"OnNotify", Signature);
	_FMulticastScriptDelegate CopiedBound(Bound);
	bool bCopiedBound = CopiedBound.IsBound();
	Bound.Clear();
	bool bCopiedListIndependent = CopiedBound.IsBound() && !Bound.IsBound();

	return bCopiedEmptyUnbound && bCopiedBound && bCopiedListIndependent;
}
/** @end */
/**
 * @begin delegate-signature
 * @summary not bind or execute the value.
 * @topic Unreal
 */
/**
 * @function ObserveDelegateSignatureNominal
 * @summary not bind or execute the value.
 * @covers Delegates.delegate-signature
 * @inputs Delegates values exercised by this observe
 * @return true when the observe comparison holds
 */
delegate

bool ObserveDelegateSignatureNominal()
{
	FTSDelegatesSignatureNotify TypedSingle;
	UDelegateFunction SingleSignature = __DelegateSignature(TypedSingle);
	UDelegateFunction SingleSignatureAgain = __DelegateSignature(TypedSingle);
	bool bSingleSignatureLive = SingleSignature != nullptr;
	bool bSingleSignatureIdentity = SingleSignature == SingleSignatureAgain;

	FTSDelegatesSignatureMulticast TypedMulti;
	UDelegateFunction MultiSignature = __DelegateSignature(TypedMulti);
	UDelegateFunction MultiSignatureAgain = __DelegateSignature(TypedMulti);
	bool bMultiSignatureLive = MultiSignature != nullptr;
	bool bMultiSignatureIdentity = MultiSignature == MultiSignatureAgain;

	return bSingleSignatureLive &&
		bSingleSignatureIdentity &&
		bMultiSignatureLive &&
		bMultiSignatureIdentity;
}
/** @end */
/**
 * @begin assignment
 * @summary assignable.
 * @topic Unreal
 */
/**
 * @function ObserveAssignmentNominal
 * @summary assignable.
 * @covers Delegates.assignment
 * @inputs Delegates values exercised by this observe
 * @return true when the observe comparison holds
 */
delegate

bool ObserveAssignmentNominal()
{
	UTSDelegatesAssignmentReceiver Receiver;
	if (Receiver is null)
	{
		throw("TS_Delegates_ConstructionAndAssignment_01 setup: required Receiver is null");
	}
	Receiver.ReceivedValue = 0;

	FTSDelegatesAssignmentCompute EmptySingle;
	FTSDelegatesAssignmentCompute AssignedSingle = EmptySingle;
	bool bUnboundSingleCopyRemainsUnbound = !AssignedSingle.IsBound();

	FTSDelegatesAssignmentCompute BoundSingle;
	BoundSingle.BindUFunction(Receiver, n"OnCompute");
	AssignedSingle = BoundSingle;
	UObject CopiedSingleObject = AssignedSingle.GetUObject();
	FName CopiedSingleName = AssignedSingle.GetFunctionName();
	bool bAssignedSingleCopiedBinding =
		AssignedSingle.IsBound() &&
		CopiedSingleObject == Receiver &&
		CopiedSingleName.IsEqual(n"OnCompute");
	BoundSingle.Clear();
	bool bSingleCopyIndependentOfSource = AssignedSingle.IsBound() && !BoundSingle.IsBound();
	int CopiedSingleResult = AssignedSingle.Execute(21);
	bool bCopiedSingleStillDispatches = CopiedSingleResult == 42 && Receiver.ReceivedValue == 21;

	FTSDelegatesAssignmentNotify EmptyMulti;
	FTSDelegatesAssignmentNotify AssignedMulti = EmptyMulti;
	bool bUnboundMultiCopyRemainsUnbound = !AssignedMulti.IsBound();

	FTSDelegatesAssignmentNotify BoundMulti;
	BoundMulti.AddUFunction(Receiver, n"OnNotify");
	AssignedMulti = BoundMulti;
	bool bAssignedMultiCopiedList = AssignedMulti.IsBound();
	BoundMulti.Clear();
	bool bMultiCopyIndependentOfSource = AssignedMulti.IsBound() && !BoundMulti.IsBound();
	AssignedMulti.Broadcast(7);
	bool bCopiedMultiStillDispatches = Receiver.ReceivedValue == 7;

	UDelegateFunction SingleSignature = __DelegateSignature(EmptySingle);
	UDelegateFunction MultiSignature = __DelegateSignature(EmptyMulti);

	_FScriptDelegate EmptyErasedSingle;
	_FScriptDelegate AssignedErasedSingle = EmptyErasedSingle;
	bool bUnboundErasedSingleRemainsUnbound = !AssignedErasedSingle.IsBound();

	_FScriptDelegate BoundErasedSingle;
	BoundErasedSingle.BindUFunction(Receiver, n"OnCompute", SingleSignature);
	AssignedErasedSingle = BoundErasedSingle;
	UObject CopiedErasedObject = AssignedErasedSingle.GetUObject();
	FName CopiedErasedName = AssignedErasedSingle.GetFunctionName();
	bool bAssignedErasedSingleCopiedBinding =
		AssignedErasedSingle.IsBound() &&
		CopiedErasedObject == Receiver &&
		CopiedErasedName.IsEqual(n"OnCompute");
	BoundErasedSingle.Clear();
	bool bErasedSingleCopyIndependent = AssignedErasedSingle.IsBound() && !BoundErasedSingle.IsBound();

	_FMulticastScriptDelegate EmptyErasedMulti;
	_FMulticastScriptDelegate AssignedErasedMulti = EmptyErasedMulti;
	bool bUnboundErasedMultiRemainsUnbound = !AssignedErasedMulti.IsBound();

	_FMulticastScriptDelegate BoundErasedMulti;
	BoundErasedMulti.AddUFunction(Receiver, n"OnNotify", MultiSignature);
	AssignedErasedMulti = BoundErasedMulti;
	bool bAssignedErasedMultiCopiedList = AssignedErasedMulti.IsBound();
	BoundErasedMulti.Clear();
	bool bErasedMultiCopyIndependent = AssignedErasedMulti.IsBound() && !BoundErasedMulti.IsBound();

	return bUnboundSingleCopyRemainsUnbound &&
		bAssignedSingleCopiedBinding &&
		bSingleCopyIndependentOfSource &&
		bCopiedSingleStillDispatches &&
		bUnboundMultiCopyRemainsUnbound &&
		bAssignedMultiCopiedList &&
		bMultiCopyIndependentOfSource &&
		bCopiedMultiStillDispatches &&
		bUnboundErasedSingleRemainsUnbound &&
		bAssignedErasedSingleCopiedBinding &&
		bErasedSingleCopyIndependent &&
		bUnboundErasedMultiRemainsUnbound &&
		bAssignedErasedMultiCopiedList &&
		bErasedMultiCopyIndependent;
}
/** @end */
/**
 * @begin clear
 * @summary is a no-op.
 * @topic Unreal
 */
/**
 * @function ObserveClearNominal
 * @summary is a no-op.
 * @covers Delegates.clear
 * @inputs Delegates values exercised by this observe
 * @return true when the observe comparison holds
 */
// returns 62

bool ObserveClearNominal()
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
/** @end */
/**
 * @begin bind-u-function
 * @summary is a no-op.
 * @topic Unreal
 */
/**
 * @function ObserveBindUFunctionNominal
 * @summary is a no-op.
 * @covers Delegates.bind-u-function
 * @inputs Delegates values exercised by this observe
 * @return true when the observe comparison holds
 */
// returns 62

bool ObserveBindUFunctionNominal()
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
/** @end */
/**
 * @begin execute
 * @summary is a no-op.
 * @topic Unreal
 */
/**
 * @function ObserveExecuteNominal
 * @summary is a no-op.
 * @covers Delegates.execute
 * @inputs Delegates values exercised by this observe
 * @return true when the observe comparison holds
 */
// returns 62

bool ObserveExecuteNominal()
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
/** @end */
/**
 * @begin execute-if-bound
 * @summary is a no-op.
 * @topic Unreal
 */
/**
 * @function ObserveExecuteIfBoundNominal
 * @summary is a no-op.
 * @covers Delegates.execute-if-bound
 * @inputs Delegates values exercised by this observe
 * @return true when the observe comparison holds
 */
// returns 62

bool ObserveExecuteIfBoundNominal()
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
/** @end */
/**
 * @begin add-u-function
 * @summary is a no-op.
 * @topic Unreal
 */
/**
 * @function ObserveAddUFunctionNominal
 * @summary is a no-op.
 * @covers Delegates.add-u-function
 * @inputs Delegates values exercised by this observe
 * @return true when the observe comparison holds
 */
// returns 62

bool ObserveAddUFunctionNominal()
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
/** @end */
/**
 * @begin unbind
 * @summary is a no-op.
 * @topic Unreal
 */
/**
 * @function ObserveUnbindNominal
 * @summary is a no-op.
 * @covers Delegates.unbind
 * @inputs Delegates values exercised by this observe
 * @return true when the observe comparison holds
 */
// returns 62

bool ObserveUnbindNominal()
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
/** @end */
/**
 * @begin unbind-object
 * @summary is a no-op.
 * @topic Unreal
 */
/**
 * @function ObserveUnbindObjectNominal
 * @summary is a no-op.
 * @covers Delegates.unbind-object
 * @inputs Delegates values exercised by this observe
 * @return true when the observe comparison holds
 */
// returns 62

bool ObserveUnbindObjectNominal()
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
/** @end */
/**
 * @begin broadcast
 * @summary is a no-op.
 * @topic Unreal
 */
/**
 * @function ObserveBroadcastNominal
 * @summary is a no-op.
 * @covers Delegates.broadcast
 * @inputs Delegates values exercised by this observe
 * @return true when the observe comparison holds
 */
// returns 62

bool ObserveBroadcastNominal()
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
/** @end */
/**
 * @begin Delegates-MutationAndLifecycle_02-add-u-function
 * @summary delegate still only borrows Object.
 * @topic Unreal
 */
/**
 * @function ObserveAddUFunctionNominal
 * @summary delegate still only borrows Object.
 * @covers Delegates.add-u-function
 * @inputs Delegates values exercised by this observe
 * @return true when the observe comparison holds
 */
delegate

bool ObserveAddUFunctionNominal()
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
/** @end */
/**
 * @begin Delegates-MutationAndLifecycle_02-unbind
 * @summary delegate still only borrows Object.
 * @topic Unreal
 */
/**
 * @function ObserveUnbindNominal
 * @summary delegate still only borrows Object.
 * @covers Delegates.unbind
 * @inputs Delegates values exercised by this observe
 * @return true when the observe comparison holds
 */
delegate

bool ObserveUnbindNominal()
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
/** @end */
/**
 * @begin Delegates-MutationAndLifecycle_02-unbind-object
 * @summary delegate still only borrows Object.
 * @topic Unreal
 */
/**
 * @function ObserveUnbindObjectNominal
 * @summary delegate still only borrows Object.
 * @covers Delegates.unbind-object
 * @inputs Delegates values exercised by this observe
 * @return true when the observe comparison holds
 */
delegate

bool ObserveUnbindObjectNominal()
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
/** @end */
/**
 * @begin Delegates-MutationAndLifecycle_02-broadcast
 * @summary delegate still only borrows Object.
 * @topic Unreal
 */
/**
 * @function ObserveBroadcastNominal
 * @summary delegate still only borrows Object.
 * @covers Delegates.broadcast
 * @inputs Delegates values exercised by this observe
 * @return true when the observe comparison holds
 */
delegate

bool ObserveBroadcastNominal()
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
/** @end */
/**
 * @begin Delegates-MutationAndLifecycle_02-clear
 * @summary delegate still only borrows Object.
 * @topic Unreal
 */
/**
 * @function ObserveClearNominal
 * @summary delegate still only borrows Object.
 * @covers Delegates.clear
 * @inputs Delegates values exercised by this observe
 * @return true when the observe comparison holds
 */
delegate

bool ObserveClearNominal()
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
/** @end */
/**
 * @begin Delegates-MutationAndLifecycle_02-bind-u-function
 * @summary delegate still only borrows Object.
 * @topic Unreal
 */
/**
 * @function ObserveBindUFunctionNominal
 * @summary delegate still only borrows Object.
 * @covers Delegates.bind-u-function
 * @inputs Delegates values exercised by this observe
 * @return true when the observe comparison holds
 */
delegate

bool ObserveBindUFunctionNominal()
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
/** @end */
/**
 * @begin is-bound
 * @summary the target UObject alive.
 * @topic Unreal
 */
/**
 * @function ObserveIsBoundNominal
 * @summary the target UObject alive.
 * @covers Delegates.is-bound
 * @inputs Delegates values exercised by this observe
 * @return true when the observe comparison holds
 */
delegate

bool ObserveIsBoundNominal()
{
	UTSDelegatesQueryReceiver Receiver;
	if (Receiver is null)
	{
		throw("TS_Delegates_Queries_01 setup: required Receiver is null");
	}
	FTSDelegatesQueryCompute Single;
	bool bEmptySingleUnbound = Single.IsBound();
	Single.BindUFunction(Receiver, n"OnCompute");
	bool bBoundSingle = Single.IsBound();

	FTSDelegatesQueryNotify Multi;
	bool bEmptyMultiUnbound = Multi.IsBound();
	Multi.AddUFunction(Receiver, n"OnNotify");
	bool bBoundMulti = Multi.IsBound();

	ATSDelegatesQuerySparseReceiver SparseOwner;
	if (SparseOwner is null)
	{
		throw("TS_Delegates_Queries_01 setup: required SparseOwner is null");
	}
	bool bEmptySparseUnbound = SparseOwner.OnActorBeginOverlap.IsBound();
	SparseOwner.OnActorBeginOverlap.AddUFunction(SparseOwner, n"OnBeginOverlap");
	bool bBoundSparse = SparseOwner.OnActorBeginOverlap.IsBound();

	UDelegateFunction SingleSignature = __DelegateSignature(Single);
	UDelegateFunction MultiSignature = __DelegateSignature(Multi);

	_FScriptDelegate ErasedSingle;
	bool bEmptyErasedSingleUnbound = ErasedSingle.IsBound();
	ErasedSingle.BindUFunction(Receiver, n"OnCompute", SingleSignature);
	bool bBoundErasedSingle = ErasedSingle.IsBound();

	_FMulticastScriptDelegate ErasedMulti;
	bool bEmptyErasedMultiUnbound = ErasedMulti.IsBound();
	ErasedMulti.AddUFunction(Receiver, n"OnNotify", MultiSignature);
	bool bBoundErasedMulti = ErasedMulti.IsBound();

	return !bEmptySingleUnbound &&
		bBoundSingle &&
		!bEmptyMultiUnbound &&
		bBoundMulti &&
		!bEmptySparseUnbound &&
		bBoundSparse &&
		!bEmptyErasedSingleUnbound &&
		bBoundErasedSingle &&
		!bEmptyErasedMultiUnbound &&
		bBoundErasedMulti;
}
/** @end */
/**
 * @begin get-u-object
 * @summary the target UObject alive.
 * @topic Unreal
 */
/**
 * @function ObserveGetUObjectNominal
 * @summary the target UObject alive.
 * @covers Delegates.get-u-object
 * @inputs Delegates values exercised by this observe
 * @return true when the observe comparison holds
 */
delegate

bool ObserveGetUObjectNominal()
{
	UTSDelegatesQueryReceiver Receiver;
	if (Receiver is null)
	{
		throw("TS_Delegates_Queries_01 setup: required Receiver is null");
	}
	FTSDelegatesQueryCompute Single;
	UObject EmptySingleObject = Single.GetUObject();
	bool bEmptySingleIsNull = EmptySingleObject is null;

	Single.BindUFunction(Receiver, n"OnCompute");
	UObject BoundSingleObject = Single.GetUObject();
	bool bBoundSingleIdentity = BoundSingleObject == Receiver;

	UDelegateFunction Signature = __DelegateSignature(Single);
	_FScriptDelegate Erased;
	UObject EmptyErasedObject = Erased.GetUObject();
	bool bEmptyErasedIsNull = EmptyErasedObject is null;

	Erased.BindUFunction(Receiver, n"OnCompute", Signature);
	UObject BoundErasedObject = Erased.GetUObject();
	bool bBoundErasedIdentity = BoundErasedObject == Receiver;

	return bEmptySingleIsNull &&
		bBoundSingleIdentity &&
		bEmptyErasedIsNull &&
		bBoundErasedIdentity;
}
/** @end */
/**
 * @begin get-function-name
 * @summary the target UObject alive.
 * @topic Unreal
 */
/**
 * @function ObserveGetFunctionNameNominal
 * @summary the target UObject alive.
 * @covers Delegates.get-function-name
 * @inputs Delegates values exercised by this observe
 * @return true when the observe comparison holds
 */
delegate

bool ObserveGetFunctionNameNominal()
{
	UTSDelegatesQueryReceiver Receiver;
	if (Receiver is null)
	{
		throw("TS_Delegates_Queries_01 setup: required Receiver is null");
	}
	FTSDelegatesQueryCompute Single;
	FName EmptySingleName = Single.GetFunctionName();
	bool bEmptySingleIsNone = EmptySingleName.IsNone();

	Single.BindUFunction(Receiver, n"OnCompute");
	FName BoundSingleName = Single.GetFunctionName();
	bool bBoundSingleNameMatches = BoundSingleName.IsEqual(n"OnCompute");

	UDelegateFunction Signature = __DelegateSignature(Single);
	_FScriptDelegate Erased;
	FName EmptyErasedName = Erased.GetFunctionName();
	bool bEmptyErasedIsNone = EmptyErasedName.IsNone();

	Erased.BindUFunction(Receiver, n"OnCompute", Signature);
	FName BoundErasedName = Erased.GetFunctionName();
	bool bBoundErasedNameMatches = BoundErasedName.IsEqual(n"OnCompute");

	return bEmptySingleIsNone &&
		bBoundSingleNameMatches &&
		bEmptyErasedIsNone &&
		bBoundErasedNameMatches;
}
/** @end */
