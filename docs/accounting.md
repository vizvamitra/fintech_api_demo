# Accounting

## Chart of Accounts

1000 Assets
  └─ 1100 Assets:PaymentProcessorBalance

2000 Liabilities
  └─ 2100 Liabilities:ClientDeposits
       └─ 2100-xxxx-01 Liabilities:ClientDeposits:xxxx:Available
       └─ 2100-xxxx-02 Liabilities:ClientDeposits:xxxx:Reserved

Nothing else is needed based on the task description.

## Operation Plans

### 1. Fund Reservation

DR  Liabilities:ClientDeposits:xxxx:Available  100  (-100)
CR  Liabilities:ClientDeposits:xxxx:Reserved   100  (+100)

### 2. Client Deposit

DR  Assets:PaymentProcessorBalance             100  (+100)
CR  Liabilities:ClientDeposits:xxxx:Available  100  (+100)

### 3. Client Withdrawal

DR  Liabilities:ClientDeposits:xxxx:Reserved   100  (-100)
CR  Assets:PaymentProcessorBalance             100  (-100)

### 4. Transfer Between CLients

DR  Liabilities:ClientDeposits:xxxx:Available  100  (-100)
CR  Liabilities:ClientDeposits:yyyy:Available  100  (+100)

### 5. Reservation Release

DR  Liabilities:ClientDeposits:xxxx:Reserved   100  (-100)
CR  Liabilities:ClientDeposits:xxxx:Available  100  (+100)
