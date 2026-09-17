/**
 * @version v1
 * @summary Casting between unrelated types is rejected: an FString is not part of the actor hierarchy, so there is no conversion to attempt. This file is the illegal program itself.
 * @topic Language
 */
/**
 * @version root
 * @summary Casting between unrelated types is rejected: an FString is not part of the actor hierarchy, so there is no conversion to attempt. This file is the illegal program itself.
 * @topic Negative
 */
/** */
void Test()
{
	FString S = "hello";
	auto X = Cast<AActor>(S);
}
/** @end */
