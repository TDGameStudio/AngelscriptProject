/**
 * @version v1
 * @summary A mutable FString at module level is rejected: only const globals are supported. This file is the illegal program itself; do not add const, since the mutable global is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary A mutable FString at module level is rejected: only const globals are supported. This file is the illegal program itself; do not add const, since the mutable global is the point.
 * @topic Negative
 */
FString GMutable = "Mutable";
/** */
FString ReadMutable()
{
	return GMutable;
}
/** @end */
