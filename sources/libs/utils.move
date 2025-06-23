module uniswap_v2::utils {
    use aptos_framework::object::{Self, Object};
    use aptos_framework::fungible_asset::{Self, FungibleStore, Metadata};
    use aptos_framework::primary_fungible_store;

    use aptos_std::comparator;

    /// Identical Addresses
    const ERROR_IDENTICAL_ADDRESSES: u64 = 1;

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
}
