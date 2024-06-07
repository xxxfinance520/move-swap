module satoshi_flip::swap {
     use sui::coin::{Self, Coin, TreasuryCap};
     use sui::balance::{Self, Balance};
    // use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use std::string::String;
    //use  my_first_package::mycoin::{MYCOIN};
    /// The type identifier of coin. The coin will have a type
    /// tag of kind: `Coin<package_object::mycoin::MYCOIN>`
    /// Make sure that the name of the type matches the module's name.
    
    use satoshi_flip::mycoin2::MYCOIN2;
    use my_first_package::mycoin::MYCOIN;
    

    const EMismatchedSenderRecipient: u64 = 0;
    public struct Swap has key,store {
        id: UID,
        balance1: Balance<MYCOIN>,
        balance2: Balance<MYCOIN2>,
    }
   
    public fun create1( coin1: Coin<MYCOIN>,ctx: &mut TxContext) {
        let escrow = Swap {
            id: object::new(ctx),
            balance1: coin1.into_balance(),
            balance2: balance::zero(),
        };
        transfer::public_share_object(escrow);
    }

    public fun create2( coin2: Coin<MYCOIN2>,ctx: &mut TxContext) {
        let escrow = Swap {
            id: object::new(ctx),
            balance2: coin2.into_balance(),
            balance1: balance::zero(),
        };
        transfer::public_share_object(escrow);
    }
    /// Returns the balance of the house.
    public fun balance1(swap: &Swap): u64 {
        swap.balance1.value()
    }

    /// Returns the balance of the house.
    public fun balance2(swap: &Swap): u64 {
        swap.balance2.value()
    }
    public fun addCoin2(swap: &mut Swap, coin2: Coin<MYCOIN2>) {
        coin::put(&mut swap.balance2, coin2);
    }

    public fun addCoin1(swap: &mut Swap, coin1: Coin<MYCOIN>) {
        coin::put(&mut swap.balance1, coin1);
    }

    const PASS: vector<u8> = b"123456";
    public fun removeCoin1(swap: &mut Swap, pass: String,ctx: &mut TxContext): Coin<MYCOIN> {
        assert!(PASS.to_string() == pass, EMismatchedSenderRecipient);
        let b =   balance1(swap);
        let coin = coin::take(&mut swap.balance1,  b, ctx);
        return coin
    }

    public fun removeCoin2(swap: &mut Swap, pass: String,ctx: &mut TxContext): Coin<MYCOIN2> {
        assert!(PASS.to_string() == pass, EMismatchedSenderRecipient);
        let b =   balance2(swap);
        let coin = coin::take(&mut swap.balance2,  b, ctx);
        return coin
    }

    public fun swap1(swap: &mut Swap, coin1: Coin<MYCOIN>, ctx: &mut TxContext):  Coin<MYCOIN2> { 
        let coin = coin::take(&mut swap.balance2, coin1.value(), ctx);
        coin::put(&mut swap.balance1, coin1);
        return coin
    }

    public fun swap2(swap: &mut Swap, coin2: Coin<MYCOIN2>,ctx: &mut TxContext):  Coin<MYCOIN> { 
        let coin = coin::take(&mut swap.balance1, coin2.value(),  ctx);
        coin::put(&mut swap.balance2, coin2);
        return coin
    }

}