module challenge::marketplace;

use challenge::hero::Hero;
use sui::coin::{Self, Coin};
use sui::event;
use sui::sui::SUI;

// ========= ERRORS =========

const EInvalidPayment: u64 = 1;

// ========= STRUCTS =========

public struct ListHero has key, store {
    id: UID,
    nft: Hero,
    price: u64,
    seller: address,
}

// ========= CAPABILITIES =========

public struct AdminCap has key, store {
    id: UID,
}

// ========= EVENTS =========

public struct HeroListed has copy, drop {
    list_hero_id: ID,
    price: u64,
    seller: address,
    timestamp: u64,
}

public struct HeroBought has copy, drop {
    list_hero_id: ID,
    price: u64,
    buyer: address,
    seller: address,
    timestamp: u64,
}

// ========= FUNCTIONS =========

fun init(ctx: &mut TxContext) {
    let admin_cap = AdminCap {
        id: object::new(ctx),
    };
    transfer::public_transfer(admin_cap, ctx.sender());
    // NOTE: The init function runs once when the module is published
    // TODO: Initialize the module by creating AdminCap
    // Hints:
    // Create AdminCap id with object::new(ctx)
    // TODO: Transfer it to the module publisher (ctx.sender()) using transfer::public_transfer() function
}

public fun list_hero(nft: Hero, price: u64, ctx: &mut TxContext) {
    let list_hero = ListHero {
        id: object::new(ctx),
        nft: nft,
        price: price,
        seller: ctx.sender(),
    };
    let hero_listed = HeroListed {
        list_hero_id: object::id(&list_hero),
        price: price,
        seller: ctx.sender(),
        timestamp: ctx.epoch_timestamp_ms(),
    };
    sui::event::emit(hero_listed);
    transfer::share_object(list_hero);
}

#[allow(lint(self_transfer))]
public fun buy_hero(list_hero: ListHero, coin: Coin<SUI>, ctx: &mut TxContext) {
    let ListHero { id, nft, price, seller } = list_hero;
    assert!(coin.value() == price, EInvalidPayment);
    transfer::public_transfer(coin, seller);
    transfer::public_transfer(nft, ctx.sender());
    let hero_bought = HeroBought {
        list_hero_id: object::uid_to_inner(&id),
        price: price,
        buyer: ctx.sender(),
        seller: seller,
        timestamp: ctx.epoch_timestamp_ms(),
    };
    sui::event::emit(hero_bought);
    object::delete(id);
}

// ========= ADMIN FUNCTIONS =========

public fun delist(_: &AdminCap, list_hero: ListHero) {
    let ListHero { id, nft, price, seller } = list_hero;
    transfer::public_transfer(nft, seller);
    object::delete(id);
}

public fun change_the_price(_: &AdminCap, list_hero: &mut ListHero, new_price: u64) {
    list_hero.price = new_price;
}

// ========= GETTER FUNCTIONS =========

#[test_only]
public fun listing_price(list_hero: &ListHero): u64 {
    list_hero.price
}

// ========= TEST ONLY FUNCTIONS =========

#[test_only]
public fun test_init(ctx: &mut TxContext) {
    let admin_cap = AdminCap {
        id: object::new(ctx),
    };
    transfer::transfer(admin_cap, ctx.sender());
}