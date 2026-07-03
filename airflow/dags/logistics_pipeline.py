from datetime import datetime, timedelta

from airflow import DAG
from airflow.providers.standard.operators.bash import BashOperator

# Define absolute paths mapped inside the Docker container
PROJECT_DIR = "/opt/airflow/project"
DBT_PROJECT = "/opt/airflow/project/dbt/logistics_project"

default_args = {
    "owner": "saswata",
    "retries": 3,
    "retry_delay": timedelta(seconds=30),
}

with DAG(
    dag_id="logistics_pipeline",
    description="End to End Logistics Analytics Pipeline",
    start_date=datetime(2026, 7, 1),
    schedule="@daily",
    catchup=False,
    default_args=default_args,
    tags=["logistics", "dbt", "duckdb"],
) as dag:

    
    load_bronze = BashOperator(
        task_id="load_bronze",
        cwd=PROJECT_DIR,
        bash_command="python scripts/load_bronze.py",
    )

    dbt_debug = BashOperator(
        task_id="dbt_debug",
        cwd=DBT_PROJECT,
        bash_command="dbt debug --profiles-dir .",
    )

    dbt_build = BashOperator(
        task_id="dbt_build",
        cwd=DBT_PROJECT,
        bash_command="dbt build --profiles-dir .",
    )

    export_gold = BashOperator(
        task_id="export_gold",
        cwd=PROJECT_DIR,
        bash_command="python scripts/export_gold_marts.py",
    )

    # --- NEW DEPENDENCIES (Skipping load_bronze) ---
    load_bronze >> dbt_debug >> dbt_build >> export_gold