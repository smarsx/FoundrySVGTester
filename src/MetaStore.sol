// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Ownable} from "solady/auth/Ownable.sol";
import "./libraries/NFTMeta.sol";

contract MetaStore is Ownable {
    mapping(address => string) public uris; // public getter

    constructor(address owner) {}

    function store(
        NFTMeta.TypeURI uri,
        string calldata _name,
        string calldata _description,
        string calldata _blob
    ) public {
        uris[msg.sender] = NFTMeta.constructTokenURI(
            NFTMeta.MetaParams({typeUri: uri, name: _name, description: _description, blob: _blob})
        );
    }

    function remove() public {
        delete uris[msg.sender];
    }

    function implode(address payable _to) external onlyOwner {
        selfdestruct(_to);
    }
}
