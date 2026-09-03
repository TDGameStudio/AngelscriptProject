/**
 * Isolated compile-fail: removed virtual property syntax. C++ concatenates `get; set;`
 * into StoredValue { ... } and expects bCompiled==false with
 * "Virtual property syntax has been removed".
 *
 * @Theme Feature.PropertyAccess
 * @Subject PropertyAccess.VirtualPropertyBlockDoesNotCompile
 * @Harness CompileReject
 * @Tag Feature.PropertyAccess.VirtualPropertyBlockDoesNotCompile
 * @Kind CompileReject
 * @Covers PropertyAccess.VirtualPropertyBlockDoesNotCompile
 * @Inputs int StoredValue { get; set; }
 * @Return does not compile; "Virtual property syntax has been removed"
 * @Provenance Theme: Feature.PropertyAccess. Isolated compile-fail: removed virtual property syntax.
 * @Provenance CSV Positive. C++ VirtualPropertyBlockDoesNotCompile concatenates `get; set;`
 * @Provenance into StoredValue { ... }; bCompiled==false. Expected diagnostic:
 * @Provenance "Virtual property syntax has been removed".
 * @Provenance Isolate this failing program. Do not add declarations that would compile it away.
 */

class FAutoAccessorVirtualPropertyFailure
{
	int Stored = 3;
	int StoredValue { get; set; }
}
