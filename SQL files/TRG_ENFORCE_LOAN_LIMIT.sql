CREATE OR REPLACE TRIGGER TRG_ENFORCE_LOAN_LIMIT
BEFORE INSERT ON LOAN_TRANSACTION
FOR EACH ROW
DECLARE
    v_current_loans NUMBER;
    v_max_allowed NUMBER;
BEGIN
    -- 1. Retrieve the maximum allowed books for this member's type
    SELECT mt.MAX_BOOKS 
    INTO v_max_allowed
    FROM MEMBER m
    JOIN MEMBERSHIP_TYPE mt ON m.TYPE_ID = mt.TYPE_ID
    WHERE m.MEMBER_ID = :NEW.MEMBER_ID;

    -- 2. Count the currently open loans for this member
    SELECT COUNT(*)
    INTO v_current_loans
    FROM LOAN_TRANSACTION
    WHERE MEMBER_ID = :NEW.MEMBER_ID AND STATUS = 'OPEN';

    -- 3. Validation Logic
    IF v_current_loans >= v_max_allowed THEN
        RAISE_APPLICATION_ERROR(-20001, 
            'Borrowing limit reached. Member cannot borrow more than ' || v_max_allowed || items.');
    END IF;
END;
