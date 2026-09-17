/**
 * @version v1
 * @summary Observe signature-erased multicast copy construction and __DelegateSignature lookup for typed single-cast and multicast values.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe signature-erased multicast copy construction and __DelegateSignature lookup for typed single-cast and multicast values.
 * @topic Baseline
 */
// UDelegateFunction Signature = __DelegateSignature(?& Delegate);
// Inputs: An empty erased multicast, a bound erased multicast targeting
// OnNotify, and unbound typed single-cast/multicast values used only as
// signature carriers.
// Expected observations: Copy-constructing an unbound erased multicast stays
// unbound. Copying a bound list keeps IsBound true after Other.Clear().
// __DelegateSignature returns a non-null UDelegateFunction whose identity is
// stable across repeated queries of the same typed value.
// Boundary/ownership: The copy owns its invocation-list snapshot, not Object.
// __DelegateSignature reads the delegate type's reflected signature; it does
// not bind or execute the value.

delegate void FTSDelegatesSignatureNotify(int Value);
event void FTSDelegatesSignatureMulticast(int Value);

UCLASS()
class UTSDelegatesSignatureReceiver : UObject
{
	int ReceivedValue = 0;

	UFUNCTION()
	void OnNotify(int Value)
	{
		ReceivedValue = Value;
	}
}

namespace TS_Delegates_Behavior_02
{
	bool Observe_Delegate_Nominal()
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

	bool Observe___DelegateSignature_Nominal()
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
}
/** @end */
