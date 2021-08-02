pragma solidity ^0.5.16;

import "./COKT.sol";

/**
 * @title Acmd's Maximillion Contract
 * @author Acmd
 */
contract Maximillion {
    /**
     * @notice The default COKT market to repay in
     */
    COKT public COKT_;

    /**
     * @notice Construct a Maximillion to repay max in a COKT market
     */
    constructor(COKT COKT__) public {
        COKT_ = COKT__;
    }

    /**
     * @notice msg.sender sends OKT to repay an account's borrow in the COKT market
     * @dev The provided OKT is applied towards the borrow balance, any excess is refunded
     * @param borrower The address of the borrower account to repay on behalf of
     */
    function repayBehalf(address borrower) public payable {
        repayBehalfExplicit(borrower, COKT_);
    }

    /**
     * @notice msg.sender sends OKT to repay an account's borrow in a COKT market
     * @dev The provided OKT is applied towards the borrow balance, any excess is refunded
     * @param borrower The address of the borrower account to repay on behalf of
     * @param COKT__ The address of the COKT contract to repay in
     */
    function repayBehalfExplicit(address borrower, COKT COKT__) public payable {
        uint received = msg.value;
        uint borrows = COKT__.borrowBalanceCurrent(borrower);
        if (received > borrows) {
            COKT__.repayBorrowBehalf.value(borrows)(borrower);
            msg.sender.transfer(received - borrows);
        } else {
            COKT__.repayBorrowBehalf.value(received)(borrower);
        }
    }
}
