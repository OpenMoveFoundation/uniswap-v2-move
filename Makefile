# ============================= VARIABLES ============================= #
DEV_ACCOUNT = 0x1234 # TODO: Change to your account address


# ============================= CLEAN ============================= #
clean:
	rm -rf build

# ============================= BUILD ============================= #
compile:
	aptos move compile \
	--save-metadata \
	--included-artifacts sparse \
	--named-addresses "uniswap_v2=$(DEV_ACCOUNT)"


format:
	aptos move fmt

# ============================= TEST ============================= #
test:
	aptos move test \
	--named-addresses "uniswap_v2=$(DEV_ACCOUNT)" \
	--coverage

docs:
	aptos move document \
	--named-addresses "uniswap_v2=$(DEV_ACCOUNT)"