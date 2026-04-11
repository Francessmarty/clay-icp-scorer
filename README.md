# Clay ICP Scorer

An automated ICP lead scoring system built in Bash that processes Clay lead exports, scores each contact against 7 ICP criteria, and routes hot leads to Slack in real time.

## What it does

- Reads a Clay CSV export of 100 leads
- Scores each lead out of 7 against ICP criteria
- Automatically sends hot leads (score 5 and above) to a Slack channel via webhook
- Reduced manual lead review from 2 hours to under 5 minutes

## ICP Scoring Criteria

| Criteria | Points |
|---|---|
| Title: Founder, CEO, VP, Director, Head, GTM, RevOps, COO, CTO | 2 |
| Location: UK, US, Canada | 1 |
| Employee count: 10 to 500 | 1 |
| Industry: SaaS, Software, Tech, AI, B2B, Digital | 2 |
| Funding: Seed, Series A, B, C, Bootstrapped | 1 |
| LinkedIn URL present | 1 |

**Total: 7 points. Hot lead threshold: 5 and above.**

## Stack

- Bash
- Clay (CSV export)
- Slack Incoming Webhooks
- Claude Code (debugging and iteration)
- VS Code

## How to use

1. Export your Clay table as CSV
2. Clean the CSV remove columns with long text fields like Summary and Headline
3. Replace commas in Location and Name fields with dashes using Find and Replace
4. Add your Slack webhook URL to a `.env` file:


    SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"



## RUN SCRIPTS
    bash icp_scorer.sh leads.csv

## Project Structure

  clay-icp-scorer/

  
    icp_scorer.sh            
    .gitignore          
    leads.csv            
    screenshots/         
    README.md

## Built by 
      Frances Ehinor 

      gtm.francesehinor.com