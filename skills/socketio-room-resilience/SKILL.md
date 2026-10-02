---
name: socketio-room-resilience
description: Realtime WebSocket architecture for live tournament scoring, match rooms, automatic reconnection, state resynchronization, and memory leak cleanup.
---

# Socket.IO Realtime Resilience & Live Score Playbook

Sử dụng khi viết Gateway, Room, hoặc Event realtime trong NestJS và client Web/Mobile.

## 1. Handshake Auth & Room Isolation
- Xác thực JWT token ngay tại `handleConnection` handshake: nếu token hết hạn, reject kết nối ngay lập tức, không để socket treo vô định.
- Gom nhóm theo Room giải đấu: `socket.join("tournament:" + tournamentId)`.
- Client rời màn hình hoặc disconnect: BẮT BUỘC gọi cleanup listener để tránh rò rỉ RAM (Memory Leak).

## 2. Reconnection & State Catch-up
- Mạng di động (4G/Wifi) hay bị chập chờn ngắt kết nối.
- Khi socket kết nối lại (reconnect): Không chỉ nghe event mới, client phải gửi event `sync:state` để server trả về snapshot tỉ số mới nhất, tránh trường hợp người xem bị miss 2 bàn thắng vừa diễn ra.
