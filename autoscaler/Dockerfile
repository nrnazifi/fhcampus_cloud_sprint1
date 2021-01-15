FROM ubuntu:20.04
FROM python:3

ENV EXOSCALE_KEY=key
ENV EXOSCALE_SECRET=secret
ENV EXOSCALE_ZONE=zone
ENV EXOSCALE_INSTANCEPOOL_ID=pool
ENV LISTEN_PORT=port

RUN pip install exoscale
RUN pip install flask

RUN mkdir -p /srv/autoscaling/
COPY webapp.py /srv/autoscaling/webapp.py

CMD [ "python3", "/srv/autoscaling/webapp.py" ]
