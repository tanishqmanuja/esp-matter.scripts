#!/bin/bash

# Save current directory
pushd "$(pwd)" >/dev/null

# Source ESP-IDF environment
source ~/esp-idf/export.sh

# Source ESP-Matter environment
source ~/esp-matter/export.sh

# Return to original directory
popd >/dev/null

# Enable ccache for ESP-IDF builds
export IDF_CCACHE_ENABLE=1

# Set Matter SDK path
export MATTER_SDK_PATH="$ESP_MATTER_PATH/connectedhomeip/connectedhomeip"

# Add Matter host tools to PATH
export PATH="$PATH:$MATTER_SDK_PATH/out/host"

# Shortcuts for common IDF commands
alias itarget="idf.py set-target"
alias ierase="idf.py erase-flash"
alias iflash="idf.py flash"
alias ibuild="idf.py build"
alias imenu="idf.py menuconfig"
alias imonitor="idf.py monitor"

iflashmfg() {

  bins_file="$(mktemp)"

  # Find binaries and write to temp file
  find mfg_binaries -maxdepth 1 -type f -name "*.bin" 2>/dev/null >>"$bins_file"
  find out -type f -name "*-partition.bin" 2>/dev/null >>"$bins_file"

  if ! [ -s "$bins_file" ]; then
    echo "No manufacturing binaries found."
    rm -f "$bins_file"
    return 1
  fi

  bin_count=$(wc -l <"$bins_file" | tr -d ' ')

  if [ "$bin_count" -eq 1 ]; then
    # Only one binary found, flash immediately
    bin=$(cat "$bins_file")
    echo "Flashing $bin to 0x10000..."
    esptool.py write_flash 0x10000 "$bin"
    rm -f "$bins_file"
    return
  fi

  # Multiple binaries found
  i=0
  while IFS= read -r bin; do
    echo "[$i] $bin"
    eval "bin_$i=\"\$bin\""
    i=$((i + 1))
  done <"$bins_file"

  echo
  printf "Select a binary to flash (0-%d): " $((i - 1))
  read choice

  eval "bin=\$bin_$choice"

  if [ -z "$bin" ]; then
    echo "Invalid choice."
    rm -f "$bins_file"
    return 1
  fi

  echo "Flashing $bin to 0x10000..."
  esptool.py write_flash 0x10000 "$bin"

  rm -f "$bins_file"
}
