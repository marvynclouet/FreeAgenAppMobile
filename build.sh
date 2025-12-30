#!/bin/bash
set -e

echo "🔨 Building Flutter web application..."

# Install Flutter dependencies
cd freeagentapp
flutter pub get

# Build Flutter web
flutter build web --release

echo "✅ Build completed successfully!"

