/**
 * @version v1
 * @summary DefaultComponent on a non-UPROPERTY field is rejected. The specifier belongs on a UPROPERTY, not a default-assignment; this file is the illegal program.
 * @topic Feature
 */
/**
 * @version root
 * @summary DefaultComponent on a non-UPROPERTY field is rejected. The specifier belongs on a UPROPERTY, not a default-assignment; this file is the illegal program.
 * @topic Negative
 */
class ADefCompNoUPropActor : AActor
{
	USceneComponent Root;
	default Root = DefaultComponent;
}
/** @end */
