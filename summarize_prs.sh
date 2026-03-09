#!/bin/bash

gemini "
These are my PRs from the last week.
I have to provide a highlight of my last week of work for my company.
Can you provide a brief summary of what I got done and what I focused on?

$(gh search prs --author "@me" --merged-at ">2026-02-27" --limit 100)
" >demo_friday.md
