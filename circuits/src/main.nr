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

// ------------------
//      TESTS
// ------------------

#[test]
fn test_pass_case_one() {
    let base: u32 = 5;
    let exponent: u32 = 3;
    let modulus: u32 = 17;
    let result: Field = 6; // 5^3 mod 17 = 125 mod 17 = 6
    main(base, exponent, modulus, result);
}

#[test]
fn test_pass_case_two() {
    let base: u32 = 7;
    let exponent: u32 = 2;
    let modulus: u32 = 17;
    let result: Field = 15; // 7^2 mod 17 = 49 mod 17 = 15
    main(base, exponent, modulus, result);
}

#[test(should_fail)]
fn test_fail_case() {
    let base: u32 = 4;
    let exponent: u32 = 2;
    let modulus: u32 = 17;
    let result: Field = 5; // Should be 16
    main(base, exponent, modulus, result);
}

/// Test with modulus 0 (should fail)
#[test(should_fail)]
fn test_modulus_zero_fails() {
    let base: u32 = 3;
    let exponent: u32 = 4;
    let modulus: u32 = 0;
    let result: Field = 0;
    main(base, exponent, modulus, result);
}

/// Test with large exponent
#[test]
fn test_large_exponent() {
    let base: u32 = 2;
    let exponent: u32 = 30;
    let modulus: u32 = 1009;
    let result: Field = 348; // 2^30 mod 1009 = 348
    main(base, exponent, modulus, result);
}