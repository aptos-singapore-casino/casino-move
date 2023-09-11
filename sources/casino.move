module casino_addr::casino {
    //==============================================================================================
    // Dependencies
    //==============================================================================================



    //==============================================================================================
    // Constants
    //==============================================================================================

    // Possible roulette outcomes
    const STRAIGHT_0: vector<u8> = <0>;
    const STRAIGHT_1: vector<u8> = <1>;
    const STRAIGHT_2: vector<u8> = <2>;
    const STRAIGHT_3: vector<u8> = <3>;
    const STRAIGHT_4: vector<u8> = <4>;
    const STRAIGHT_5: vector<u8> = <5>;
    const STRAIGHT_6: vector<u8> = <6>;
    const STRAIGHT_7: vector<u8> = <7>;
    const STRAIGHT_8: vector<u8> = <8>;
    const STRAIGHT_9: vector<u8> = <9>;
    const STRAIGHT_10: vector<u8> = <10>;
    const STRAIGHT_11: vector<u8> = <11>;
    const STRAIGHT_12: vector<u8> = <12>;
    const STRAIGHT_13: vector<u8> = <13>;
    const STRAIGHT_14: vector<u8> = <14>;
    const STRAIGHT_15: vector<u8> = <15>;
    const STRAIGHT_16: vector<u8> = <16>;
    const STRAIGHT_17: vector<u8> = <17>;
    const STRAIGHT_18: vector<u8> = <18>;
    const STRAIGHT_19: vector<u8> = <19>;
    const STRAIGHT_20: vector<u8> = <20>;
    const STRAIGHT_21: vector<u8> = <21>;
    const STRAIGHT_22: vector<u8> = <22>;
    const STRAIGHT_23: vector<u8> = <23>;
    const STRAIGHT_24: vector<u8> = <24>;
    const STRAIGHT_25: vector<u8> = <25>;
    const STRAIGHT_26: vector<u8> = <26>;
    const STRAIGHT_27: vector<u8> = <27>;
    const STRAIGHT_28: vector<u8> = <28>;
    const STRAIGHT_29: vector<u8> = <29>;
    const STRAIGHT_30: vector<u8> = <30>;
    const STRAIGHT_31: vector<u8> = <31>;
    const STRAIGHT_32: vector<u8> = <32>;
    const STRAIGHT_33: vector<u8> = <33>;
    const STRAIGHT_34: vector<u8> = <34>;
    const STRAIGHT_35: vector<u8> = <35>;
    const STRAIGHT_36: vector<u8> = <36>;
    const ODD: vector<u8> = <1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36>;
    const EVEN: vector<u8> = <2, 4, 6, 8, 10, 11, 13, 15, 17, 20, 22, 24, 26, 28, 29, 31, 33, 35>;
    const LOW: vector<u8> = <1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12>;
    const MID: vector<u8> = <13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24>;
    const HIGH: vector<u8> = <25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36>;
    const FIRST_DOZEN: vector<u8> = <1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12>;
    const SECOND_DOZEN: vector<u8> = <13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24>;
    const THIRD_DOZEN: vector<u8> = <25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36>;
    const FIRST_COLUMN: vector<u8> = <1, 4, 7, 10, 13, 16, 19, 22, 25, 28, 31, 34>;
    const SECOND_COLUMN: vector<u8> = <2, 5, 8, 11, 14, 17, 20, 23, 26, 29, 32, 35>;
    const THIRD_COLUMN: vector<u8> = <3, 6, 9, 12, 15, 18, 21, 24, 27, 30, 33, 36>;
    const FIRST_HALF: vector<u8> = <1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18>;
    const SECOND_HALF: vector<u8> = <19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36>;

    //==============================================================================================
    // Error codes
    //==============================================================================================

    const EInsufficientAptBalance: u64 = 0;
    const EGameDoesNotExist: u64: 1;

    
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
        // Boolean value indicating if any player has already claimed the prize
        prize_claimed: bool,
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
        play_time: date,
        // bets_per_player contain the bets of each player mapped to their address
        bets_per_player: SimpleMap<address, PlayerBets>,
        // outcome is value in range 0,36
        outcome: u8,
    }

    /*
        Struct representing a single player's bets
    */
    struct PlayerBets has store, drop, copy {
        bets: vector<Bet>
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
        amount: u128,
        token: coin;

    }

    //==============================================================================================
    // Event structs
    //==============================================================================================


    /*
        Event to be emitted when a player placed a bet
    */
    struct PlaceBetsEvent has store, drop {
        // TODO
    }

    /*
        Event to be emitted when the random number is drawn and the game is completed
    */
    struct ResultEvent has store, drop {
        // TODO
    }

    /*
        Event to be emitted when the player has won and they are payed out their winnings
    */
    struct PayoutWinnerEvent has store, drop {
        // TODO
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
        _player: &signer,
        _game_id: u128,
        _bets: PlayerBets
        ) acquires State {
            // TODO
    }

        /*
        Play the game with the players that have placed their bets. A random number is drawn,
        and players who have bets on the winning number get paid out.
        @param admin - signer representing the admin account
        @param game_id - ID of the game
    */
    public entry fun spin(
        _admin: &signer, 
        _game_id: u128
    ) acquires State {
        // TODO: Check if there are any bets placed
        // TODO: Generate random number
        // TODO: Payout winners
    }

    /*
        Gets and returns all games in a simple_map
        @returns - SimpleMap instance containing all games
    */
    #[view]
    public fun get_all_games(): SimpleMap<u128, Game> acquires State {
        // TODO: return vector with all games 
    }

    /*
        Returns outcome of the game with the corresponding game_id
        @param game_id - ID of the game
        @returns - u8 in range 0,36 representing the result
    */
    #[view]
    public fun get_game_result(_game_id: u128): u8 acquires State {
        // TODO: return result by game id
    }

    //==============================================================================================
    // Helper functions
    //==============================================================================================

    /*
        Creates the resource account address and returns it
        @returns - address of the resource account created in `init_module` function
    */
    inline fun get_resource_account_address(): address {    
        // TODO
    }

    
    inline fun calculate_payout() {
        // TODO
    }

    inline fun payout_player(_player_address: address, _apt_amount: u64) {
        // TODO
    }

    //==============================================================================================
    // Validation functions
    //==============================================================================================

    inline fun check_if_account_has_enough_apt_coins(_account: address, _apt_amount: u64) {
        false
        // TODO
    }

    inline fun check_if_signer_is_admin(_account: &signer) {
        false
        // TODO
    }

}