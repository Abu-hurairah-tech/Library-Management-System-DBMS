CREATE OR REPLACE PROCEDURE PROC_RETURN_BOOK(
    p_trans_id IN NUMBER
) IS
    v_due_date DATE;
    v_member_id NUMBER;
    v_overdue_days NUMBER;
    v_daily_fine NUMBER;
    v_fine_amt NUMBER;
    v_loan_status VARCHAR2(10);
BEGIN
    -- 1. Retrieve Loan Details
    SELECT DUE_DATE, MEMBER_ID, STATUS
    INTO v_due_date, v_member_id, v_loan_status
    FROM LOAN_TRANSACTION
    WHERE TRANS_ID = p_trans_id;

    IF v_loan_status = 'CLOSED' THEN
        RAISE_APPLICATION_ERROR(-20005, 'This transaction is already closed.');
    END IF;

    -- 2. Calculate Fines (using the Helper Function)
    v_overdue_days := FN_CALC_OVERDUE_DAYS(v_due_date, TRUNC(SYSDATE));
    
    IF v_overdue_days > 0 THEN
        -- Fetch Fine Rate for this member
        SELECT mt.DAILY_FINE 
        INTO v_daily_fine
        FROM MEMBER m
        JOIN MEMBERSHIP_TYPE mt ON m.TYPE_ID = mt.TYPE_ID
        WHERE m.MEMBER_ID = v_member_id;

        v_fine_amt := v_overdue_days * v_daily_fine;

        -- Insert Fine Record
        INSERT INTO FINE (FINE_ID, TRANS_ID, AMOUNT)
        VALUES (seq_fine_id.NEXTVAL, p_trans_id, v_fine_amt);
        
        DBMS_OUTPUT.PUT_LINE('Book returned overdue. Fine Generated: ' |

| v_fine_amt);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Book returned on time. No fine.');
    END IF;

    -- 3. Close the Loan Transaction
    UPDATE LOAN_TRANSACTION
    SET RETURN_DATE = SYSDATE,
        STATUS = 'CLOSED'
    WHERE TRANS_ID = p_trans_id;

    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20006, 'Transaction ID not found.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
