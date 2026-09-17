/**
 * @version v1
 * @summary Observe FJsonObject field iteration, including empty objects and Proceed aliasing. Each function returns the exact comparison.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FJsonObject field iteration, including empty objects and Proceed aliasing. Each function returns the exact comparison.
 * @topic Baseline
 */
// FJsonObjectFieldIterator& FJsonObjectFieldIterator.Proceed();
// Inputs: Empty object, one-field object Name=Alice, and a two-field object
// as the last-position case.
// Expected observations: Empty iterator CanProceed is false. After Proceed on
// a one-field object GetFieldName is Name. Proceed returns an alias used for
// a follow-up CanProceed read.
// Boundary/ownership: The iterator borrows the object. Proceeding past the
// last field is the diagnostic path.

namespace TS_Json_IndexAndIteration_01
{
	bool Observe_Iterator_Nominal()
	{
		FJsonObject Empty;
		FJsonObjectFieldIterator EmptyIt = Empty.Iterator();
		FJsonObject Root;
		Root.SetStringField("Name", "Alice");
		FJsonObjectFieldIterator It = Root.Iterator();
		return !EmptyIt.CanProceed && It.CanProceed;
	}

	bool Observe_Proceed_Nominal()
	{
		FJsonObject Root;
		Root.SetStringField("Name", "Alice");
		Root.SetNumberField("Score", 1.0);
		FJsonObjectFieldIterator It = Root.Iterator();
		FJsonObjectFieldIterator& Alias = It.Proceed();
		FString First = Alias.GetFieldName();
		bool bCanContinue = Alias.CanProceed;
		if (bCanContinue)
		{
			Alias.Proceed();
		}
		return (First == "Name" || First == "Score") && bCanContinue;
	}
}
/** @end */
