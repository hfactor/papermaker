#!/bin/bash

# Start script for PDF Calendar Generator
# This script starts the Node.js server

echo "📅 PDF Calendar Generator"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Error: Node.js is not installed."
    echo ""
    echo "Please install Node.js from: https://nodejs.org/"
    echo "Or use: brew install node (on macOS)"
    echo ""
    exit 1
fi

# Check if Typst is installed
if ! command -v typst &> /dev/null; then
    echo "❌ Error: Typst is not installed."
    echo ""
    echo "Please install Typst from: https://github.com/typst/typst"
    echo "Or use: brew install typst (on macOS)"
    echo ""
    exit 1
fi

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
    echo ""
fi

# Start the server
echo "🚀 Starting server..."
echo ""
npm start
