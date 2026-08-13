#include "CoreMinimal.h"

static int32 AS_Test_Semantic_SemanticLoopSwitch(const int32 as_sem_s0)
{
	int32 as_sem_s1 = int32(0);
	for (int32 as_sem_s2 = int32(0); (as_sem_s2 < as_sem_s0); as_sem_s2++)
	{
		switch (as_sem_s2)
		{
			case int32(0):
				continue;
			case int32(2):
				break;
			default:
				as_sem_s1 += as_sem_s2;
		}
	}
	return as_sem_s1;
}
