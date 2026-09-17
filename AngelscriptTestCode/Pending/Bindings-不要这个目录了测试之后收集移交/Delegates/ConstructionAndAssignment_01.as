/**
 * @version v1
 * @summary Observe assignment of typed single-cast, typed multicast, and signature-erased single-cast/multicast bindings, including copy independence.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe assignment of typed single-cast, typed multicast, and signature-erased single-cast/multicast bindings, including copy independence.
 * @topic Baseline
 */
// assignment into an empty receiver, then Clear on the source after copying.
// Expected observations: Unbound assignment leaves IsBound false. Bound
// assignment copies the live target. Clearing the source leaves the assigned
// copy bound to the same UObject and function name.
// Boundary/ownership: Assignment copies the binding or invocation list. It
// does not take ownership of the target UObject. Sparse delegates are not
// assignable.

delegate int FTSDelegatesAssignmentCompute(int Value);
event void FTSDelegatesAssignmentNotify(int Value);

UCLASS()
class UTSDelegatesAssignmentReceiver : UObject
{
	int ReceivedValue = 0;

	UFUNCTION()
	int OnCompute(int Value)
	{
		ReceivedValue = Value;
		return Value + 21;
	}

	UFUNCTION()
	void OnNotify(int Value)
	{
		ReceivedValue = Value;
	}
}

namespace TS_Delegates_ConstructionAndAssignment_01
{
	bool Observe_Assignment_Nominal()
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
}
/** @end */
