#!/bin/bash

# Fetch all remote branches
git fetch --all

# Get the list of all remote branches and their last commit date
branches_info=$(git for-each-ref --sort=-committerdate refs/remotes/ --format='%(refname:short) %(committerdate:short)')

# Generate the markdown table header
echo "| Branch Name | Last Commit Date | Date Feedback Requested On | Status |"
echo "|-------------|------------------|----------------------------|--------|"

# Process each branch info line
while read -r line; do
    # Extract branch name and last commit date
    branch_name=$(echo "$line" | awk '{print $1}' | sed 's|^origin/||')
    last_commit_date=$(echo "$line" | awk '{print $2}')
    
    # Output the branch information in markdown table row
    echo "| $branch_name | $last_commit_date |                            |        |"
done <<< "$branches_info"
