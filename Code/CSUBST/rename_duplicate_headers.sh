#!/bin/bash

# Initialize an associative array to hold the count of each header
declare -A header_count

# Initialize an empty variable to hold sequence data
sequence=""

# Read from standard input line by line
while IFS= read -r line; do
    # Check if the line starts with '>'
    if [[ $line == ">"* ]]; then
        # Output the sequence data if it's not empty
        if [[ ! -z $sequence ]]; then
            echo "$sequence"
            sequence=""
        fi

        # Increment the count for this header
        header_count["$line"]=$((header_count["$line"] + 1))

        # Check if this header has duplicates
        if [[ ${header_count["$line"]} -gt 1 ]]; then
            # Append the count to the header
            echo "${line}:${header_count["$line"]}"
        else
            echo "$line"
        fi
    else
        # Append sequence data
        sequence+="$line"
    fi
done

# Output the last sequence data if it's not empty
if [[ ! -z $sequence ]]; then
    echo "$sequence"
fi

