import time
import os
from concurrent import futures
import grpc
import users_pb2
import users_pb2_grpc

# In-memory store
USERS = {
    '1': {'id': '1', 'name': 'Alice', 'age': 30},
    '2': {'id': '2', 'name': 'Bob', 'age': 25},
}

class UserService(users_pb2_grpc.UserServiceServicer):
    def GetUser(self, request, context):
        user = USERS.get(request.id)
        if not user:
            context.set_code(grpc.StatusCode.NOT_FOUND)
            context.set_details('User not found')
            return users_pb2.UserResponse()
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
    port = os.environ.get("USER_PORT", "50051")
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    users_pb2_grpc.add_UserServiceServicer_to_server(UserService(), server)
    server.add_insecure_port(f'[::]:{port}')
    server.start()
    print(f'UserService running on :{port}')
    server.wait_for_termination()

if __name__ == '__main__':
    serve()
