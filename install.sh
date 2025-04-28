#!/bin/bash

set -e

INSTALL_PACKAGES=false
CLEAN_IDF=false
CLEAN_MATTER=false
IDF_VERSION="v5.4.1"
MATTER_BRANCH="main"

print_help() {
  cat <<EOF
Usage: install.sh [options]

Options:
  --packages           Install all required system dependencies
  --idf-version <ver>  Set the esp-idf version to install (default: v5.4.1)
  --matter-branch <b>  Set the esp-matter branch to use (default: main)
  --clean-idf          Remove ~/esp-idf before setup
  --clean-matter       Remove ~/esp-matter before setup
  --clean              Shortcut: removes both ~/esp-idf and ~/esp-matter
  --help, -h           Show this help message

All logs will be saved to ~/install.log
EOF
}

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  print_help
  exit 0
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
  --packages)
    INSTALL_PACKAGES=true
    shift
    ;;
  --clean)
    CLEAN_IDF=true
    CLEAN_MATTER=true
    ;;
  --clean-idf)
    CLEAN_IDF=true
    shift
    ;;
  --clean-matter)
    CLEAN_MATTER=true
    shift
    ;;
  --idf-version)
    shift
    if [[ $# -gt 0 ]]; then
      IDF_VERSION="$1"
      shift
    else
      echo "Error: --idf-version requires a value"
      exit 1
    fi
    ;;
  --matter-branch)
    shift
    if [[ $# -gt 0 ]]; then
      MATTER_BRANCH="$1"
      shift
    else
      echo "Error: --matter-branch requires a value"
      exit 1
    fi
    ;;
  *)
    echo "Unknown option: $1"
    exit 1
    ;;
  esac
done

# Logging

LOG_DIR="$HOME/.logs/esp"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
LOG_FILE="$LOG_DIR/install-$TIMESTAMP.log"

find "$LOG_DIR" -type f -name "install-*.log" -mtime +7 -delete

exec > >(tee "$LOG_FILE") 2>&1
echo "Logging to $LOG_FILE"

ln -sf "$LOG_FILE" "$LOG_DIR/install-latest.log"

# Packages

if $INSTALL_PACKAGES; then
  echo "Installing required packages..."
  sudo apt-get update
  sudo apt-get install -y git wget flex bison gperf python3 python3-pip python3-venv \
    cmake ninja-build ccache libffi-dev libssl-dev dfu-util libusb-1.0-0 \
    gcc g++ pkg-config libdbus-1-dev libglib2.0-dev libavahi-client-dev \
    unzip libgirepository1.0-dev libcairo2-dev libreadline-dev default-jre
else
  echo "Skipping package installation (use --packages to install dependencies)."
fi

# ESP-IDF

if $CLEAN_IDF; then
  echo "Removing existing esp-idf..."
  rm -rf "$HOME/esp-idf"
fi

if [ ! -d "$HOME/esp-idf" ]; then
  echo "Cloning esp-idf..."
  git clone --recursive https://github.com/espressif/esp-idf.git ~/esp-idf
  cd ~/esp-idf
  echo "Checking out esp-idf version $IDF_VERSION"
  git checkout "$IDF_VERSION"
  git submodule update --init --recursive --jobs=$(nproc)
  ./install.sh
  cd ..
else
  echo "esp-idf already exists, skipping clone."
fi

# ESP-MATTER

if $CLEAN_MATTER; then
  echo "Removing existing esp-matter..."
  rm -rf "$HOME/esp-matter"
fi

if [ ! -d "$HOME/esp-matter" ]; then
  source ~/esp-idf/export.sh
  echo "Cloning esp-matter..."
  git clone --branch "$MATTER_BRANCH" https://github.com/espressif/esp-matter.git ~/esp-matter
  cd ~/esp-matter
  git submodule update --init --depth 1 --jobs=$(nproc)
  cd connectedhomeip/connectedhomeip
  ./scripts/checkout_submodules.py --platform esp32 linux --shallow
  cd ../..
  ./install.sh --no-host-tool
  cd ..
else
  echo "esp-matter already exists, skipping clone."
fi
