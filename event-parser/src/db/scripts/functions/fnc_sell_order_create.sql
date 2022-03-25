CREATE OR REPLACE FUNCTION BACKEND.FNC_SELL_ORDER_CREATE ()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
BEGIN
    --------------------------------------------------
    -- Creates order
    --------------------------------------------------

    IF NEW.STATUS = TRUE THEN
        INSERT INTO BACKEND.SELL_ORDERS (
            NFT_CONTRACT,
            TOKEN_ID,
            SELLER,
            PRICE,
            CURRENCY_CONTRACT
        )
        VALUES (
            NEW.ERC721,
            NEW.TOKEN_ID,
            NEW.SELLER,
            NEW.PRICE,
            NEW.ERC20
        )
        ON CONFLICT (NFT_CONTRACT, TOKEN_ID)
        DO
        NOTHING;
    END IF;

    --------------------------------------------------
    -- Deletes old order
    --------------------------------------------------

    IF NEW.STATUS = FALSE THEN
 		DELETE
        FROM    BACKEND.SELL_ORDERS
        WHERE   NFT_CONTRACT    = NEW.ERC721
        AND     TOKEN_ID        = NEW.TOKEN_ID;
    END IF;

    --------------------------------------------------
    -- Creates order history
    --------------------------------------------------

    INSERT INTO BACKEND.SELL_ORDERS_HISTORY (
        NFT_CONTRACT,
        TOKEN_ID,
        SELLER,
        PRICE,
        CURRENCY_CONTRACT,
        STATUS,
        TRANSACTION,
        TRANSACTION_TIME
    )
    VALUES (
        NEW.ERC721,
        NEW.TOKEN_ID,
        NEW.SELLER,
        NEW.PRICE,
        NEW.ERC20,
        NEW.STATUS,
        NEW.TRANSACTION,
        NEW.TIMESTAMP
    )
    ON CONFLICT (NFT_CONTRACT, TOKEN_ID, TRANSACTION)
    DO
    NOTHING;

	RETURN NULL;
END;
$$