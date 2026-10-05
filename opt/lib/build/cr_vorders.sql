
CREATE VIEW vorders AS (
        select  o.id, o.sid, o.uid, o.pay_meth, o.instime, vat_rate, amount_incl_vat, uname, email, o.status, o.remarks
        FROM    orders o
        LEFT    JOIN users u
        ON      uid=u.id
);
