#!/usr/bin/env uv run
# /// script
# dependencies = [
#   "loguru",
#   "tqdm",
#   "rich"
# ]
# ///

import subprocess
import sys
import time
from loguru import logger
from tqdm import tqdm
from rich.console import Console
from rich.table import Table

console = Console()
logger.remove()
logger.add(sys.stderr, format="<level>{message}</level>", colorize=True, level="INFO")

def run_cmd(cmd):
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    return result.returncode == 0, result.stdout.strip()

def check_container(name):
    success, output = run_cmd(f"docker ps --filter name={name} --format '{{{{.Status}}}}'")
    if success and output and "Up" in output:
        return True, output
    return False, "Not running"

def test_postgres():
    success, _ = run_cmd("docker exec rtmc_postgres pg_isready -U admin -d TaskManagementDb 2>/dev/null")
    return success

def test_redis():
    success, output = run_cmd("docker exec rtmc_redis redis-cli ping 2>/dev/null")
    return success and output == "PONG"

def test_kafka():
    success, _ = run_cmd("docker exec rtmc_kafka kafka-broker-api-versions --bootstrap-server localhost:9092 2>/dev/null")
    return success

def test_rabbitmq():
    success, _ = run_cmd("docker exec rtmc_rabbitmq rabbitmqctl status 2>/dev/null")
    return success

def test_api():
    success, _ = run_cmd("curl -sf http://localhost:8080/weatherforecast > /dev/null 2>&1")
    return success

def main():
    console.print("\n[bold cyan]Docker Compose Status[/bold cyan]\n")

    services = {
        "PostgreSQL": ("rtmc_postgres", test_postgres),
        "Redis": ("rtmc_redis", test_redis),
        "Kafka": ("rtmc_kafka", test_kafka),
        "RabbitMQ": ("rtmc_rabbitmq", test_rabbitmq),
        "API": ("rtmc_api", test_api)
    }

    table = Table(show_header=True, header_style="bold cyan")
    table.add_column("Service", style="white", width=15)
    table.add_column("Status", width=20)
    table.add_column("Connection", width=20)

    all_ok = True

    with tqdm(total=len(services), desc="Checking services", ncols=80, colour="cyan") as pbar:
        for name, (container, test_func) in services.items():
            pbar.set_description(f"Checking {name:12}")

            running, status = check_container(container)

            if running:
                if name == "API":
                    time.sleep(1)

                connected = test_func()
                if connected:
                    table.add_row(name, "[green]Running[/green]", "[green]✓ Connected[/green]")
                else:
                    table.add_row(name, "[yellow]Running[/yellow]", "[yellow]✗ Failed[/yellow]")
                    all_ok = False
            else:
                table.add_row(name, "[red]Not Running[/red]", "[dim]-[/dim]")
                all_ok = False

            pbar.update(1)

    console.print(table)
    console.print("\n[bold cyan]Endpoints:[/bold cyan]")
    console.print("  [blue]API:[/blue]         http://localhost:8080")
    console.print("  [blue]Swagger:[/blue]     http://localhost:8080/swagger")
    console.print("  [blue]RabbitMQ UI:[/blue] http://localhost:15672\n")

    sys.exit(0 if all_ok else 1)

if __name__ == "__main__":
    main()
