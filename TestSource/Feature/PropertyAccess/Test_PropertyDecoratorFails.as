// Theme: Feature.PropertyAccess. Isolated compile-fail: `property` decorator on GetHealth.
// CSV WorldStory. C++ PropertyDecoratorFails AssertFailsWithError
// "The 'property' decorator has been removed".
// Isolate this failing program. DiagnosticOnly.

class AActorPAProperty : AActor
{
	int GetHealth() property
	{
		return 100;
	}
}
