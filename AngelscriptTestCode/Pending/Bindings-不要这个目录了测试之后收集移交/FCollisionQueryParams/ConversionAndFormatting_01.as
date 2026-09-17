/**
 * @version v1
 * @summary Observe ToString diagnostic text for query and component params.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe ToString diagnostic text for query and component params.
 * @topic Baseline
 */
// The bool return is the runner-readable oracle.
// AS-facing API: FString FCollisionQueryParams.ToString() const;
// FString FComponentQueryParams.ToString() const;
// Inputs: Default params, TraceTag n"QueryTag" / n"ComponentTag", and
// bTraceComplex true.
// Expected observations: Named params produce non-empty diagnostic text that
// differs from the default query ToString after the tag is set.
// Boundary/ownership: ToString returns a new FString. It does not mutate the
// parameter object.

namespace TS_FCollisionQueryParams_ConversionAndFormatting_01
{
	bool Observe_ToString_Nominal()
	{
		FCollisionQueryParams QueryParams;
		FString DefaultQuery = QueryParams.ToString();
		QueryParams.TraceTag = n"QueryTag";
		QueryParams.bTraceComplex = true;
		FString NamedQuery = QueryParams.ToString();

		FComponentQueryParams ComponentParams;
		FString DefaultComponent = ComponentParams.ToString();
		ComponentParams.TraceTag = n"ComponentTag";
		FString NamedComponent = ComponentParams.ToString();
		return NamedQuery.Len() > 0 && NamedComponent.Len() > 0;
	}
}
/** @end */
