# Accounting

## Chart of Accounts

```
1000 Assets
  └─ 1100 Current
       └─ 1110 assets:current:payment-processor-receivables

2000 Liabilities
  └─ 2100 Customer Deposits
       └─ 2110 liabilities:customer-deposits:xxxx:available
       └─ 2120 liabilities:customer-deposits:xxxx:reserved
```

I intentionally simplified the accounting chart to the bare essentials for the task. In a production system, there would be more account categories, and customer wallet balances would usually be maintained in a dedicated subledger, with summarized activity posted into the company general ledger

## Operation Plans

### 1. Fund Reservation

```
DR  liabilities:customer-deposits:xxxx:available    1000  (-$10 to balance)
CR  liabilities:customer-deposits:xxxx:reserved     1000  (+$10 to balance)
```

### 2. Customer Deposit

```
DR  assets:current:payment-processor-receivables  1000  (+$10 to balance)
CR  liabilities:customer-deposits:xxxx:available    1000  (+$10 to balance)
```

### 3. Customer Withdrawal

```
DR  liabilities:customer-deposits:xxxx:reserved     1000  (-$10 to balance)
CR  assets:current:payment-processor-receivables  1000  (-$10 to balance)
```

### 4. Transfer Between Customers

```
DR  liabilities:customer-deposits:xxxx:available    1000  (-$10 to balance)
CR  liabilities:customer-deposits:yyyy:available    1000  (+$10 to balance)
```

### 5. Reservation Release

```
DR  liabilities:customer-deposits:xxxx:reserved     1000  (-$10 to balance)
CR  liabilities:customer-deposits:xxxx:available    1000  (+$10 to balance)
```
