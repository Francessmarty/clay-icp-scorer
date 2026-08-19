# ICP Scoring & Automated Lead Routing Engine

A lightweight GTM Engineering workflow built in Bash that converts predefined Ideal Customer Profile (ICP) criteria into executable lead-scoring and routing logic.

The system processes lead data exported from Clay, evaluates each contact against six weighted ICP criteria, calculates a score out of 8, and automatically routes qualified leads to Slack when they meet the defined threshold.

## Overview

Manual lead review becomes increasingly difficult to manage consistently as prospect volumes grow.

This project was built to test a simple question:

**Can predefined ICP qualification rules be converted into an automated decision system that evaluates every lead consistently and immediately routes the strongest prospects for action?**

The resulting workflow is:

**Clay CSV Export → Input Validation → CSV Parsing → Field Mapping → ICP Evaluation → Weighted Scoring → Qualification Threshold → Slack Routing → Processing Summary**

Rather than treating every record in a prospect list equally, the system evaluates each lead against explicit qualification criteria before deciding whether it should be surfaced for action.

---

## What the System Does

The workflow:

- reads a Clay CSV lead export;
- validates that an input file has been supplied;
- confirms that the CSV file exists;
- loads the Slack webhook securely from a `.env` file;
- parses CSV records, including quoted fields;
- dynamically maps required columns from the CSV header;
- evaluates each contact against six ICP criteria;
- calculates a weighted score out of 8;
- classifies leads scoring 5 or above as hot leads;
- automatically sends qualifying leads to Slack;
- counts the number of routed leads;
- returns a final processing summary.

The project was tested using a Clay export containing 100 leads.

---

## Business Problem

Lead lists often contain contacts with very different levels of relevance.

Reviewing each record manually requires an operator to repeatedly check factors such as:

- role and seniority;
- geography;
- company size;
- industry;
- funding stage;
- availability of useful prospect information.

That creates repetitive manual work and can also introduce inconsistency into qualification decisions.

The objective of this project was to convert those recurring qualification checks into explicit scoring rules that could be executed automatically.

---

## System Architecture

The workflow follows a controlled decision path:

**1. Receive Clay CSV export**

Use the exported prospect dataset as the system input.

↓

**2. Validate input**

Confirm that a CSV file has been supplied and that the file exists.

↓

**3. Load environment configuration**

Retrieve the Slack webhook URL from `.env`.

↓

**4. Parse the CSV**

Process each row while accounting for quoted fields and escaped quotation marks.

↓

**5. Map required fields**

Identify column positions dynamically from the CSV header.

↓

**6. Evaluate ICP criteria**

Assess Title, Location, Employee Count, Industry, Funding Stage and LinkedIn availability.

↓

**7. Calculate weighted ICP score**

Assign points according to the predefined qualification model.

↓

**8. Apply qualification threshold**

**Score ≥ 5 → Hot Lead**

**Score < 5 → Do Not Route**

↓

**9. Route qualified leads**

Send hot-lead information to Slack through an Incoming Webhook.

↓

**10. Report processing result**

Return the total number of hot leads routed to Slack.

---

## ICP Scoring Model

Each lead is evaluated against six criteria.

| Criterion | Qualification Rule | Points |
| --- | --- | ---: |
| Title | Founder, CEO, VP, Director, Head, GTM, RevOps, Revenue, Growth, COO or CTO | 2 |
| Location | United Kingdom, United States, Canada or matching supported location terms | 1 |
| Employee Count | 10–500 employees | 1 |
| Industry | SaaS, Software, Tech, AI, B2B or Digital | 2 |
| Funding | Seed, Series A, Series B, Series C or Bootstrapped | 1 |
| LinkedIn | LinkedIn profile field is present | 1 |
| **Maximum Score** |  | **8** |

### Qualification Threshold

**5 to 8 points → Hot Lead → Route to Slack**

**0 to 4 points → Below routing threshold**

The weighting deliberately gives greater importance to **role relevance** and **industry fit**, which each contribute two points.

---

## Decision Logic

The central decision is intentionally simple and transparent:

**Lead Data**

↓

**Evaluate Six ICP Criteria**

↓

**Calculate Score /8**

↓

**Is Score ≥5?**

**YES → Increment Hot Lead Count → Send Lead to Slack**

**NO → Continue Processing**

This makes the qualification decision deterministic and auditable: the same input evaluated against the same rules produces the same scoring outcome.

---

## Automated Slack Routing

When a lead reaches the qualification threshold, the script creates a Slack message containing relevant prospect information, including:

- name;
- job title;
- company;
- location;
- industry;
- funding stage;
- ICP score;
- LinkedIn profile.

The notification is sent automatically using a Slack Incoming Webhook.

This turns the scoring result into an operational action rather than leaving the score inside the source dataset.

---

## Input and Configuration Controls

The script includes several basic controls before processing begins.

### Missing File Argument

If no CSV file is supplied, the script stops and returns usage instructions.

### File Validation

If the specified CSV file does not exist, processing stops.

### Environment Configuration

The Slack webhook is loaded from:

`.env`

If `SLACK_WEBHOOK_URL` is unavailable, the workflow stops rather than attempting routing without the required configuration.

The webhook itself should not be committed to the repository.

---

## CSV Processing

The script includes a custom CSV parsing function to handle:

- comma-separated fields;
- quoted fields;
- escaped quotation marks;
- CRLF line endings.

Column positions are then mapped dynamically from the header row rather than relying entirely on fixed column numbers.

The expected fields include:

- Full Name
- Job Title
- Company Name
- Location
- Employee Count
- Industry
- Funding Stage
- LinkedIn Profile

---

## Results

The project was tested against a Clay CSV export containing:

**100 leads**

The automated workflow evaluates every record using the same six qualification criteria and routes records scoring at least 5/8 to Slack.

The project reduced the stated lead-review workflow from approximately:

**2 hours of manual review → under 5 minutes using the automated workflow**

This represents workflow processing and review efficiency within the project test, rather than a production SLA or universally expected performance result.

---

## Technology Stack

- **Bash** scoring, decision and routing logic
- **Clay** source lead data / CSV export
- **Slack Incoming Webhooks** automated hot-lead routing
- **Claude Code** debugging and development iteration
- **VS Code** development environment

---

## Project Structure

clay-icp-scorer/

├── icp_scorer.sh  
├── .gitignore  
├── leads.csv  
├── screenshots/  
└── README.md

---

## Running the Project

### 1. Export lead data from Clay

Export the required Clay table as CSV.

### 2. Prepare the input file

Ensure the required columns are available and remove unnecessary long-text fields where appropriate.

### 3. Configure Slack

Create a `.env` file and add:

SLACK_WEBHOOK_URL="YOUR_SLACK_WEBHOOK_URL"

Do not commit the `.env` file or webhook secret to GitHub.

### 4. Run the scorer

bash icp_scorer.sh leads.csv

The script will evaluate each record and display its score.

Example:

Name: Example Lead | Score: 6 / 8

Qualified records are automatically routed to Slack.

At completion, the script returns:

Done. X hot lead(s) sent to Slack.

---

## What This Project Demonstrates

This project demonstrates how GTM qualification policy can be translated into executable operational logic.

Instead of manually reviewing every lead and deciding whether it appears relevant, the workflow establishes:

**What makes a lead qualified?**

↓

**How important is each criterion?**

↓

**What score is sufficient to trigger action?**

↓

**What should happen when that threshold is reached?**

The result is a lightweight decision-and-routing engine connecting prospect data directly to a downstream sales action.

It demonstrates:

- rule-based ICP qualification;
- weighted lead scoring;
- Bash automation;
- CSV processing;
- threshold-based decision logic;
- environment-variable handling;
- webhook integration;
- automated Slack routing;
- GTM workflow design.

---

## Limitations

This project is a lightweight proof of concept rather than a production lead-scoring platform.

The qualification rules and weights are predefined and should be recalibrated for a company's actual ICP and historical conversion data before production use.

The workflow also relies on the quality and consistency of the source Clay data.

A production implementation could add:

- schema validation;
- stronger error handling;
- score-component logging;
- CRM integration;
- duplicate controls;
- configurable scoring rules;
- automated data-quality checks;
- routing by territory or owner;
- persistent scoring history;
- monitoring and retry handling for failed webhook requests.

---

## Final Outcome

**Clay lead export → CSV validation and parsing → six ICP criteria evaluated → weighted score /8 → ≥5 qualification threshold → automated Slack routing → processing summary**

The project demonstrates a simple GTM Engineering principle:

**qualification logic should not end with a score the decision should trigger a clear operational next action.**      


## Author 

Frances Ehinor
[Frances Builds](https://francesbuilds.com)
