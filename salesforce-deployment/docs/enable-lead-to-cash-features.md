# Enabling Quotes, Orders and Contracts

Lead, Account, Contact and Opportunity are available by default. Quote,
Order and Contract are standard objects but are **switched off** until an
admin enables them. Do this once, before deploying the validation rules in
this folder.

## 1. Enable Contracts

Setup → Quick Find → **Contract Settings** → check **"Enable"** (Auto-Calculate
Contract Status is optional but recommended). Then Setup → **Object Manager**
→ verify **Contracts** now has a tab available; add it to the relevant Lightning
App(s) via **App Manager**.

## 2. Enable Orders

Setup → Quick Find → **Order Settings** → check **"Enable Orders"**. Optionally
check "Enable Negative Quantity" only if your business needs it. Add the
**Orders** tab to your Lightning App(s).

## 3. Enable Quotes

Setup → Quick Find → **Quote Settings** → check **"Enable Quotes"**. This adds
the Quotes related list to Opportunities and the Quote/QuoteLineItem objects.
Add the **Quotes** tab to your Lightning App(s).

## 4. Permissions

Enabling a feature does not grant access. Update the relevant Permission
Sets / Profiles (Object Settings) to give your Sales users **Read/Create/Edit**
on Quote, Order and Contract, and on their line item / child objects
(QuoteLineItem, OrderItem). The dedicated QA automation user referenced in
`../../automation/.env.example` needs the same access to run the Playwright suite.

## 5. Deploy the validation rules

Once the objects are enabled and accessible, deploy this folder's metadata
(e.g. `sf project deploy start --source-dir force-app`, run from inside
`salesforce-deployment/`, or through a Gearset compare & deploy job pointed
at this folder) into your org.
