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

def run_cmd(cmd, shell=False):
    if shell:
        result = subprocess.run(cmd, shell=True)
    else:
        result = subprocess.run(cmd)
    return result.returncode == 0

def main():
    console.print("[yellow]Building API image...[/yellow]")
    if not run_cmd(["docker-compose", "build", "api"]):
        console.print("[red]Failed to build API image[/red]")
        sys.exit(1)

    console.print("[yellow]Tagging and pushing to local registry...[/yellow]")
    if not run_cmd(["docker", "tag", "rtmc-api:latest", "localhost:35000/rtmc/api:latest"]):
        sys.exit(1)
    if not run_cmd(["docker", "push", "localhost:35000/rtmc/api:latest"]):
        sys.exit(1)

    console.print("[yellow]Installing Helm chart...[/yellow]")
    if not run_cmd(["helm", "install", "rtmc", "./helm/rtmc"]):
        console.print("[red]Failed to install Helm chart[/red]")
        sys.exit(1)

    console.print("[green]Helm chart installed![/green]\n")
    console.print("[yellow]Waiting for all pods to be ready (may take 2-3 minutes for first-time image pulls)...[/yellow]")

    result = subprocess.run([
        "kubectl", "wait", "--for=condition=ready", "pod",
        "-l", "app.kubernetes.io/instance=rtmc",
        "--timeout=300s"
    ])

    if result.returncode != 0:
        console.print("[red]Timeout waiting for pods to be ready[/red]")
        console.print("[yellow]Check status with: make k3d-status[/yellow]")
        sys.exit(1)

    console.print("[green]All pods are ready![/green]\n")
    subprocess.run(["kubectl", "get", "pods"])

    console.print("\n[cyan]Access API:[/cyan]")
    console.print("  [blue]curl http://localhost:8080/weatherforecast[/blue]\n")

if __name__ == "__main__":
    main()
