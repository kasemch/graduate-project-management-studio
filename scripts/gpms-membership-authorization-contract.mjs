// Pure, offline authorization contract. NOT an HTTP endpoint or a JWT verifier.
export function authorizeMembershipTransition(input) {
  const { session, operator, target, request } = input ?? {};
  if (!session?.verified || !session?.subject || !session?.issuerAccepted || !session?.audienceAccepted || !session?.notExpired) return { ok: false, reason: 'unauthenticated' };
  if (!operator?.active || operator.userId !== session.subject || operator.projectId !== request?.projectId || operator.role !== 'project_admin') return { ok: false, reason: 'forbidden' };
  if (!target || target.projectId !== request.projectId || !target.userId || typeof request.active !== 'boolean') return { ok: false, reason: 'invalid_target' };
  if (typeof request.idempotencyKey !== 'string' || !/^[a-zA-Z0-9_-]{16,128}$/.test(request.idempotencyKey)) return { ok: false, reason: 'invalid_idempotency_key' };
  if (request.active === target.active) return { ok: false, reason: 'no_op' };
  if (request.actorId !== undefined || request.actor_id !== undefined) return { ok: false, reason: 'client_actor_forbidden' };
  return { ok: true, actorId: session.subject, projectId: request.projectId, targetUserId: target.userId, active: request.active, idempotencyKey: request.idempotencyKey };
}
