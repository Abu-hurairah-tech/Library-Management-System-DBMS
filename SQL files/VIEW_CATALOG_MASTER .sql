CREATE
OR REPLACE VIEW VIEW_CATALOG_MASTER AS
SELECT
    b.ISBN,
    b.TITLE,
    b.EDITION,
    p.PUB_NAME,
    b.PUB_YEAR,
    LISTAGG (a.FULL_NAME, ', ') WITHIN GROUP (
        ORDER BY
            a.FULL_NAME
    ) AS AUTHORS,
    (
        SELECT
            COUNT(*)
        FROM
            BOOK_COPY bc
        WHERE
            bc.ISBN = b.ISBN
            AND bc.STATUS = 'AVAILABLE'
    ) AS COPIES_AVAILABLE,
    (
        SELECT
            COUNT(*)
        FROM
            BOOK_COPY bc
        WHERE
            bc.ISBN = b.ISBN
    ) AS TOTAL_COPIES
FROM
    BOOK b
    JOIN PUBLISHER p ON b.PUB_ID = p.PUB_ID
    JOIN BOOK_AUTHOR ba ON b.ISBN = ba.ISBN
    JOIN AUTHOR a ON ba.AUTHOR_ID = a.AUTHOR_ID
GROUP BY
    b.ISBN,
    b.TITLE,
    b.EDITION,
    p.PUB_NAME,
    b.PUB_YEAR;