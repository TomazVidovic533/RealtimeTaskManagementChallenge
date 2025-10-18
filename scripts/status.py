#!/usr/bin/env uv run
# /// script
# dependencies = [
#   "loguru",
#   "rich"
# ]
# ///

import subprocess
import sys
import os
from loguru import logger
from rich.console import Console

console = Console()
logger.remove()
logger.add(sys.stderr, format="<level>{message}</level>", colorize=True, level="INFO")

def run_cmd(cmd):
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    return result.returncode == 0, result.stdout.strip()

def check_docker_compose():
    success, output = run_cmd("docker ps --filter name=rtmc_ --format '{{.Names}}' | wc -l")
    if success and output:
        count = int(output.strip())
        return count > 0
    return False

def check_k3d():
    success, _ = run_cmd("kubectl get pods -l app.kubernetes.io/instance=rtmc 2>/dev/null")
    return success

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))

    docker_running = check_docker_compose()
    k3d_running = check_k3d()

    if docker_running and k3d_running:
        console.print("[yellow]Both Docker Compose and k3d are running![/yellow]")
        console.print("[yellow]Defaulting to Docker Compose validation...[/yellow]\n")
        sys.exit(subprocess.call(["uv", "run", os.path.join(script_dir, "docker", "validate_docker.py")]))

    elif docker_running:
        console.print("[cyan]Detected: Docker Compose[/cyan]\n")
        sys.exit(subprocess.call(["uv", "run", os.path.join(script_dir, "docker", "validate_docker.py")]))

    elif k3d_running:
        console.print("[cyan]Detected: Kubernetes (k3d)[/cyan]\n")
        sys.exit(subprocess.call(["uv", "run", os.path.join(script_dir, "k8s", "validate_k8s.py")]))

    else:
        console.print("[red]No running environment detected![/red]")
        console.print("\n[yellow]Start an environment:[/yellow]")
        console.print("  Docker Compose: [blue]make start[/blue]")
        console.print("  Kubernetes:     [blue]make k3d-create && make helm-install[/blue]\n")
        sys.exit(1)

if __name__ == "__main__":
    main()
