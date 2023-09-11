module casino_addr::casino {
    //==============================================================================================
    // Dependencies
    //==============================================================================================

    use aptos_framework::coin;
    use aptos_framework::timestamp;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::event::{Self, EventHandle};
    use aptos_framework::account::{Self, SignerCapability};
    use aptos_std::simple_map::{Self, SimpleMap};

    // NOTE: AIP-41, if deployed, this would be aptos_std (or aptos_framework).
    use aptos_std_extra::randomness;

    use std::signer;
    use std::vector;
    use std::option::{Self, Option};

    // seed for the module's resource account
    const SEED: vector<u8> = b"Casino";

    //==============================================================================================
    // Constants
    //==============================================================================================

    const MIN_ROULETTE_OUTCOME: u64 = 0;
    const MAX_ROULETTE_OUTCOME: u64 = 36;

    // Possible roulette outcomes
    const STRAIGHT_0: vector<u8> = vector[0];
    const STRAIGHT_1: vector<u8> = vector [1];
    const STRAIGHT_2: vector<u8> = vector [2];
    const STRAIGHT_3: vector<u8> = vector [3];
    const STRAIGHT_4: vector<u8> = vector [4];
    const STRAIGHT_5: vector<u8> = vector [5];
    const STRAIGHT_6: vector<u8> = vector [6];
    const STRAIGHT_7: vector<u8> = vector [7];
    const STRAIGHT_8: vector<u8> = vector [8];
    const STRAIGHT_9: vector<u8> = vector [9];
    const STRAIGHT_10: vector<u8> = vector [10];
    const STRAIGHT_11: vector<u8> = vector [11];
    const STRAIGHT_12: vector<u8> = vector [12];
    const STRAIGHT_13: vector<u8> = vector [13];
    const STRAIGHT_14: vector<u8> = vector [14];
    const STRAIGHT_15: vector<u8> = vector [15];
    const STRAIGHT_16: vector<u8> = vector [16];
    const STRAIGHT_17: vector<u8> = vector [17];
    const STRAIGHT_18: vector<u8> = vector [18];
    const STRAIGHT_19: vector<u8> = vector [19];
    const STRAIGHT_20: vector<u8> = vector [20];
    const STRAIGHT_21: vector<u8> = vector [21];
    const STRAIGHT_22: vector<u8> = vector [22];
    const STRAIGHT_23: vector<u8> = vector [23];
    const STRAIGHT_24: vector<u8> = vector [24];
    const STRAIGHT_25: vector<u8> = vector [25];
    const STRAIGHT_26: vector<u8> = vector [26];
    const STRAIGHT_27: vector<u8> = vector [27];
    const STRAIGHT_28: vector<u8> = vector [28];
    const STRAIGHT_29: vector<u8> = vector [29];
    const STRAIGHT_30: vector<u8> = vector [30];
    const STRAIGHT_31: vector<u8> = vector [31];
    const STRAIGHT_32: vector<u8> = vector [32];
    const STRAIGHT_33: vector<u8> = vector [33];
    const STRAIGHT_34: vector<u8> = vector [34];
    const STRAIGHT_35: vector<u8> = vector [35];
    const STRAIGHT_36: vector<u8> = vector [36];
    const ODD: vector<u8> = vector [1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36];
    const EVEN: vector<u8> = vector [2, 4, 6, 8, 10, 11, 13, 15, 17, 20, 22, 24, 26, 28, 29, 31, 33, 35];
    const LOW: vector<u8> = vector [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
    const MID: vector<u8> = vector [13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24];
    const HIGH: vector<u8> = vector [25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36];
    const FIRST_DOZEN: vector<u8> = vector [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
    const SECOND_DOZEN: vector<u8> = vector [13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24];
    const THIRD_DOZEN: vector<u8> = vector [25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36];
    const FIRST_COLUMN: vector<u8> = vector [1, 4, 7, 10, 13, 16, 19, 22, 25, 28, 31, 34];
    const SECOND_COLUMN: vector<u8> = vector [2, 5, 8, 11, 14, 17, 20, 23, 26, 29, 32, 35];
    const THIRD_COLUMN: vector<u8> = vector [3, 6, 9, 12, 15, 18, 21, 24, 27, 30, 33, 36];
    const FIRST_HALF: vector<u8> = vector [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18];
    const SECOND_HALF: vector<u8> = vector [19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36];

    //==============================================================================================
    // Error codes
    //==============================================================================================

    const EInsufficientAptBalance: u64 = 0;
    const ESignerIsNotAdmin: u64 = 1;
    const EGameDoesNotExist: u64 = 2;
    const EInvalidBetSelected: u64 = 3;
    const EGameIsNotFinished: u64 = 4;
    const EGameIsFinished: u64 = 5;

    const ENotImplemented: u64 = 99;
    


    
    //==============================================================================================
    // Module Structs
    //==============================================================================================

    /*
        Resource struct holding data about the games, prize, and events
    */
    struct State has key {
        // ID of the next game - IDs start at 0
        next_game_id: u128,
        // SimpleMap instance mapping game IDs to Game instances
        games: SimpleMap<u128, Game>,
        // Resource account's SignerCapability
        cap: SignerCapability,
        // Events
        place_bets_events: EventHandle<PlaceBetsEvent>,
        result_events: EventHandle<ResultEvent>,
        payout_winner_events: EventHandle<PayoutWinnerEvent>,
    }

    /*
        Struct representing a single game
    */
    struct Game has store, drop, copy {
        // play_time is the start time of the game, no more bets can be placed after this moment.
        play_time: u64,
        // player_bets contain the bets of each player mapped to their address
        player_bets: SimpleMap<address, vector<Bet>>,
        // outcome is value in range 0,36 and empty for game that is not finished
        outcome: Option<u8>,

    }
    
    /*
        Struct representing different betting options and the amount bet on each
    */
    struct Bet has store, drop, copy {
        // selection is the range that the bet is placed on
        // For a straight up bet it's a single value
        // For a bet on "even" it's all even values (0 excluded)
        // Note: See constant values for possible outcomes 
        selection: vector<u8>,
        amount: u128

    }

    //==============================================================================================
    // Event structs
    //==============================================================================================

    /*
        Event to be emitted when a player placed a bet
    */
    struct PlaceBetsEvent has store, drop {
        game_id: u128,
        player_address: address,
        bets: vector<Bet>,
        event_creation_timestamp_in_seconds: u64
    }

    /*
        Event to be emitted when the random number is drawn and the game is completed
    */
    struct ResultEvent has store, drop {
        game_id: u128,
        game_result: u8,
        event_creation_timestamp_in_seconds: u64
    }

    /*
        Event to be emitted when the player has won and they are payed out their winnings
    */
    struct PayoutWinnerEvent has store, drop {
        // TODO: Should we do 1 event for all players or multiple events for each player?
        // Current implementation: 1 event for each player payout
        game_id: u128,
        player_address: address,
        amount: u256,
        event_creation_timestamp_in_seconds: u64
    }

    //==============================================================================================
    // Functions
    //==============================================================================================

    /*
        Function called at the deployment time
        @param admin - signer representing the admin account
    */
    fun init_module(admin: &signer) {
        // TODO
    }

    /*
        Registers the bet for a specific game.
        @param player - player participating in the game
        @param game_id - ID of the game
        @param bets - a vector of all the bets the player wants to play this game
    */
    public entry fun place_bet(
        player: &signer,
        game_id: u128,
        bets: vector<Bet>
        ) acquires State {

            let resource_account_address = get_resource_account_address();
            let state = borrow_global_mut<State>(resource_account_address);
            let player_address = signer::address_of(player);

            // TODO: place bet and add to state of game 


            event::emit_event<PlaceBetsEvent>(
            &mut state.place_bets_events,
            PlaceBetsEvent {
                game_id: game_id,
                player_address: player_address,
                bets: bets,
                event_creation_timestamp_in_seconds: timestamp::now_seconds()
            }
        );
    }

    /*
        Play the game with the players who have placed their bets. A random number is drawn,
        and players who have placed bets on the winning number receive their respective payout.
        @param admin - signer representing the admin account
        @param game_id - ID of the game
        @returns - u8 with random spin outcome (range 0,36 inclusive)
    */
    public entry fun spin(
        admin: &signer, 
        game_id: u128
    ) acquires State {
        // Checks
        check_if_signer_is_admin(admin);


        let resource_account_address = get_resource_account_address();
        let state = borrow_global_mut<State>(resource_account_address);

        // Get game by game_id
        let game = simple_map::borrow_mut(&mut state.games, &game_id);
        check_if_game_is_not_finished(game);

        // Generate random number using randomness module
        let spin_outcome = (randomness::u64_range(
            MIN_ROULETTE_OUTCOME,
            MAX_ROULETTE_OUTCOME + 1
        ) as u8);

        // Save the outcome in the game struct
        game.outcome = option::some(spin_outcome);

        // Emit ResultEvent
        // event::emit_event<ResultEvent>(
        // &mut state.result_events,
        // ResultEvent {
        //     game_id: game_id,
        //     game_result: spin_outcome,
        //     event_creation_timestamp_in_seconds: timestamp::now_seconds()
        // }
        // );

        // TODO: Check results for each player
        // apt_amount = calculate_result();

        // TODO: Payout winners


        // TODO: Create a new game

        let current_game_id = 0;
        simple_map::add(
            &mut state.games, 
            current_game_id,
            Game {
                play_time: 0,
                player_bets: simple_map::create(),
                outcome: option::none()
            });

        // TODO: Returns the random outcome
    }

    /*
        Gets and returns all games in a simple_map
        @returns - SimpleMap instance containing all games
    */
    // #[view]
    // public fun get_all_games(): SimpleMap<u128, Game> acquires State {
    //     // TODO: return vector with all games 
    // }

    /*
        Returns outcome of the game with the corresponding game_id
        @param game_id - ID of the game
        @returns - u8 in range 0,36 representing the result
    */
    // #[view]
    // public fun get_game_result(_game_id: u128): u8 acquires State {
    //     // TODO: return result by game id
    // }

    //==============================================================================================
    // Helper functions
    //==============================================================================================

    /*
        Creates the resource account address and returns it
        @returns - address of the resource account created in `init_module` function
    */
    inline fun get_resource_account_address(): address {    
        account::create_resource_address(&@casino_addr, SEED)        
    }

    
    // inline fun calculate_payout() {
    //     // TODO
    // }

    // inline fun payout_player(_player_address: address, _apt_amount: u64) {

    // }

    // inline fun close_game(_game_id: u128) {

    // }

    // inline fun payout_player(_player_address: address, _apt_amount: u64) {

    // }



    //==============================================================================================
    // Validation functions
    //==============================================================================================

    inline fun check_if_account_has_enough_apt_coins(account: address, apt_amount: u64) {
        assert!(coin::balance<AptosCoin>(account) >= apt_amount, EInsufficientAptBalance);

    }

    inline fun check_if_signer_is_admin(account: &signer) {
        assert!(signer::address_of(account) == @casino_addr,ESignerIsNotAdmin);
        // TODO: check if the casino_addr is correct to use here
    }

    inline fun check_if_player_has_placed_bet(_account: &signer) {
        assert!(false,ENotImplemented);
        // TODO: copy paste this to create new validation function
    }
    
    inline fun check_if_bets_are_valid(_account: &signer, _bets: &vector<Bet>) {
        assert!(false,ENotImplemented);
        // TODO: copy paste this to create new validation function
    }

    inline fun check_for_nonzero_bets_placed(_account: &signer) {
        assert!(false,ENotImplemented);
        // TODO: copy paste this to create new validation function
    }

    inline fun dummy_check(_account: &signer) {
        assert!(false,ENotImplemented);
        // TODO: copy paste this to create new validation function
    }

    inline fun check_if_game_is_not_finished(game: &Game) {
        assert!(option::is_none(&game.outcome),EGameIsFinished);
    }

    inline fun check_if_game_is_finished(game: &Game) {
        assert!(option::is_some(&game.outcome),EGameIsNotFinished);
    }

    

    //==============================================================================================
    // Tests
    //==============================================================================================

}