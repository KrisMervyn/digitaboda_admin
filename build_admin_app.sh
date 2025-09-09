#!/bin/bash

# DigitalBoda Admin App Build Script
# This script builds the admin app for multiple platforms

echo "🏍️ DigitalBoda Admin App Builder"
echo "================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

print_status "Flutter version:"
flutter --version

# Get dependencies
print_status "Getting Flutter dependencies..."
flutter pub get

if [ $? -ne 0 ]; then
    print_error "Failed to get dependencies"
    exit 1
fi

print_success "Dependencies resolved successfully"

# Build for different platforms
echo ""
echo "Select build target:"
echo "1) Android APK (Release)"
echo "2) Android App Bundle (AAB)"
echo "3) Linux Desktop"
echo "4) Windows Desktop"
echo "5) macOS Desktop"
echo "6) All platforms"
echo ""
read -p "Enter choice (1-6): " choice

case $choice in
    1)
        print_status "Building Android APK (Release)..."
        flutter build apk --release
        if [ $? -eq 0 ]; then
            print_success "Android APK built successfully!"
            print_status "APK location: build/app/outputs/flutter-apk/app-release.apk"
        else
            print_error "Android APK build failed"
        fi
        ;;
    2)
        print_status "Building Android App Bundle (AAB)..."
        flutter build appbundle --release
        if [ $? -eq 0 ]; then
            print_success "Android App Bundle built successfully!"
            print_status "AAB location: build/app/outputs/bundle/release/app-release.aab"
        else
            print_error "Android App Bundle build failed"
        fi
        ;;
    3)
        print_status "Building Linux Desktop app..."
        flutter build linux --release
        if [ $? -eq 0 ]; then
            print_success "Linux Desktop app built successfully!"
            print_status "App location: build/linux/x64/release/bundle/"
        else
            print_error "Linux Desktop build failed"
        fi
        ;;
    4)
        print_status "Building Windows Desktop app..."
        flutter build windows --release
        if [ $? -eq 0 ]; then
            print_success "Windows Desktop app built successfully!"
            print_status "App location: build/windows/runner/Release/"
        else
            print_error "Windows Desktop build failed"
        fi
        ;;
    5)
        print_status "Building macOS Desktop app..."
        flutter build macos --release
        if [ $? -eq 0 ]; then
            print_success "macOS Desktop app built successfully!"
            print_status "App location: build/macos/Build/Products/Release/"
        else
            print_error "macOS Desktop build failed"
        fi
        ;;
    6)
        print_status "Building for all platforms..."
        
        # Android APK
        print_status "Building Android APK..."
        flutter build apk --release
        
        # Linux
        print_status "Building Linux Desktop..."
        flutter build linux --release
        
        # Add other platforms as needed
        print_success "Multi-platform build completed!"
        ;;
    *)
        print_error "Invalid choice"
        exit 1
        ;;
esac

echo ""
print_success "Build process completed!"
print_status "Admin app is ready for deployment"

echo ""
echo "📋 Next steps:"
echo "1. Test the built app on target devices"
echo "2. Distribute to admin personnel only"
echo "3. Update admin credentials for production use"
echo "4. Configure network access to Django backend"

echo ""
echo "🔐 Default admin credentials:"
echo "   Username: admin"
echo "   Password: admin123"
print_warning "IMPORTANT: Change these credentials in production!"