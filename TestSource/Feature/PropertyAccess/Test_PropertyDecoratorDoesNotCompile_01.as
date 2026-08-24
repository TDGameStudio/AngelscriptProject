// Theme: Feature.PropertyAccess. Isolated compile-fail: removed `property` decorator.
// CSV Positive. C++ PropertyDecoratorDoesNotCompile concatenates `property` into
// GetStored(); bCompiled==false. Expected diagnostic:
// "The 'property' decorator has been removed".
// Isolate this failing program. Do not add declarations that would compile it away.

class FAutoAccessorDecoratorFailure
{
	int Stored = 3;

	int GetStored() property
	{
		return Stored;
	}
}
