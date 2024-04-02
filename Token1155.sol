// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;
import "@openzeppelin/contracts/utils/Strings.sol";

/**
    @title ERC-1155 Multi Token Standard
    @dev See https://eips.ethereum.org/EIPS/eip-1155
    Note: The ERC-165 identifier for this interface is 0xd9b67a26.
 */
/* is ERC165 */
interface ERC1155 {
    /**
        @dev Either `TransferSingle` or `TransferBatch` MUST emit when tokens are transferred, including zero value transfers as well as minting or burning (see "Safe Transfer Rules" section of the standard).
        The `_operator` argument MUST be the address of an account/contract that is approved to make the transfer (SHOULD be msg.sender).
        The `_from` argument MUST be the address of the holder whose balance is decreased.
        The `_to` argument MUST be the address of the recipient whose balance is increased.
        The `_id` argument MUST be the token type being transferred.
        The `_value` argument MUST be the number of tokens the holder balance is decreased by and match what the recipient balance is increased by.
        When minting/creating tokens, the `_from` argument MUST be set to `0x0` (i.e. zero address).
        When burning/destroying tokens, the `_to` argument MUST be set to `0x0` (i.e. zero address).        
    */
    event TransferSingle(
        address indexed _operator,
        address indexed _from,
        address indexed _to,
        uint256 _id,
        uint256 _value
    );

    /**
        @dev Either `TransferSingle` or `TransferBatch` MUST emit when tokens are transferred, including zero value transfers as well as minting or burning (see "Safe Transfer Rules" section of the standard).      
        The `_operator` argument MUST be the address of an account/contract that is approved to make the transfer (SHOULD be msg.sender).
        The `_from` argument MUST be the address of the holder whose balance is decreased.
        The `_to` argument MUST be the address of the recipient whose balance is increased.
        The `_ids` argument MUST be the list of tokens being transferred.
        The `_values` argument MUST be the list of number of tokens (matching the list and order of tokens specified in _ids) the holder balance is decreased by and match what the recipient balance is increased by.
        When minting/creating tokens, the `_from` argument MUST be set to `0x0` (i.e. zero address).
        When burning/destroying tokens, the `_to` argument MUST be set to `0x0` (i.e. zero address).                
    */
    event TransferBatch(
        address indexed _operator,
        address indexed _from,
        address indexed _to,
        uint256[] _ids,
        uint256[] _values
    );

    /**
        @dev MUST emit when approval for a second party/operator address to manage all tokens for an owner address is enabled or disabled (absence of an event assumes disabled).        
    */
    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );

    /**
        @dev MUST emit when the URI is updated for a token ID.
        URIs are defined in RFC 3986.
        The URI MUST point to a JSON file that conforms to the "ERC-1155 Metadata URI JSON Schema".
    */
    event URI(string _value, uint256 indexed _id);

    /**
        @notice Transfers `_value` amount of an `_id` from the `_from` address to the `_to` address specified (with safety call).
        @dev Caller must be approved to manage the tokens being transferred out of the `_from` account (see "Approval" section of the standard).
        MUST revert if `_to` is the zero address.
        MUST revert if balance of holder for token `_id` is lower than the `_value` sent.
        MUST revert on any other error.
        MUST emit the `TransferSingle` event to reflect the balance change (see "Safe Transfer Rules" section of the standard).
        After the above conditions are met, this function MUST check if `_to` is a smart contract (e.g. code size > 0). If so, it MUST call `onERC1155Received` on `_to` and act appropriately (see "Safe Transfer Rules" section of the standard).        
        @param _from    Source address
        @param _to      Target address
        @param _id      ID of the token type
        @param _value   Transfer amount
        @param _data    Additional data with no specified format, MUST be sent unaltered in call to `onERC1155Received` on `_to`
    */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _value,
        bytes calldata _data
    ) external;

    /**
        @notice Transfers `_values` amount(s) of `_ids` from the `_from` address to the `_to` address specified (with safety call).
        @dev Caller must be approved to manage the tokens being transferred out of the `_from` account (see "Approval" section of the standard).
        MUST revert if `_to` is the zero address.
        MUST revert if length of `_ids` is not the same as length of `_values`.
        MUST revert if any of the balance(s) of the holder(s) for token(s) in `_ids` is lower than the respective amount(s) in `_values` sent to the recipient.
        MUST revert on any other error.        
        MUST emit `TransferSingle` or `TransferBatch` event(s) such that all the balance changes are reflected (see "Safe Transfer Rules" section of the standard).
        Balance changes and events MUST follow the ordering of the arrays (_ids[0]/_values[0] before _ids[1]/_values[1], etc).
        After the above conditions for the transfer(s) in the batch are met, this function MUST check if `_to` is a smart contract (e.g. code size > 0). If so, it MUST call the relevant `ERC1155TokenReceiver` hook(s) on `_to` and act appropriately (see "Safe Transfer Rules" section of the standard).                      
        @param _from    Source address
        @param _to      Target address
        @param _ids     IDs of each token type (order and length must match _values array)
        @param _values  Transfer amounts per token type (order and length must match _ids array)
        @param _data    Additional data with no specified format, MUST be sent unaltered in call to the `ERC1155TokenReceiver` hook(s) on `_to`
    */
    function safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes calldata _data
    ) external;

    /**
        @notice Get the balance of an account's tokens.
        @param _owner  The address of the token holder
        @param _id     ID of the token
        @return        The _owner's balance of the token type requested
     */
    function balanceOf(address _owner, uint256 _id)
        external
        view
        returns (uint256);

    /**
        @notice Get the balance of multiple account/token pairs
        @param _owners The addresses of the token holders
        @param _ids    ID of the tokens
        @return        The _owner's balance of the token types requested (i.e. balance for each (owner, id) pair)
     */
    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids)
        external
        view
        returns (uint256[] memory);

    /**
        @notice Enable or disable approval for a third party ("operator") to manage all of the caller's tokens.
        @dev MUST emit the ApprovalForAll event on success.
        @param _operator  Address to add to the set of authorized operators
        @param _approved  True if the operator is approved, false to revoke approval
    */
    function setApprovalForAll(address _operator, bool _approved) external;

    /**
        @notice Queries the approval status of an operator for a given owner.
        @param _owner     The owner of the tokens
        @param _operator  Address of authorized operator
        @return           True if the operator is approved, false if not
    */
    function isApprovedForAll(address _owner, address _operator)
        external
        view
        returns (bool);
}

interface ERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

interface ERC1155TokenReceiver {
    /**
        @notice Handle the receipt of a single ERC1155 token type.
        @dev An ERC1155-compliant smart contract MUST call this function on the token recipient contract, at the end of a `safeTransferFrom` after the balance has been updated.        
        This function MUST return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` (i.e. 0xf23a6e61) if it accepts the transfer.
        This function MUST revert if it rejects the transfer.
        Return of any other value than the prescribed keccak256 generated value MUST result in the transaction being reverted by the caller.
        @param _operator  The address which initiated the transfer (i.e. msg.sender)
        @param _from      The address which previously owned the token
        @param _id        The ID of the token being transferred
        @param _value     The amount of tokens being transferred
        @param _data      Additional data with no specified format
        @return           `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
    */
    function onERC1155Received(
        address _operator,
        address _from,
        uint256 _id,
        uint256 _value,
        bytes calldata _data
    ) external returns (bytes4);

    /**
        @notice Handle the receipt of multiple ERC1155 token types.
        @dev An ERC1155-compliant smart contract MUST call this function on the token recipient contract, at the end of a `safeBatchTransferFrom` after the balances have been updated.        
        This function MUST return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` (i.e. 0xbc197c81) if it accepts the transfer(s).
        This function MUST revert if it rejects the transfer(s).
        Return of any other value than the prescribed keccak256 generated value MUST result in the transaction being reverted by the caller.
        @param _operator  The address which initiated the batch transfer (i.e. msg.sender)
        @param _from      The address which previously owned the token
        @param _ids       An array containing ids of each token being transferred (order and length must match _values array)
        @param _values    An array containing amounts of each token being transferred (order and length must match _ids array)
        @param _data      Additional data with no specified format
        @return           `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
    */
    function onERC1155BatchReceived(
        address _operator,
        address _from,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes calldata _data
    ) external returns (bytes4);
}

interface ERC1155Metadata_URI {
    /**
        @notice A distinct Uniform Resource Identifier (URI) for a given token.
        @dev URIs are defined in RFC 3986.
        The URI MUST point to a JSON file that conforms to the "ERC-1155 Metadata URI JSON Schema".        
        @return URI string
    */
    function uri(uint256 _id) external view returns (string memory);
}

contract Token1155 is ERC1155, ERC165, ERC1155Metadata_URI {
    uint256 private constant NFT_1 = 0;
    uint256 private constant NFT_2 = 1;
    uint256 private constant NTF_3 = 2;
    address payable  private immutable _contractOwner;


    constructor(){
        _contractOwner = payable(msg.sender);
    }

    uint256[] public currentSupply = [50, 50, 50];

    uint256 public tokenPrice = 0.01 ether;

    mapping(uint256 => mapping(address => uint256)) private _balances;
    mapping(address => mapping(address => bool)) private _approvals;

    function _balanceOf(address _owner, uint256 _id)
        internal
        view
        returns (uint256)
    {
        require(_id < 3, "This token does not exists");
        require(_owner != address(0), "Invalid wallet");
        return _balances[_id][_owner];
    }

    function balanceOf(address _owner, uint256 _id)
        external
        view
        returns (uint256)
    {
        return _balanceOf(_owner, _id);
    }

    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids)
        external
        view
        returns (uint256[] memory)
    {
        require(_owners.length == _ids.length, "Owners x ids length mismatch");
        uint256[] memory balance = new uint256[](_owners.length);

        for (uint256 i = 0; i < _owners.length; i++) {
            balance[i] = _balanceOf(_owners[i], _ids[i]);
        }

        return balance;
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        require(_operator != address(0), "Invalid wallet");

        emit ApprovalForAll(msg.sender, _operator, _approved);

        _approvals[msg.sender][_operator] = _approved;
    }

    function isApprovedForAll(address _owner, address _operator)
        external
        view
        returns (bool)
    {
        require(_operator != address(0), "Invalid operator");
        require(_owner != address(0), "Invalid owner");

        return _approvals[_owner][_operator];
    }

    function _isApprovedOrOwner(address _owner, address _spender)
        internal
        view
        returns (bool)
    {
        return _owner == _spender || _approvals[_owner][_spender];
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _id,
        uint256 _value
    ) internal {
        require(_from != address(0), "Invalid _from");
        require(_to != address(0), "Invalid _to");
        require(_id < 3, "This token does not exists");
        require(_value > 0, "Invalid value");
        require(_isApprovedOrOwner(_from, msg.sender), "Not authorized");
        require(_balances[_id][_from] >= _value, "Insufficient balance");

        _balances[_id][_from] -= _value;
        _balances[_id][_to] += _value;
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _value,
        bytes calldata _data
    ) external {
        _transfer(_from, _to, _id, _value);

        emit TransferSingle(msg.sender, _from, _to, _id, _value);

        require(
            _to.code.length == 0 ||
                ERC1155TokenReceiver(_to).onERC1155Received(
                    msg.sender,
                    _from,
                    _id,
                    _value,
                    _data
                ) ==
                ERC1155TokenReceiver.onERC1155Received.selector,
            "Unsafe recipient"
        );
    }

    function safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes calldata _data
    ) external {
        require(_ids.length == _values.length, "length mismatch");

        for (uint256 i; i < _ids.length; i++) {
            _transfer(_from, _to, _ids[i], _values[i]);
        }

        emit TransferBatch(msg.sender, _from, _to, _ids, _values);

        require(
            _to.code.length == 0 ||
                ERC1155TokenReceiver(_to).onERC1155BatchReceived(
                    msg.sender,
                    _from,
                    _ids,
                    _values,
                    _data
                ) ==
                ERC1155TokenReceiver.onERC1155BatchReceived.selector,
            "Unsafe recipient"
        );
    }

    function uri(uint256 _id) external pure returns (string memory) {
        require(_id < 3, "This token does not exists");
        return string.concat("ipfs://yourhash", Strings.toString(_id), ".json");
    }

    function supportsInterface(bytes4 interfaceID)
        external
        pure
        returns (bool)
    {
        return
            interfaceID == 0xd9b67a26 ||
            interfaceID == 0x0e89341c ||
            interfaceID == 0x01ffc9a7;
    }

    function mint(uint256 _id) external payable {
        require(_id < 3, "This token does not exists");
        require(currentSupply[_id] > 0, "Max supply riched");
        require(msg.value >= tokenPrice, "Insufficient payment");

        _balances[_id][msg.sender] += 1;
        currentSupply[_id] -= 1;

        emit TransferSingle(msg.sender, address(0), msg.sender, _id, 1);

        require(
            msg.sender.code.length == 0 ||
                ERC1155TokenReceiver(msg.sender).onERC1155Received(
                    msg.sender,
                    address(0),
                    _id,
                    1,
                    ""
                ) ==
                ERC1155TokenReceiver.onERC1155Received.selector,
            "Unsafe recipient"
        );
    }

    function burn(address _from, uint256 _id) external {
        require(_from != address(0), "Invalid _from");
        require(_id < 3, "This token does not exists");
        require(_isApprovedOrOwner(_from, msg.sender), "Not authorized");
        require(_balances[_id][_from] > 0, "Insufficient balance");

        _balances[_id][msg.sender] -= 1;

        emit TransferSingle(msg.sender, _from, address(0), _id, 1);
    }

      function withdraw() public {
        require(msg.sender == _contractOwner, "Only owner can withdraw");
        uint256 balance = address(this).balance;
        (bool success, ) = _contractOwner.call{value: balance}("");
        require(success, "Transfer failed.");
    }
}
