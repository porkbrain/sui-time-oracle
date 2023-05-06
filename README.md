**This won't work anymore due to Sui updates.**


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

# Exported type

```move
/// Created as a read-only object on every call to `fun stamp`
struct Timestamp has key {
    id: UID,
    /// The unix timestamp in ms recorded by the oracle.
    /// Always larger than all timestamp objects with lower index.
    unix_ms: u64,
    /// First timestamp has index 0, second 1, ...
    index: u64,
    /// Points to the next timestamp object.
    ///
    /// If this timestamp is the latest published one, this ID will point
    /// to a non-existing object.
    next: ID,
}
```

# Example

1. Create a new `.env` file and provide any `sui client gas` ID:

```
SUI_GAS=<<GAS OBJECT'S ID>>
```

2. `$ ./bin/publish.sh`

which results in something like

```
----- Transaction Effects ----
Status : Success
Created Objects:
  - ID: 0x22014df774653536fb406adc6651ed6c8577b704 , Owner: Immutable
  - ID: 0x902ca793e7ac4814d27e4866c36406d5229b5a20 , Owner: Account Address ( 0xf9dca1977a129e19cd161a46ee02479b14c9673a )
```

3. Insert two new lines into your `.env` file, the immutable object being
   your newly deployed package, and the second object being your authority.

```
SUI_GAS=<<GAS OBJECT'S ID>>
SUI_TIMEORACLE_PACKAGE=<<THE IMMUTABLE OBJECT'S (PACKAGE's) ID>>
SUI_TIMEORACLE_AUTH=<<THE SECOND CREATED OBJECT'S ID>>
```

4. Run `./bin/stamp.sh` repeatedly to publish new timestamp objects.

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
