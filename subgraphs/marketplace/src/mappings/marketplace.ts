/* eslint-disable prefer-const */
import { log } from "@graphprotocol/graph-ts";

import { AskCreated, AskCanceled, TokenSold } from '../types/Marketplace/Marketplace';
import { SellOrder, MatchedOrder } from '../types/schema';

export function handleAskCreated (event: AskCreated): void {
    let erc721 = event.params.erc721.toHex();
    let erc20 = event.params.erc20.toHex();
    let tokenId = event.params.tokenId;
    let seller = event.params.seller.toHex();
    let price = event.params.price;
    let transaction = event.transaction.hash.toHex();
    let timestamp = event.block.timestamp;

    log.info('List sale, erc721: {}, erc20: {}, tokenId: {}, seller: {}, price: {}', [erc721, erc20, tokenId.toString(), seller, price.toString()]);

    let order = new SellOrder(transaction);
    order.erc721 = erc721;
    order.tokenId = tokenId;
    order.seller = seller;
    order.price = price;
    order.erc20 = erc20;
    order.status = true;
    order.transaction = transaction;
    order.timestamp = timestamp;
    order.save();
}

export function handleAskCanceled (event: AskCanceled): void {
    let erc721 = event.params.erc721.toHex();
    let erc20 = event.params.erc20.toHex();
    let tokenId = event.params.tokenId;
    let seller = event.params.seller.toHex();
    let price = event.params.price;
    let transaction = event.transaction.hash.toHex();
    let timestamp = event.block.timestamp;

    log.info('Cancel sale, erc721: {}, erc20: {}, tokenId: {}, seller: {}, price: {}', [erc721, erc20, tokenId.toString(), seller, price.toString()]);

    let order = new SellOrder(transaction);
    order.erc721 = erc721;
    order.tokenId = tokenId;
    order.seller = seller;
    order.price = price;
    order.erc20 = erc20;
    order.status = false;
    order.transaction = transaction;
    order.timestamp = timestamp;
    order.save();
}

export function handleTokenSold (event: TokenSold): void {
    let erc721 = event.params.erc721.toHex();
    let erc20 = event.params.erc20.toHex();
    let tokenId = event.params.tokenId;
    let seller = event.params.seller.toHex();
    let buyer = event.params.buyer.toHex();
    let price = event.params.price;
    let transaction = event.transaction.hash.toHex();
    let timestamp = event.block.timestamp;

    log.info('Buy, erc721: {}, erc20: {}, tokenId: {}, seller: {}, buyer: {}, price: {}', [erc721, erc20, tokenId.toString(), seller, buyer, price.toString()]);

    let order = new MatchedOrder(transaction);
    order.erc721 = erc721;
    order.tokenId = tokenId;
    order.seller = seller;
    order.buyer = buyer;
    order.price = price;
    order.erc20 = erc20;
    order.transaction = transaction;
    order.timestamp = timestamp;
    order.save();
}