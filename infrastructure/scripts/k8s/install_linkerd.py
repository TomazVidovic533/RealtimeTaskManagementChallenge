#!/usr/bin/env uv run
# /// script
# dependencies = [
#   "rich"
# ]
# ///

import subprocess
import sys
import os
import shutil
from pathlib import Path
from rich.console import Console

console = Console()

def get_gateway_api_url():
    """Always use latest Gateway API CRDs"""
    return "https://github.com/kubernetes-sigs/gateway-api/releases/latest/download/standard-install.yaml"

def run_cmd(cmd, shell=False):
    if shell:
        result = subprocess.run(cmd, shell=True)
    else:
        result = subprocess.run(cmd)
    return result.returncode == 0

def get_linkerd_path():
    linkerd_cmd = shutil.which("linkerd")
    if linkerd_cmd:
        return linkerd_cmd

    default_path = os.path.expanduser("~/.linkerd2/bin/linkerd")
    if os.path.exists(default_path):
        return default_path

    return None

def install_linkerd_cli():
    console.print("[yellow]Linkerd CLI not found. Installing...[/yellow]")

    result = subprocess.run(
        "curl -sL https://run.linkerd.io/install | sh",
        shell=True
    )

    if result.returncode != 0:
        console.print("[red]Failed to install Linkerd CLI[/red]")
        return None

    linkerd_path = os.path.expanduser("~/.linkerd2/bin")
    linkerd_bin = f"{linkerd_path}/linkerd"

    if not os.path.exists(linkerd_bin):
        console.print("[red]Linkerd CLI not found after installation[/red]")
        return None

    current_path = os.environ.get("PATH", "")
    if linkerd_path not in current_path:
        os.environ["PATH"] = f"{linkerd_path}:{current_path}"

    console.print("[green]Linkerd CLI installed![/green]")
    console.print(f"[yellow]Add to your shell: export PATH=$PATH:{linkerd_path}[/yellow]\n")
    return linkerd_bin

def main():
    console.print("[yellow]Installing Linkerd...[/yellow]")

    linkerd_cmd = get_linkerd_path()
    if not linkerd_cmd:
        linkerd_cmd = install_linkerd_cli()
        if not linkerd_cmd:
            sys.exit(1)

    console.print("[cyan]Step 1/5: Pre-flight check[/cyan]")
    if not run_cmd([linkerd_cmd, "check", "--pre"]):
        console.print("[red]Pre-flight check failed[/red]")
        sys.exit(1)

    console.print("[cyan]Step 2/5: Installing Gateway API CRDs (latest)[/cyan]")
    gateway_api_url = get_gateway_api_url()
    if not run_cmd(f"kubectl apply -f {gateway_api_url}", shell=True):
        console.print("[red]Failed to install Gateway API CRDs[/red]")
        sys.exit(1)

    console.print("[cyan]Step 3/5: Installing Linkerd CRDs[/cyan]")
    if not run_cmd(f"{linkerd_cmd} install --crds | kubectl apply -f -", shell=True):
        console.print("[red]Failed to install Linkerd CRDs[/red]")
        sys.exit(1)

    console.print("[cyan]Step 4/5: Installing Linkerd control plane[/cyan]")
    if not run_cmd(f"{linkerd_cmd} install | kubectl apply -f -", shell=True):
        console.print("[red]Failed to install Linkerd control plane[/red]")
        sys.exit(1)

    console.print("[cyan]Step 5/5: Installing Linkerd Viz (observability)[/cyan]")
    if not run_cmd(f"{linkerd_cmd} viz install | kubectl apply -f -", shell=True):
        console.print("[red]Failed to install Linkerd Viz[/red]")
        sys.exit(1)

    console.print("\n[green]Linkerd installed successfully![/green]\n")

    console.print("[cyan]Verifying installation...[/cyan]")
    subprocess.run([linkerd_cmd, "check"])

    console.print("\n[yellow]To view the dashboard:[/yellow]")
    console.print(f"  {linkerd_cmd} viz dashboard\n")

if __name__ == "__main__":
    main()