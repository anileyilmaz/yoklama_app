// Flutter web build'ini (build/web) self-signed sertifika ile HTTPS üzerinden
// LAN'a servis eder — telefon tarayıcısı localhost olmayan adreslerde kamerayı
// (getUserMedia) yalnızca secure context'te (HTTPS) açtığı için gerekli.
// Sertifika yoklama-sistemi-v3/certs altındaki backend sertifikasıyla aynıdır.
const https = require("https");
const fs = require("fs");
const path = require("path");

const PORT = process.env.PORT || 8443;
const ROOT = path.join(__dirname, "build", "web");
const CERT_DIR = path.join(__dirname, "..", "yoklama-sistemi-v3", "certs");

const MIME = {
  ".html": "text/html",
  ".js": "application/javascript",
  ".json": "application/json",
  ".css": "text/css",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".svg": "image/svg+xml",
  ".wasm": "application/wasm",
  ".ico": "image/x-icon",
  ".ttf": "font/ttf",
  ".otf": "font/otf",
};

const server = https.createServer(
  {
    key: fs.readFileSync(path.join(CERT_DIR, "key.pem")),
    cert: fs.readFileSync(path.join(CERT_DIR, "cert.pem")),
  },
  (req, res) => {
    const urlPath = decodeURIComponent(req.url.split("?")[0]);
    let filePath = path.join(ROOT, urlPath === "/" ? "index.html" : urlPath);
    if (!filePath.startsWith(ROOT)) {
      res.writeHead(403);
      return res.end("Forbidden");
    }
    fs.readFile(filePath, (err, data) => {
      if (err) {
        // Flutter web SPA fallback
        return fs.readFile(path.join(ROOT, "index.html"), (err2, indexData) => {
          if (err2) {
            res.writeHead(404);
            return res.end("Not found");
          }
          res.writeHead(200, { "Content-Type": "text/html" });
          res.end(indexData);
        });
      }
      res.writeHead(200, { "Content-Type": MIME[path.extname(filePath)] || "application/octet-stream" });
      res.end(data);
    });
  }
);

server.listen(PORT, "0.0.0.0", () => {
  console.log(`Flutter web (HTTPS) → https://0.0.0.0:${PORT}`);
});
