FROM python:3-buster AS base

ENV USER "tron"
ENV USERID 8877
ENV APPDIR "/app"

RUN useradd --uid ${USERID} ${USER} \
    && mkdir -p ${APPDIR} \
    && chown -R ${USER} ${APPDIR} \
    && mkdir -p /home/${USER} \
    && chown -R ${USER} /home/${USER}

USER ${USER}
WORKDIR ${APPDIR}
ENV PYTHONPATH ${APPDIR}
ENV PATH ${PATH}:/home/${USER}/.local/bin
RUN pip install --no-cache-dir \
    fastapi \
    uvicorn \
    ``

COPY main.py .

EXPOSE 8080

# VERY IMPORTANT: Host should not be 127.0.0.1 not localhost only 0.0.0.0 
# I repeat, please use 0.0.0.0 if you want to avoid hours of wondering 
# why your pod won't connect. You have been warned.
CMD [ "uvicorn", "--reload", "--host=0.0.0.0", "--port=8080", "main:app" ]
