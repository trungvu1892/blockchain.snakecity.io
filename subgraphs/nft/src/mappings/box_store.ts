/* eslint-disable prefer-const */
import { log } from "@graphprotocol/graph-ts";

import { BoxBought, BoxOpened } from '../types/BoxStore/BoxStore';
import { MysteryBoxSold, MysteryBoxOpened } from '../types/schema';

export function handleBoxBought (event: BoxBought): void {
    let buyer = event.params.user.toHex();
    let boxIds = event.params.boxIds;
    let boxType = event.params.boxType;
    let transaction = event.transaction.hash.toHex();
    let timestamp = event.block.timestamp;

    log.info('Buy box, buyer: {}, boxIds: {}, boxType: {}', [buyer, boxIds.toString(), boxType.toString()]);

    for (let i = 0; i < boxIds.length; i++) {
        let boxId = boxIds[i];

        let history = new MysteryBoxSold(transaction + '_' + boxId.toString());
        history.boxId = boxId;
        history.boxType = boxType;
        history.buyer = buyer;
        history.transaction = transaction;
        history.timestamp = timestamp;
        history.save();
    }
}

export function handleBoxOpened (event: BoxOpened): void {
    let user = event.params.user.toHex();
    let boxId = event.params.boxId;
    let itemIds = event.params.itemIds;
    let boxType = event.params.boxType;
    let transaction = event.transaction.hash.toHex();
    let timestamp = event.block.timestamp;

    log.info('Open box, user: {}, itemIds: {}, boxId: {}, boxType: {}', [user, itemIds.toString(), boxId.toString(), boxType.toString()]);

    for (let i = 0; i < itemIds.length; i++) {
        let itemId = itemIds[i];

        let history = new MysteryBoxOpened(transaction + '_' + itemId.toString());
        history.itemId = itemId;
        history.boxId = boxId;
        history.boxType = boxType;
        history.user = user;
        history.transaction = transaction;
        history.timestamp = timestamp;
        history.save();
    }
}