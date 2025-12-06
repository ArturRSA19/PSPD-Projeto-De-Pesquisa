FROM python:3.12-slim
WORKDIR /app
RUN useradd -m app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt \
 && chown -R app /app
COPY users_pb2.py users_pb2_grpc.py ./
COPY server.py .
USER app
EXPOSE 50051
CMD ["python", "server.py"]
