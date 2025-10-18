#!/usr/bin/env uv run
# /// script
# dependencies = [
#   "rich"
# ]
# ///

import subprocess
import sys
from rich.console import Console

console = Console()

def main():
    console.print("[yellow]Starting all services...[/yellow]")

    result = subprocess.run(["docker-compose", "up", "-d"], capture_output=True)
    if result.returncode != 0:
        console.print("[red]Failed to start services[/red]")
        sys.exit(1)

    console.print("[yellow]Waiting for services to be healthy...[/yellow]")
    subprocess.run(["sleep", "5"])

    console.print("[green]All services started![/green]\n")
    console.print("[cyan]Access points:[/cyan]")
    console.print("  [blue]API:[/blue]         http://localhost:8080")
    console.print("  [blue]Swagger:[/blue]     http://localhost:8080/swagger")
    console.print("  [blue]RabbitMQ:[/blue]    http://localhost:15672")
    console.print("  [blue]PostgreSQL:[/blue]  localhost:5432\n")

if __name__ == "__main__":
    main()
