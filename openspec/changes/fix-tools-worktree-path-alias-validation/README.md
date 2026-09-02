# fix-tools-worktree-path-alias-validation

AgentConfig.ini ProjectFile validation compares paths lexically, so junction/subst worktree aliases are rejected even though they are the same directory
