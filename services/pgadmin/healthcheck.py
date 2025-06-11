#!/usr/bin/env python3
import http.client
import sys
import os
import atexit
from typing import Callable
import traceback

def on_exit() -> None:
    """Handle cleanup on exit."""
    print("Exiting gracefully...")

def main_wrapper(main_func: Callable[..., None], *args, **kwargs) -> None:
    """Wrapper to handle exceptions and exit codes."""
    try:
        print("Starting health check...")
        main_func(*args, **kwargs)
    except KeyboardInterrupt:
        print("Health check interrupted by user.")
        sys.exit(130)
    except SystemExit as e:
        print(f"Exiting with code: {e.code}")
        sys.exit(e.code)
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        traceback.print_exc()
        sys.exit(1)

def main() -> None:
    """Main health check function."""
    try:
        connection = http.client.HTTPConnection("localhost", os.environ.get("PGADMIN_PORT", 5050))
        connection.request("GET", "/")
        response = connection.getresponse()
        print(f"Status: {response.status}")
        if response.status in (200, 302):
            print("pgAdmin is healthy.")
        else:
            print(f"pgAdmin health check failed with status: {response.status}")
            sys.exit(1)
    except Exception as e:
        print(f"Error during health check: {e}")
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    atexit.register(on_exit)
    main_wrapper(main)
