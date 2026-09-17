/**
 * @version v1
 * @summary Callable workflow helpers that log their own branches and record what they probed. C++ calls both entrypoints and checks the returned counts against the recorded state, so those names and the UPROPERTY names are part of.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary Callable workflow helpers that log their own branches and record what they probed. C++ calls both entrypoints and checks the returned counts against the recorded state, so those names and the UPROPERTY names are part of.
 * @topic Baseline
 */
UCLASS()
class ADebugWorkflowCoverageActor : AActor
{
	UPROPERTY()
	int ProbeCount = 0;

	UPROPERTY()
	FString LastProbe = "";

	UPROPERTY()
	bool bRecordedReproContext = false;

	UPROPERTY()
	bool bConditionalProbeHit = false;

	/**
	 * Log entering and exiting a branch, record which side was taken, and report the
	 * running probe count.
	 *
	 * @Kind Observe
	 * @Covers Debug.DebuggingWorkflowPatterns
	 * @Inputs the value deciding which branch to take
	 * @Return the probe count after this call
	 * @Param Value the value deciding which branch to take
	 */
	UFUNCTION()
	int TraceBranch(int Value)
	{
		Log(n"CoverageDebugWorkflow", "Enter TraceBranch Value=" + Value);

		if (Value > 10)
		{
			ProbeCount++;
			LastProbe = "High:" + Value;
			bConditionalProbeHit = true;
			Log(n"CoverageDebugWorkflow", "Branch High Value=" + Value);
		}
		else
		{
			ProbeCount++;
			LastProbe = "Low:" + Value;
			Log(n"CoverageDebugWorkflow", "Branch Low Value=" + Value);
		}

		Log(n"CoverageDebugWorkflow", "Exit TraceBranch ProbeCount=" + ProbeCount);
		return ProbeCount;
	}

	/**
	 * Log a repro step together with the actor and class names, and report whether both
	 * were non-empty.
	 *
	 * @Kind Observe
	 * @Covers Debug.DebuggingWorkflowPatterns
	 * @Inputs the repro step name
	 * @Return 1 when both the step name and the actor name are non-empty, otherwise 0
	 * @Param StepName the repro step name
	 * @Boundary empty step name
	 */
	UFUNCTION()
	int RecordReproContext(FString StepName)
	{
		Log(n"CoverageDebugWorkflow", "ReproStep=" + StepName + " Actor=" + GetName() + " Class=" + GetClass().GetName());
		bRecordedReproContext = StepName.Len() > 0 && GetName().ToString().Len() > 0;
		return bRecordedReproContext ? 1 : 0;
	}

	/**
	 * Observe that a locally constructed actor has probed nothing.
	 *
	 * @Kind Observe
	 * @Covers Debug.DebuggingWorkflowPatterns
	 * @Inputs an actor that has not been driven
	 * @Return true when the count is 0, the last probe is empty and both flags are clear
	 * @Boundary declared defaults
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (ProbeCount != 0)
		{
			return false;
		}
		if (LastProbe.Len() != 0)
		{
			return false;
		}
		if (bRecordedReproContext)
		{
			return false;
		}
		return !bConditionalProbeHit;
	}

	/**
	 * Observe that tracing a low then a high value leaves the recorded state consistent.
	 *
	 * @Kind Observe
	 * @Covers Debug.DebuggingWorkflowPatterns
	 * @Inputs none
	 * @Return true when the two calls counted 1 and 2 and the recorded state matches
	 */
	UFUNCTION()
	bool Nominal()
	{
		int Low = TraceBranch(4);
		int High = TraceBranch(42);

		if (Low != 1)
		{
			return false;
		}
		if (High != 2)
		{
			return false;
		}
		if (ProbeCount != 2)
		{
			return false;
		}
		if (!bConditionalProbeHit)
		{
			return false;
		}
		return LastProbe == "High:42";
	}

	/**
	 * Observe that an empty step name is rejected.
	 *
	 * @Kind Observe
	 * @Covers Debug.DebuggingWorkflowPatterns
	 * @Inputs none
	 * @Return true when the entrypoint returned 0 and the flag stayed clear
	 * @Boundary empty step name
	 */
	UFUNCTION()
	bool EmptyStepName()
	{
		if (RecordReproContext("") != 0)
		{
			return false;
		}
		return !bRecordedReproContext;
	}
}
/** @end */
