/**
 * @version v1
 * @summary Assigning nullptr makes the weak pointer explicitly null and invalid.
 * @topic Containers
 *
 * AssigningNullptrIsExplicitlyNull
 */
/**
 * @begin AssigningNullptrIsExplicitlyNull
 * @summary Assigning nullptr makes the weak pointer explicitly null and invalid.
 * @topic Containers
 */
bool AssigningNullptrIsExplicitlyNull()
{
	TWeakObjectPtr<UObject> Weak;
	Weak = nullptr;
	return !Weak.IsValid() && Weak.IsExplicitlyNull();
}
/** @end */
