# FoundrySVGTester
Test SVG &amp; metadata encoding with Foundry

- SVGStore.sol - basic contract to set/get URI's
- NFTSVG.sol - library to base64 encode metadata and SVG into URI
- SVGStore.t.sol - use Foundrys ffi cheatcode and file methods to test encoding/decoding of svg's & metadata
- assets - collection of various SVG's from [web-platform-tests](https://github.com/web-platform-tests/wpt)

More complex encoding and manipulation can be done in NFTSVG.sol. like [Uniswap](https://github.com/Uniswap/v3-periphery/blob/main/contracts/libraries/NFTSVG.sol), [Untitled-Frontier](https://github.com/Untitled-Frontier/tlatc/blob/02ce8d629fdf4efeb8eea5fec1deea8b9bdb5542/packages/hardhat/contracts/AnchorCertificates.sol#L178), and [neolastics](https://github.com/simondlr/neolastics/blob/3836ff425b32665d338d6669b078d43c9dddaf10/packages/hardhat/contracts/ERC721.sol#L172).
The SVGStore & NFTSVG files are vanilla, imo the notable aspects are 
- the collection of diverse SVG's in the /assets dir to test with
- the usage of foundrys FFI cheatcode, json read/write, and file methods to decode the URI. Whereas in the past I would've used Hardhat for javascript.
