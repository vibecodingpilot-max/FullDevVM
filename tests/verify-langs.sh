#!/bin/bash
set -euo pipefail

# Language Runtime Verification Script
# Tests installed programming languages and tools

echo "=== Language Runtime Verification Test ==="
echo "Date: $(date)"
echo

# Test Python
echo "1. Checking Python..."
if command -v python3 >/dev/null 2>&1; then
    python_version=$(python3 --version 2>&1)
    echo "✓ Python: $python_version"
    
    if command -v pip3 >/dev/null 2>&1; then
        pip_version=$(pip3 --version 2>&1 | cut -d' ' -f2)
        echo "✓ pip: $pip_version"
    else
        echo "✗ pip3 not found"
    fi
else
    echo "✗ Python3 not found"
fi

# Test Node.js
echo "2. Checking Node.js..."
if command -v node >/dev/null 2>&1; then
    node_version=$(node --version 2>&1)
    echo "✓ Node.js: $node_version"
    
    if command -v npm >/dev/null 2>&1; then
        npm_version=$(npm --version 2>&1)
        echo "✓ npm: $npm_version"
    else
        echo "✗ npm not found"
    fi
else
    echo "✗ Node.js not found"
fi

# Test Java
echo "3. Checking Java..."
if command -v java >/dev/null 2>&1; then
    java_version=$(java -version 2>&1 | head -n1)
    echo "✓ Java: $java_version"
    
    if command -v javac >/dev/null 2>&1; then
        javac_version=$(javac -version 2>&1)
        echo "✓ javac: $javac_version"
    else
        echo "✗ javac not found"
    fi
else
    echo "✗ Java not found"
fi

# Test Go
echo "4. Checking Go..."
if command -v go >/dev/null 2>&1; then
    go_version=$(go version 2>&1)
    echo "✓ Go: $go_version"
    
    if [ -n "${GOPATH:-}" ]; then
        echo "✓ GOPATH is set: $GOPATH"
    else
        echo "⚠ GOPATH not set"
    fi
else
    echo "✗ Go not found"
fi

# Test Rust
echo "5. Checking Rust..."
if command -v rustc >/dev/null 2>&1; then
    rust_version=$(rustc --version 2>&1)
    echo "✓ Rust: $rust_version"
    
    if command -v cargo >/dev/null 2>&1; then
        cargo_version=$(cargo --version 2>&1)
        echo "✓ Cargo: $cargo_version"
    else
        echo "✗ Cargo not found"
    fi
else
    echo "✗ Rust not found"
fi

# Test C/C++ tools
echo "6. Checking C/C++ tools..."
if command -v gcc >/dev/null 2>&1; then
    gcc_version=$(gcc --version 2>&1 | head -n1)
    echo "✓ GCC: $gcc_version"
else
    echo "✗ GCC not found"
fi

if command -v g++ >/dev/null 2>&1; then
    gpp_version=$(g++ --version 2>&1 | head -n1)
    echo "✓ G++: $gpp_version"
else
    echo "✗ G++ not found"
fi

if command -v make >/dev/null 2>&1; then
    make_version=$(make --version 2>&1 | head -n1)
    echo "✓ Make: $make_version"
else
    echo "✗ Make not found"
fi

if command -v cmake >/dev/null 2>&1; then
    cmake_version=$(cmake --version 2>&1 | head -n1)
    echo "✓ CMake: $cmake_version"
else
    echo "✗ CMake not found"
fi

# Test Docker
echo "7. Checking Docker..."
if command -v docker >/dev/null 2>&1; then
    docker_version=$(docker --version 2>&1)
    echo "✓ Docker: $docker_version"
    
    if systemctl is-active --quiet docker; then
        echo "✓ Docker service is running"
    else
        echo "⚠ Docker service is not running"
    fi
else
    echo "✗ Docker not found"
fi

if command -v docker-compose >/dev/null 2>&1; then
    compose_version=$(docker-compose --version 2>&1)
    echo "✓ Docker Compose: $compose_version"
else
    echo "✗ Docker Compose not found"
fi

# Test Git
echo "8. Checking Git..."
if command -v git >/dev/null 2>&1; then
    git_version=$(git --version 2>&1)
    echo "✓ Git: $git_version"
else
    echo "✗ Git not found"
fi

# Test VS Code Server
echo "9. Checking VS Code Server..."
if command -v code-server >/dev/null 2>&1; then
    code_server_version=$(code-server --version 2>&1 | head -n1)
    echo "✓ VS Code Server: $code_server_version"
    
    if systemctl is-active --quiet code-server; then
        echo "✓ VS Code Server service is running"
    else
        echo "⚠ VS Code Server service is not running"
    fi
else
    echo "✗ VS Code Server not found"
fi

echo
echo "=== Language Runtime Verification Complete ==="
