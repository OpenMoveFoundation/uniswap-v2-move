#[test_only]
module uniswap_v2::test_coins {
    use uniswap_v2::usdc_token;
    use uniswap_v2::usdt_token;
    use uniswap_v2::wbtc_token;
    use uniswap_v2::weth_token;

    use aptos_framework::account;

    public entry fun init_coins() {
        let account = &account::create_account_for_test(@uniswap_v2);
        usdc_token::init_for_test(account);
        usdt_token::init_for_test(account);
        wbtc_token::init_for_test(account);
        weth_token::init_for_test(account);
    }

    public entry fun mint_usdc(account: &signer, to: address, amount: u64) {
        usdc_token::mint(account, to, amount);
    }

    public entry fun mint_usdt(account: &signer, to: address, amount: u64) {
        usdt_token::mint(account, to, amount);
    }

    public entry fun mint_wbtc(account: &signer, to: address, amount: u64) {
        wbtc_token::mint(account, to, amount);
    }

    public entry fun mint_weth(account: &signer, to: address, amount: u64) {
        weth_token::mint(account, to, amount);
    }
}
