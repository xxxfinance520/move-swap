

module satoshi_flip::mycoin2 {
     use sui::coin::{Self, Coin, TreasuryCap};
     
    // use sui::transfer;
    // use sui::tx_context::{Self, TxContext};
  
    /// The type identifier of coin. The coin will have a type
    /// tag of kind: `Coin<package_object::mycoin::MYCOIN>`
    /// Make sure that the name of the type matches the module's name.
    public struct MYCOIN2 has drop {}
 
    /// Module initializer is called once on module publish. A treasury
    /// cap is sent to the publisher, who then controls minting and burning
    fun init(witness: MYCOIN2, ctx: &mut TxContext) {
        let (treasury, metadata) = coin::create_currency(witness, 6, b"MYCOIN2", b"", b"", option::none(), ctx);
        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury, tx_context::sender(ctx));
    }

  public fun mint(
    treasury_cap: &mut TreasuryCap<MYCOIN2>, 
    amount: u64, 
    recipient: address, 
    ctx: &mut TxContext,
  ) {
      let coin = coin::mint(treasury_cap, amount, ctx);
      transfer::public_transfer(coin, recipient)
  }

    #[test]
    fun test_mint() {
        use sui::test_scenario;

        // Create test addresses representing users
        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        // First transaction executed by initial owner to create the sword
        let mut scenario = test_scenario::begin(initial_owner);
        {
            let mycoin = MYCOIN2 {
            };
            init(mycoin, scenario.ctx());
            scenario.next_tx(initial_owner);
            // Create the sword and transfer it to the initial owner
            let mut treasuryCap = scenario.take_from_sender<TreasuryCap<MYCOIN2>>();
            let treasury_cap: &mut TreasuryCap<MYCOIN2> = &mut treasuryCap;
            mint( treasury_cap, 10000000, final_owner, scenario.ctx());
            scenario.return_to_sender(treasuryCap);
        };

        
        scenario.end();
    }
}