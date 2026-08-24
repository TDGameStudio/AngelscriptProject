// Theme: Feature.PropertyAccess. Isolated compile-fail: virtual property get/set block.
// CSV WorldStory. C++ VirtualPropertyFails AssertFailsWithError
// "Virtual property syntax has been removed".
// Isolate this failing program. DiagnosticOnly.

class AActorPAVirtual : AActor
{
	int Health
	{
		get
		{
			return 100;
		}

		set
		{
		}
	}
}
