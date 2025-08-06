# noir_modular_exponentiation

This project demonstrates a simple **Zero-Knowledge Proof (ZKP)** circuit using **Noir** to prove knowledge of a modular exponentiation computation without revealing the base or the exponent.

## 📝 Circuit Description

The circuit computes:

$$\mathrm{result} = \mathrm{base}^\mathrm{exponent} \bmod \mathrm{modulus}$$

**The modulus, base, and exponent are all provided as circuit inputs.**  
The result is exposed as a public output, allowing you to prove you know `x` and `e` such that $y = x^e \bmod m$.

### Circuit Code

```rust
/// Modular exponentiation using branchless right-to-left binary method.
/// Returns (base^exponent) mod modulus as a Field element.
/// All inputs are u32, output is Field.
fn mod_exp_branchless_u32(mut base: u32, mut exponent: u32, modulus: u32) -> u32 {
    assert(modulus != 0, "Modulus must be nonzero");
    let mut result: u32 = 1;
    base = base % modulus;

    for _ in 0..32 {
        let bit = exponent & 1;
        let mult = (result * base) % modulus;
        result = mult * bit + result * (1 - bit);
        base = (base * base) % modulus;
        exponent = exponent >> 1;
    }
    result
}

/// Main entry point for the circuit.
/// All inputs are u32, output is public Field.
fn main(x: u32, e: u32, m: u32, y: pub Field) {
    assert(m != 0, "Modulus must be nonzero");
    let result: u32 = mod_exp_branchless_u32(x, e, m);
    assert(result.into() == y);
}
```

- `x`: private base (`u32`)
- `e`: private exponent (`u32`)
- `m`: private modulus (`u32`)
- `y`: public expected result (`Field`)

The constraint ensures that:
$$y = x^e \bmod m$$

## Project Structure

This repo lets you verify Noir circuits (with the `bb` backend) using a Solidity verifier.

- `/circuits` — Contains the Noir circuit and build scripts.
- `/contract` — Foundry project with the Solidity verifier and integration test contract.
- `/js` — JS code to generate a proof and save as a file.

Tested with Noir >= 1.0.0-beta.6 and bb >= 0.84.0.

### Installation / Setup

```bash
# Foundry
git submodule update

# Build circuits, generate verifier contract
(cd circuits && ./build.sh)

# Install JS dependencies
(cd js && yarn)
```

### Proof Generation in JS

```bash
# Use bb.js to generate proof and save to a file
(cd js && yarn generate-proof)

# Run Foundry test to verify the generated proof
(cd contract && forge test --optimize --optimizer-runs 5000 --gas-report -vvv)
```

### Proof Generation with bb CLI
```bash
# Generate witness
nargo execute

# Generate proof with keccak hash
bb prove -b ./target/noir_modular_exponentiation.json -w target/noir_modular_exponentiation.gz -o ./target --oracle_hash keccak

# Run Foundry test to verify proof
cd ..
(cd contract && forge test --optimize --optimizer-runs 5000 --gas-report -vvv)
```

