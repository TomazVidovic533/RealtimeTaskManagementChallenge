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

def run_cmd(cmd):
    result = subprocess.run(cmd)
    return result.returncode == 0

def main():
    console.print("[yellow]Installing nginx-ingress controller...[/yellow]")

    console.print("[cyan]Step 1/3: Adding Helm repo[/cyan]")
    if not run_cmd(["helm", "repo", "add", "ingress-nginx", "https://kubernetes.github.io/ingress-nginx"]):
        console.print("[red]Failed to add Helm repo[/red]")
        sys.exit(1)

    console.print("[cyan]Step 2/3: Updating Helm repos[/cyan]")
    if not run_cmd(["helm", "repo", "update"]):
        console.print("[red]Failed to update Helm repos[/red]")
        sys.exit(1)

    console.print("[cyan]Step 3/3: Installing nginx-ingress[/cyan]")
    if not run_cmd([
        "helm", "install", "nginx-ingress", "ingress-nginx/ingress-nginx",
        "--namespace", "ingress-nginx",
        "--create-namespace",
        "--set", "controller.service.type=LoadBalancer"
    ]):
        console.print("[red]Failed to install nginx-ingress[/red]")
        sys.exit(1)

    console.print("\n[green]nginx-ingress installed successfully![/green]\n")

    console.print("[cyan]Waiting for ingress controller to be ready...[/cyan]")
    subprocess.run([
        "kubectl", "wait", "--namespace", "ingress-nginx",
        "--for=condition=ready", "pod",
        "--selector=app.kubernetes.io/component=controller",
        "--timeout=120s"
    ])

    console.print("\n[cyan]Ingress controller status:[/cyan]")
    subprocess.run(["kubectl", "get", "pods", "-n", "ingress-nginx"])

if __name__ == "__main__":
    main()