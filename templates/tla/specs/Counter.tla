---- MODULE Counter ----
(* Processes increment a shared counter in two steps: read it, then write
   the read value plus one. A lock makes the two steps safe. Delete the
   `lock = NONE` guard in Read and run `make check` to see TLC find the
   lost update. *)
EXTENDS Naturals, FiniteSets

CONSTANTS Procs, NONE

VARIABLES x, tmp, pc, lock

vars == <<x, tmp, pc, lock>>

Init ==
    /\ x = 0
    /\ tmp = [p \in Procs |-> 0]
    /\ pc = [p \in Procs |-> "read"]
    /\ lock = NONE

Read(p) ==
    /\ pc[p] = "read"
    /\ lock = NONE
    /\ lock' = p
    /\ tmp' = [tmp EXCEPT ![p] = x]
    /\ pc' = [pc EXCEPT ![p] = "write"]
    /\ UNCHANGED x

Write(p) ==
    /\ pc[p] = "write"
    /\ x' = tmp[p] + 1
    /\ lock' = NONE
    /\ pc' = [pc EXCEPT ![p] = "done"]
    /\ UNCHANGED tmp

Done == \A p \in Procs : pc[p] = "done"

\* Stutter once everyone has finished, so TLC does not report a deadlock.
Next ==
    \/ \E p \in Procs : Read(p) \/ Write(p)
    \/ (Done /\ UNCHANGED vars)

Spec == Init /\ [][Next]_vars

TypeOK ==
    /\ x \in 0..Cardinality(Procs)
    /\ pc \in [Procs -> {"read", "write", "done"}]
    /\ lock \in Procs \cup {NONE}

NoLostUpdate == Done => x = Cardinality(Procs)
====
