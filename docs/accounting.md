# Accounting

## Chart of Accounts

```
1000 Assets
  └─ 1100 Cash
       └─ 1110 assets:cash:payment-processor-balance

2000 Liabilities
  └─ 2100 Client Deposits
       └─ 2110 liabilities:client-deposits:xxxx:available
       └─ 2120 liabilities:client-deposits:xxxx:reserved
```

I intentionally simplified the accounting chart to the bare essentials for the task. In a production system, there would be more account categories, and client wallet balances would usually be maintained in a dedicated subledger, with summarized activity posted into the company general ledger

## Operation Plans

### 1. Fund Reservation

```
DR  liabilities:client-deposits:xxxx:available  1000  (-$10 to balance)
CR  liabilities:client-deposits:xxxx:reserved   1000  (+$10 to balance)
```

### 2. Client Deposit

```
DR  assets:cash:payment-processor-balance       1000  (+$10 to balance)
CR  liabilities:client-deposits:xxxx:available  1000  (+$10 to balance)
```

### 3. Client Withdrawal

```
DR  liabilities:client-deposits:xxxx:reserved   1000  (-$10 to balance)
CR  assets:cash:payment-processor-balance       1000  (-$10 to balance)
```

### 4. Transfer Between Clients

```
DR  liabilities:client-deposits:xxxx:available  1000  (-$10 to balance)
CR  liabilities:client-deposits:yyyy:available  1000  (+$10 to balance)
```

### 5. Reservation Release

```
DR  liabilities:client-deposits:xxxx:reserved   1000  (-$10 to balance)
CR  liabilities:client-deposits:xxxx:available  1000  (+$10 to balance)
```
