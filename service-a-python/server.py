import time
import os
from concurrent import futures
import grpc
import users_pb2
import users_pb2_grpc
from prometheus_client import start_http_server, Counter, Histogram
import threading

# Prometheus metrics
REQUEST_COUNT = Counter('grpc_requests_total', 'Total gRPC requests', ['method', 'status'])
REQUEST_DURATION = Histogram('grpc_request_duration_seconds', 'gRPC request duration', ['method'])

# In-memory store
USERS = {
    '1': {'id': '1', 'name': 'Alice', 'age': 30},
    '2': {'id': '2', 'name': 'Bob', 'age': 25},
}

class UserService(users_pb2_grpc.UserServiceServicer):
    def GetUser(self, request, context):
        with REQUEST_DURATION.labels(method='GetUser').time():
            user = USERS.get(request.id)
            if not user:
                REQUEST_COUNT.labels(method='GetUser', status='NOT_FOUND').inc()
                context.set_code(grpc.StatusCode.NOT_FOUND)
                context.set_details('User not found')
                return users_pb2.UserResponse()
            REQUEST_COUNT.labels(method='GetUser', status='OK').inc()
            return users_pb2.UserResponse(user=users_pb2.User(**user))

    def ListUsers(self, request, context):
        for u in USERS.values():
            yield users_pb2.User(**u)
            time.sleep(0.1)

    def CreateUsers(self, request_iterator, context):
        ids = []
        count = 0
        for user in request_iterator:
            USERS[user.id] = {'id': user.id, 'name': user.name, 'age': user.age}
            ids.append(user.id)
            count += 1
        return users_pb2.UsersSummary(count=count, ids=ids)

    def UserChat(self, request_iterator, context):
        # Echo back messages with server-side timestamp
        for msg in request_iterator:
            yield users_pb2.ChatMessage(user_id=msg.user_id, text=msg.text.upper(), timestamp=int(time.time()))


def serve():
    # Start Prometheus metrics server
    metrics_port = int(os.environ.get("METRICS_PORT", "9090"))
    start_http_server(metrics_port)
    print(f'Metrics server running on :{metrics_port}')
    
    port = os.environ.get("USER_PORT", "50051")
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    users_pb2_grpc.add_UserServiceServicer_to_server(UserService(), server)
    server.add_insecure_port(f'[::]:{port}')
    server.start()
    print(f'UserService running on :{port}')
    server.wait_for_termination()

if __name__ == '__main__':
    serve()
