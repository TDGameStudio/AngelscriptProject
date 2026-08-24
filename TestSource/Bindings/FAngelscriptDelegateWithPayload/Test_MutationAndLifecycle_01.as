// Purpose: Observe ExecuteIfBound, BindUFunction, and BindWithPayload on a
// payload delegate, including unbound no-op and payload-clearing rebind.
// The bool return is the runner-readable oracle.
// AS-facing API: void FAngelscriptDelegateWithPayload.ExecuteIfBound() const;
// void FAngelscriptDelegateWithPayload.BindUFunction(UObject Object, const FName& FunctionName);
// void FAngelscriptDelegateWithPayload.BindWithPayload(UObject Object, const FName& FunctionName, const ?&in Payload);
// Inputs: Unbound ExecuteIfBound, BindUFunction n"OnNoPayload", BindWithPayload
// n"OnIntPayload" with copied int 41, then BindUFunction again to clear payload.
// Expected observations: Unbound ExecuteIfBound does not change bFlag or
// PayloadValue. Bound no-payload execute sets bFlag true. Payload execute
// writes 41. Rebinding with BindUFunction keeps IsBound true and the next
// ExecuteIfBound calls OnNoPayload rather than OnIntPayload.
// Boundary/ownership: Payload is copied into the delegate. BindUFunction
// clears any previous payload. Object is stored weakly; incompatible
// signatures raise and are outside this Positive file.

UCLASS()
class UTSDelegateWithPayloadMutationReceiver : UObject
{
	bool bFlag = false;
	int PayloadValue = 0;
	int NoPayloadCount = 0;

	UFUNCTION()
	void OnNoPayload()
	{
		bFlag = true;
		NoPayloadCount += 1;
	}

	UFUNCTION()
	void OnIntPayload(int Value)
	{
		PayloadValue = Value;
	}
}

namespace TS_FAngelscriptDelegateWithPayload_MutationAndLifecycle_01
{
	bool Observe_ExecuteIfBound_Nominal()
	{
		UTSDelegateWithPayloadMutationReceiver Receiver;
		if (Receiver is null)
		{
			throw("TS_FAngelscriptDelegateWithPayload_MutationAndLifecycle_01 setup: required Receiver is null");
		}
		Receiver.bFlag = false;
		Receiver.PayloadValue = 3;
		FAngelscriptDelegateWithPayload Unbound;
		Unbound.ExecuteIfBound();
		bool bUnboundIsNoOp = !Receiver.bFlag && Receiver.PayloadValue == 3;

		FAngelscriptDelegateWithPayload Bound;
		Bound.BindUFunction(Receiver, n"OnNoPayload");
		Bound.ExecuteIfBound();
		bool bBoundPathInvoked = Receiver.bFlag && Receiver.NoPayloadCount == 1;

		Bound.ExecuteIfBound();
		bool bRepeatedExecuteInvoked = Receiver.NoPayloadCount == 2;

		return bUnboundIsNoOp && bBoundPathInvoked && bRepeatedExecuteInvoked;
	}

	bool Observe_BindUFunction_Nominal()
	{
		UTSDelegateWithPayloadMutationReceiver Receiver;
		if (Receiver is null)
		{
			throw("TS_FAngelscriptDelegateWithPayload_MutationAndLifecycle_01 setup: required Receiver is null");
		}
		Receiver.bFlag = false;
		Receiver.PayloadValue = 9;
		FAngelscriptDelegateWithPayload Delegate;
		Delegate.BindUFunction(Receiver, n"OnNoPayload");
		bool bBoundAfterBind = Delegate.IsBound();
		Delegate.ExecuteIfBound();
		bool bNoPayloadInvoked = Receiver.bFlag && Receiver.PayloadValue == 9;

		Delegate.BindUFunction(Receiver, n"OnNoPayload");
		bool bRepeatedBindRemainsBound = Delegate.IsBound();

		return bBoundAfterBind && bNoPayloadInvoked && bRepeatedBindRemainsBound;
	}

	bool Observe_BindWithPayload_Nominal()
	{
		UTSDelegateWithPayloadMutationReceiver Receiver;
		if (Receiver is null)
		{
			throw("TS_FAngelscriptDelegateWithPayload_MutationAndLifecycle_01 setup: required Receiver is null");
		}
		Receiver.bFlag = false;
		Receiver.PayloadValue = 0;
		Receiver.NoPayloadCount = 0;
		FAngelscriptDelegateWithPayload Delegate;
		int Payload = 41;
		Delegate.BindWithPayload(Receiver, n"OnIntPayload", Payload);
		bool bBoundWithPayload = Delegate.IsBound();
		Delegate.ExecuteIfBound();
		bool bPayloadCopiedAndDelivered = Receiver.PayloadValue == 41 && Payload == 41;

		Delegate.BindWithPayload(Receiver, n"OnIntPayload", 7);
		Delegate.ExecuteIfBound();
		bool bRepeatedPayloadReplaced = Receiver.PayloadValue == 7;

		Delegate.BindUFunction(Receiver, n"OnNoPayload");
		int PayloadBeforeClearingBind = Receiver.PayloadValue;
		Delegate.ExecuteIfBound();
		bool bBindUFunctionClearedPayloadPath =
			Delegate.IsBound() &&
			Receiver.NoPayloadCount == 1 &&
			Receiver.PayloadValue == PayloadBeforeClearingBind;

		return bBoundWithPayload && bPayloadCopiedAndDelivered && bRepeatedPayloadReplaced && bBindUFunctionClearedPayloadPath;
	}
}
