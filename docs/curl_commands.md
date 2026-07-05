## Debugging

```bash
JQ_DEBUG='{data, errors, status, error, exception, traces: {"Application Trace": (.traces["Application Trace"] // [])[:3]}}'
```

## Sign Up

```bash
# main client
curl -s -X POST -H "content-type: application/json" localhost:3000/api/sign_ups -d '{"email": "test@example.com"}' | jq $JQ_DEBUG

# other client (for transfers)
curl -s -X POST -H "content-type: application/json" localhost:3000/api/sign_ups -d '{"email": "test2@example.com"}' | jq $JQ_DEBUG
```

## Sign In

```bash
curl -s -X POST -H "content-type: application/json" localhost:3000/api/sign_ins -d '{"sign_in": {"email": "test@example.com"}}' | jq $JQ_DEBUG

TOKEN=...

curl -s -X POST -H "content-type: application/json" localhost:3000/api/sign_ins -d '{"sign_in": {"email": "test2@example.com"}}' | jq $JQ_DEBUG

TOKEN2=...
```

## Read Balance

```bash
curl -s -X GET -H "content-type: application/json" -H "Authorization: Bearer $TOKEN" localhost:3000/api/client | jq $JQ_DEBUG

curl -s -X GET -H "content-type: application/json" -H "Authorization: Bearer $TOKEN2" localhost:3000/api/client | jq $JQ_DEBUG

RECEIVER_ID=...
```

## Create Deposit

```bash
curl -s -X POST -H "content-type: application/json" -H "Authorization: Bearer $TOKEN" localhost:3000/api/fin_ops/deposits -d '{"amount_cents": 200}' | jq $JQ_DEBUG
```

## Create Transfer

```bash
curl -s -X POST -H "content-type: application/json" -H "Authorization: Bearer $TOKEN" localhost:3000/api/fin_ops/transfers -d "{\"amount_cents\": 100, \"receiver_id\": \"$RECEIVER_ID\"}" | jq $JQ_DEBUG
```

## Create Withdrawal

```bash
curl -s -X POST -H "content-type: application/json" -H "Authorization: Bearer $TOKEN2" localhost:3000/api/fin_ops/withdrawals -d '{"amount_cents": 50}' | jq $JQ_DEBUG
```


## List Money Movements

```bash
curl -s -X GET -H "content-type: application/json" -H "Authorization: Bearer $TOKEN" localhost:3000/api/cx/money_movements | jq $JQ_DEBUG

curl -s -X GET -H "content-type: application/json" -H "Authorization: Bearer $TOKEN2" localhost:3000/api/cx/money_movements | jq $JQ_DEBUG
```
