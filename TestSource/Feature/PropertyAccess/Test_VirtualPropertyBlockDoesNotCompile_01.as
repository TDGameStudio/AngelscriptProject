// Theme: Feature.PropertyAccess. Isolated compile-fail: removed virtual property syntax.
// CSV Positive. C++ VirtualPropertyBlockDoesNotCompile concatenates `get; set;`
// into StoredValue { ... }; bCompiled==false. Expected diagnostic:
// "Virtual property syntax has been removed".
// Isolate this failing program. Do not add declarations that would compile it away.

class FAutoAccessorVirtualPropertyFailure
{
	int Stored = 3;
	int StoredValue { get; set; }
}
