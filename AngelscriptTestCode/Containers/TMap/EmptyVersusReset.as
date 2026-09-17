/**
 * @version v1
 * @summary Empty and Reset both clear Num to 0.
 * @topic Containers
 *
 * EmptyVersusReset
 */
/**
 * @begin EmptyVersusReset
 * @summary Empty and Reset both clear Num to 0.
 * @topic Containers
 */
bool EmptyVersusReset()
{
	TMap<FName, int32> Emptied;
	Emptied.Add(n"Alpha", 1);
	Emptied.Empty();
	TMap<FName, int32> Reset;
	Reset.Add(n"Alpha", 1);
	Reset.Reset();
	return Emptied.IsEmpty() && Emptied.Num() == 0
		&& Reset.IsEmpty() && Reset.Num() == 0;
}
/** @end */
