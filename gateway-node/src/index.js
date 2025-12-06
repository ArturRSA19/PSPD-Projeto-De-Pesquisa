import express from 'express';
import morgan from 'morgan';
import grpc from '@grpc/grpc-js';
import protoLoader from '@grpc/proto-loader';
import path from 'path';
import { fileURLToPath } from 'url';
import { WebSocketServer } from 'ws';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const PROTO_PATH = path.join(__dirname, '../proto/users.proto');
const packageDefinition = protoLoader.loadSync(PROTO_PATH, {
  keepCase: true,
  longs: String,
  enums: String,
  defaults: true,
  oneofs: true,
});
const proto = grpc.loadPackageDefinition(packageDefinition).pspd;

// gRPC clients
const userServiceAddr = process.env.USER_SERVICE_ADDR || 'localhost:50051';
const statsServiceAddr = process.env.STATS_SERVICE_ADDR || 'localhost:50052';
console.log('[Config] USER_SERVICE_ADDR =', userServiceAddr);
console.log('[Config] STATS_SERVICE_ADDR =', statsServiceAddr);
const userClient = new proto.UserService(userServiceAddr, grpc.credentials.createInsecure());
const statsClient = new proto.StatsService(statsServiceAddr, grpc.credentials.createInsecure());

const app = express();
app.use(express.json());
app.use(morgan('dev'));
// Static UI (minimal frontend) served from ../public
import fs from 'fs';
const publicDir = path.join(__dirname, '../public');
if (fs.existsSync(publicDir)) {
  app.use(express.static(publicDir));
}

app.get('/healthz', (req, res) => res.json({ status: 'ok' }));

// Unary example
app.get('/users/:id', (req, res) => {
  userClient.GetUser({ id: req.params.id }, (err, response) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(response.user);
  });
});

// Server streaming example
app.get('/users', (req, res) => {
  const call = userClient.ListUsers({});
  const users = [];
  call.on('data', (user) => users.push(user));
  call.on('end', () => res.json(users));
  call.on('error', (err) => res.status(500).json({ error: err.message }));
});

// Client streaming example (bulk create)
app.post('/users/bulk', (req, res) => {
  const call = userClient.CreateUsers((err, summary) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(summary);
  });
  const users = req.body.users || [];
  users.forEach(u => call.write(u));
  call.end();
});

// Unary to Stats service
app.get('/scores/:userId', (req, res) => {
  statsClient.GetScore({ user_id: req.params.userId, base: 10 }, (err, response) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(response);
  });
});

const port = process.env.PORT || 8080;
const server = app.listen(port, () => {
  console.log(`Gateway listening on port ${port}`);
});

// --- WebSocket Chat (bidirectional) ---
// Cada conexão WebSocket abrirá um stream gRPC UserChat.
const wss = new WebSocketServer({ server, path: '/chat' });
console.log('WebSocket /chat enabled');

// Mantém broadcast simples em memória
function nowTs() { return Date.now(); }

wss.on('connection', (ws) => {
  console.log('[WS] Nova conexão');
  const grpcStream = userClient.UserChat();

  // Recebe mensagens do gRPC e envia ao cliente WebSocket
  grpcStream.on('data', (msg) => {
    try {
      ws.send(JSON.stringify({ user_id: msg.user_id, text: msg.text, timestamp: msg.timestamp }));
    } catch (e) {
      console.error('[WS] send error', e.message);
    }
  });
  grpcStream.on('error', (err) => {
    console.error('[gRPC Chat] stream error:', err.message);
    if (ws.readyState === ws.OPEN) ws.send(JSON.stringify({ error: err.message }));
  });
  grpcStream.on('end', () => {
    console.log('[gRPC Chat] stream ended');
    if (ws.readyState === ws.OPEN) ws.close();
  });

  ws.on('message', (data) => {
    let parsed;
    try {
      parsed = JSON.parse(data.toString());
    } catch {
      return ws.send(JSON.stringify({ error: 'Invalid JSON' }));
    }
    const userId = parsed.user_id || 'anon';
    const text = parsed.text || '';
    grpcStream.write({ user_id: userId, text, timestamp: nowTs() });
  });

  ws.on('close', () => {
    console.log('[WS] conexão fechada');
    try { grpcStream.end(); } catch {}
  });
});

// Página simples opcional
app.get('/chat-test', (_req, res) => {
  res.setHeader('Content-Type', 'text/html');
  res.end(`<!DOCTYPE html><html><body>
<h3>Chat Bidirecional gRPC via WebSocket</h3>
<input id="user" placeholder="user id" value="u1"/> <br/>
<input id="msg" placeholder="mensagem"/> <button onclick="sendMsg()">Enviar</button>
<pre id="log" style="background:#111;color:#0f0;padding:8px;height:240px;overflow:auto"></pre>
<script>
const ws = new WebSocket((location.protocol==='https:'?'wss':'ws')+'://'+location.host+'/chat');
ws.onmessage = ev => { const m = JSON.parse(ev.data); log.textContent += JSON.stringify(m)+"\n"; log.scrollTop = log.scrollHeight; };
function sendMsg(){ ws.send(JSON.stringify({user_id: user.value, text: msg.value})); msg.value=''; }
</script>
</body></html>`);
});
