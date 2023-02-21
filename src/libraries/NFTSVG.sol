// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.0;

import {Base64} from "openzeppelin/utils/Base64.sol";

library NFTSVG {
    struct SVGParams {
        string name;
        string description;
        string svg;
    }

    function constructTokenURI(SVGParams memory params) public pure returns (string memory) {
        string memory svg = Base64.encode(bytes(params.svg));
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name":"',
                            params.name,
                            '", "description":"',
                            params.description,
                            '", "image": "',
                            "data:image/svg+xml;base64,",
                            svg,
                            '"}'
                        )
                    )
                )
            )
        );
    }
}
