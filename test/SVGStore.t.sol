// SPDX-License-Identifier: Unlicense
pragma solidity >= 0.8.15;

import {Test} from "forge-std/Test.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {console2 as console} from "forge-std/console2.sol";
import {strings} from "stringutils/strings.sol";

import {SVGStore} from "../src/SVGStore.sol";

struct Json {
    string description;
    string image;
    string name;
}

contract SVGStoreTest is Test {
    using stdJson for string;
    using strings for *;

    SVGStore svgstore;
    mapping(string => string[]) public filenames;

    string tempdir = string.concat(vm.projectRoot(), "/temp");
    string assetsdir = string.concat(vm.projectRoot(), "/assets");
    string assetsOut = string.concat(assetsdir, "/out");

    /*///////////////////////////////////////////////////////////////////
                                UTILS
    //////////////////////////////////////////////////////////////////*/

    function getActors(uint256 _n) public pure returns (address[] memory) {
        address[] memory actors = new address[](_n);
        for (uint256 i; i < _n; i++) {
            actors[i] = address(uint160(i));
        }
        return actors;
    }

    function ls(string memory _file) public returns (string memory) {
        string[] memory inputs = new string[](3);
        inputs[0] = "ls";
        inputs[1] = "-A"; // exclude implied . ..
        inputs[2] = _file;
        return string(vm.ffi(inputs));
    }

    /**
     * cut URI at first comma to get encoded portion.
     *                              *
     * (data:application/json;base64,eyJuYW1lIjoiVW5pc3dhcC)
     */
    function cutURI(string memory _file) public returns (string memory) {
        string[] memory inputs = new string[](6);
        inputs[0] = "cut";
        inputs[1] = "-d"; // delimiter
        inputs[2] = ",";
        inputs[3] = "-f"; // fields
        inputs[4] = "2";
        inputs[5] = _file;
        return string(vm.ffi(inputs));
    }

    function decodeURI(string memory _file) public returns (string memory) {
        string[] memory inputs = new string[](3);
        inputs[0] = "base64";
        inputs[1] = "-d";
        inputs[2] = _file;
        return string(vm.ffi(inputs));
    }

    function cutAndDecodeURI(string memory _file) public returns (string memory) {
        string memory cut = cutURI(_file);
        vm.writeFile(_file, cut);
        return decodeURI(_file);
    }

    /**
     * populate filenames map for _dir
     */
    function setFiles(string memory _dir) public {
        if (filenames[_dir].length > 0) return;

        string memory temptxt = string.concat(tempdir, "/", _dir, ".txt");
        string memory dir = string.concat(assetsdir, "/", _dir);
        string memory files = ls(dir);
        vm.writeFile(temptxt, files);
        strings.slice memory ending = ".svg".toSlice();
        strings.slice memory next = vm.readLine(temptxt).toSlice();

        while (next.len() > 0) {
            if (next.endsWith(ending)) {
                filenames[_dir].push(next.toString());
            }
            next = vm.readLine(temptxt).toSlice();
        }
    }

    /*///////////////////////////////////////////////////////////////////
                                SETUP
    //////////////////////////////////////////////////////////////////*/

    function setUp() public {
        svgstore = new SVGStore(address(this));
    }

    /*///////////////////////////////////////////////////////////////////
                                TEST HELPERS
    //////////////////////////////////////////////////////////////////*/

    /**
     * read svg, store in contract, retrieve URI from contract, decode, parse, and assert.
     * tests that inputs to contract == URI output
     */
    function assertSvg(string memory _filename, string memory _dir, address _actor) public {
        string memory temptxt = string.concat(tempdir, "/", _filename, ".txt");
        string memory tempjson = string.concat(tempdir, "/", _filename, ".json");

        // make path
        string memory path = string.concat(assetsdir, "/", _dir, "/", _filename);

        // read svg
        string memory svg = vm.readFile(path);

        // store in contract
        vm.prank(_actor);
        svgstore.store(_filename, path, svg);

        // get uri from contract
        string memory uri = svgstore.uris(_actor);
        // store uri in temp
        vm.writeFile(temptxt, uri);

        // cut and decode uri
        string memory decodedMetadata = cutAndDecodeURI(temptxt);
        // write decoded metadata to json
        vm.writeJson(decodedMetadata, tempjson);
        // read json
        string memory json = vm.readFile(tempjson);
        // parse json
        bytes memory metadata = json.parseRaw("$");
        // decode json into struct
        Json memory decodedJson = abi.decode(metadata, (Json));

        // write encoded image to temp
        vm.writeFile(temptxt, decodedJson.image);

        // cut & decode image
        string memory decodedSvg = cutAndDecodeURI(temptxt);

        // asserts
        assertEq(_filename, decodedJson.name);
        assertEq(path, decodedJson.description);
        assertEq(svg, decodedSvg);

        // write decoded svg to out to view
        // vm.writeFile(string.concat(assetsOut, "/", _filename), decodedSvg);

        vm.removeFile(temptxt);
        vm.removeFile(tempjson);
    }

    function assertSvgs(string memory _dir) public {
        address[] memory actors = getActors(filenames[_dir].length);
        for (uint256 i; i < filenames[_dir].length; i++) {
            assertSvg(filenames[_dir][i], _dir, actors[i]);
        }
    }

    function assertSvgs(string memory _dir, uint256 index) public {
        address actor = address(uint160(4444));
        assertSvg(filenames[_dir][index], _dir, actor);
    }

    /*///////////////////////////////////////////////////////////////////
                                TESTS
    //////////////////////////////////////////////////////////////////*/

    // function testSingle() public {
    //     string memory dir = "embedded";
    //     setFiles(dir);
    //     assertSvgs(dir, 0);
    // }

    function testAnimations() public {
        string memory dir = "animations";
        setFiles(dir);
        assertSvgs(dir);
    }

    function testEmbedded() public {
        string memory dir = "embedded";
        setFiles(dir);
        assertSvgs(dir);
    }

    function testImport() public {
        string memory dir = "import";
        setFiles(dir);
        assertSvgs(dir);
    }

    function testImport2() public {
        string memory dir = "import2";
        setFiles(dir);
        assertSvgs(dir);
    }

    function testImport3() public {
        string memory dir = "import3";
        setFiles(dir);
        assertSvgs(dir);
    }

    function testImport4() public {
        string memory dir = "import4";
        setFiles(dir);
        assertSvgs(dir);
    }

    function testInteract() public {
        string memory dir = "interact";
        setFiles(dir);
        assertSvgs(dir);
    }

    function testLinking() public {
        string memory dir = "linking";
        setFiles(dir);
        assertSvgs(dir);
    }

    function testPainting() public {
        string memory dir = "painting";
        setFiles(dir);
        assertSvgs(dir);
    }

    function testPath() public {
        string memory dir = "path";
        setFiles(dir);
        assertSvgs(dir);
    }

    function testPservers() public {
        string memory dir = "pservers";
        setFiles(dir);
        assertSvgs(dir);
    }

    function testRender() public {
        string memory dir = "render";
        setFiles(dir);
        assertSvgs(dir);
    }

    function testRendering() public {
        string memory dir = "rendering";
        setFiles(dir);
        assertSvgs(dir);
    }

    function testScripted() public {
        string memory dir = "scripted";
        setFiles(dir);
        assertSvgs(dir);
    }

    function testShapes() public {
        string memory dir = "shapes";
        setFiles(dir);
        assertSvgs(dir);
    }

    function testStruct() public {
        string memory dir = "struct";
        setFiles(dir);
        assertSvgs(dir);
    }

    function testStyling() public {
        string memory dir = "styling";
        setFiles(dir);
        assertSvgs(dir);
    }

    function testText() public {
        string memory dir = "text";
        setFiles(dir);
        assertSvgs(dir);
    }

    function testTypes() public {
        string memory dir = "types";
        setFiles(dir);
        assertSvgs(dir);
    }
}
