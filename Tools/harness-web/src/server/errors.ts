import type { DocumentContent } from '../shared/types.js';

export class ApiFailure extends Error {
  constructor(
    public statusCode: number,
    public code: string,
    message: string,
    public current?: DocumentContent,
  ) {
    super(message);
  }
}
