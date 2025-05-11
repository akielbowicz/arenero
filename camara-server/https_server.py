import http.server
import ssl
import os
import base64
import json
import argparse
import datetime
from pathlib import Path

def save_image(data, name, timestamp):
    global basePath
    # Extract the base64-encoded image data from the DataURL
    image_data = data.get(name, '')  # Assuming the image data is sent as a DataURL
    image_name = f"{timestamp}_{name}.png"  # Use the provided name and timestamp for the image file
    
    path = basePath / image_name
    
    # Save the received image to a file
    with open(path, "wb") as f:
        # f.write(base64.urlsafe_b64decode(image_data))  # Decode the base64 string and write to file
        f.write(base64.b64decode(image_data.split(",",1)[1]))  # Write the raw bytes to the file


class CustomHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def do_POST(self):
        # Handle POST requests
        if self.path == '/save-images':  # Endpoint to receive the image
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)

            # Save the received image to a file
            # Parse the JSON body to extract the image name and data
            
            body = json.loads(post_data.decode('utf-8'))
              # Sanitize the image name to make it safe for a filename
            timestamp = body.get('timestamp', '')  # Default to 'uploaded_image.png' if no name is provided
            sanitized_timestamp = "".join(c for c in timestamp if c.isalnum() or c in (' ', '.', '_')).strip()

            save_image(body, 'coverImage', sanitized_timestamp)  # Save the image using the provided name
            save_image(body, 'editionImage', sanitized_timestamp)  # Save the image using the provided name

            # Send a response
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            response = {'message': 'Image uploaded successfully!', 'file_name': timestamp}
            self.wfile.write(json.dumps(response).encode('utf-8'))
            self.end_headers()
            self.wfile.write(b"Image uploaded successfully!")
        else:
            # Handle other POST requests (if needed)
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b"Endpoint not found.")



if __name__ == "__main__":
    # Parse command-line arguments
    parser = argparse.ArgumentParser(description="HTTPS Server")
    parser.add_argument('--basepath', type=str, default="/tmp/camera-server/", help="Base path for the server")
    args = parser.parse_args()

    # Check if the base path exists and is a directory, if not create recursively
    basePath = Path(args.basepath) / f"{datetime.datetime.now().strftime('%Y-%m-%d')}"
    basePath.mkdir(parents=True, exist_ok=True)

    # Define the server address and port
    server_address = ('0.0.0.0', 4443)  # Bind to all network interfaces

    # Create an HTTP server
    httpd = http.server.HTTPServer(server_address, CustomHTTPRequestHandler)

    # Create an SSL context
    ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    ssl_context.load_cert_chain(certfile="cert.pem", keyfile="key.pem")

    # Wrap the server's socket with the SSL context
    httpd.socket = ssl_context.wrap_socket(httpd.socket, server_side=True)

    print(f"Serving on https://0.0.0.0:4443 with basepath {args.basepath}")
    httpd.serve_forever()