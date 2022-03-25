CREATE OR REPLACE FUNCTION BACKEND.FNC_MATCHED_ORDER_CREATE ()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
BEGIN
    --------------------------------------------------
    -- Deletes old order
    --------------------------------------------------

    DELETE
    FROM    BACKEND.SELL_ORDERS
    WHERE   NFT_CONTRACT    = NEW.ERC721
    AND     TOKEN_ID        = NEW.TOKEN_ID;

    --------------------------------------------------
    -- Creates matched order history
    --------------------------------------------------

    INSERT INTO BACKEND.MATCHED_ORDERS_HISTORY (
        NFT_CONTRACT,
        TOKEN_ID,
        SELLER,
        BUYER,
        PRICE,
        CURRENCY_CONTRACT,
        TYPE,
        TRANSACTION,
        TRANSACTION_TIME
    )
    VALUES (
        NEW.ERC721,
        NEW.TOKEN_ID,
        NEW.SELLER,
        NEW.BUYER,
        NEW.PRICE,
        NEW.ERC20,
        'fixed price',
        NEW.TRANSACTION,
        NEW.TIMESTAMP
    )
    ON CONFLICT (NFT_CONTRACT, TOKEN_ID, TRANSACTION)
    DO
    NOTHING;

	RETURN NULL;
END;
$$