CREATE OR REPLACE FUNCTION BACKEND.FNC_SNAKE_OWNERSHIP_CREATE ()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
    DECLARE
		v_genesis           VARCHAR(50);
        v_sc_marketplace    VARCHAR(50);
BEGIN
    v_genesis := '0x0000000000000000000000000000000000000000';

    v_sc_marketplace := '{SC_MARKETPLACE}';

    --------------------------------------------------
    -- Creates snake data
    --------------------------------------------------

    IF NEW.USER_FROM = v_genesis THEN
        INSERT INTO BACKEND.SNAKES (
            ID,
            CREATOR,
            OWNER,
            LATEST_TRANSACTION_TIME
        )
        VALUES (
            NEW.SNAKE_ID,
            NEW.USER_TO,
            NEW.USER_TO,
            NEW.TIMESTAMP
        )
        ON CONFLICT (ID)
        DO
        NOTHING;
    END IF;

    --------------------------------------------------
    -- Updates snake ownership
    --------------------------------------------------

    IF NEW.USER_FROM <> v_genesis AND NEW.USER_TO <> v_sc_marketplace THEN
 		UPDATE	BACKEND.SNAKES
 		SET		OWNER 	                 = NEW.USER_TO,
		 		LATEST_TRANSACTION_TIME  = NEW.TIMESTAMP
 		WHERE	ID                       = NEW.SNAKE_ID
        AND     LATEST_TRANSACTION_TIME <= NEW.TIMESTAMP;
    END IF;

    --------------------------------------------------
    -- Creates snake ownership history
    --------------------------------------------------

    IF NEW.USER_FROM <> v_sc_marketplace AND NEW.USER_TO <> v_sc_marketplace THEN
        INSERT INTO BACKEND.SNAKES_HISTORY (
            SNAKE_ID,
            USER_FROM,
            USER_TO,
            TRANSACTION,
            TRANSACTION_TIME
        )
        VALUES (
            NEW.SNAKE_ID,
            NEW.USER_FROM,
            NEW.USER_TO,
            NEW.TRANSACTION,
            NEW.TIMESTAMP
        )
        ON CONFLICT (SNAKE_ID, USER_FROM, USER_TO, TRANSACTION)
        DO
        NOTHING;
    END;

	RETURN NULL;
END;
$$