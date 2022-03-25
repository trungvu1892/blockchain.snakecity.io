/* eslint-disable prefer-const */
import { log } from "@graphprotocol/graph-ts";

import { Transfer } from '../types/Snake/Snake';
import { SnakeOwnership } from '../types/schema';

export function handleTransfer (event: Transfer): void {
    let userFrom = event.params.from.toHex();
    let userTo = event.params.to.toHex();
    let tokenId = event.params.tokenId;
    let transaction = event.transaction.hash.toHex();
    let timestamp = event.block.timestamp;

    log.info('Snake, userFrom: {}, userTo: {}, tokenId: {}', [userFrom, userTo, tokenId.toString()]);

    let history = new SnakeOwnership(transaction + '_' + tokenId.toString());
    history.snakeId = tokenId;
    history.userFrom = userFrom;
    history.userTo = userTo;
    history.transaction = transaction;
    history.timestamp = timestamp;
    history.save();
}