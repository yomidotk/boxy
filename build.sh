#!/bin/bash
if [ -d "build/web" ] && [ -f "build/web/index.html" ]; then
  echo "build/web already present, skipping Flutter build."
  exit 0
fi
echo "ERROR: build/web not found."
exit 1
