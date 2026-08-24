// Purpose: Observe remaining FNavigationEvent modifier, platform-user, and
// device queries.
// AS-facing API: bool NavigationEvent.IsLeftControlDown() const;
// bool NavigationEvent.IsRightControlDown() const;
// bool NavigationEvent.IsAltDown() const; bool NavigationEvent.IsLeftAltDown() const;
// bool NavigationEvent.IsRightAltDown() const;
// bool NavigationEvent.IsCommandDown() const;
// bool NavigationEvent.IsLeftCommandDown() const;
// bool NavigationEvent.IsRightCommandDown() const;
// FPlatformUserId NavigationEvent.GetPlatformUserid() const;
// FInputDeviceId NavigationEvent.GetInputDeviceId() const;
// Inputs: A default-constructed FNavigationEvent as the empty receiver.
// Expected observations: All listed modifier queries are false. Platform user
// and device ids match a second read of the same empty event.
// Boundary/ownership: Queries do not mutate the navigation event.

namespace TS_InputEvents_Queries_07
{
	bool Observe_IsLeftControlDown_Nominal()
	{
		FNavigationEvent NavigationEvent;
		return !NavigationEvent.IsLeftControlDown();
	}

	bool Observe_IsRightControlDown_Nominal()
	{
		FNavigationEvent NavigationEvent;
		return !NavigationEvent.IsRightControlDown();
	}

	bool Observe_IsAltDown_Nominal()
	{
		FNavigationEvent NavigationEvent;
		return !NavigationEvent.IsAltDown();
	}

	bool Observe_IsLeftAltDown_Nominal()
	{
		FNavigationEvent NavigationEvent;
		return !NavigationEvent.IsLeftAltDown();
	}

	bool Observe_IsRightAltDown_Nominal()
	{
		FNavigationEvent NavigationEvent;
		return !NavigationEvent.IsRightAltDown();
	}

	bool Observe_IsCommandDown_Nominal()
	{
		FNavigationEvent NavigationEvent;
		return !NavigationEvent.IsCommandDown();
	}

	bool Observe_IsLeftCommandDown_Nominal()
	{
		FNavigationEvent NavigationEvent;
		return !NavigationEvent.IsLeftCommandDown();
	}

	bool Observe_IsRightCommandDown_Nominal()
	{
		FNavigationEvent NavigationEvent;
		return !NavigationEvent.IsRightCommandDown();
	}

	bool Observe_GetPlatformUserid_Nominal()
	{
		FNavigationEvent NavigationEvent;
		FPlatformUserId PlatformUser = NavigationEvent.GetPlatformUserid();
		FPlatformUserId Again = NavigationEvent.GetPlatformUserid();
		return PlatformUser == Again;
	}

	bool Observe_GetInputDeviceId_Nominal()
	{
		FNavigationEvent NavigationEvent;
		FInputDeviceId InputDevice = NavigationEvent.GetInputDeviceId();
		FInputDeviceId Again = NavigationEvent.GetInputDeviceId();
		return InputDevice == Again;
	}
}
