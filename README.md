# Time oracle

As of now, the time stamping granularity on Sui is on the order of epochs,
ie. several days.

A temporary patch until more resolution is available is to use an oracle.
That is an off-chain service that periodically publishes the current time.

This package provides an oracle logic where the objects that hold the timestamp
are read-only.
The advantage of read-only objects is lower gas costs because contention penalty
does not apply to them.
Read-only objects can also be used in the broadcast txs.

# How it works

We publish read-only objects that store unix timestamps in ms (can be modified
for any format).
These objects also contain the ID of the next read-only object and a counter.
Both unix timestamp and counter are monotonically increasing.
The tip of the chain is the object with the highest counter.
Alternatively, the tip of the chain can be defined as the object that points to
a non-existing "next" ID.

Periodically, an off-chain service calls a privileged endpoint.
It provides the previous timestamp reference, a proof of authority and "now".
The endpoint creates a new read-only object with the timestamp "now".
It increments the counter.
It asserts that the previous timestamp reference is less than "now".
