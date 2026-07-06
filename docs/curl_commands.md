# Example `curl` Commands

This list provides a complete scenario:

- Sign up twice, creating two clients: "sender" and "receiver"
- Fetch access tokens for both
- Fetch client records to check balances
- As sender, deposit $200
- As sender, search receiver by email to get public ID
- As sender, transfer $100 to receiver
- As receiver, withdraw $50
- List money movements for both

Scenario should leave sender with $100, receiver -- with $50, and create the following money movements:

Sender:
- deposit, $200
- outgoing_transfer, $100

Receiver:
- incoming_transfer, $100,
- withdrawal, $50

## Sign Up

```bash
# sender
curl -s -X POST -H "content-type: application/json" localhost:3000/api/sign_ups -d '{"email": "test@example.com"}'

# receiver (for transfers)
curl -s -X POST -H "content-type: application/json" localhost:3000/api/sign_ups -d '{"email": "test2@example.com"}'
```

## Sign In

```bash
curl -s -X POST -H "content-type: application/json" localhost:3000/api/sign_ins -d '{"sign_in": {"email": "test@example.com"}}'

SENDER_TOKEN=... # token from the response of the command above

curl -s -X POST -H "content-type: application/json" localhost:3000/api/sign_ins -d '{"sign_in": {"email": "test2@example.com"}}'

RECEIVER_TOKEN=... # token from the response of the command above
```

## Check Balances

```bash
curl -s -X GET -H "content-type: application/json" -H "Authorization: Bearer $SENDER_TOKEN" localhost:3000/api/me

curl -s -X GET -H "content-type: application/json" -H "Authorization: Bearer $RECEIVER_TOKEN" localhost:3000/api/me
```

## Create Deposit

```bash
curl -s -X POST -H "content-type: application/json" -H "Authorization: Bearer $SENDER_TOKEN" localhost:3000/api/fin_ops/deposits -d '{"amount_cents": 20000}'
```

## Search Client by Email

```bash
curl -s -X GET -H "content-type: application/json" -H "Authorization: Bearer $SENDER_TOKEN" localhost:3000/api/cx/client\?public_email=test2@example.com

RECEIVER_ID=... # public_id from the response of the command above
```


## Create Transfer

```bash
curl -s -X POST -H "content-type: application/json" -H "Authorization: Bearer $SENDER_TOKEN" localhost:3000/api/fin_ops/transfers -d "{\"amount_cents\": 10000, \"receiver_id\": \"$RECEIVER_ID\"}"
```

## Create Withdrawal

```bash
curl -s -X POST -H "content-type: application/json" -H "Authorization: Bearer $RECEIVER_TOKEN" localhost:3000/api/fin_ops/withdrawals -d '{"amount_cents": 5000}'
```

## List Money Movements

```bash
curl -s -X GET -H "content-type: application/json" -H "Authorization: Bearer $SENDER_TOKEN" localhost:3000/api/cx/money_movements

curl -s -X GET -H "content-type: application/json" -H "Authorization: Bearer $RECEIVER_TOKEN" localhost:3000/api/cx/money_movements
```
