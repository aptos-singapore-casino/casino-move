module casino_addr::casino {
    //==============================================================================================
    // Dependencies
    //==============================================================================================

    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::account::{Self, SignerCapability};
    use aptos_std::simple_map::{Self, SimpleMap};


    // use aptos_framework::timestamp;
    use aptos_framework::event::{Self, EventHandle};

    // NOTE: AIP-41, if deployed, this would be aptos_std (or aptos_framework).
    use aptos_std_extra::randomness;

    use std::signer;
    use std::vector;
    use std::option::{Self, Option};

    // #[test_only]
    use aptos_framework::aptos_coin;


    //==============================================================================================
    // Constants
    //==============================================================================================

    // seed for the module's resource account
    const SEED: vector<u8> = b"Casino";

    const MIN_ROULETTE_OUTCOME: u8 = 0;
    const MAX_ROULETTE_OUTCOME: u8 = 36;

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

    const RED: vector<u8> = vector[1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36];
    const BLACK: vector<u8> = vector[2, 4, 6, 8, 10, 11, 13, 15, 17, 20, 22, 24, 26, 28, 29, 31, 33, 35];
    const ODD: vector<u8> = vector[1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31, 33, 35];
    const EVEN: vector<u8> = vector[2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36];
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
    const EVectorsAreNotSameLength: u64 = 6;
    const EPlayerHasNotPlacedBet: u64 = 7;
    const EPlayerHasAlreadyPlacedBet: u64 = 8;

    // Use this for not implemented errors
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
        // TODO: Implement timed spins
        play_time: u64,
        // player_bets contain the bets of each player mapped to their address
        players_bets: SimpleMap<address, vector<Bet>>,
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
        Event to be emitted when a player is getting a payout
    */
    struct PayoutWinnerEvent has store, drop {
        game_id: u128,
        player_address: address,
        amount: u128,
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

        let (resource, signer_cap) = account::create_resource_account(admin, SEED);
        coin::register<AptosCoin>(&resource);
        let resource_account_signer = account::create_signer_with_capability(&signer_cap);
        
        let next_game_id = 0;
        let games = simple_map::create();

        // Create a new game
        let current_game_id = get_next_game_id(&mut next_game_id);
        start_new_game(&mut games, current_game_id);

        move_to(&resource,
            State {
                next_game_id: next_game_id,
                games: games,
                cap: signer_cap,
                place_bets_events: account::new_event_handle<PlaceBetsEvent>(&resource_account_signer),
                result_events: account::new_event_handle<ResultEvent>(&resource_account_signer),
                payout_winner_events: account::new_event_handle<PayoutWinnerEvent>(&resource_account_signer),
            }
        )
    }

    /*
        Registers the bet for a specific game.
        @param player - player participating in the game
        @param game_id - ID of the game
        @param bets - a vector of all the bets the player wants to play this game
    */
    public entry fun place_bets(
        player: &signer,
        selections: vector<vector<u8>>,
        amounts: vector<u128>,
        ) acquires State {
            let resource_account_address = get_resource_account_address();
            let state = borrow_global_mut<State>(resource_account_address);
            let resource_account_signer = account::create_signer_with_capability(&state.cap);
            let player_address = signer::address_of(player);
            let game_id = (state.next_game_id -1);
            let game = simple_map::borrow_mut(&mut state.games, &game_id);

            // let player_bets = simple_map::borrow_mut(&mut game.players_bets, &player_address);

            // Create bets vector based on inputs and add to player_bets
            check_if_vectors_are_same_length(selections, amounts);
            let player_bets = vector::empty();
            while (!vector::is_empty(&amounts)) {
                let bet = Bet{
                    // TODO: change this to vector::zip
                    selection: vector::pop_back(&mut selections), 
                    amount: vector::pop_back(&mut amounts)
                    };
                vector::push_back(&mut player_bets, bet)
            };

            // Check if map is empty, if not empty it and payback player before registering the new bet
            // TODO: Make this integrated in 1 single payment. Check if this could be exploitable somehow?
            if (simple_map::contains_key(&game.players_bets, &player_address)) {
                let previous_bets = simple_map::borrow(&game.players_bets, &player_address);
                let previous_bet_amount = calculate_total_bet_amount(*previous_bets);
                simple_map::remove(&mut game.players_bets, &player_address);
                coin::transfer<AptosCoin>(&resource_account_signer, player_address, (previous_bet_amount as u64));
            };

            // Register player_bets and receive payment from player
            simple_map::add(&mut game.players_bets, player_address, player_bets);
            let bet_amount = calculate_total_bet_amount(player_bets);
            coin::transfer<AptosCoin>(player, resource_account_address, (bet_amount as u64));

            // Emit PlaceBetsEvent
            event::emit_event<PlaceBetsEvent>(
            &mut state.place_bets_events,
            PlaceBetsEvent {
                game_id: game_id,
                player_address: player_address,
                bets: player_bets,
                event_creation_timestamp_in_seconds: 0
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
        // admin: &signer,
    ) acquires State {
        // // For hackathon purposes we allow everyone to spin
        // check_if_signer_is_admin(admin);

        let resource_account_address = get_resource_account_address();
        let state = borrow_global_mut<State>(resource_account_address);

        // Get game by game_id
        let game_id = (state.next_game_id -1);
        let game = simple_map::borrow_mut(&mut state.games, &game_id);
        check_if_game_is_not_finished(game);

        // Generate outcome using randomness module and save in game strut
        // TODO implement randomness
        let spin_outcome = (randomness::u64_range(
            (MIN_ROULETTE_OUTCOME as u64),
            (MAX_ROULETTE_OUTCOME + 1 as u64)
        ) as u8);
        game.outcome = option::some(spin_outcome);

        // Emit ResultEvent
        event::emit_event<ResultEvent>(
        &mut state.result_events,
        ResultEvent {
            game_id: game_id,
            game_result: spin_outcome,
            event_creation_timestamp_in_seconds: 0
        }
        );
        
        // // Loop over all players to payout any winners
        let resource_account_signer = account::create_signer_with_capability(&state.cap);
        let players = simple_map::keys(&game.players_bets);
        vector::for_each(players, |player_address| {
            
            // Calculate and pay winning players
            let player_bets = simple_map::borrow_mut(&mut game.players_bets, &player_address);
            let apt_amount_won = calculate_total_payout(*player_bets, &spin_outcome);
            if (apt_amount_won > 0) {
                coin::transfer<AptosCoin>(&resource_account_signer, player_address, (apt_amount_won as u64));
            };


            // Emit PayoutWinnerEvent including 0 winnings which don't get a payout
            event::emit_event<PayoutWinnerEvent>(
            &mut state.payout_winner_events,
            PayoutWinnerEvent {
                game_id: game_id,
                player_address: player_address,
                amount: apt_amount_won,
                event_creation_timestamp_in_seconds: 0
            }
            );
        });

        // Start the next game
        let current_game_id = get_next_game_id(&mut state.next_game_id);
        start_new_game(&mut state.games, current_game_id);
    }

    /*
        Gets and returns all games in a simple_map
        @returns - SimpleMap instance containing all games
    */
    #[view]
    public fun get_all_games(): SimpleMap<u128, Game> acquires State {
        let resource_account_address = get_resource_account_address();
        let state = borrow_global_mut<State>(resource_account_address);
        state.games
    }

    /*
        Returns outcome of the game with the corresponding game_id
        @param game_id - ID of the game
        @returns - u8 in range 0,36 representing the result
    */
    #[view]
    public fun get_game_result(game_id: u128): u8 acquires State {
        let resource_account_address = get_resource_account_address();
        let state = borrow_global_mut<State>(resource_account_address);

        check_if_game_exists(&state.games, &game_id);

        let game = simple_map::borrow(&state.games, &game_id);
        check_if_game_is_finished(game);

        *option::borrow(&game.outcome)   
    }

    // /*
    //     Creates the resource account address and returns it
    //     @returns - address of the resource account created in `init_module` function
    // */
    #[view]
    public fun get_resource_account_address(): address {
        account::create_resource_address(&@casino_addr, SEED)   
        
    }

    //==============================================================================================
    // Helper functions
    //==============================================================================================

    /*
        Calculate the total payout for a vector of bets and an outcome
        @returns - payout amount as u128 
    */
    inline fun calculate_total_payout(bets: vector<Bet>, outcome: &u8): u128 {
        let total_payout: u128 = 0;
        vector::for_each(bets, |bet| {
            total_payout = total_payout + calculate_single_payout(&bet, outcome)
        });
        total_payout
    }

    /*
        Calculate the payout for a single bet and an outcome
        @returns - payout amount as u128 
    */
    inline fun calculate_single_payout(bet: &Bet, outcome: &u8): u128 {
        let win_amount = 0;
        if (vector::contains(&bet.selection, outcome)) {
            std::debug::print(&bet.selection);
            let selection2 = vector::borrow(&bet.selection,0);
            std::debug::print(selection2);
            win_amount = (bet.amount * (MAX_ROULETTE_OUTCOME as u128)) / (vector::length(&bet.selection) as u128);
        };
        win_amount
    }

    inline fun get_next_game_id(next_game_id: &mut u128): u128 {
        let current_value = *next_game_id;
        *next_game_id = current_value +1;
        current_value
    }

    inline fun start_new_game(games: &mut SimpleMap<u128, Game>, current_game_id: u128) {
        simple_map::add(
            games,
            current_game_id,
            Game {
                play_time: 0,
                players_bets: simple_map::create(),
                outcome: option::none()
            }
        );
    }

     inline fun get_bet_amount(bet: &Bet): u128 {
        bet.amount
    }
    
    inline fun calculate_total_bet_amount(bets: vector<Bet>): u128 {
        let total_bet_amount: u128 = 0;
        vector::for_each<Bet>(bets, |bet| {
            total_bet_amount = total_bet_amount + get_bet_amount(&bet);
        });
        total_bet_amount
    }

    //==============================================================================================
    // Validation functions
    //==============================================================================================

    inline fun check_if_account_has_enough_apt_coins(account: address, apt_amount: u64) {
        assert!(coin::balance<AptosCoin>(account) >= apt_amount, EInsufficientAptBalance);

    }

    inline fun check_if_signer_is_admin(account: &signer) {
        assert!(signer::address_of(account) == @casino_addr,ESignerIsNotAdmin);
    }

    inline fun check_if_bets_are_valid(bets: vector<Bet>) {
        vector::for_each(bets, |bet| {
            check_if_bet_selection_is_valid(&bet);
        });
    }

    inline fun check_if_bet_selection_is_valid(bet: &Bet) {
            vector::for_each(bet.selection, |selection| {
                assert!(selection >= MIN_ROULETTE_OUTCOME && selection <= MAX_ROULETTE_OUTCOME ,EInvalidBetSelected);
            });
    }

    inline fun check_if_game_is_not_finished(game: &Game) {
        assert!(option::is_none(&game.outcome),EGameIsFinished);
    }

    inline fun check_if_game_is_finished(game: &Game) {
        assert!(option::is_some(&game.outcome),EGameIsNotFinished);
    }

    inline fun check_if_vectors_are_same_length(selections: vector<vector<u8>>, amounts: vector<u128>) {
        assert!(vector::length(&selections) == vector::length(&amounts), EVectorsAreNotSameLength);
        // TODO selections counts double, fix this
    }

    inline fun check_if_game_exists(games: &SimpleMap<u128, Game>, game_id: &u128) {
        assert!(simple_map::contains_key(games, game_id), EGameDoesNotExist);
    }
    

    //==============================================================================================
    // Tests
    //==============================================================================================

    #[test]
    fun test_init_module() acquires State {
        let casino = account::create_account_for_test(@casino_addr);
        coin::register<AptosCoin>(&casino);
        init_module(&casino);

        let resource_account_address = account::create_resource_address(&@casino_addr, SEED);
        let state = borrow_global<State>(resource_account_address);
        assert!(state.next_game_id == 1, 0);
        assert!(simple_map::length(&state.games) == 1, 1);
        let games = get_all_games();
        assert!(simple_map::length(&games) == 1, 2);
    }

    #[test]
    fun test_spin_empty_game() acquires State {
        let casino = account::create_account_for_test(@casino_addr);
        coin::register<AptosCoin>(&casino);
        init_module(&casino);

        spin();
        
        let resource_account_address = account::create_resource_address(&@casino_addr, SEED);
        let state = borrow_global<State>(resource_account_address);
        assert!(state.next_game_id == 2, 0);
        assert!(simple_map::length(&state.games) == 2, 1);
        let games = get_all_games();
        assert!(simple_map::length(&games) == 2, 2);
    }

    #[test]
    fun test_bet_on_game_and_receive_winnings() acquires State {
        let aptos_framework = account::create_account_for_test(@aptos_framework);
        let player = account::create_account_for_test(@player_addr);
        let casino = account::create_account_for_test(@casino_addr);
        init_module(&casino);

        // Mint APT for player
        let (burn_cap, mint_cap) =
            aptos_coin::initialize_for_test(&aptos_framework);
        coin::register<AptosCoin>(&player);
        aptos_coin::mint(&aptos_framework, @player_addr, 100);
        
        // Place bets and spin
        place_bets(&player,vector[vector[0], vector[1]], vector[1,50]);
        spin();
        let outcome = get_game_result(0);
        assert!(outcome == 0, 0);
        assert!(coin::balance<AptosCoin>(@player_addr) == (100 - 1 - 50 + 36), 2);
        coin::destroy_burn_cap(burn_cap);
        coin::destroy_mint_cap(mint_cap);
    }

    #[test]
    fun test_calculate_single_payout_win() {
        let amount: u128 = 10;
        let bet_odd = Bet {
            selection: ODD,
            amount: amount
        };
        let winnings = calculate_single_payout(&bet_odd, &11);
        assert!(winnings == 20, 0);
    }

    #[test]
    fun test_calculate_single_payout_lose() {
        let amount: u128 = 10;
        let bet_odd = Bet {
            selection: ODD,
            amount: amount
        };
        let winnings = calculate_single_payout(&bet_odd, &10);
        assert!(winnings == 0, 0);
    }

    
    #[test]
    fun test_calculate_single_straight_payout_win() {
        let amount: u128 = 1;
        let bet_odd = Bet {
            selection: STRAIGHT_0,
            amount: amount
        };
        let winnings = calculate_single_payout(&bet_odd, &0);
        assert!(winnings == 36, 0);
    }
    
    #[test]
    fun test_calculate_total_payout_win_all() {
        let bets = vector::empty();
        vector::push_back(&mut bets, Bet {
            selection: STRAIGHT_14,
            amount: 1
        });
        vector::push_back(&mut bets, Bet {
            selection: EVEN,
            amount: 1
        });
        let winnings = calculate_total_payout(bets, &14);
        assert!(winnings == 38, 0);
        let total_bet_amount = calculate_total_bet_amount(bets);
        assert!(total_bet_amount == 2, 0);
    }
    
    #[test]
    fun test_calculate_total_payout_win_mixed() {
        let bets = vector::empty();
        vector::push_back(&mut bets, Bet {
            selection: STRAIGHT_14,
            amount: 1
        });
        vector::push_back(&mut bets, Bet {
            selection: EVEN,
            amount: 1
        });
        let winnings = calculate_total_payout(bets, &8);
        assert!(winnings == 2, 0);
        let total_bet_amount = calculate_total_bet_amount(bets);
        assert!(total_bet_amount == 2, 0);
    }

    #[test]
    fun test_calculate_total_payout_lose() {
        let bets = vector::empty();
        vector::push_back(&mut bets, Bet {
            selection: STRAIGHT_0,
            amount: 1
        });
        vector::push_back(&mut bets, Bet {
            selection: STRAIGHT_1,
            amount: 1
        });
        vector::push_back(&mut bets, Bet {
            selection: STRAIGHT_36,
            amount: 1
        });
        vector::push_back(&mut bets, Bet {
            selection: EVEN,
            amount: 1
        });
        check_if_bets_are_valid(bets);
        let winnings = calculate_total_payout(bets, &9);
        assert!(winnings == 0, 0);
        let total_bet_amount = calculate_total_bet_amount(bets);
        assert!(total_bet_amount == 4, 0);
    }

    #[test]
    #[expected_failure(abort_code = EInvalidBetSelected, location = Self)]
    fun test_invalid_bet_selected() {
        let bets = vector::empty();
        vector::push_back(&mut bets, Bet {
            selection: vector[37],
            amount: 1
        });
        vector::push_back(&mut bets, Bet {
            selection: EVEN,
            amount: 1
        });
        check_if_bets_are_valid(bets);
    }
}