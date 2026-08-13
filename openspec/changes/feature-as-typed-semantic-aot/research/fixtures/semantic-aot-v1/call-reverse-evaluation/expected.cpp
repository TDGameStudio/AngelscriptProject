#include "CoreMinimal.h"

static int32 AS_Test_Semantic_SemanticCallOrder(FScriptExecution& Execution)
{
    const int32 as_sem_eval_formal_2 = AS_Test_Semantic_Step(Execution, int32(3));
    if (Execution.bExceptionThrown) return {};
    const int32 as_sem_eval_formal_1 = AS_Test_Semantic_Step(Execution, int32(2));
    if (Execution.bExceptionThrown) return {};
    const int32 as_sem_eval_formal_0 = AS_Test_Semantic_Step(Execution, int32(1));
    if (Execution.bExceptionThrown) return {};
    const int32 as_sem_result = AS_Test_Semantic_Collect(
        Execution,
        as_sem_eval_formal_0,
        as_sem_eval_formal_1,
        as_sem_eval_formal_2);
    if (Execution.bExceptionThrown) return {};
    return as_sem_result;
}
