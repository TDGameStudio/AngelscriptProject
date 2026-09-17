/**
 * @version v1
 * @summary Set stores an FString and marks the optional set.
 * @topic Containers
 *
 * SetValueFString
 */
/**
 * @begin SetValueFString
 * @summary Set stores an FString and marks the optional set.
 * @topic Containers
 */
bool SetValueFString()
{
	TOptional<FString> Optional;
	Optional.Set("alpha");
	return Optional.IsSet() && Optional.GetValue() == "alpha";
}
/** @end */
