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

    console.print("[green]✓ Helm chart installed![/green]")
    console.print("[dim]Pods are starting in the background...[/dim]\n")

if __name__ == "__main__":
    main()
