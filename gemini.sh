#!/bin/bash

source ~/.scripts/.env

# Check if an argument was provided
if [ -z "$1" ]; then
	echo "Usage: ./gemini.sh \"Your prompt here\""
	exit 1
fi

# Your API Key (Set this as an environment variable for security)
# Run: export GEMINI_API_KEY='your_key_here'
API_KEY=$GEMINI_API_KEY

if [ -z "$API_KEY" ]; then
	echo "Error: GEMINI_API_KEY environment variable is not set."
	exit 1
fi

# The API Endpoint
URL="https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$API_KEY"

# Execute the request and parse the JSON response
# We use 'jq' to extract just the text content for a clean output
# Execute the request using jq to safely encode the payload
response=$(jq -n --arg prompt "$1" '{
  contents: [{
    parts: [{ text: $prompt }]
  }]
}' | curl -s -X POST "$URL" \
	-H 'Content-Type: application/json' \
	-d @-) # The '@-' tells curl to read the body from stdin (the jq output)

# Extract the text from the nested JSON structure
echo "$response" | jq -r '.candidates[0].content.parts[0].text'
