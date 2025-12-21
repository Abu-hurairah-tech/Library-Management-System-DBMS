CREATE OR REPLACE FUNCTION FN_CALC_OVERDUE_DAYS(p_due_date DATE, p_return_date DATE) 
RETURN NUMBER IS
    v_days NUMBER := 0;
    v_curr_date DATE;
    v_is_holiday NUMBER;
BEGIN
    -- If returned on time or early, no fine days
    IF p_return_date <= p_due_date THEN
        RETURN 0;
    END IF;

    -- Start counting from the day after the due date
    v_curr_date := p_due_date + 1;
    
    WHILE v_curr_date <= p_return_date LOOP
        -- Check if the day is a weekend (Safe check using DY format)
        -- Note: NLS settings can affect this, so explicit English check is safer for this example
        IF TO_CHAR(v_curr_date, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH') NOT IN ('SAT', 'SUN') THEN
            
            -- Check if the day is in the HOLIDAYS table
            SELECT COUNT(*) INTO v_is_holiday 
            FROM HOLIDAYS 
            WHERE HOLIDAY_DATE = TRUNC(v_curr_date);
            
            -- If not a holiday, increment the fineable day count
            IF v_is_holiday = 0 THEN
                v_days := v_days + 1;
            END IF;
        END IF;
        
        -- Move to the next day
        v_curr_date := v_curr_date + 1;
    END LOOP;
    
    RETURN v_days;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0; -- Fail safe
END;
