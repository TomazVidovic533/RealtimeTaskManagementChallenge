#!/usr/bin/env uv run
# /// script
# dependencies = [
#   "rich"
# ]
# ///

import subprocess
import sys
import os
from pathlib import Path
from rich.console import Console

console = Console()

def run_cmd(cmd, shell=False, cwd=None):
    if shell:
        result = subprocess.run(cmd, shell=True, cwd=cwd)
    else:
        result = subprocess.run(cmd, cwd=cwd)
    return result.returncode == 0

def main():
    project_root = Path(__file__).parent.parent.parent.parent

    console.print("[yellow]Building images...[/yellow]")
    compose_cmd = [
        "docker-compose",
        "-f", str(project_root / "infrastructure/docker/docker-compose.yml"),
        "--env-file", str(project_root / ".env"),
        "build", "api", "frontend"
    ]
    if not run_cmd(compose_cmd):
        console.print("[red]Failed to build images[/red]")
        sys.exit(1)

    console.print("[yellow]Tagging and pushing to local registry...[/yellow]")
    if not run_cmd(["docker", "tag", "rtmc-api:latest", "localhost:35000/rtmc/api:latest"]):
        sys.exit(1)
    if not run_cmd(["docker", "tag", "rtmc-frontend:latest", "localhost:35000/rtmc/frontend:latest"]):
        sys.exit(1)
    if not run_cmd(["docker", "push", "localhost:35000/rtmc/api:latest"]):
        sys.exit(1)
    if not run_cmd(["docker", "push", "localhost:35000/rtmc/frontend:latest"]):
        sys.exit(1)

    console.print("[yellow]Installing Helm chart...[/yellow]")
    helm_chart_path = project_root / "infrastructure/helm/rtmc"
    if not run_cmd(["helm", "install", "rtmc", str(helm_chart_path)]):
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
