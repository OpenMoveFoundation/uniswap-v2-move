
<a id="0x1234_utils"></a>

# Module `0x1234::utils`



-  [Constants](#@Constants_0)
-  [Function `is_sorted_two`](#0x1234_utils_is_sorted_two)
-  [Function `sort_two_tokens`](#0x1234_utils_sort_two_tokens)
-  [Function `create_token_store`](#0x1234_utils_create_token_store)
-  [Function `ensure_account_token_store`](#0x1234_utils_ensure_account_token_store)
-  [Function `quote`](#0x1234_utils_quote)
-  [Function `get_amount_out`](#0x1234_utils_get_amount_out)
-  [Function `get_amount_in`](#0x1234_utils_get_amount_in)


<pre><code><b>use</b> <a href="">0x1::comparator</a>;
<b>use</b> <a href="">0x1::fungible_asset</a>;
<b>use</b> <a href="">0x1::object</a>;
<b>use</b> <a href="">0x1::primary_fungible_store</a>;
</code></pre>



<a id="@Constants_0"></a>

## Constants


<a id="0x1234_utils_MAX_U64"></a>



<pre><code><b>const</b> <a href="utils.md#0x1234_utils_MAX_U64">MAX_U64</a>: u64 = 18446744073709551615;
</code></pre>



<a id="0x1234_utils_ERROR_IDENTICAL_ADDRESSES"></a>

Identical Addresses


<pre><code><b>const</b> <a href="utils.md#0x1234_utils_ERROR_IDENTICAL_ADDRESSES">ERROR_IDENTICAL_ADDRESSES</a>: u64 = 2;
</code></pre>



<a id="0x1234_utils_ERROR_INSUFFICIENT_AMOUNT"></a>

Insufficient Amount


<pre><code><b>const</b> <a href="utils.md#0x1234_utils_ERROR_INSUFFICIENT_AMOUNT">ERROR_INSUFFICIENT_AMOUNT</a>: u64 = 4;
</code></pre>



<a id="0x1234_utils_ERROR_INSUFFICIENT_INPUT_AMOUNT"></a>

Insufficient Input Amount


<pre><code><b>const</b> <a href="utils.md#0x1234_utils_ERROR_INSUFFICIENT_INPUT_AMOUNT">ERROR_INSUFFICIENT_INPUT_AMOUNT</a>: u64 = 6;
</code></pre>



<a id="0x1234_utils_ERROR_INSUFFICIENT_LIQUIDITY"></a>

Insufficient Liquidity


<pre><code><b>const</b> <a href="utils.md#0x1234_utils_ERROR_INSUFFICIENT_LIQUIDITY">ERROR_INSUFFICIENT_LIQUIDITY</a>: u64 = 3;
</code></pre>



<a id="0x1234_utils_ERROR_INSUFFICIENT_OUTPUT_AMOUNT"></a>

Insufficient Output Amount


<pre><code><b>const</b> <a href="utils.md#0x1234_utils_ERROR_INSUFFICIENT_OUTPUT_AMOUNT">ERROR_INSUFFICIENT_OUTPUT_AMOUNT</a>: u64 = 7;
</code></pre>



<a id="0x1234_utils_ERROR_OVERFLOW"></a>

Overflow


<pre><code><b>const</b> <a href="utils.md#0x1234_utils_ERROR_OVERFLOW">ERROR_OVERFLOW</a>: u64 = 5;
</code></pre>



<a id="0x1234_utils_is_sorted_two"></a>

## Function `is_sorted_two`

Determines if two token metadata objects are in canonical order based on their addresses
@param token0: First token metadata object
@param token1: Second token metadata object
@return bool: true if tokens are in correct order (token0 < token1)


<pre><code><b>public</b> <b>fun</b> <a href="utils.md#0x1234_utils_is_sorted_two">is_sorted_two</a>(token0: <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;, token1: <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;): bool
</code></pre>



<a id="0x1234_utils_sort_two_tokens"></a>

## Function `sort_two_tokens`



<pre><code><b>public</b> <b>fun</b> <a href="utils.md#0x1234_utils_sort_two_tokens">sort_two_tokens</a>(token_a: <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;, token_b: <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;): (<a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;, <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;)
</code></pre>



<a id="0x1234_utils_create_token_store"></a>

## Function `create_token_store`



<pre><code><b>public</b> <b>fun</b> <a href="utils.md#0x1234_utils_create_token_store">create_token_store</a>(pool_signer: &<a href="">signer</a>, token: <a href="_Object">object::Object</a>&lt;<a href="_Metadata">fungible_asset::Metadata</a>&gt;): <a href="_Object">object::Object</a>&lt;<a href="_FungibleStore">fungible_asset::FungibleStore</a>&gt;
</code></pre>



<a id="0x1234_utils_ensure_account_token_store"></a>

## Function `ensure_account_token_store`



<pre><code><b>public</b> <b>fun</b> <a href="utils.md#0x1234_utils_ensure_account_token_store">ensure_account_token_store</a>&lt;T: key&gt;(<a href="">account</a>: <b>address</b>, <a href="pair.md#0x1234_pair">pair</a>: <a href="_Object">object::Object</a>&lt;T&gt;): <a href="_Object">object::Object</a>&lt;<a href="_FungibleStore">fungible_asset::FungibleStore</a>&gt;
</code></pre>



<a id="0x1234_utils_quote"></a>

## Function `quote`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="utils.md#0x1234_utils_quote">quote</a>(amount_a: u64, reserve_a: u64, reserve_b: u64): u64
</code></pre>



<a id="0x1234_utils_get_amount_out"></a>

## Function `get_amount_out`



<pre><code><b>public</b> <b>fun</b> <a href="utils.md#0x1234_utils_get_amount_out">get_amount_out</a>(amount_in: u64, reserve_in: u64, reserve_out: u64): u64
</code></pre>



<a id="0x1234_utils_get_amount_in"></a>

## Function `get_amount_in`



<pre><code><b>public</b> <b>fun</b> <a href="utils.md#0x1234_utils_get_amount_in">get_amount_in</a>(amount_out: u64, reserve_in: u64, reserve_out: u64): u64
</code></pre>
