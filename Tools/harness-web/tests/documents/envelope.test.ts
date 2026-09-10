import { describe, expect, it } from 'vitest';
import {
  assertProtectedContentUnchanged,
  serializeDocument,
  splitDocument,
} from '../../src/shared/documents';

describe('protected document envelope', () => {
  it.each(['\n', '\r\n', '\r'])('keeps untouched bytes including BOM and %j line endings', (eol) => {
    const source =
      '\uFEFF' +
      [
        '---',
        '# do not normalize YAML',
        'tags: [one, two]',
        '---',
        '',
        '# 标题',
        '',
        'A **sentence**.  ',
        '',
      ].join(eol);
    expect(serializeDocument(splitDocument(source), {})).toBe(source);
  });

  it('edits body without rewriting frontmatter or machine task fields', () => {
    const source =
      '\uFEFF---\r\ntask_graph:\r\n  version: 1\r\n---\r\n\r\n- [ ] 1.1 First — verify: `npm test`\r\n  > Files: `src/**`\r\n\r\n  #### Scenario: nested\r\n  - GIVEN a value\r\n    - and its child\r\n  - THEN keep it\r\n';
    const envelope = splitDocument(source);
    const body = envelope.segments.find(
      (segment) => segment.kind === 'editable' && segment.markdown.includes('Scenario'),
    )!;
    const next = serializeDocument(envelope, {
      [body.id]: '#### Scenario: nested\n\n- GIVEN a changed value\n  - and its child\n- THEN keep it\n',
    });
    expect(next).toContain('\uFEFF---\r\ntask_graph:\r\n  version: 1\r\n---\r\n');
    expect(next).toContain('- [ ] 1.1 First — verify: `npm test`\r\n  > Files: `src/**`\r\n');
    expect(next).toContain(
      '  #### Scenario: nested\r\n\r\n  - GIVEN a changed value\r\n    - and its child\r\n  - THEN keep it\r\n',
    );
    expect(() => assertProtectedContentUnchanged(source, next)).not.toThrow();
  });

  it.each([
    ['task status', '- [ ] 1.1 First — verify: `npm test`\n', '- [x] 1.1 First — verify: `npm test`\n'],
    ['verification', '- [ ] 1.1 First — verify: `npm test`\n', '- [ ] 1.1 First — verify: `npm other`\n'],
    ['file scope', '  > Files: `src/**`\n', '  > Files: `other/**`\n'],
    ['frontmatter', '---\na: 1\n---\n', '---\na: 2\n---\n'],
    ['opaque comment', '<!-- keep this metadata -->\n', ''],
  ])('rejects a changed %s block', (_name, original, next) => {
    expect(() => assertProtectedContentUnchanged(original, next)).toThrow();
  });

  it('keeps unknown syntax opaque while surrounding prose stays editable', () => {
    const source =
      '# Before\n\n:::custom x="1"\nkeep **exactly**\n:::\n\nAfter.\n\n<!-- agent: preserve -->\n';
    const envelope = splitDocument(source);
    expect(
      envelope.segments
        .filter((segment) => segment.kind === 'protected')
        .map((segment) => segment.source)
        .join(''),
    ).toContain(':::custom x="1"\nkeep **exactly**\n:::\n');
    const body = envelope.segments.find(
      (segment) => segment.kind === 'editable' && segment.markdown.includes('After.'),
    )!;
    const next = serializeDocument(envelope, { [body.id]: 'Changed.\n' });
    expect(next).toContain(':::custom x="1"\nkeep **exactly**\n:::\n');
    expect(next).toContain('<!-- agent: preserve -->');
    expect(next).toContain('Changed.');
  });

  it('does not mistake fenced code examples for machine task headers', () => {
    const source = '```markdown\n- [ ] 1.1 Example — verify: `echo demo`\n  > Files: `example`\n```\n';
    expect(splitDocument(source).segments.every((segment) => segment.kind === 'editable')).toBe(true);
    expect(() =>
      assertProtectedContentUnchanged(source, source.replace('echo demo', 'echo changed')),
    ).not.toThrow();
  });

  it('keeps prose around an opaque comment inside a task editable', () => {
    const source =
      '- [ ] 1.1 Work — verify: `npm test`\n  > Files: `src/**`\n\n  Before.\n\n  <!-- metadata -->\n\n  After.\n';
    const envelope = splitDocument(source);
    expect(
      envelope.segments.some((part) => part.kind === 'editable' && part.markdown.includes('Before.')),
    ).toBe(true);
    expect(
      envelope.segments.some((part) => part.kind === 'editable' && part.markdown.includes('After.')),
    ).toBe(true);
  });

  it('keeps editable continuation indentation separate from the next section', () => {
    const source =
      '- [ ] 1.1 First — verify: `npm test`\n  > Files: `src/**`\n\n  1. First step.\n     - Nested.\n\n## Next section\n\nNotes.\n';
    const envelope = splitDocument(source);
    const body = envelope.segments.find(
      (segment) => segment.kind === 'editable' && segment.markdown.includes('First step'),
    )!;
    const next = serializeDocument(envelope, { [body.id]: '1. Updated step.\n   - Nested.\n' });
    expect(next).toContain('  1. Updated step.\n     - Nested.\n\n## Next section');
    expect(next).toContain('Notes.\n');
  });

  it('rejects injection of new machine fields from an editable body', () => {
    const envelope = splitDocument('Plain text.\n');
    const body = envelope.segments[0]!;
    expect(() =>
      serializeDocument(envelope, { [body.id]: '- [ ] 9.1 Injected — verify: `run`\n' }),
    ).toThrow();
  });

  it('preserves missing terminal newline after editing', () => {
    const envelope = splitDocument('# Title\n\nNo terminal newline.');
    const body = envelope.segments[0]!;
    expect(serializeDocument(envelope, { [body.id]: '# Title\n\nUpdated.\n' })).toBe('# Title\n\nUpdated.');
  });
});
