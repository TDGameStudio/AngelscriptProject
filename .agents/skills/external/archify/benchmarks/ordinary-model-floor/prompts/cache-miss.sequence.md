# Cache-miss request sequence

Use the Archify skill in this repository to create a sequence diagram for a dashboard request. A browser calls an API, the API validates the JWT, then reads Redis. Redis returns a cache miss, so the API queries PostgreSQL for profile and metric data, stores the result back in Redis, emits a trace, and returns JSON for the browser to render.

Author a fresh typed JSON diagram specification targeting the `showcase` quality profile. Choose your own stable internal IDs and layout. Preserve message direction and distinguish calls, returns, security checks, and asynchronous trace emission. Use the bundled Archify CLI to validate and repair the candidate when shell access is available. The external harness will independently validate the frozen candidate.

Write the final candidate to exactly `benchmark-candidate.json` in the repository root. Do not edit any other file. The candidate file, not the prose response, is the attempt 1 artifact. Do not copy a checked-in example. Do not claim that validation passed.
