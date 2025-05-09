import http.server
import ssl
import os
import base64
import json

class CustomHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def do_POST(self):
        # Handle POST requests
        if self.path == '/save-image':  # Endpoint to receive the image
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)

            # Save the received image to a file
            # Parse the JSON body to extract the image name and data
            
            body = json.loads(post_data.decode('utf-8'))
            # Extract the base64-encoded image data from the DataURL
            image_data = body.get('image', '')  # Assuming the image data is sent as a DataURL
            # Sanitize the image name to make it safe for a filename
            image_name = f"{body.get('name', 'uploaded_image.png')}.png"  # Default to 'uploaded_image.png' if no name is provided
            image_name = "".join(c for c in image_name if c.isalnum() or c in (' ', '.', '_')).strip()
            if not image_name:
                image_name = 'uploaded_image.png'  # Fallback to default if the sanitized name is empty

            # Save the received image to a file
            with open(image_name, "wb") as f:
                # f.write(base64.urlsafe_b64decode(image_data))  # Decode the base64 string and write to file
                f.write(base64.b64decode(image_data.split(",",1)[1]))  # Write the raw bytes to the file

            # Send a response
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            response = {'message': 'Image uploaded successfully!', 'file_name': image_name}
            self.wfile.write(json.dumps(response).encode('utf-8'))
            self.end_headers()
            self.wfile.write(b"Image uploaded successfully!")
        else:
            # Handle other POST requests (if needed)
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b"Endpoint not found.")

# Define the server address and port
server_address = ('0.0.0.0', 4443)  # Bind to all network interfaces

# Create an HTTP server
httpd = http.server.HTTPServer(server_address, CustomHTTPRequestHandler)

# Create an SSL context
ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
ssl_context.load_cert_chain(certfile="cert.pem", keyfile="key.pem")

# Wrap the server's socket with the SSL context
httpd.socket = ssl_context.wrap_socket(httpd.socket, server_side=True)

print("Serving on https://0.0.0.0:4443")
httpd.serve_forever()