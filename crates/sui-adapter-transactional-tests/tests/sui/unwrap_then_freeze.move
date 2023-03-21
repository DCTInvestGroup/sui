// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// Exercise test functions that wrap and object and subsequently unwrap it
// Ensure that the object's version is consistent

//# init --addresses test=0x0 --accounts A

//# publish

module test::object_basics {
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;

    struct Object has key, store {
        id: UID,
        value: u64,
    }

    struct Wrapper has key {
        id: UID,
        o: Object
    }

    public entry fun create(value: u64, recipient: address, ctx: &mut TxContext) {
        transfer::transfer(
            Object { id: object::new(ctx), value },
            recipient
        )
    }

    public entry fun wrap(o: Object, ctx: &mut TxContext) {
        transfer::transfer(Wrapper { id: object::new(ctx), o }, tx_context::sender(ctx))
    }

    public entry fun unwrap_and_freeze(w: Wrapper) {
        let Wrapper { id, o } = w;
        object::delete(id);
        transfer::freeze_object(o)
    }
}

//# run test::object_basics::create --args 10 @A

//# view-object 107

//# run test::object_basics::wrap --args object(107) --sender A

//# run test::object_basics::unwrap_and_freeze --args object(109) --sender A

//# view-object 107