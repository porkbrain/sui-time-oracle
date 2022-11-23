module timeoracle::timeoracle {
    //! Monotonically increasing timestamping provided by an off-chain oracle.

    use sui::object::{Self, ID, UID};
    use std::option::{Self, Option};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer::{transfer, freeze_object};

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
        /// If this timestamp is the lastest published one, this ID will point
        /// to a non-existing object.
        next: ID,
    }

    /// Created as a single-writer object, unique
    struct AuthorityCap has key, store {
        id: UID,
        /// Option so that we can take out UID and replace it with a new one.
        next_id: Option<UID>,
        /// Incremented by 1 with every call to stamping function.
        next_index: u64,
        /// Ensures that each new timestamp is strictly larger than previous.
        last_unix_ms: u64,
    }

    // === Getters ===

    public fun unix_ms(t: &Timestamp): u64 {
        t.unix_ms
    }

    public fun index(t: &Timestamp): u64 {
        t.index
    }

    // === For maintainer ===

    fun init(ctx: &mut TxContext) {
        transfer(AuthorityCap {
            id: object::new(ctx),
            next_id: option::some(object::new(ctx)),
            next_index: 0,
            last_unix_ms: 0,
        }, tx_context::sender(ctx));
    }

    public entry fun stamp(
        unix_ms_now: u64,
        auth: &mut AuthorityCap,
        ctx: &mut TxContext,
    ) {
        assert!(unix_ms_now > auth.last_unix_ms, 0);

        let next_uid = object::new(ctx);
        let next_id = object::uid_to_inner(&next_uid);
        let id = option::swap(&mut auth.next_id, next_uid);

        freeze_object(Timestamp {
            id,
            unix_ms: unix_ms_now,
            index: auth.next_index,
            next: next_id,
        });

        auth.next_index = auth.next_index + 1;
        auth.last_unix_ms = unix_ms_now;
    }
}
