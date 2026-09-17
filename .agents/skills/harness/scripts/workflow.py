"""Internal JSON transport for typed Harness workflow routes."""
import json
import sys
from discussions import talk
from replans import apply_replan, replan_status
from execution import execute, hook


def main():
    try:
        payload = json.load(sys.stdin)
        context, parameters = payload['context'], payload.get('parameters', {})
        group, action = sys.argv[1:3]
        if group == 'talk':
            result = talk(context, action, parameters)
        elif group == 'replan':
            result = replan_status(context, parameters['Change']) if action == 'status' else apply_replan(context, parameters)
        elif group == 'execution':
            result = hook(context, parameters) if action == 'hook' else execute(context, action, parameters)
        else:
            raise ValueError('Unknown workflow group')
        print(json.dumps(result, ensure_ascii=False))
        return 0
    except (ValueError, OSError, KeyError) as error:
        print(json.dumps({'error': str(error)}))
        return 1


if __name__ == '__main__':
    sys.exit(main())
