// Purpose: Observe System::SetTimer registration and ClearAndInvalidateTimerHandle
// writeback, including default looping omission and cleanup. Each function
// returns the exact comparison for the C++ runner.
// AS-facing API: FTimerHandle System::SetTimer(const UObject Object,
// const FName& FunctionName, float32 Time, bool bLooping = false);
// void System::ClearAndInvalidateTimerHandle(FTimerHandle& Handle);
// Inputs: UTSSystemTimersMutationHost as the reflected object, n"NoopTimerCallback"
// as the parameterless function, Time 0.25 with bLooping omitted, Time 0.5 with
// bLooping true, a repeated SetTimer on the same host, and the returned handle
// passed by reference into ClearAndInvalidateTimerHandle.
// Expected observations: SetTimer returns a handle that is not paused while
// active. Clearing the handle makes a later IsTimerPausedHandle read report
// false. A second SetTimer replaces the previous schedule for that function.
// Boundary/ownership: FunctionName must be a parameterless UFUNCTION on Object.
// ClearAndInvalidateTimerHandle mutates Handle to the invalid state. The host
// object is borrowed by the world timer manager until cleared.

UCLASS()
class UTSSystemTimersMutationHost : UObject
{
	UFUNCTION()
	void NoopTimerCallback()
	{
	}

	UFUNCTION()
	void ParameterCallback(int Value)
	{
	}
}

namespace TS_SystemTimers_MutationAndLifecycle_01
{
	bool Observe_SetTimer_Nominal()
	{
		UTSSystemTimersMutationHost Host;
		FTimerHandle SingleShot = System::SetTimer(Host, n"NoopTimerCallback", 0.25);
		bool bSingleShotActive = !System::IsTimerPausedHandle(SingleShot);
		FTimerHandle Looping = System::SetTimer(Host, n"NoopTimerCallback", 0.5, true);
		bool bLoopingActive = !System::IsTimerPausedHandle(Looping);
		FTimerHandle Repeated = System::SetTimer(Host, n"NoopTimerCallback", 0.5, true);
		bool bRepeatedActive = !System::IsTimerPausedHandle(Repeated);
		System::ClearAndInvalidateTimerHandle(SingleShot);
		System::ClearAndInvalidateTimerHandle(Looping);
		System::ClearAndInvalidateTimerHandle(Repeated);
		return bSingleShotActive && bLoopingActive && bRepeatedActive;
	}

	bool Observe_ClearAndInvalidateTimerHandle_Nominal()
	{
		UTSSystemTimersMutationHost Host;
		FTimerHandle Handle = System::SetTimer(Host, n"NoopTimerCallback", 0.5, true);
		bool bBeforeClearPaused = System::IsTimerPausedHandle(Handle);
		System::ClearAndInvalidateTimerHandle(Handle);
		bool bAfterClearPaused = System::IsTimerPausedHandle(Handle);
		System::ClearAndInvalidateTimerHandle(Handle);
		bool bRepeatedClearPaused = System::IsTimerPausedHandle(Handle);
		FTimerHandle Empty;
		System::ClearAndInvalidateTimerHandle(Empty);
		return !bBeforeClearPaused && !bAfterClearPaused && !bRepeatedClearPaused;
	}

	void ExerciseExpectedFailure()
	{
		UTSSystemTimersMutationHost Host;
		FTimerHandle Invalid = System::SetTimer(Host, n"ParameterCallback", 0.1);
		System::ClearAndInvalidateTimerHandle(Invalid);
	}
}
