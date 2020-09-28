#!/bin/sh
branch=$(git branch --show-current)
remote=$(git config --get remote.origin.url)
hash=$(git rev-parse HEAD)
echo "{\"branch\": \"$branch\", \"remote\": \"$remote\", \"hash\": \"$hash\"}"