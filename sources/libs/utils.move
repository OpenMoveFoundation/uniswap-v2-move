module uniswap_v2::utils {
    use aptos_framework::object::{Self, Object};
    use aptos_framework::fungible_asset::{Self, FungibleStore, Metadata};
    use aptos_framework::primary_fungible_store;

    use aptos_std::comparator;

    const MAX_U64: u64 = 18446744073709551615;

    /// Identical Addresses
    const ERROR_IDENTICAL_ADDRESSES: u64 = 2;
    /// Insufficient Liquidity
    const ERROR_INSUFFICIENT_LIQUIDITY: u64 = 3;
    /// Insufficient Amount
    const ERROR_INSUFFICIENT_AMOUNT: u64 = 4;
    /// Overflow
    const ERROR_OVERFLOW: u64 = 5;
    /// Insufficient Input Amount
    const ERROR_INSUFFICIENT_INPUT_AMOUNT: u64 = 6;
    /// Insufficient Output Amount
    const ERROR_INSUFFICIENT_OUTPUT_AMOUNT: u64 = 7;

    /// Determines if two token metadata objects are in canonical order based on their addresses
    /// @param token0: First token metadata object
    /// @param token1: Second token metadata object
    /// @return bool: true if tokens are in correct order (token0 < token1)
    public fun is_sorted_two(
        token0: Object<Metadata>, token1: Object<Metadata>
    ): bool {
        let token0_addr = object::object_address(&token0);
        let token1_addr = object::object_address(&token1);
        comparator::is_smaller_than(&comparator::compare(&token0_addr, &token1_addr))
    }

    // returns sorted token Metadata objects, used to handle return values from
    // pairs sorted in this order
    public fun sort_two_tokens(
        token_a: Object<Metadata>, token_b: Object<Metadata>
    ): (Object<Metadata>, Object<Metadata>) {
        let token_a_addr = object::object_address(&token_a);
        let token_b_addr = object::object_address(&token_b);
        assert!(token_a_addr != token_b_addr, ERROR_IDENTICAL_ADDRESSES);
        let (token0, token1);
        if (is_sorted_two(token_a, token_b)) {
            (token0, token1) = (token_a, token_b)
        } else {
            (token0, token1) = (token_b, token_a)
        };

        (token0, token1)
    }

    public fun create_token_store(
        pool_signer: &signer, token: Object<Metadata>
    ): Object<FungibleStore> {
        let constructor_ref = &object::create_object_from_object(pool_signer);
        fungible_asset::create_store(constructor_ref, token)
    }

    public fun ensure_account_token_store<T: key>(
        account: address, pair: Object<T>
    ): Object<FungibleStore> {
        primary_fungible_store::ensure_primary_store_exists(account, pair);
        let store = primary_fungible_store::primary_store(account, pair);
        store
    }

    // given some amount of an asset and pair reserves,
    //returns an equivalent amount of the other asset
    #[view]
    public fun quote(amount_a: u64, reserve_a: u64, reserve_b: u64): u64 {
        assert!(amount_a > 0, ERROR_INSUFFICIENT_AMOUNT);
        assert!(
            reserve_a > 0 && reserve_b > 0,
            ERROR_INSUFFICIENT_LIQUIDITY
        );
        let amount_b = ((amount_a as u128) * (reserve_b as u128) / (reserve_a as u128) as u64);
        amount_b
    }

    // given an input amount of an asset and pair reserves,
    // returns the maximum output amount of the other asset
    public fun get_amount_out(
        amount_in: u64, reserve_in: u64, reserve_out: u64
    ): u64 {
        assert!(amount_in > 0, ERROR_INSUFFICIENT_INPUT_AMOUNT);
        assert!(
            reserve_in > 0 && reserve_out > 0,
            ERROR_INSUFFICIENT_LIQUIDITY
        );

        // Add check for maximum input to prevent overflow
        assert!(amount_in <= MAX_U64 / 9975, ERROR_OVERFLOW);

        let amount_in_with_fee = (amount_in as u128) * 9975u128;
        let numerator = amount_in_with_fee * (reserve_out as u128);
        let denominator = (reserve_in as u128) * 10000 + amount_in_with_fee;
        let amount_out = numerator / denominator;
        (amount_out as u64)
    }

    // given an output amount of an asset and pair reserves, returns a required
    // input amount of the other asset
    public fun get_amount_in(
        amount_out: u64, reserve_in: u64, reserve_out: u64
    ): u64 {
        assert!(amount_out > 0, ERROR_INSUFFICIENT_OUTPUT_AMOUNT);
        assert!(
            reserve_in > 0 && reserve_out > 0,
            ERROR_INSUFFICIENT_LIQUIDITY
        );
        let numerator = (reserve_in as u128) * (amount_out as u128) * 10000;
        let denominator = ((reserve_out - amount_out) as u128) * ((9975) as u128);
        let amount_in = numerator / denominator + 1;
        (amount_in as u64)
    }
}
