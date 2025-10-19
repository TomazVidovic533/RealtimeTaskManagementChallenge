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

def get_pod_status(component):
    success, output = run_cmd(f"kubectl get pods -l app.kubernetes.io/component={component} -o jsonpath='{{.items[0].status.phase}}'")
    if not success or not output:
        return False, "Not Found"

    if output == "Running":
        ready_success, ready_status = run_cmd(
            f"kubectl get pods -l app.kubernetes.io/component={component} -o jsonpath='{{.items[0].status.conditions[?(@.type==\"Ready\")].status}}'"
        )
        if ready_success and ready_status == "True":
            return True, "Running"
        else:
            return False, "Starting"
    elif output == "Pending":
        return False, "Pending"
    elif output == "ContainerCreating":
        return False, "Creating"

    return False, output

def test_postgres():
    success, _ = run_cmd("kubectl exec $(kubectl get pod -l app.kubernetes.io/component=postgres -o jsonpath='{.items[0].metadata.name}') -- pg_isready -U admin -d TaskManagementDb 2>/dev/null")
    return success

def test_redis():
    success, output = run_cmd("kubectl exec $(kubectl get pod -l app.kubernetes.io/component=redis -o jsonpath='{.items[0].metadata.name}') -- redis-cli ping 2>/dev/null")
    return success and "PONG" in output

def test_kafka():
    success, _ = run_cmd("kubectl exec $(kubectl get pod -l app.kubernetes.io/component=kafka -o jsonpath='{.items[0].metadata.name}') -- kafka-broker-api-versions --bootstrap-server localhost:9092 2>/dev/null")
    return success

def test_rabbitmq():
    success, _ = run_cmd("kubectl exec $(kubectl get pod -l app.kubernetes.io/component=rabbitmq -o jsonpath='{.items[0].metadata.name}') -- rabbitmqctl status 2>/dev/null")
    return success

def test_elasticsearch():
    success, _ = run_cmd("kubectl exec $(kubectl get pod -l app.kubernetes.io/component=elasticsearch -o jsonpath='{.items[0].metadata.name}') -- curl -u elastic:elastic123 -sf http://localhost:9200/_cluster/health 2>/dev/null")
    return success

def test_grafana():
    success, _ = run_cmd("kubectl exec $(kubectl get pod -l app.kubernetes.io/component=grafana -o jsonpath='{.items[0].metadata.name}') -- curl -sf http://localhost:3000/api/health 2>/dev/null")
    return success

def test_api():
    success, _ = run_cmd("curl -sf http://localhost:8080/weatherforecast > /dev/null 2>&1")
    return success

def test_frontend():
    success, _ = run_cmd("curl -sf http://localhost:30081 > /dev/null 2>&1")
    return success

def main():
    console.print("\n[bold cyan]Kubernetes (k3d) Status[/bold cyan]\n")

    services = {
        "PostgreSQL": ("postgres", test_postgres),
        "Redis": ("redis", test_redis),
        "Kafka": ("kafka", test_kafka),
        "RabbitMQ": ("rabbitmq", test_rabbitmq),
        "Elasticsearch": ("elasticsearch", test_elasticsearch),
        "Grafana": ("grafana", test_grafana),
        "API": ("api", test_api),
        "Frontend": ("frontend", test_frontend)
    }

    table = Table(show_header=True, header_style="bold cyan")
    table.add_column("Service", style="white", width=15)
    table.add_column("Pod Status", width=20)
    table.add_column("Connection", width=20)

    all_ok = True
    pods_starting = False

    with tqdm(total=len(services), desc="Checking services", ncols=80, colour="cyan") as pbar:
        for name, (component, test_func) in services.items():
            pbar.set_description(f"Checking {name:12}")

            running, status = get_pod_status(component)

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
                if status in ["Pending", "Creating", "Starting"]:
                    table.add_row(name, f"[yellow]{status}[/yellow]", "[dim]...[/dim]")
                    pods_starting = True
                    all_ok = False
                else:
                    table.add_row(name, f"[red]{status}[/red]", "[dim]-[/dim]")
                    all_ok = False

            pbar.update(1)

    console.print(table)

    if pods_starting:
        console.print("\n[yellow]⚠ Some pods are still starting. This may take 2-3 minutes for first-time image pulls.[/yellow]")
        console.print("[yellow]Run 'make status' again in a minute or check: make k3d-status[/yellow]\n")

    console.print("\n[bold cyan]Endpoints:[/bold cyan]")
    console.print("  [blue]Frontend:[/blue]       http://localhost:30081")
    console.print("  [blue]API:[/blue]            http://localhost:8080")
    console.print("  [blue]Swagger:[/blue]        http://localhost:8080/swagger")
    console.print("\n[bold cyan]Port Forwarding (internal services):[/bold cyan]")
    console.print("  [blue]RabbitMQ:[/blue]       kubectl port-forward svc/rtmc-rabbitmq 15672:15672")
    console.print("  [blue]Grafana:[/blue]        kubectl port-forward svc/rtmc-grafana 3000:3000")
    console.print("  [blue]Elasticsearch:[/blue]  kubectl port-forward svc/rtmc-elasticsearch 9200:9200\n")

    sys.exit(0 if all_ok else 1)

if __name__ == "__main__":
    main()
