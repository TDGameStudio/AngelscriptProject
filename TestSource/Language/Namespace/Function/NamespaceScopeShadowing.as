/**
 * An inner declaration shadows an outer one of the same name: the inner scope
 * sees its own binding and the outer scope keeps its own value once the inner
 * block exits. Shadowing works the same way for a global, a local, a loop
 * variable, a conditional branch, and a class member versus a parameter. The
 * shadowed name is a warning, not a compile failure, so every case here
 * executes. The actor carries a UPROPERTY named Value that a parameter
 * shadows, so the member must be reached through this.
 *
 * @Theme Language.Namespace
 * @Subject Namespace.ScopeShadowing
 * @Harness Function
 * @Tag Language.Namespace.NamespaceScopeShadowing
 * @Namespace NamespaceTest
 * @Provenance C++: AngelscriptCoverageNamespaceTests.cpp::ScopeShadowing
 * @Provenance sha256=6c0ebc91e7b829d3e5088b9f93ec798e1f0d06b10cfcb7c7ea845131a17b014e; lines 510-604.
 * @Provenance Oracle: LocalShadowsGlobal 50; InnerShadowsOuter 20; MultipleShadowLevels 3;
 * @Provenance ShadowingInLoop 100; ShadowingSameType 30; AccessOuterAfterInner 10;
 * @Provenance ShadowingInConditional(true) 200; ParameterShadowsMember(5) == 105.
 * @Provenance Extra: ShadowingInConditional(false) == 100. Keep UPROPERTY Value.
 */

UCLASS()
class AScopeShadowMemberActor : AActor
{
	UPROPERTY()
	int Value = 100;

	/**
	 * Adds the parameter to the member of the same name, proving both are
	 * reachable: the parameter directly and the member through this.
	 */
	UFUNCTION()
	int ParameterShadowsMember(int Value)
	{
		return Value + this.Value;
	}
}

const int GlobalValue = 100;

namespace NamespaceTest
{
	/**
	 * Observe that a local shadows a global of the same name.
	 *
	 * @Kind Observe
	 * @Covers Namespace.ScopeShadowing
	 * @Inputs Declare int GlobalValue = 50 inside a function, shadowing the global 100
	 * @Return 50 when the local wins over the global
	 */
	UFUNCTION()
	int LocalShadowsGlobal()
	{
		int GlobalValue = 50;
		return GlobalValue;
	}

	/**
	 * Observe that a block-level declaration shadows an outer local.
	 *
	 * @Kind Observe
	 * @Covers Namespace.ScopeShadowing
	 * @Inputs Declare X = 10, then redeclare X = 20 inside a block
	 * @Return 20 when the inner block sees its own binding
	 */
	UFUNCTION()
	int InnerShadowsOuter()
	{
		int X = 10;
		{
			int X = 20;
			return X;
		}
	}

	/**
	 * Observe that shadowing nests: the innermost of three bindings wins.
	 *
	 * @Kind Observe
	 * @Covers Namespace.ScopeShadowing
	 * @Inputs Declare Value at three nesting levels: 1, 2, then 3
	 * @Return 3 when the innermost declaration wins
	 */
	UFUNCTION()
	int MultipleShadowLevels()
	{
		int Value = 1;
		{
			int Value = 2;
			{
				int Value = 3;
				return Value;
			}
		}
	}

	/**
	 * Observe that a loop variable shadows an outer variable of the same name,
	 * and that reading the name after the loop returns the outer value.
	 *
	 * @Kind Observe
	 * @Covers Namespace.ScopeShadowing
	 * @Inputs Declare i = 100, then run a for loop that declares its own i
	 * @Return 100 when the post-loop read sees the outer i, not the loop one
	 */
	UFUNCTION()
	int ShadowingInLoop()
	{
		int i = 100;
		int Sum = 0;
		for (int i = 0; i < 5; i++)
		{
			Sum += i;
		}
		return i;
	}

	/**
	 * Observe that shadowing works for repeated declarations of the same type
	 * across nested blocks.
	 *
	 * @Kind Observe
	 * @Covers Namespace.ScopeShadowing
	 * @Inputs Declare Value = 10, then 20, then 30 in successive nested blocks
	 * @Return 30 when the innermost block wins
	 */
	UFUNCTION()
	int ShadowingSameType()
	{
		int Value = 10;
		{
			int Value = 20;
			{
				int Value = 30;
				return Value;
			}
		}
	}

	/**
	 * Observe that leaving the inner block restores the outer binding: the
	 * inner declaration does not overwrite the outer variable.
	 *
	 * @Kind Observe
	 * @Covers Namespace.ScopeShadowing
	 * @Inputs Declare X = 10, shadow it with X = 20 in a block, then read X after the block
	 * @Return 10 when the outer binding is intact after the block exits
	 */
	UFUNCTION()
	int AccessOuterAfterInner()
	{
		int X = 10;
		{
			int X = 20;
		}
		return X;
	}

	/**
	 * Observe shadowing inside a conditional branch: the branch returns its
	 * own binding, and the outer value is returned when the branch is not taken.
	 *
	 * @Kind Observe
	 * @Covers Namespace.ScopeShadowing
	 * @Param Flag Selects the shadowing branch when true
	 * @Inputs Declare Value = 100; shadow it with 200 inside an if; return inside the branch
	 * @Return 200 when Flag is true, otherwise 100
	 */
	UFUNCTION()
	int ShadowingInConditional(bool Flag)
	{
		int Value = 100;
		if (Flag)
		{
			int Value = 200;
			return Value;
		}
		return Value;
	}

	/**
	 * Observe the false boundary of the conditional shadowing case.
	 *
	 * @Kind Observe
	 * @Covers Namespace.ScopeShadowing
	 * @Inputs Call ShadowingInConditional(false)
	 * @Return 100 when the branch is skipped and the outer value is returned
	 * @Boundary branch not taken
	 */
	UFUNCTION()
	int ShadowingInConditionalFalseBoundary()
	{
		return ShadowingInConditional(false);
	}

	/**
	 * Observe that a parameter shadows a UPROPERTY of the same name, and the
	 * member is still reachable through this.
	 *
	 * @Kind Observe
	 * @Covers Namespace.ScopeShadowing
	 * @Inputs Spawn the actor and call ParameterShadowsMember(5), which adds the parameter to this.Value
	 * @Return 105 when the parameter is 5 and the member is 100
	 */
	UFUNCTION()
	bool ParameterShadowsMember()
	{
		AScopeShadowMemberActor Actor = SpawnActor(AScopeShadowMemberActor::StaticClass());
		if (Actor == nullptr)
		{
			return false;
		}
		return Actor.ParameterShadowsMember(5) == 105;
	}
}
