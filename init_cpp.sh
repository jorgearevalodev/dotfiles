#!/bin/bash
set -e  # Exit on error

# Check if a project name is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <project_name>"
  exit 1
fi

PROJECT_NAME=$1
CURRENT_DIR=$(pwd)  # Get the current working directory

# Create project structure in the current directory
mkdir -p "$CURRENT_DIR/$PROJECT_NAME"/{src,include,build}
cd "$CURRENT_DIR/$PROJECT_NAME"

# Create default CMakeLists.txt
cat <<EOL > CMakeLists.txt
cmake_minimum_required(VERSION 3.16)
project($PROJECT_NAME VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Specify source files
file(GLOB SOURCES src/*.cpp)

# Create the executable
add_executable($PROJECT_NAME \${SOURCES})

# Include headers
target_include_directories($PROJECT_NAME PRIVATE include)
EOL

# Create a default build script
cat <<EOL > build.sh
#!/bin/bash
set -e
build_type=\${1:-Debug}
cmake -B build -S . -DCMAKE_BUILD_TYPE=\$build_type
cmake --build build
./build/$PROJECT_NAME
EOL
chmod +x build.sh

# Add default source and header files
cat <<EOL > src/main.cpp
#include <iostream>

int main() {
    std::cout << "Hello, $PROJECT_NAME!" << std::endl;
    return 0;
}
EOL

cat <<EOL > include/helpers.h
#ifndef HELPERS_H
#define HELPERS_H

void print_hello();

#endif // HELPERS_H
EOL

cat <<EOL > src/helpers.cpp
#include "helpers.h"
#include <iostream>

void print_hello() {
    std::cout << "Hello from helpers!" << std::endl;
}
EOL

# Add a .vimrc file
cat <<EOL > .vimrc
set makeprg=./build.sh
EOL

echo "C++ project '$PROJECT_NAME' initialized in $CURRENT_DIR/$PROJECT_NAME!"
