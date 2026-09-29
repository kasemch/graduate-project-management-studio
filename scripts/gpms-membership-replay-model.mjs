// Offline behavioral model only. Database uniqueness and atomic execution are separate release gates.
import { createHash } from 'node:crypto';
export const fingerprint = ({actorId,projectId,targetUserId,active}) => createHash('sha256').update(JSON.stringify([actorId,projectId,targetUserId,active])).digest('hex');
export class ReplayLedger {
  #entries = new Map();
  execute(authorized, perform) {
    if (!authorized?.ok) return {status:'denied'};
    const key=JSON.stringify([authorized.actorId,authorized.projectId,authorized.idempotencyKey]);
    const hash=fingerprint(authorized);
    const prior=this.#entries.get(key);
    if(prior) return prior.hash===hash ? {status:'replayed',result:prior.result} : {status:'conflict'};
    const result=perform(authorized); // synchronous model; throw means no entry recorded
    this.#entries.set(key,{hash,result});
    return {status:'created',result};
  }
  get size(){return this.#entries.size}
}
