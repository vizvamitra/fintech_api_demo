# Fintech API Demo

> **Note:** This README is human-written.

A small wallet-style Rails API-only demo app. It features deposits, withdrawals, between-user transfers, balance checks and transaction history, and tracks all cash flows using double-entry accounting.

The purpose of this repo is to demonstrate my engineering skill. I wrote most of the code over a weekend as part of a client evaluation process (README took additional time), but the app intentionally goes beyond the [requirements](docs/task_definition.md) to reflect how I model and structure apps in real-life projects.

**Stack:** Ruby 4.0, Rails 8.1, PostgreSQL, RS256 JWT, Alba, RSpec

> **Scope note:** This is an architectural demo, not a production financial system. No real money or payment processors are involved, some non-essential parts are intentionally kept rudimentary and tests are representative rather than exhaustive

## Highlights

- **Double-entry accounting:** Balanced journal entries, derived balances and fund reservation for withdrawals, with a complete audit trail
- **Modular monolith:** Three bounded contexts ("CX", "FinOps" and "Accounting") communicating strictly through explicit interfaces
- **Clear layering:** Business workflows, fact storage, presentation and low-level focused tools are modeled independently of each other
- **Process-oriented business logic:** Business workflows are captured in function-style classes aligned with how people naturally think about processes
- **Small, fixed set of object roles:** A limited vocabulary of building blocks per layer helps any part of the codebase feel familiar

## Reading Guide

- **Evaluating architecture & domain modeling:** [Architecture](#architecture) -> [Code Navigation](#code-navigation) -> [Accounting Rules](docs/accounting.md)
- **Running or testing the API locally:** [API](#api) -> [Setup](#setup) -> [Example `curl` Walkthrough](docs/curl_commands.md)
- **Original task:** [Task Definition](docs/task_definition.md)

## API

Customers can sign up with an email, authenticate via RS256 JWT, inspect their balance and movement history, discover other customers by email, and perform deposits, withdrawals, and peer-to-peer transfers.

Authenticated endpoints expect `Authorization: Bearer <access_token>`.

### Endpoints

| Method |                      Path |   Auth |          Input |                 Purpose |
| ------ | ------------------------- | ------ | -------------- | ----------------------- |
| `POST` | `/api/sign_ups`           | Public |        `email` | Register a customer (`201`, empty body). |
| `POST` | `/api/sign_ins`           | Public |        `email` | Issue a JWT access token (`24h` TTL). |
|  `GET` | `/api/me`                 | Bearer |             -- | Current customer profile and available balance. |
|  `GET` | `/api/cx/customer`        | Bearer | `?public_email=...` | Look up a transfer counterparty by email. |
|  `GET` | `/api/cx/money_movements` | Bearer |             -- | Customer-scoped history (newest first). |
| `POST` | `/api/fin_ops/deposits`   | Bearer | `amount_cents` | Deposit funds into current customer's account. |
| `POST` | `/api/fin_ops/withdrawals`| Bearer | `amount_cents` | Withdraw funds from the current customer's account. |
| `POST` | `/api/fin_ops/transfers`  | Bearer | `receiver_id`, `amount_cents` | Transfer funds to another customer by their `public_id`. |

### Conventions

- **Amounts:** Integer cents (`amount_cents`). Min/max limits are configured in [`config/settings.yml`](config/settings.yml) ($1 minimum; $1,000,000 maximum for deposits and transfers)
- **Payloads:** Resource-wrapped JSON bodies:
    - `{"deposit": {"amount_cents": 2000}}`
    - `{"sign_up": { "email": "customer@example.com" }}`
- **Response format:** `{"data": <object or array>}`.
- **Error format:**

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

## Architecture

### Domain Decomposition

I've identified three subdomains in this app, distinct by the specific problem they solve:

* `Customer Experience (CX)`: customer enrollment, customer-visible activity and capabilities
* `Financial Operations (FinOps)`: orchestration and lifecycle tracking for deposits, withdrawals and transfers
* `Accounting`: reliable, auditable record of financial facts and the source of truth for account balances

Each of those problem spaces would most likely evolve separately and have different non-functional requirements. The application is split into bounded contexts following this distinction.

`CX` currently groups the capabilities through which customers enter and use the product: enrollment, counterparty discovery, and a customer-specific view of financial activity. Its boundary is the least settled of the three and would likely be refined as product, eligibility, and compliance rules emerge.

Authentication is not considered a separate subdomain, but rather a presentation-specific detail that happens to store some state. This might change with the evolution of the system though.

### Data Model

<img src="docs/Data Model.png">

Solid lines represent direct table relationships. Dashed lines represent logical cross-context references, generally using public IDs and stable string identifiers rather than database foreign keys.

In the DB, tables are prefixed with the name of the context they come from (e.g. `fin_ops_deposits`, `accounting_postings`).

`Accounting` records financial facts with a double-entry accounting model. Each money movement is expressed as a journal entry containing at least two postings, debit and credit, with a constraint that total debits should always match total credits (entry should be "balanced"). This makes balance changes auditable. Customers have a pair of accounts: for available and reserved funds. Account balance is calculated on the fly by summing the related postings. The full chart of accounts and transaction rules are documented in [docs/accounting.md](docs/accounting.md).

`Deposits`, `Withdrawals` and `Transfers` in FinOps track corresponding operation lifecycles.

`Money Movements` represent customer-scoped projections of money movements from the viewpoint of this specific customer. E.g., a single `Transfer` would produce two money movements: sender will see an "outgoing transfer" while receiver -- an "incoming transfer".

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

### Guided Tour: Following a Transfer

To see the layering and context boundaries in practice, trace `POST /api/fin_ops/transfers` top to bottom:

1. **HTTP entry point** — [`TransfersController`](app/controllers/api/fin_ops/transfers_controller.rb) extracts params, delegates to the action, and serializes the result via [`TransferSerializer`](app/serializers/fin_ops/transfer_serializer.rb).
2. **Input validation & error mapping** — [`Api::FinOps::Transfers::Create`](app/actions/api/fin_ops/transfers/create.rb) checks input shape, calls `FinOps::Interface`, and maps domain errors to [`HttpErrors`](lib/http_errors.rb).
3. **Context boundary** — [`FinOps::Interface`](app/services/fin_ops/interface.rb) exposes the context's public API and inherits uniform tagged logging/timing from [`Subsystems::Interface`](lib/subsystems/interface.rb).
4. **Workflow orchestration** — [`FinOps::Transfers::Initiate`](app/services/fin_ops/transfers/initiate.rb) checks limits, locks the sender's `PayerAccount`, verifies available balance, creates the transfer record, and coordinates `Accounting` and `CX`.
5. **Double-entry ledger** — [`FinOps::Bookkeeping::RecordTransfer`](app/services/fin_ops/bookkeeping/record_transfer.rb) hands debit/credit postings to [`Accounting::JournalEntries::Create`](app/services/accounting/journal_entries/create.rb), which enforces balance, locks accounts in deterministic order, and persists the entry with an idempotency key.
6. **Customer projection** — [`CX::MoneyMovements::Store`](app/services/cx/money_movements/store.rb) records two customer-scoped views (`outgoing_transfer` for the sender, `incoming_transfer` for the receiver).

**A few other representative files:**
* **Two-phase fund reservation:** [`FinOps::Withdrawals::Initiate`](app/services/fin_ops/withdrawals/initiate.rb)
* **Pragmatic read-only controller (skipping action/interface):** [`Api::CX::MoneyMovementsController`](app/controllers/api/cx/money_movements_controller.rb)
* **Tests:** [`financial_operations_spec.rb`](spec/features/financial_operations_spec.rb) (end-to-end) and [`initiate_spec.rb`](spec/services/fin_ops/deposits/initiate_spec.rb) (isolated unit spec)

## Setup

Prerequisites: Ruby from [.ruby-version](.ruby-version) (e.g. `mise install`), Bundler and a running PostgreSQL instance.

If you don't have PostgreSQL installed locally, you can run one with Docker:

```bash
docker run --name fintech-pg -e POSTGRES_HOST_AUTH_METHOD=trust -p 5432:5432 -d postgres:17
export PGHOST=127.0.0.1 PGUSER=postgres
```

Run the setup script to install dependencies, generate local credentials with a JWT signing key (if `config/master.key` is missing) and prepare and seed the database:

```bash
bin/setup --skip-server
```

Start the server on `http://localhost:3000`:

```bash
bundle exec bin/rails server
```

Run tests:

```bash
bundle exec rspec
```
