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
        "--port", "80:80@loadbalancer",
        "--port", "443:443@loadbalancer"
    ])

    if result.returncode != 0:
        console.print("[red]Failed to create cluster[/red]")
        sys.exit(1)

    console.print("[green]k3d cluster created![/green]")
    console.print("[blue]Cluster:[/blue] rtmc")
    console.print("[blue]Registry:[/blue] localhost:35000\n")

if __name__ == "__main__":
    main()
