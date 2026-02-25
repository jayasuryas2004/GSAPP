#!/usr/bin/env python3
"""
Verification script to check if all backend files were created correctly.
Run this to validate your backend setup before testing.

Usage:
    python verify_setup.py
"""

import os
import sys
from pathlib import Path

# Color codes for terminal output
GREEN = "\033[92m"
RED = "\033[91m"
YELLOW = "\033[93m"
BLUE = "\033[94m"
RESET = "\033[0m"


def check_file_exists(file_path):
    """Check if a file exists."""
    return os.path.isfile(file_path)


def check_directory_exists(dir_path):
    """Check if a directory exists."""
    return os.path.isdir(dir_path)


def check_imports(file_path):
    """Try to parse a Python file to check for syntax errors."""
    try:
        with open(file_path, "r") as f:
            compile(f.read(), file_path, "exec")
        return True, None
    except SyntaxError as e:
        return False, str(e)
    except Exception as e:
        return False, str(e)


def main():
    print(f"\n{BLUE}{'='*60}")
    print("Backend Verification Script")
    print(f"{'='*60}{RESET}\n")

    base_dir = Path(__file__).parent
    all_checks_passed = True

    # Define required files and directories
    required_dirs = [
        "app",
        "app/api",
        "app/api/v1",
        "app/api/v1/endpoints",
        "app/models",
        "app/schemas",
        "app/services",
        "app/middleware",
        "app/utils",
        "config",
        "tests",
    ]

    required_files = {
        "main.py": "FastAPI Application",
        "Dockerfile": "Docker Configuration",
        "requirements.txt": "Python Dependencies",
        "config/settings.py": "Settings Configuration",
        "config/__init__.py": "Config Package Init",
        "app/__init__.py": "App Package Init",
        "app/api/__init__.py": "API Package Init",
        "app/api/v1/__init__.py": "API v1 Package Init",
        "app/api/v1/endpoints/__init__.py": "Endpoints Package Init",
        "app/api/v1/endpoints/health.py": "Health Check Endpoints",
        "app/api/v1/endpoints/schemes.py": "Schemes Endpoints",
        "app/api/v1/endpoints/users.py": "Users Endpoints",
        "app/api/v1/router.py": "API Router",
        "app/models/__init__.py": "Models Package Init",
        "app/models/scheme.py": "Scheme Model",
        "app/models/user.py": "User Model",
        "app/schemas/__init__.py": "Schemas Package Init",
        "app/schemas/scheme.py": "Scheme Schemas",
        "app/schemas/user.py": "User Schemas",
        "app/schemas/response.py": "Response Schemas",
        "app/services/__init__.py": "Services Package Init",
        "app/services/supabase_service.py": "Supabase Service",
        "app/services/cache_service.py": "Cache Service",
        "app/middleware/__init__.py": "Middleware Package Init",
        "app/middleware/error_handler.py": "Error Handler Middleware",
        "app/utils/__init__.py": "Utils Package Init",
        "app/utils/logger.py": "Logger Utility",
    }

    # Check directories
    print(f"{BLUE}Checking directories...{RESET}")
    for dir_path in required_dirs:
        full_path = base_dir / dir_path
        if check_directory_exists(full_path):
            print(f"{GREEN}✓{RESET} {dir_path}/")
        else:
            print(f"{RED}✗{RESET} {dir_path}/ - NOT FOUND")
            all_checks_passed = False

    print()

    # Check files
    print(f"{BLUE}Checking files...{RESET}")
    for file_path, description in required_files.items():
        full_path = base_dir / file_path
        if check_file_exists(full_path):
            # Check for Python syntax errors
            if file_path.endswith(".py"):
                is_valid, error = check_imports(full_path)
                if is_valid:
                    print(f"{GREEN}✓{RESET} {file_path:<40} - {description}")
                else:
                    print(f"{YELLOW}⚠{RESET} {file_path:<40} - {description} (Syntax Error: {error})")
                    all_checks_passed = False
            else:
                print(f"{GREEN}✓{RESET} {file_path:<40} - {description}")
        else:
            print(f"{RED}✗{RESET} {file_path:<40} - NOT FOUND")
            all_checks_passed = False

    print()

    # Check requirements.txt content
    print(f"{BLUE}Checking dependencies in requirements.txt...{RESET}")
    requirements_file = base_dir / "requirements.txt"
    required_packages = [
        "fastapi",
        "uvicorn",
        "supabase",
        "pydantic",
        "python-dotenv",
    ]

    if check_file_exists(requirements_file):
        with open(requirements_file, "r") as f:
            content = f.read().lower()
            for package in required_packages:
                if package.lower() in content:
                    print(f"{GREEN}✓{RESET} {package}")
                else:
                    print(f"{RED}✗{RESET} {package} - NOT FOUND")
                    all_checks_passed = False
    else:
        print(f"{RED}✗{RESET} requirements.txt - NOT FOUND")
        all_checks_passed = False

    print()

    # Summary
    if all_checks_passed:
        print(f"{GREEN}{'='*60}")
        print("✓ ALL CHECKS PASSED - Backend is ready!")
        print(f"{'='*60}{RESET}\n")
        print(f"{BLUE}Next steps:{RESET}")
        print("1. Install dependencies: pip install -r requirements.txt")
        print("2. Create .env file with Supabase credentials")
        print("3. Run: python main.py")
        print("4. Visit: http://localhost:8000/api/docs\n")
        return 0
    else:
        print(f"{RED}{'='*60}")
        print("✗ SOME CHECKS FAILED - Please review above")
        print(f"{'='*60}{RESET}\n")
        return 1


if __name__ == "__main__":
    sys.exit(main())
