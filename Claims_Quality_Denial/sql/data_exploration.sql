SELECT * 
FROM claims_cleaned;

SELECT COUNT(*) AS TotalClaims
FROM claims_cleaned;

CREATE TABLE claims_staged
LIKE claims_cleaned;

DESCRIBE claims_staged;

ALTER TABLE claims_staged
MODIFY COLUMN `Provider Fixed` VARCHAR(20),
MODIFY COLUMN `Patient Fixed` VARCHAR(20),
MODIFY COLUMN `DOS Fixed` TEXT,
MODIFY COLUMN `Billed Amount` DOUBLE,
MODIFY COLUMN `Allowed Amount` DOUBLE,
MODIFY COLUMN `Paid Amount` DOUBLE;

INSERT INTO claims_staged (
    `ï»¿Claim ID`,
    `Provider Fixed`,
    `Patient Fixed`,
    `DOS Fixed`,
    `Billed Amount`,
    `Procedure Code`,
    `Diag Fixed`,
    `Allowed Amount`,
    `Paid Amount`,
    `Insurance Fixed`,
    `Claim Status`,
    `Reason Code`,
    `Follow-up Required`,
    `AR Status`,
    `Outcome`
)
SELECT
    `ï»¿Claim ID`,
    `Provider Fixed`,
    `Patient Fixed`,
    STR_TO_DATE(`DOS Fixed`, '%Y-%m-%Yd'),

    NULLIF(`Billed Amount`, '') + 0,
    `Procedure Code`,
    `Diag Fixed`,

    NULLIF(`Allowed Amount`, '') + 0,
    NULLIF(`Paid Amount`, '') + 0,

    `Insurance Fixed`,
    `Claim Status`,
    `Reason Code`,
    `Follow-up Required`,
    `AR Status`,
    `Outcome`
FROM claims_cleaned;

SELECT *
FROM claims_staged;

ALTER TABLE claims_staged
CHANGE `ï»¿Claim ID` `Claim ID` VARCHAR(50);

-- Number of claims by Insurance Type

SELECT `Insurance Fixed`, COUNT(*) AS ClaimCount
FROM claims_staged
GROUP BY `Insurance Fixed`
ORDER BY ClaimCount DESC;

-- Average Amount Paid

SELECT ROUND(AVG(`Paid Amount`),2) AS AveragePaid
FROM claims_staged;

-- Total Paid by Insurance

SELECT `Insurance Fixed`, SUM(`Paid Amount`) AS TotalPaid
FROM claims_staged
GROUP BY `Insurance Fixed`
ORDER BY TotalPaid DESC;

-- Claims Denied by Reason

SELECT `Reason Code`, COUNT(*) AS ClaimCount
FROM claims_staged
WHERE Outcome = 'Denied'
GROUP BY `Reason Code`
ORDER BY ClaimCount DESC;

-- Reimbursement Rate

SELECT ROUND(AVG(`Allowed Amount`/`Billed Amount`) * 100, 2) AS reimbursed
FROM claims_staged;

-- Denial by DX/PX

SELECT `Procedure Code`, `Diag Fixed`, COUNT(`Outcome`) AS DeniedTally
FROM claims_staged
WHERE Outcome = 'Denied'
GROUP BY `Procedure Code`, `Diag Fixed`
ORDER BY DeniedTally DESC
LIMIT 10;

-- Corrected the Date Format

UPDATE claims_staged
SET `DOS Fixed` = STR_TO_DATE(`DOS Fixed`, '%Y-%m-%d');

ALTER TABLE claims_staged
MODIFY COLUMN `DOS Fixed` DATE;

DESCRIBE claims_staged;