# Product analytics data flow

Use the Archify skill in this repository to create a data-flow diagram for product analytics. Web and mobile clients send events to an edge ingestion API. Consent is checked before identity data enters a protected PII vault. Accepted events enter a stream, become normalized warehouse facts, and feed dashboards. Aggregated warehouse data also feeds a feature store and model.

Author a fresh typed JSON diagram specification targeting the `showcase` quality profile. Choose your own stable internal IDs and layout. Make the privacy boundary and restricted identity path visually distinct from the ordinary analytics path. Use the bundled Archify CLI to validate and repair the candidate when shell access is available. The external harness will independently validate the frozen candidate.

Write the final candidate to exactly `benchmark-candidate.json` in the repository root. Do not edit any other file. The candidate file, not the prose response, is the attempt 1 artifact. Do not copy a checked-in example. Do not claim that validation passed.
