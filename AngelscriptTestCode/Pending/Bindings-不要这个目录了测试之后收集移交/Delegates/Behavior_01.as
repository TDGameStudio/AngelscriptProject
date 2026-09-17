/**
 * @version v1
 * @summary Observe default, copy, and bind constructors for typed single-cast and multicast delegates, empty sparse construction, and signature-erased single-cast/multicast default construction.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe default, copy, and bind constructors for typed single-cast and multicast delegates, empty sparse construction, and signature-erased single-cast/multicast default construction.
 * @topic Baseline
 */
// <SingleCastDelegate> Delegate(const <SingleCastDelegate>& Other);
// <SingleCastDelegate> Delegate(UObject Object, const FName& FunctionName);
// <MulticastDelegate> Delegate();
// <MulticastDelegate> Delegate(const <MulticastDelegate>& Other);
// <SparseDelegate> Delegate();
// _FScriptDelegate Delegate();
// _FScriptDelegate Delegate(const _FScriptDelegate& Other);
// _FScriptDelegate Delegate(UObject Object, const FName& FunctionName, UDelegateFunction Signature);
// _FMulticastScriptDelegate Delegate();
// Inputs: Default empty values, bound Other targeting OnCompute/OnNotify,
// Receiver plus n"OnCompute", and a fresh AActor sparse property.
// Expected observations: Default constructors are unbound. Copy constructors
// preserve the binding independently of later Clear on Other. The bind
// constructor IsBound is true and GetUObject is Receiver. Sparse default
// construction through OnActorBeginOverlap is unbound.
// Boundary/ownership: Constructors copy bindings; they do not own Object.
// Sparse construction is observed on the actor property because sparse
// storage is owner-resolved and is not copied.

delegate int FTSDelegatesBehaviorCompute(int Value);
event void FTSDelegatesBehaviorNotify(int Value);

UCLASS()
class UTSDelegatesBehaviorReceiver : UObject
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

class ATSDelegatesBehaviorSparseReceiver : AActor
{
	int OverlapCount = 0;

	UFUNCTION()
	void OnBeginOverlap(AActor OverlappedActor, AActor OtherActor)
	{
		OverlapCount += 1;
	}
}

namespace TS_Delegates_Behavior_01
{
	bool Observe_Delegate_Nominal()
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
}
/** @end */
