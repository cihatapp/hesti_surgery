#!/bin/bash

# --- Smart Navigation Logic ---
echo "🔎 Locating project root..."
# Start from the script's directory and travel up until we find the 'ios' folder
cd "$(dirname "$0")"
while [[ ! -d "ios" && "$(pwd)" != "/" ]]; do
    cd ..
done

# If we are at the root of the filesystem and haven't found it, exit.
if [ ! -d "ios" ]; then
    echo "❌ Error: Could not find the project root (a directory containing an 'ios' folder)."
    exit 1
fi

echo "✅ Project root found at: $(pwd)"
# --- End of Smart Navigation Logic ---


# --- Main Reset Process ---
echo "🚀 Starting the pod reset process for x86_64 architecture..."

# 1. Clean the Flutter project
echo "🧹 Running 'flutter clean'..."
flutter clean

# 2. Get Flutter packages
echo "📦 Running 'flutter pub get'..."
flutter pub get

# 3. Navigate into the iOS directory
cd ios

# 4. Remove existing Pods and Podfile.lock
echo "🗑️ Removing Podfile.lock and Pods directory..."
rm -rf Podfile.lock Pods

# 5. Deintegrate CocoaPods from the Xcode project using x86_64
echo "🔗 Deintegrating CocoaPods from the project (using x86_64)..."
arch -x86_64 pod deintegrate

# 6. Update the local pod spec repositories using x86_64
echo "🔄 Updating CocoaPods repositories (using x86_64)..."
arch -x86_64 pod repo update

# 7. Install the pods using x86_64
echo "🛠️ Installing pods (using x86_64)..."
arch -x86_64 pod install

# Announce the completion of the script
echo "✅ All done! Your pods have been reset and reinstalled."