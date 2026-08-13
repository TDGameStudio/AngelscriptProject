#include "CoreMinimal.h"

static int32 AS_Test_Semantic_SemanticScalarBranch(
	const int32 as_sem_s0,
	const int32 as_sem_s1)
{
	const int32 as_sem_s2 = (as_sem_s0 + as_sem_s1);
	if ((as_sem_s2 > int32(10)))
	{
		return (as_sem_s2 * int32(2));
	}
	return (as_sem_s2 - int32(1));
}
