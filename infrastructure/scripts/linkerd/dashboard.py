#!/usr/bin/env uv run
# /// script
# dependencies = [
#   "rich"
# ]
# ///

import subprocess
import sys
import os
import time
import webbrowser
import signal
from pathlib import Path
from rich.console import Console

console = Console()

def get_linkerd_path():
    """Find linkerd CLI path"""
    linkerd_cmd = os.path.expanduser("~/.linkerd2/bin/linkerd")
    if os.path.exists(linkerd_cmd):
        return linkerd_cmd

    console.print("[red]Linkerd CLI not found at ~/.linkerd2/bin/linkerd[/red]")
    console.print("[yellow]Run 'make k3d-start' first to install Linkerd[/yellow]")
    return None

def kill_existing_dashboard():
    """Kill any existing dashboard processes"""
    console.print("[yellow]Checking for existing dashboard processes...[/yellow]")

    # Kill kubectl port-forward for linkerd-viz
    subprocess.run(
        "pkill -f 'kubectl.*port-forward.*linkerd-viz' 2>/dev/null",
        shell=True
    )

    # Kill linkerd viz dashboard
    subprocess.run(
        "pkill -f 'linkerd viz dashboard' 2>/dev/null",
        shell=True
    )

    time.sleep(1)
    console.print("[green]Cleaned up existing processes[/green]")

def open_dashboard(linkerd_cmd):
    """Start dashboard and open browser"""
    console.print("[cyan]Starting Linkerd dashboard...[/cyan]")
    console.print("[dim]This will keep running until you press Ctrl+C[/dim]\n")

    # Start dashboard in background
    process = subprocess.Popen(
        [linkerd_cmd, "viz", "dashboard", "--show", "url"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )

    # Wait a bit for dashboard to start
    time.sleep(3)

    # Open browser
    dashboard_url = "http://localhost:50750"
    grafana_url = "http://localhost:50750/grafana"

    console.print(f"[green]✓ Dashboard started![/green]\n")
    console.print("[cyan]Access points:[/cyan]")
    console.print(f"  [yellow]Dashboard:[/yellow] {dashboard_url}")
    console.print(f"  [yellow]Grafana:[/yellow]   {grafana_url}\n")

    console.print("[green]Opening dashboard in browser...[/green]")
    webbrowser.open(dashboard_url)

    console.print("\n[yellow]Press Ctrl+C to stop the dashboard[/yellow]\n")

    # Wait for user to stop
    try:
        process.wait()
    except KeyboardInterrupt:
        console.print("\n[yellow]Stopping dashboard...[/yellow]")
        process.terminate()
        try:
            process.wait(timeout=5)
        except subprocess.TimeoutExpired:
            process.kill()

        # Clean up port-forwards
        kill_existing_dashboard()
        console.print("[green]Dashboard stopped![/green]")

def main():
    linkerd_cmd = get_linkerd_path()
    if not linkerd_cmd:
        sys.exit(1)

    kill_existing_dashboard()

    try:
        open_dashboard(linkerd_cmd)
    except Exception as e:
        console.print(f"[red]Error: {e}[/red]")
        sys.exit(1)

if __name__ == "__main__":
    main()