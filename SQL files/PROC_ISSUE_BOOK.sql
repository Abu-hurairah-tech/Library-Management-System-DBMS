CREATE OR REPLACE PROCEDURE PROC_ISSUE_BOOK(
    p_member_id IN NUMBER,
    p_copy_id IN NUMBER
) IS
    v_copy_status VARCHAR2(20);
    v_loan_days NUMBER;
    v_due_date DATE;
    v_mem_status VARCHAR2(10);
BEGIN
    -- 1. Validate Member Status
    SELECT STATUS INTO v_mem_status FROM MEMBER WHERE MEMBER_ID = p_member_id;
    IF v_mem_status!= 'ACTIVE' THEN
        RAISE_APPLICATION_ERROR(-20002, 'Member account is Suspended or Expired.');
    END IF;

    -- 2. Validate Copy Availability
    SELECT STATUS INTO v_copy_status FROM BOOK_COPY WHERE COPY_ID = p_copy_id;
    IF v_copy_status!= 'AVAILABLE' THEN
        RAISE_APPLICATION_ERROR(-20003, 'Book Copy is not available for circulation.');
    END IF;

    -- 3. Calculate Due Date based on Membership Type
    SELECT mt.LOAN_DAYS 
    INTO v_loan_days
    FROM MEMBER m
    JOIN MEMBERSHIP_TYPE mt ON m.TYPE_ID = mt.TYPE_ID
    WHERE m.MEMBER_ID = p_member_id;

    v_due_date := TRUNC(SYSDATE) + v_loan_days;

    -- 4. Create Transaction (Triggers will handle Limit Check and Status Update)
    INSERT INTO LOAN_TRANSACTION (TRANS_ID, COPY_ID, MEMBER_ID, DUE_DATE)
    VALUES (seq_trans_id.NEXTVAL, p_copy_id, p_member_id, v_due_date);
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Book issued successfully. Due Date: ' || v_due_date);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20004, 'Invalid Member ID or Book Copy ID.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE; -- Propagate error to application
END;
