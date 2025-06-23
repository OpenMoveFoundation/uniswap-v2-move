module uniswap_v2::owner {
    use aptos_framework::object::{Self, ExtendRef};

    use std::signer;

    friend uniswap_v2::pair;
    friend uniswap_v2::factory;

    const FEE_ADMIN: address = @fee_admin;
    const ADMIN: address = @admin;

    /// No operations are allowed when contract is paused
    const ERROR_PAUSED: u64 = 1;
    /// Contract is needs to be paused first
    const ERROR_UNPAUSED: u64 = 2;
    /// Operation is not allowed
    const ERROR_FORBIDDEN: u64 = 3;
    /// No Pending Admin
    const ERROR_NO_PENDING_ADMIN: u64 = 4;
    /// Invalid Address
    const ERROR_INVALID_ADDRESS: u64 = 5;
    /// Pending Admin Exists
    const ERROR_PENDING_ADMIN_EXISTS: u64 = 6;

    /// Configuration object that manages AMM protocol settings and administrative controls.
    /// This is a singleton object stored at the @uniswap_v2 address.
    struct OwnerShip has key {
        extend_ref: ExtendRef,
        fee_to: address,
        current_admin: address,
        pending_admin: address,
        fee_on: bool,
        paused: bool
    }

    /// Initializes the AMM protocol with default configuration.
    /// Can only be called once during package deployment.
    /// @param deployer - The signer of the deployment transaction
    fun init_module(deployer: &signer) {
        let constructor_ref = object::create_object(@uniswap_v2);
        let extend_ref = object::generate_extend_ref(&constructor_ref);

        move_to(
            deployer,
            OwnerShip {
                extend_ref: extend_ref,
                fee_to: FEE_ADMIN,
                current_admin: ADMIN,
                pending_admin: @0x0,
                fee_on: true,
                paused: false
            }
        )
    }

    /// Can be called by friended modules to obtain the object signer.
    public(friend) fun get_signer(): signer acquires OwnerShip {
        let ref = &safe_ownership().extend_ref;
        object::generate_signer_for_extending(ref)
    }

    #[view]
    public fun get_signer_address(): address acquires OwnerShip {
        signer::address_of(&get_signer())
    }

    #[view]
    public fun get_fee_to(): address acquires OwnerShip {
        safe_ownership().fee_to
    }

    #[view]
    public fun get_admin(): address acquires OwnerShip {
        safe_ownership().current_admin
    }

    #[view]
    public fun get_fee_on(): bool acquires OwnerShip {
        safe_ownership().fee_on
    }

    /// Asserts that the protocol is in paused state
    /// Aborts if protocol is not paused
    public fun assert_paused() acquires OwnerShip {
        assert!(safe_ownership().paused == true, ERROR_UNPAUSED);
    }

    /// Asserts that the protocol is not paused
    /// Aborts if protocol is paused
    public fun assert_unpaused() acquires OwnerShip {
        assert!(safe_ownership().paused == false, ERROR_PAUSED);
    }

    /// Pauses the protocol
    /// Can only be called by the current admin
    public(friend) fun pause(account: &signer) acquires OwnerShip {
        assert_unpaused();
        let swap_config = borrow_global_mut<OwnerShip>(@uniswap_v2);
        assert!(
            signer::address_of(account) == swap_config.current_admin, ERROR_FORBIDDEN
        );
        swap_config.paused = true;
    }

    /// Unpauses the protocol
    /// Can only be called by the current admin
    public(friend) fun unpause(account: &signer) acquires OwnerShip {
        assert_paused();
        let swap_config = borrow_global_mut<OwnerShip>(@uniswap_v2);
        assert!(
            signer::address_of(account) == swap_config.current_admin, ERROR_FORBIDDEN
        );
        swap_config.paused = false;
    }

    public(friend) fun set_fee_to(account: &signer, fee_to: address) acquires OwnerShip {
        let swap_config = borrow_global_mut<OwnerShip>(@uniswap_v2);
        assert!(
            signer::address_of(account) == swap_config.current_admin, ERROR_FORBIDDEN
        );
        swap_config.fee_to = fee_to;
    }

    public(friend) fun set_admin_address(
        account: &signer, admin_address: address
    ) acquires OwnerShip {
        let swap_config = borrow_global_mut<OwnerShip>(@uniswap_v2);
        assert!(
            signer::address_of(account) == swap_config.current_admin, ERROR_FORBIDDEN
        );
        assert!(admin_address != @0x0, ERROR_INVALID_ADDRESS); // Add new error check
        assert!(swap_config.pending_admin == @0x0, ERROR_PENDING_ADMIN_EXISTS); // Add new error check
        swap_config.pending_admin = admin_address;
    }

    public(friend) fun claim_admin(account: &signer) acquires OwnerShip {
        let swap_config = borrow_global_mut<OwnerShip>(@uniswap_v2);
        let account_addr = signer::address_of(account);
        assert!(account_addr == swap_config.pending_admin, ERROR_FORBIDDEN);
        assert!(swap_config.pending_admin != @0x0, ERROR_NO_PENDING_ADMIN); // Add new error check
        swap_config.current_admin = account_addr; // Use stored address instead of re-reading
        swap_config.pending_admin = @0x0;
    }

    inline fun safe_ownership(): &OwnerShip acquires OwnerShip {
        borrow_global<OwnerShip>(@uniswap_v2)
    }

    #[test_only]
    public fun initialize_for_test(admin: &signer) {
        let admin_addr = std::signer::address_of(admin);
        if (!exists<OwnerShip>(admin_addr)) {
            aptos_framework::timestamp::set_time_has_started_for_testing(
                &aptos_framework::account::create_signer_for_test(@0x1)
            );

            aptos_framework::account::create_account_for_test(admin_addr);

            let constructor_ref = object::create_object(admin_addr);

            move_to(
                admin,
                OwnerShip {
                    extend_ref: object::generate_extend_ref(&constructor_ref),
                    fee_to: FEE_ADMIN,
                    current_admin: ADMIN,
                    pending_admin: @0x0,
                    fee_on: true,
                    paused: false
                }
            )
        };
    }

    #[test_only]
    friend uniswap_v2::owner_tests;
    #[test_only]
    friend uniswap_v2::pair_tests;

    #[test_only]
    public fun initialize_for_testing(sender: &signer) {
        init_module(sender);
    }
}
