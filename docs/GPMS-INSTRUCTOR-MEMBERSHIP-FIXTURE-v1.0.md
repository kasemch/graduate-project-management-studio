# GPMS instructor membership fixture v1.0

Isolated Neon test branch only; synthetic records.

- Project A: instructor is both creator and instructor member.
- Project B: learner B is creator; instructor is an instructor member but **not** creator.
- Learner A belongs to A; learner B belongs to B.
- The instructor's expected access to project B must therefore be supported by membership policy rather than creator policy.

The exact-ID JWT isolation test remains NOT RUN pending genuine signed sessions and Issue #12 resolution. This fixture improvement is not proof that RLS works. PR #11 stays DRAFT; no production change.
