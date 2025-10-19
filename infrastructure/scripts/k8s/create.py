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
    console.print("[yellow]Creating k3d cluster 'rtmc' with local registry...[/yellow]")

    result = subprocess.run([
        "k3d", "cluster", "create", "rtmc",
        "--registry-create", "rtmc-registry:0.0.0.0:35000",
        "--port", "8080:8080@loadbalancer",
        "--port", "30081:30081@server:0",
        "--port", "5432:5432@loadbalancer",
        "--port", "6379:6379@loadbalancer",
        "--port", "9092:9092@loadbalancer",
        "--port", "5672:5672@loadbalancer",
        "--port", "15672:15672@loadbalancer"
    ])

    if result.returncode != 0:
        console.print("[red]Failed to create cluster[/red]")
        sys.exit(1)

    console.print("[green]k3d cluster created![/green]")
    console.print("[blue]Cluster:[/blue] rtmc")
    console.print("[blue]Registry:[/blue] localhost:35000\n")

if __name__ == "__main__":
    main()
