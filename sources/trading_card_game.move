module TradingCardGame::CardGame {
    use std::string::String;
    use aptos_framework::object::{Self, Object};
    use aptos_framework::signer;
    
    // Error codes
    const EINVALID_POWER: u64 = 1;
    const ENOT_OWNER: u64 = 2;
    
    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    /// Represents a trading card with attributes
    struct Card has key {
        name: String,
        power: u64,
        card_type: String,
    }

    /// Creates a new trading card
    public fun create_card(
        creator: &signer,
        name: String,
        power: u64,
        card_type: String,
    ): Object<Card> {
        // Validate power value (let's say power should be between 1 and 100)
        assert!(power > 0 && power <= 100, EINVALID_POWER);
        
        // Create a new token object with a seed based on name
        let constructor_ref = object::create_object(signer::address_of(creator));
        
        // Create the card with given attributes
        let card = Card {
            name,
            power,
            card_type,
        };
        
        let object_signer = object::generate_signer(&constructor_ref);
        move_to(&object_signer, card);
        
        object::object_from_constructor_ref(&constructor_ref)
    }

    /// Trade a card between two players
    public fun trade_card(
        from: &signer,
        to: address,
        card: Object<Card>
    ) {
        // Verify the sender owns the card
        assert!(
            object::owner(card) == signer::address_of(from),
            ENOT_OWNER
        );
        
        // Transfer the card to the recipient
        object::transfer(from, card, to);
    }

    #[test_only]
    /// Function to create a test card (only used in testing)
    public fun create_test_card(creator: &signer): Object<Card> {
        create_card(
            creator,
            string::utf8(b"Test Card"),
            50,
            string::utf8(b"Warrior")
        )
    }
}
