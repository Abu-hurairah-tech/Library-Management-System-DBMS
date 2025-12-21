SELECT
    b.TITLE,
    b.ISBN,
    bc.COPY_ID,
    bc.STATUS,
    bc.SHELF_ID
FROM
    BOOK b
    JOIN BOOK_COPY bc ON b.ISBN = bc.ISBN
WHERE
    NOT EXISTS (
        SELECT
            1
        FROM
            LOAN_TRANSACTION l
        WHERE
            l.COPY_ID = bc.COPY_ID
    )
ORDER BY
    b.TITLE;