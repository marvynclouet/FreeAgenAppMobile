#!/bin/bash
set -e

echo "🔨 Setting up Flutter for Vercel build..."

# Install Flutter if not present
if ! command -v flutter &> /dev/null; then
    echo "📥 Installing Flutter..."
    git clone https://github.com/flutter/flutter.git -b stable --depth 1
    export PATH="$PATH:$(pwd)/flutter/bin"
    flutter doctor
fi

# Navigate to Flutter app directory
cd freeagentapp

# Get Flutter dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Build Flutter web
echo "🔨 Building Flutter web application..."
flutter build web --release

echo "✅ Build completed successfully!"

