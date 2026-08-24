// Purpose: Observe typed and type-erased event argument push helpers, pending
// reflected-event execution, and both instance and mixin EventName expansion.
// AS-facing API: void __Evt_PushArgument__<TypeName>(const <Type>& Value);
// void __Evt_PushArgumentRef__<TypeName>(const <Type>& Value);
// void __Evt_PushArgument(const ?& Value);
// void __Evt_PushArgumentRef(const ?& Value);
// void __Evt_Execute(const UObject Object, const FName& Name);
// void __Evt_ExecuteDelegate(const _FScriptDelegate& Delegate);
// void __Evt_ExecuteDelegate(const _FMulticastScriptDelegate& Delegate);
// ReturnType EventOwner.EventName(Arguments...);
// ReturnType Receiver.EventName(Arguments...);
// Inputs: Copied int 21, writable int32 alias 4, type-erased FString "queued",
// empty FString, and a live owner whose BlueprintEvent Compute is pending.
// Expected observations: Instance Compute(21) returns 42. Mixin-style call
// on the receiver targets the class default object. After push + execute the
// pending argument list is consumed and Receiver.LastValue becomes 21.
// Boundary/ownership: Push copies or borrows according to the typed versus
// Ref helper. Pending arguments are owned by the internal call until
// __Evt_Execute or __Evt_ExecuteDelegate drains them. At most 16 supported
// arguments. Unbound multicast execute-delegate still broadcasts as a no-op.

event void FTSBlueprintEventBehaviorMulticast(int Value);
delegate void FTSBlueprintEventBehaviorDelegate(int Value);

UCLASS()
class UTSBlueprintEventBehaviorOwner : UObject
{
	int LastValue = -1;

	UFUNCTION(BlueprintEvent)
	int Compute(int Value)
	{
		LastValue = Value;
		return Value + 21;
	}

	UFUNCTION()
	void Store(int Value)
	{
		LastValue = Value;
	}
}

namespace TS_BlueprintEvent_Behavior_01
{
	// void __Evt_PushArgument__int(const int& Value) copies the argument.
	// Inputs: CopiedValue 21, then Compute drains the pending list.
	// Oracle: caller storage stays 21 and LastValue becomes 21.
	// Ownership: push copies; pending args are consumed by __Evt_Execute.
	bool Observe_Surface001_Nominal()
	{
		UTSBlueprintEventBehaviorOwner Owner;
		if (Owner is null)
		{
			throw("TS_BlueprintEvent_Behavior_01 setup: required Owner is null");
		}
		int CopiedValue = 21;
		__Evt_PushArgument__int(CopiedValue);
		__Evt_Execute(Owner, n"Compute");
		return CopiedValue == 21 && Owner.LastValue == 21;
	}

	// void __Evt_PushArgumentRef__int32(const int32& Value) keeps caller storage.
	// Inputs: WritableAlias 4, then Compute drains the pending list.
	// Oracle: alias stays 4 and LastValue becomes 4.
	// Ownership: ref helper borrows caller storage until execute.
	bool Observe_Surface002_Nominal()
	{
		UTSBlueprintEventBehaviorOwner Owner;
		if (Owner is null)
		{
			throw("TS_BlueprintEvent_Behavior_01 setup: required Owner is null");
		}
		int32 WritableAlias = 4;
		__Evt_PushArgumentRef__int32(WritableAlias);
		__Evt_Execute(Owner, n"Compute");
		return WritableAlias == 4 && Owner.LastValue == 4;
	}

	// void __Evt_PushArgument(const ?& Value) copies a type-erased FString.
	// Inputs: "queued" and empty "".
	// Oracle: both strings remain independent after the copy push.
	// Ownership: type-erased copy; pending list is drained by Compute.
	bool Observe___Evt_PushArgument_Nominal()
	{
		FString CopiedText = "queued";
		__Evt_PushArgument(CopiedText);
		FString EmptyText = "";
		__Evt_PushArgument(EmptyText);
		return CopiedText == "queued" && EmptyText.IsEmpty();
	}

	// void __Evt_PushArgumentRef(const ?& Value) borrows a type-erased FString.
	// Inputs: WritableText "pending".
	// Oracle: caller string stays "pending".
	// Ownership: ref helper borrows; Compute drains the pending slot.
	bool Observe___Evt_PushArgumentRef_Nominal()
	{
		FString WritableText = "pending";
		__Evt_PushArgumentRef(WritableText);
		return WritableText == "pending";
	}

	// void __Evt_Execute(const UObject Object, const FName& Name) drains pending args.
	// Inputs: Owner, n"Compute", pushed int 21.
	// Oracle: LastValue goes from -1 to 21.
	// Ownership: Object is borrowed; pending list is consumed.
	bool Observe___Evt_Execute_Nominal()
	{
		UTSBlueprintEventBehaviorOwner Owner;
		if (Owner is null)
		{
			throw("TS_BlueprintEvent_Behavior_01 setup: required Owner is null");
		}
		int Before = Owner.LastValue;
		__Evt_PushArgument__int(21);
		__Evt_Execute(Owner, n"Compute");
		return Before == -1 && Owner.LastValue == 21;
	}

	// void __Evt_ExecuteDelegate executes bound single-cast and multicast delegates.
	// Inputs: Bound Store, pushed 21 then 7.
	// Oracle: LastValue is 21 after single-cast and 7 after multicast.
	// Ownership: delegates borrow Owner; unbound multicast is not used here.
	bool Observe___Evt_ExecuteDelegate_Nominal()
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

	// ReturnType EventOwner.EventName(Arguments...) invokes the BlueprintEvent.
	// Inputs: Compute(21) then Compute(0).
	// Oracle: 21 returns 42 with LastValue 21; 0 returns 21.
	// Ownership: instance call mutates Owner; no new receiver is spawned.
	bool Observe_EventName_Nominal()
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
}
