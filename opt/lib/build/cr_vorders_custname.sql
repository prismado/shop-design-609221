CREATE VIEW vorders_custname AS (
        select  v.id, sid, uid, firstname, lastname, gender, company, zip, city, country, pay_meth, v.instime, vat_rate, amount_incl_vat, uname, email, status, remarks
        FROM    vorders v, users_addr a
        WHERE   uid=a.user_id AND a.type=1
);
