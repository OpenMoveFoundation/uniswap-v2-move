#[test_only]
module uniswap_v2::factory_tests {
    use std::signer;
    use std::vector;

    use aptos_std::math64::pow;

    use aptos_framework::account;
    use aptos_framework::object;
    use uniswap_v2::factory;
    use uniswap_v2::pair;
    use uniswap_v2::owner_tests;
    use uniswap_v2::test_coins;
    use uniswap_v2::usdt_token;
    use uniswap_v2::usdc_token;

    #[test(admin = @admin, deployer = @uniswap_v2, bob = @bob)]
    public fun create_pair(
        admin: &signer, deployer: &signer, bob: &signer
    ) {
        account::create_account_for_test(signer::address_of(bob));
        owner_tests::setup_test_with_genesis(deployer);

        test_coins::init_coins();

        test_coins::mint_usdt(admin, signer::address_of(bob), 100 * pow(10, 8));
        test_coins::mint_usdc(admin, signer::address_of(bob), 100 * pow(10, 8));

        let usdt_metadata = usdt_token::metadata();
        let usdc_metadata = usdc_token::metadata();

        let usdt_address = usdt_token::usdt_token_address();
        let usdc_address = usdc_token::usdc_token_address();

        factory::create_pair(bob, usdt_address, usdc_address);

        let expected_pair_address = factory::get_pair(usdt_address, usdc_address);
        let created_pair_address =
            pair::liquidity_pool_address(usdt_metadata, usdc_metadata);
        assert!(created_pair_address == expected_pair_address, 0);

        let all_pairs = factory::all_pairs();
        let first_pair = *vector::borrow(&all_pairs, 0);
        assert!(first_pair == expected_pair_address, 1);

        let all_pairs_length = factory::all_pairs_length();
        assert!(all_pairs_length == 1, 2);
    }

    #[test(deployer = @uniswap_v2)]
    public fun test_initialization(deployer: &signer) {
        owner_tests::setup_test_with_genesis(deployer);
        assert!(factory::is_initialized(), 0);
    }

    #[test(deployer = @uniswap_v2, bob = @bob)]
    #[expected_failure(abort_code = 1, location = uniswap_v2::factory)]
    // amm_errors::identical_addresses
    public fun test_create_pair_identical_tokens(
        deployer: &signer, bob: &signer
    ) {
        account::create_account_for_test(signer::address_of(bob));
        owner_tests::setup_test_with_genesis(deployer);
        test_coins::init_coins();

        let usdt_address = usdt_token::usdt_token_address();
        factory::create_pair(bob, usdt_address, usdt_address);
    }

    #[test(deployer = @uniswap_v2, bob = @bob)]
    #[expected_failure(abort_code = 2, location = uniswap_v2::factory)]
    // amm_errors::pair_exists
    public fun test_create_duplicate_pair(
        deployer: &signer, bob: &signer
    ) {
        account::create_account_for_test(signer::address_of(bob));
        owner_tests::setup_test_with_genesis(deployer);
        test_coins::init_coins();

        let usdt_address = usdt_token::usdt_token_address();
        let usdc_address = usdc_token::usdc_token_address();

        factory::create_pair(bob, usdt_address, usdc_address);
        // Try to create the same pair again
        factory::create_pair(bob, usdt_address, usdc_address);
    }

    #[test(deployer = @uniswap_v2, bob = @bob)]
    public fun test_get_pair_nonexistent(
        deployer: &signer, bob: &signer
    ) {
        account::create_account_for_test(signer::address_of(bob));
        owner_tests::setup_test_with_genesis(deployer);
        test_coins::init_coins();

        let usdt_address = usdt_token::usdt_token_address();
        let usdc_address = usdc_token::usdc_token_address();

        let pair_address = factory::get_pair(usdt_address, usdc_address);
        assert!(pair_address == @0x0, 0);
    }

    #[test(deployer = @uniswap_v2, bob = @bob)]
    public fun test_pair_exists_functions(
        deployer: &signer, bob: &signer
    ) {
        account::create_account_for_test(signer::address_of(bob));
        owner_tests::setup_test_with_genesis(deployer);
        test_coins::init_coins();

        let usdt_metadata = usdt_token::metadata();
        let usdc_metadata = usdc_token::metadata();

        let usdt_address = usdt_token::usdt_token_address();
        let usdc_address = usdc_token::usdc_token_address();

        // Test before pair creation
        assert!(!factory::pair_exists(usdt_metadata, usdc_metadata), 0);
        assert!(!factory::pair_exists_safe(usdt_metadata, usdc_metadata), 1);

        // Create pair
        factory::create_pair(bob, usdt_address, usdc_address);
        let pair_address = factory::get_pair(usdt_address, usdc_address);

        // Test after pair creation
        assert!(factory::pair_exists(usdt_metadata, usdc_metadata), 2);
        assert!(factory::pair_exists_safe(usdt_metadata, usdc_metadata), 3);
        assert!(factory::pair_exists_for_frontend(pair_address), 4);
    }

    #[test(deployer = @uniswap_v2, bob = @bob)]
    public fun test_all_pairs_paginated(deployer: &signer, bob: &signer) {
        account::create_account_for_test(signer::address_of(bob));
        owner_tests::setup_test_with_genesis(deployer);
        test_coins::init_coins();

        let usdt_address = usdt_token::usdt_token_address();
        let usdc_address = usdc_token::usdc_token_address();

        // Create pair
        factory::create_pair(bob, usdt_address, usdc_address);
        let pair_address = factory::get_pair(usdt_address, usdc_address);

        // Test pagination
        let pairs = factory::all_pairs_paginated(0, 1);
        assert!(vector::length(&pairs) == 1, 0);
        assert!(*vector::borrow(&pairs, 0) == pair_address, 1);

        // Test pagination with start beyond length
        let empty_pairs = factory::all_pairs_paginated(1, 1);
        assert!(vector::length(&empty_pairs) == 0, 2);

        // Test pagination with large limit
        let all_pairs = factory::all_pairs_paginated(0, 100);
        assert!(vector::length(&all_pairs) == 1, 3);
    }

    #[test(admin = @admin, deployer = @uniswap_v2, bob = @bob)]
    public fun test_admin_functions(
        admin: &signer, deployer: &signer, bob: &signer
    ) {
        account::create_account_for_test(signer::address_of(bob));
        owner_tests::setup_test_with_genesis(deployer);

        // Test pause/unpause
        factory::pause(admin);
        factory::unpause(admin);

        // Test admin management
        let bob_address = signer::address_of(bob);
        factory::set_admin(admin, bob_address);
        factory::claim_admin(bob);
    }

    #[test(deployer = @uniswap_v2, bob = @bob)]
    public fun test_pair_for(deployer: &signer, bob: &signer) {
        account::create_account_for_test(signer::address_of(bob));
        owner_tests::setup_test_with_genesis(deployer);
        test_coins::init_coins();

        let usdt_address = usdt_token::usdt_token_address();
        let usdc_address = usdc_token::usdc_token_address();

        // Create pair
        factory::create_pair(bob, usdt_address, usdc_address);

        let usdt_metadata = usdt_token::metadata();
        let usdc_metadata = usdc_token::metadata();

        // Test pair_for function
        let pair = factory::pair_for(usdt_metadata, usdc_metadata);
        let expected_pair_address = object::object_address(&pair);
        let pair_address = pair::liquidity_pool_address(usdt_metadata, usdc_metadata);

        assert!(pair_address == expected_pair_address, 1);
    }

    #[test(deployer = @uniswap_v2, bob = @bob)]
    public fun test_get_reserves(deployer: &signer, bob: &signer) {
        account::create_account_for_test(signer::address_of(bob));
        owner_tests::setup_test_with_genesis(deployer);
        test_coins::init_coins();

        let usdt_address = usdt_token::usdt_token_address();
        let usdc_address = usdc_token::usdc_token_address();

        // Create pair
        factory::create_pair(bob, usdt_address, usdc_address);

        // Test get_reserves with both token orderings
        let (reserve_a, reserve_b) = factory::get_reserves(usdt_address, usdc_address);
        assert!(reserve_a == 0 && reserve_b == 0, 0); // Initially zero

        let (reserve_b, reserve_a) = factory::get_reserves(usdc_address, usdt_address);
        assert!(reserve_a == 0 && reserve_b == 0, 1); // Initially zero, reversed order
    }

    #[test(deployer = @uniswap_v2, bob = @bob)]
    #[expected_failure(abort_code = 1, location = uniswap_v2::factory)]
    // ERROR_IDENTICAL_ADDRESSES
    public fun test_get_reserves_identical_tokens(
        deployer: &signer, bob: &signer
    ) {
        account::create_account_for_test(signer::address_of(bob));
        owner_tests::setup_test_with_genesis(deployer);
        test_coins::init_coins();

        let usdt_address = usdt_token::usdt_token_address();
        factory::get_reserves(usdt_address, usdt_address);
    }

    #[test(deployer = @uniswap_v2, bob = @bob)]
    public fun test_all_pairs_empty(deployer: &signer, bob: &signer) {
        account::create_account_for_test(signer::address_of(bob));
        owner_tests::setup_test_with_genesis(deployer);

        let pairs = factory::all_pairs();
        assert!(vector::length(&pairs) == 0, 0);

        let paginated_pairs = factory::all_pairs_paginated(0, 10);
        assert!(vector::length(&paginated_pairs) == 0, 1);
    }
}
