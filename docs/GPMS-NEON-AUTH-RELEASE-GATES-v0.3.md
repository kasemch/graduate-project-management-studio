# GPMS Neon Auth release gates v0.3

Scope: isolated gpms-security-test branch only. This document does not authorize production or student data.

Verified configuration: Better Auth email/password sign-up is enabled; email verification is not required on sign-up or sign-in. Trusted origins list is empty and localhost is allowed. The auth schema belongs to cloud_admin and authenticated does not have schema USAGE under the direct SQL role test. Seven gpms tables have RLS enabled.

Before staging access: (1) decide and configure an approved staging origin; (2) require verified email for any real student identity, and validate this requirement through the actual authentication flow; (3) test a signed Neon Auth session through Data API and confirm auth.uid() behavior; (4) test learner A, learner B and instructor with synthetic records and verify cross-project denial; (5) verify audit and display approval restrictions. Do not treat role-switch SQL tests or empty tables as a substitute for signed JWT tests.

Current decision: SECURITY HOLD. No write grants, real student records, public release, production changes, or merge of PR #11.
