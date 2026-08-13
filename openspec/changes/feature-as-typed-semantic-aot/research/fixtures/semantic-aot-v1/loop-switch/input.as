int SemanticLoopSwitch(int Limit)
{
	int Total = 0;
	for (int Index = 0; Index < Limit; Index++)
	{
		switch (Index)
		{
			case 0: continue;
			case 2: break;
			default: Total += Index;
		}
	}
	return Total;
}
