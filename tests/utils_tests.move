#[test_only]
module uniswap_v2::utils_tests {
    use uniswap_v2::utils;
    use uniswap_v2::usdc_token;
    use uniswap_v2::usdt_token;
    use uniswap_v2::wbtc_token;
    use uniswap_v2::weth_token;

    use aptos_framework::account;
    use aptos_framework::object;

    public entry fun init_coins() {
        let account = &account::create_account_for_test(@uniswap_v2);
        usdc_token::init_for_test(account);
        usdt_token::init_for_test(account);
        wbtc_token::init_for_test(account);
        weth_token::init_for_test(account);
    }

    #[test]
    fun test_is_sorted_two() {
        init_coins();
        let token0 = usdc_token::metadata();
        let token1 = usdt_token::metadata();
        let token2 = wbtc_token::metadata();

        assert!(utils::is_sorted_two(token0, token1), 0);
        assert!(!utils::is_sorted_two(token1, token0), 1);
        assert!(utils::is_sorted_two(token2, token1), 2);
    }

    #[test]
    fun test_sort_two_tokens() {
        init_coins();
        let token0 = usdc_token::metadata();
        let token1 = usdt_token::metadata();

        let (sorted0, sorted1) = utils::sort_two_tokens(token1, token0);
        assert!(
            object::object_address(&sorted0)
                == @0x2ac18772fbaffdfd31bb7b5d2586a5af443ba1471ff1704d3ff71a04efcf2630,
            0
        );
        assert!(
            object::object_address(&sorted1)
                == @0x57d0d73f5dbab20e09062a9511980f7dae2cb636126d46d2da1ae95b50684a22,
            1
        );
    }

    #[test]
    #[expected_failure(abort_code = 2, location = uniswap_v2::utils)]
    fun test_sort_two_tokens_identical_addresses() {
        init_coins();
        let token0 = usdc_token::metadata();
        let token1 = usdc_token::metadata();
        utils::sort_two_tokens(token0, token1);
    }

    // Test quote function
    #[test]
    fun test_quote_normal() {
        let amount_out = utils::quote(100, 1000, 2000);
        assert!(amount_out == 200, 0);
    }

    #[test]
    #[expected_failure(abort_code = 4, location = uniswap_v2::utils)]
    fun test_quote_zero_amount() {
        utils::quote(0, 1000, 2000);
    }

    #[test]
    #[expected_failure(abort_code = 3, location = uniswap_v2::utils)]
    fun test_quote_zero_reserves() {
        utils::quote(100, 0, 2000);
    }

    // Test get_amount_out function
    #[test]
    fun test_get_amount_out_normal() {
        let amount_out = utils::get_amount_out(100, 1000, 2000);
        assert!(amount_out == 181, 0); // Expected value considering 0.25% fee
    }

    #[test]
    #[expected_failure(abort_code = 6, location = uniswap_v2::utils)]
    fun test_get_amount_out_zero_input() {
        utils::get_amount_out(0, 1000, 2000);
    }

    #[test]
    #[expected_failure(abort_code = 3, location = uniswap_v2::utils)]
    fun test_get_amount_out_zero_reserves() {
        utils::get_amount_out(100, 0, 2000);
    }

    #[test]
    #[expected_failure(abort_code = 5, location = uniswap_v2::utils)]
    fun test_get_amount_out_overflow() {
        utils::get_amount_out(18446744073709551615, 1000, 2000);
    }

    // Test get_amount_in function
    #[test]
    fun test_get_amount_in_normal() {
        let amount_in = utils::get_amount_in(100, 1000, 2000);
        assert!(amount_in == 53, 0); // Expected value considering 0.25% fee
    }

    #[test]
    #[expected_failure(abort_code = 7, location = uniswap_v2::utils)]
    fun test_get_amount_in_zero_output() {
        utils::get_amount_in(0, 1000, 2000);
    }

    #[test]
    #[expected_failure(abort_code = 3, location = uniswap_v2::utils)]
    fun test_get_amount_in_zero_reserves() {
        utils::get_amount_in(100, 0, 2000);
    }
}
