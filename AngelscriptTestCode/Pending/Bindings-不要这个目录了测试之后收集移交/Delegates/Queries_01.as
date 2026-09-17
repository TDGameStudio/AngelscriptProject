/**
 * @version v1
 * @summary Observe IsBound, GetUObject, and GetFunctionName on typed single-cast, typed multicast, sparse, and signature-erased delegates.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe IsBound, GetUObject, and GetFunctionName on typed single-cast, typed multicast, sparse, and signature-erased delegates.
 * @topic Baseline
 */
// UObject Object = Delegate.GetUObject() const;
// FName Name = Delegate.GetFunctionName() const;
// Inputs: Default unbound receivers, bound OnCompute/OnNotify/OnBeginOverlap
// targets, and an explicit empty AActor sparse property.
// Expected observations: Empty IsBound is false. Bound IsBound is true.
// GetUObject is null when unbound and the live receiver when bound.
// GetFunctionName is NAME_None when unbound and n"OnCompute" when bound.
// Boundary/ownership: Queries borrow the current binding. They do not keep
// the target UObject alive. Sparse IsBound resolves owner storage in place.

delegate int FTSDelegatesQueryCompute(int Value);
event void FTSDelegatesQueryNotify(int Value);

UCLASS()
class UTSDelegatesQueryReceiver : UObject
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

class ATSDelegatesQuerySparseReceiver : AActor
{
	int OverlapCount = 0;

	UFUNCTION()
	void OnBeginOverlap(AActor OverlappedActor, AActor OtherActor)
	{
		OverlapCount += 1;
	}
}

namespace TS_Delegates_Queries_01
{
	bool Observe_IsBound_Nominal()
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

	bool Observe_GetUObject_Nominal()
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

	bool Observe_GetFunctionName_Nominal()
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
}
/** @end */
