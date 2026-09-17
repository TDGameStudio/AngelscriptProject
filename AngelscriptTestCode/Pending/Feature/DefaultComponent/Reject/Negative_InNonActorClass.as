/**
 * @version v1
 * @summary DefaultComponent in a non-Actor class is rejected. The specifier is only valid on actor properties; this file is the illegal program itself.
 * @topic Feature
 */
/**
 * @version root
 * @summary DefaultComponent in a non-Actor class is rejected. The specifier is only valid on actor properties; this file is the illegal program itself.
 * @topic Negative
 */
struct FDefCompStruct
{
	UPROPERTY(DefaultComponent)
	USceneComponent Root;
}
/** @end */
