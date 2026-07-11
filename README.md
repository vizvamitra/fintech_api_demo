# Fintech API Demo

This is a small Rails API-only app built as part of a client evaluation process. 

The app allows its clients to sign up, deposit funds, transfer funds to others, withdraw funds and list money movements. The app keeps track of all cash flows using double entry accounting.

This is not a production-ready financial system, but a demo intended to showcase my architectural and engineering skills. Most of the code was written over a weekend; the README took additional time. No real money is involved, there are no payment-processor integrations, and the test suite includes only representative examples of unit and feature tests.

The structure intentionally goes beyond the minimum needed to implement the requested functionality. I wanted to demonstrate how I approach architecture and code organization in real-world, continuously evolving projects

The original task is kept in [docs/task_definition.md](docs/task_definition.md). Example `curl` commands are in [docs/curl_commands.md](docs/curl_commands.md).

This readme is human-written.

## ToC

1. [Setup](#setup)
2. [API](#api)
3. [Code Navigation](#code-navigation)
    1. [Layering](#layering)
    2. [Call Stack](#call-stack)
        1. [Mutating Requests (`#create`, `#update`, `#destroy`)](#mutating-requests-create-update-destroy)
        2. [Read-Only Requests (`#index`, `#show`)](#read-only-requests-index-show)
4. [Architecture](#architecture)
    1. [Domain Decomposition](#domain-decomposition)
    2. [Data Model](#data-model)

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
bin/ci
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
| `GET` | `/api/cx/client` | Search client by public email. |
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
      "title": "amount_out_of_range", 
      "detail": "Amount is out of range"
    }
  ]
}
```

## Code Navigation

### Layering

The app is split into four layers:

* **Presentation**: `app/controllers`, `app/actions` and `app/serializers` (I didn't use mailers or jobs in this app, but if I did they would fit here as well).
* **Application**: models of business operations, organized into several bounded contexts under `app/services`.
* **Domain**: records and concepts that encode facts about the system, living in `app/models`.
* **Infrastructure**: low-level gem-like code in `lib`.

Each layer has its own set of responsibilities. Presentation layer is concerned with only what's necessary to provide an interface to the system, application layer -- with interaction rules and policies, domain layer -- with the facts about system state, and infrastructure layer is basically a set of low-level tools, each focused on its own small problem. The intended dependency direction is one-way, top-to-bottom: presentation may call application or domain, but not vice versa. Overall, layering is intended to keep request handling, business workflows, system facts, and low-level tooling from blending together.

Code-wise, presentation layer is very thin, since it is only responsible for interfacing between the user and the system. Business logic lives in the application layer, organized into function-like classes. This shape is chosen because they model processes, not actors. Domain layer (models) is also thin, the only things you may find there are enums, associations, validations and scopes, but no business logic.

Code in `app/services` is organized using a three-level structure: `<context>/<entity>/<operation>.rb`. Contexts expose their interfaces via `<context>/interface.rb`. Outer code uses these interfaces instead of referencing internal operations directly. Operations, when they need to call another context, do the same.

### Call Stack

#### Mutating Requests (`#create`, `#update`, `#destroy`)

Those tend to become complex in terms of the implementation, so maintaining layer boundaries is highly important and the following call stack is mandatory.

<img src="docs/Call Stack.png">

*The diagram focuses on the main execution flow, domain and infrastructure layers are omitted for simplicity*

#### Read-Only Requests (`#index`, `#show`)

For simple read-only requests that only involve several model calls, referencing model classes directly in the controller action is tolerable. This helps to avoid boilerplate while typically being extremely cheap to change in the future if needed.

For complex read-only requests (e.g., indexing a collection with adjustable filters and sorting), maintaining layer boundaries through action/interface is mandatory. There are no examples of complex read-only requests in this particular app though.

## Architecture

### Domain Decomposition

I've identified three subdomains in this app, distinct by the specific problem they solve:

* `Client Experience (CX)`: client enrollment, client-visible activity and capabilities
* `Financial Operations (FinOps)`: orchestration and lifecycle tracking for deposits, withdrawals and transfers
* `Accounting`: reliable, auditable record of financial facts and the source of truth for account balances

Each of those problem spaces would most likely evolve separately and have different non-functional requirements. The application is split into bounded contexts following this distinction. 

`CX` currently groups the capabilities through which clients enter and use the product: enrollment, counterparty discovery, and a client-specific view of financial activity. Its boundary is the least settled of the three and would likely be refined as product, eligibility, and compliance rules emerge.

Authentication is not considered a separate subdomain, but rather a presentation-specific detail that happens to store some state. This might change with the evolution of the system though. 

### Data Model

<img src="docs/Data Model.png">

Solid lines represent direct table relationships. Dashed lines represent logical cross-context references, generally using public IDs and stable string identifiers rather than database foreign keys.

In the DB, tables are prefixed with the name of the context they come from (e.g. `fin_ops_deposits`, `accounting_postings`). 

`Accounting` records financial facts with double-entry accounting model. Each money movement is expressed as a journal entry containing at least two postings, debit and credit, with a constraint that total debits should always match total credits (entry should be "balanced"). This makes balance changes auditable. Clients have a pair of accounts: for available and reserved funds. Account balance is calculated on the fly by summing the related postings. The full chart of accounts and transaction rules are documented in [docs/accounting.md](docs/accounting.md).

`Deposits`, `Withdrawals` and `Transfers` in FinOps track corresponding operation lifecycles.

`Money Movements` represent client-scoped projections of money movements from the viewpoint of this specific client. E.g., a single `Transfer` would produce two money movements: sender will see an "outgoing transfer" while receiver -- an "incoming transfer".
