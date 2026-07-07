# Fintech API Demo

This is a small Rails API built as part of a client evaluation process. The goal is to show the shape of the solution, not to present a production-ready financial system.

The app allows to sign up, deposit funds, transfer funds to others, withdraw funds and list money movements. The app keeps track of all cash flows using double entry accounting.

The original task is kept in [docs/task_definition.md](docs/task_definition.md). Example curl calls are in [docs/curl_commands.md](docs/curl_commands.md).

## Scope Notes

This project intentionally cuts corners. It has enough behavior, structure, and tests to demonstrate the approach, but it is not hardened for production use. No real money is involved. No integrations with payment processors. The test suite only demonstrates single examples of unit and feature tests.

## Setup

Prerequisites: Ruby from [.ruby-version](.ruby-version), PostgreSQL, and Bundler.

```bash
bundle install
```

Create local Rails credentials. This creates `config/master.key`; the API also needs an RSA private key for JWT signing.

```bash
# If you were not given the matching config/master.key, recreate local credentials.
rm -f config/credentials.yml.enc
bin/rails credentials:edit
```

Generate a local private key with:

```bash
ruby -ropenssl -e 'puts OpenSSL::PKey::RSA.generate(2048)'
```

Add the generated key to the credentials file:

```yaml
jwt_private_key: |-
  -----BEGIN RSA PRIVATE KEY-----
  ...
  -----END RSA PRIVATE KEY-----
```

Prepare the database and run the checks:

```bash
bin/rails db:create db:migrate db:seed
bundle exec rspec
```

Run the API locally:

```bash
bin/rails server
```

## API

All authenticated endpoints expect `Authorization: Bearer <access_token>`.

| Method | Path | Purpose |
| --- | --- | --- |
| `POST` | `/api/sign_ups` | Create a client from an email. |
| `POST` | `/api/sign_ins` | Issue a JWT access token for an existing email. |
| `GET` | `/api/me` | Return the current client and available balance. |
| `GET` | `/api/cx/client` | Search cleint by public email. |
| `GET` | `/api/cx/money_movements` | List client-visible money movement history. |
| `POST` | `/api/fin_ops/deposits` | Deposit funds into the current client's account. |
| `POST` | `/api/fin_ops/withdrawals` | Withdraw funds from the current client's account. |
| `POST` | `/api/fin_ops/transfers` | Transfer funds to another client. |

Request bodies are resource-wrapped JSON, for example:

```json
{ "sign_up": { "email": "client@example.com" } }
{ "deposit": { "amount_cents": 2000 } }
{ "withdrawal": { "amount_cents": 2000 } }
{ "transfer": { "receiver_id": "...", "amount_cents": 500 } }
```

Successful responses return:

```json
{"data": <object or collection>}
```
Failed responses return:

```json
{
  "errors": [
    {
      "status": 422, 
      "title": "amount_below_minimum", 
      "detail": "Amounts should be positive"
    }
  ]
}
```

## Call Stack

### Mutating Requests (`#create`, `#update`, `#destroy`)

Those tend to become complex in terms of the implementation, so maintaining layer boundaries is highly important and the call stack is mandatory the following:

<img src="docs/Call Stack.png">

### Read-Only Requests (`#index`, `#show`)

For simple read-only requests that only involve several model calls, referencing model classes directly in the controller action in tolerable. This helps to avoid boilerplate while typically being extremely cheap to change in the future if needed

For complex read-only requests (e.g., indexing a collection with adjustable filters and sorting), mintaining layer boundaries through action/interface is mandatory. There are no expamples of complex read-only requests in this particular app though

## Data Model

<img src="docs/Data Model.png">

## Architecture

The code is split around three subdomains:

* `CX`: client experience, including clients and money movement history.
* `FinOps`: financial operations, including deposits, withdrawals, transfers, and payer accounts.
* `Accounting`: account balances, journal entries, and postings.

Subdomains expose their entry points through `app/services/<subdomain>/interface.rb`. Code outside a subdomain must use these interfaces instead of reaching into internal operations directly.

Financial state is recorded with double-entry accounting. Each money movement is expressed as balanced debit and credit postings, which makes balance changes auditable and keeps available/reserved client funds separate. The chart of accounts and transaction rules are documented in [docs/accounting.md](docs/accounting.md).

The app also keeps a layer separation:

* **Presentation**: `app/controllers`, `app/actions` and `app/serializers` (I didn't use mailers or jobs in this app).
* **Application**: models of business operations, organized into folders by subdomain under `app/services`.
* **Domain**: records and concepts that encode facts about the system, living in `app/models`.
* **Infrastructure**: low-level gem-like code in `lib`.

The intended dependency direction is one-way: presentation calls application code, application code works with domain-layer facts, and infrastructure stays at the edges. This keeps request handling, business workflows, system facts, and low-level tooling from blending together.
