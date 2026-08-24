// Purpose: Observe PauseTimerHandle and UnPauseTimerHandle on a live world
// timer and on an empty handle. Each function returns the exact comparison
// for the C++ runner.
// AS-facing API: void System::PauseTimerHandle(FTimerHandle Handle);
// void System::UnPauseTimerHandle(FTimerHandle Handle);
// Inputs: A looping 0.5s timer on UTSSystemTimersPauseHost.NoopTimerCallback,
// the same handle after pause then unpause, a repeated pause, and a default
// FTimerHandle as the empty/null-world variant.
// Expected observations: After PauseTimerHandle, IsTimerPausedHandle is true.
// After UnPauseTimerHandle it is false. Pausing an empty handle does not make
// it report paused.
// Boundary/ownership: Both calls borrow the current world from WorldContext
// and do not own Handle. Unpausing a handle that is not paused is a no-op.

UCLASS()
class UTSSystemTimersPauseHost : UObject
{
	UFUNCTION()
	void NoopTimerCallback()
	{
	}
}

namespace TS_SystemTimers_NamespaceAndGlobalFunctions_01
{
	bool Observe_PauseTimerHandle_Nominal()
	{
		FTimerHandle Empty;
		System::PauseTimerHandle(Empty);
		bool bEmptyPaused = System::IsTimerPausedHandle(Empty);
		UTSSystemTimersPauseHost Host;
		FTimerHandle Handle = System::SetTimer(Host, n"NoopTimerCallback", 0.5, true);
		System::PauseTimerHandle(Handle);
		bool bPaused = System::IsTimerPausedHandle(Handle);
		System::PauseTimerHandle(Handle);
		bool bRepeatedPause = System::IsTimerPausedHandle(Handle);
		System::ClearAndInvalidateTimerHandle(Handle);
		return !bEmptyPaused && bPaused && bRepeatedPause;
	}

	bool Observe_UnPauseTimerHandle_Nominal()
	{
		FTimerHandle Empty;
		System::UnPauseTimerHandle(Empty);
		bool bEmptyPaused = System::IsTimerPausedHandle(Empty);
		UTSSystemTimersPauseHost Host;
		FTimerHandle Handle = System::SetTimer(Host, n"NoopTimerCallback", 0.5, true);
		System::PauseTimerHandle(Handle);
		bool bPaused = System::IsTimerPausedHandle(Handle);
		System::UnPauseTimerHandle(Handle);
		bool bUnpaused = System::IsTimerPausedHandle(Handle);
		System::UnPauseTimerHandle(Handle);
		bool bRepeatedUnpause = System::IsTimerPausedHandle(Handle);
		System::ClearAndInvalidateTimerHandle(Handle);
		return !bEmptyPaused && bPaused && !bUnpaused && !bRepeatedUnpause;
	}
}
