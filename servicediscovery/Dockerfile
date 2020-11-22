FROM ubuntu:20.04
FROM python:3

ENV EXOSCALE_KEY=key
ENV EXOSCALE_SECRET=secret
ENV EXOSCALE_ZONE=zone
ENV EXOSCALE_INSTANCEPOOL_ID=pool
ENV TARGET_PORT=port

RUN pip install exoscale

RUN mkdir -p /srv/service-discovery/
COPY script.py /srv/service-discovery/script.py
RUN touch /srv/service-discovery/config.json
RUN chmod 777 /srv/service-discovery/config.json

CMD [ "python3", "/srv/service-discovery/script.py" ]