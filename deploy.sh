#!/bin/bash
# Deploy Shenzhen Trek to GitHub Pages
# Run this from inside the shenzhen-trek folder: ./deploy.sh

set -e

echo "🚀 Deploying Shenzhen Trek to GitHub Pages..."

# Check if gh is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) not found. Installing..."
    brew install gh 2>/dev/null || {
        echo "Install it manually: https://cli.github.com"
        exit 1
    }
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "🔐 Not logged into GitHub. Logging in..."
    gh auth login --web --git-protocol https
fi

# Get GitHub username
GH_USER=$(gh api user -q .login)
echo "✅ Logged in as: $GH_USER"

# Create the repo (public, so GitHub Pages works for free)
echo "📦 Creating GitHub repository..."
gh repo create shenzhen-trek --public --source=. --remote=origin --push 2>/dev/null || {
    # If repo already exists, just push
    echo "Repo may already exist, setting remote and pushing..."
    git remote remove origin 2>/dev/null || true
    git remote add origin "https://github.com/$GH_USER/shenzhen-trek.git"
    git push -u origin main
}

echo "✅ Code pushed to GitHub!"

# Enable GitHub Pages on main branch
echo "🌐 Enabling GitHub Pages..."
gh api repos/$GH_USER/shenzhen-trek/pages \
    -X POST \
    -f "build_type=legacy" \
    -f "source[branch]=main" \
    -f "source[path]=/" \
    2>/dev/null || {
    echo "Pages may already be enabled, updating..."
    gh api repos/$GH_USER/shenzhen-trek/pages \
        -X PUT \
        -f "build_type=legacy" \
        -f "source[branch]=main" \
        -f "source[path]=/" \
        2>/dev/null || true
}

# Wait a moment then check the URL
sleep 3
PAGES_URL="https://$GH_USER.github.io/shenzhen-trek/"

echo ""
echo "========================================="
echo "🎉 DEPLOYED!"
echo "========================================="
echo ""
echo "Your site will be live at:"
echo "  $PAGES_URL"
echo ""
echo "GitHub repo:"
echo "  https://github.com/$GH_USER/shenzhen-trek"
echo ""
echo "Note: It may take 1-2 minutes for the site"
echo "to appear. Refresh if you see a 404."
echo "========================================="

# Try to open in browser
open "$PAGES_URL" 2>/dev/null || xdg-open "$PAGES_URL" 2>/dev/null || echo "Open the URL above in your browser."
