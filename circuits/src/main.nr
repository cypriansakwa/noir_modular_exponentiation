/// Modular exponentiation using branchless right-to-left binary method.
/// Returns (base^exponent) mod modulus as a Field element.
/// All inputs are u32, output is Field.
///
/// The algorithm iterates through the bits of the exponent from right to left (least significant to most significant).
/// It maintains a result, which is initially 1, and a base that gets squared in each iteration.
/// If the current bit of the exponent is 1, it multiplies the result by the current base.
/// This is done in a branchless way to be efficient in a circuit.
fn mod_exp_branchless_u32(mut base: u32, mut exponent: u32, modulus: u32) -> u32 {
    assert(modulus != 0, "Modulus must be nonzero");
    let mut result: u32 = 1;
    base = base % modulus;

    // We iterate 32 times for a u32 exponent.
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
fn main(x: u32, e: pub u32, m: u32, y: pub Field) {
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
    main(base, exponent, modulus, result); }


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

/// Test with exponent 0
#[test]
fn test_exponent_zero() {
    let base: u32 = 5;
    let exponent: u32 = 0;
    let modulus: u32 = 17;
    let result: Field = 1; // 5^0 mod 17 = 1
    main(base, exponent, modulus, result);
}

/// Test with exponent 1
#[test]
fn test_exponent_one() {
    let base: u32 = 5;
    let exponent: u32 = 1;
    let modulus: u32 = 17;
    let result: Field = 5; // 5^1 mod 17 = 5
    main(base, exponent, modulus, result);
}

/// Test with base 0
#[test]
fn test_base_zero() {
    let base: u32 = 0;
    let exponent: u32 = 3;
    let modulus: u32 = 17;
    let result: Field = 0; // 0^3 mod 17 = 0
    main(base, exponent, modulus, result);
}

/// Test with base 1
#[test]
fn test_base_one() {
    let base: u32 = 1;
    let exponent: u32 = 10;
    let modulus: u32 = 17;
    let result: Field = 1; // 1^10 mod 17 = 1
    main(base, exponent, modulus, result);
}

/// Test with modulus 1
#[test]
fn test_modulus_one() {
    let base: u32 = 5;
    let exponent: u32 = 3;
    let modulus: u32 = 1;
    let result: Field = 0; // 5^3 mod 1 = 0
    main(base, exponent, modulus, result);
}