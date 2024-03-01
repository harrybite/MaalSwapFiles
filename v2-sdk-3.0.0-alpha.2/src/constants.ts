import JSBI from 'jsbi'

export const FACTORY_ADDRESS = '0x1cCF425Ce0E53614CbDBa284c515926a7E45A8B6' // change FACTORY_ADDRESS for testnet or mainnet

export const INIT_CODE_HASH = '0x47f1546c1597fd39354056525b84d647f10852af88dda77f7b7e1f2520cd8e95' // change INIT_CODE_HASH for testnet or mainnet
// a5d49a9592885b4f8b66115c12564d598b0a0bdce375eb0946695f112d5b45be
// 0x96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f

export const MINIMUM_LIQUIDITY = JSBI.BigInt(1000)

// exports for internal consumption
export const ZERO = JSBI.BigInt(0)
export const ONE = JSBI.BigInt(1)
export const FIVE = JSBI.BigInt(5)
export const _997 = JSBI.BigInt(997)
export const _1000 = JSBI.BigInt(1000)
