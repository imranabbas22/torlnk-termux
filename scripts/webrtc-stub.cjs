// CJS stub for webrtc-polyfill — used when node-datachannel is unavailable.
// Loaded via Module._resolveFilename hook on Node 22.0-22.14.
//
// With RTCPeerConnection undefined, simple-peer computes
// WEBRTC_SUPPORT = false and bittorrent-tracker skips WebRTC peers,
// so the swarm runs on TCP/uTP and DHT peers alone.

module.exports = {
  RTCPeerConnection: undefined,
  RTCSessionDescription: undefined,
  RTCIceCandidate: undefined,
  RTCIceTransport: undefined,
  RTCDataChannel: undefined,
  RTCSctpTransport: undefined,
  RTCDtlsTransport: undefined,
  RTCCertificate: undefined,
  default: undefined,
};
