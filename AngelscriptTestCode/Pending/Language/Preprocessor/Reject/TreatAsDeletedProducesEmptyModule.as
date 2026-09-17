/**
 * @version v1
 * @summary A file registered with bTreatAsDeleted preprocesses successfully but emits an empty module: its import is never resolved, because the file is never really compiled. Adding a real provider would defeat the case, so the.
 * @topic Language
 */
/**
 * @version root
 * @summary A file registered with bTreatAsDeleted preprocesses successfully but emits an empty module: its import is never resolved, because the file is never really compiled. Adding a real provider would defeat the case, so the.
 * @topic Negative
 */
import Tests.Preprocessor.DeletedFile.MissingProvider;

UCLASS()
class UDeletedFileProbe : UObject
{
	/**
	 * An entry point that would return 7 if the module were ever compiled. It
	 * never runs, because the file is treated as deleted.
	 *
	 * @Covers Preprocessor.Imports
	 * @Inputs none
	 * @Return 7, never reached
	 */
	UFUNCTION()
/** */
	int Entry()
	{
		return 7;
	}
}
/** @end */
