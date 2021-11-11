ARG		AIRFLOW_VERSION

FROM apache/airflow:${AIRFLOW_VERSION}

RUN pip install --user airflow-exporter

RUN pip install --user flask_admin # Was needed for some reasons during install
