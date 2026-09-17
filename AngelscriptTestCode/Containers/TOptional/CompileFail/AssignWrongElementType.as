/**
 * @version v1
 * @summary Assigning a value of the wrong element type onto TOptional<int32> is rejected.
 * @topic Containers
 *
 * AssignWrongElementType
 */
/**
 * @begin AssignWrongElementType
 * @summary Assigning a value of the wrong element type onto TOptional<int32> is rejected.
 * @topic Containers
 */
void AssignWrongElementType()
{
	TOptional<int32> Optional;
	Optional = "hello";
}
/** @end */
