#!/bin/bash
# Release creation script for OpenJTalk

set -e

# Check if tag is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <tag_name>"
    echo "Example: $0 v1.0.0"
    exit 1
fi

TAG_NAME=$1

# Validate tag format
if [[ ! $TAG_NAME =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Tag name must follow semantic versioning format (e.g., v1.0.0)"
    exit 1
fi

echo "Creating release for tag: $TAG_NAME"

# Check if tag already exists
if git tag -l | grep -q "^$TAG_NAME$"; then
    echo "Error: Tag $TAG_NAME already exists"
    exit 1
fi

# Create and push tag
echo "Creating and pushing tag..."
git tag -a $TAG_NAME -m "Release $TAG_NAME"
git push origin $TAG_NAME

echo "Tag $TAG_NAME has been created and pushed."
echo "GitHub Actions will automatically build and create the release."
echo "Check the Actions tab in your GitHub repository for build progress."
