/**
 * Composite positive: multi-step optional lifecycles that the single-API
 * Function entries do not cover on their own — repeated set/reset cycles,
 * carrying an optional across several calls, and reusing one optional as a
 * "latest value wins" slot.
 *
 * @Theme Containers.TOptional
 * @Subject TOptional.Sequence
 * @Harness Advance
 * @Tag Containers.TOptional.TOptionalSequence
 * @Namespace TOptionalTest
 */

namespace TOptionalTest
{
	/**
	 * Repeated set/reset cycles keep the optional usable and the state correct.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Reset
	 * @Inputs One TOptional<int> cycled through set(1), reset, set(2), reset, set(3)
	 * @Return true when the final state is set and holds 3
	 */
	UFUNCTION()
	bool RepeatedSetResetCyclesKeepStateCorrect()
	{
		TOptional<int> Opt;

		Opt.Set(1);
		if (!Opt.IsSet() || Opt.GetValue() != 1)
		{
			return false;
		}

		Opt.Reset();
		if (Opt.IsSet())
		{
			return false;
		}

		Opt.Set(2);
		if (!Opt.IsSet() || Opt.GetValue() != 2)
		{
			return false;
		}

		Opt.Reset();
		if (Opt.IsSet())
		{
			return false;
		}

		Opt.Set(3);
		return Opt.IsSet() && Opt.GetValue() == 3;
	}

	/**
	 * Carry one optional across several calls: each step sees the state left
	 * by the previous one, and Get provides the safe read at every step.
	 *
	 * @Kind Observe
	 * @Covers TOptional.Get
	 * @Inputs One TOptional<int>; Set(10); GetValue() += 5; Reset; Get(-1)
	 * @Return true when the intermediate read is 15 and the final fallback is -1
	 */
	UFUNCTION()
	bool OptionalCarriedAcrossSteps()
	{
		TOptional<int> Opt;

		Opt.Set(10);
		if (Opt.Get(-1) != 10)
		{
			return false;
		}

		Opt.GetValue() += 5;
		if (Opt.Get(-1) != 15)
		{
			return false;
		}

		Opt.Reset();
		return Opt.Get(-1) == -1;
	}

	/**
	 * "Latest value wins" slot: reassigning an optional replaces the previous
	 * value without needing an explicit reset first.
	 *
	 * @Kind Observe
	 * @Covers TOptional.opAssign
	 * @Inputs One TOptional<int>; assign 1, then 2, then 3
	 * @Return true when only the last value remains
	 */
	UFUNCTION()
	bool LatestAssignWins()
	{
		TOptional<int> Opt;
		Opt = 1;
		Opt = 2;
		Opt = 3;
		return Opt.IsSet() && Opt.GetValue() == 3;
	}

	/**
	 * An unset optional can be passed along and set by a callee, then read back.
	 *
	 * @Kind RoundTrip
	 * @Covers TOptional.Set
	 * @Param Value Optional received as TOptional<int>&out, starts unset
	 * @Inputs Empty &out TOptional<int>
	 * @Return void; Value is set and holds 99
	 */
	UFUNCTION()
	void SetOnBehalfOfCaller(TOptional<int>&out Value)
	{
		Value.Set(99);
	}
}
