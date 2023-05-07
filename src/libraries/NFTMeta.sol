// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.0;

import {Base64} from "solady/utils/Base64.sol";

library NFTMeta {
    enum TypeURI {
        SVG,
        HTML
    }

    // TypeURI Headers
    string constant SVG = '", "image": "data:image/svg+xml;base64,';
    string constant HTML = '", "animation_url": "data:text/html;base64,';

    struct MetaParams {
        TypeURI typeUri;
        string name;
        string description;
        string blob;
    }

    function constructTokenURI(MetaParams memory params) public pure returns (string memory) {
        string memory blobHeader = params.typeUri == TypeURI.HTML ? HTML : SVG;
        string memory blob = Base64.encode(bytes(params.blob));

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                params.name,
                                '", "description":"',
                                params.description,
                                blobHeader,
                                blob,
                                '"}'
                            )
                        )
                    )
                )
            );
    }
}
