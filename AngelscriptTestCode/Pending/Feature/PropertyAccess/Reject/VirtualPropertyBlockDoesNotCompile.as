/**
 * @version v1
 * @summary Isolated compile-fail: removed virtual property syntax. C++ concatenates `get; set;` into StoredValue { ... } and expects bCompiled==false with "Virtual property syntax has been removed".
 * @topic Feature
 */
/**
 * @version root
 * @summary Isolated compile-fail: removed virtual property syntax. C++ concatenates `get; set;` into StoredValue { ... } and expects bCompiled==false with "Virtual property syntax has been removed".
 * @topic Negative
 */
class FAutoAccessorVirtualPropertyFailure
{
	int Stored = 3;
	int StoredValue { get; set; }
}
/** @end */
