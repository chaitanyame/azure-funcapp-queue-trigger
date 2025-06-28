import os
import json
import random
import argparse
from datetime import datetime
from azure.storage.queue import QueueClient

def generate_random_json():
    """Generate random JSON data for testing"""
    sample_data = [
        {
            "id": random.randint(1000, 9999),
            "name": random.choice(["John Doe", "Jane Smith", "Bob Johnson", "Alice Williams"]),
            "email": f"user{random.randint(1, 100)}@example.com",
            "timestamp": datetime.utcnow().isoformat() + "Z"
        },
        {
            "order_id": f"ORD-{random.randint(10000, 99999)}",
            "product": random.choice(["Laptop", "Phone", "Tablet", "Monitor"]),
            "amount": round(random.uniform(10.0, 1000.0), 2),
            "status": random.choice(["pending", "completed", "cancelled"])
        },
        {
            "event": random.choice(["user_login", "user_logout", "purchase", "view_product"]),
            "user_id": random.randint(1, 1000),
            "ip_address": f"192.168.{random.randint(1, 255)}.{random.randint(1, 255)}",
            "session_id": f"sess_{random.randint(100000, 999999)}"
        }
    ]
    return random.choice(sample_data)

def send_json_to_queue(connection_string, queue_name, json_data):
    """
    Send JSON data to Azure Storage Queue
    """
    try:
        # Create queue client
        queue_client = QueueClient.from_connection_string(connection_string, queue_name)
        
        # Convert to JSON string
        json_string = json.dumps(json_data, indent=2)
        
        # Send message
        queue_client.send_message(json_string)
        
        print(f"Successfully sent JSON message to queue '{queue_name}':")
        print(json_string)
        
    except Exception as e:
        print(f"Error sending message to queue: {e}")

def main():
    """
    Main function to send JSON messages to queue
    """
    parser = argparse.ArgumentParser(description="Send JSON messages to Azure Storage Queue")
    parser.add_argument("--file", help="Path to JSON file to send (optional)")
    parser.add_argument("--queue-name", default="jsonprocessqueue", help="Queue name (default: jsonprocessqueue)")
    parser.add_argument("--count", type=int, default=1, help="Number of random messages to send (default: 1)")
    
    args = parser.parse_args()
    
    # Get connection string from environment
    connection_string = os.environ.get('AZURE_STORAGE_CONNECTION_STRING')
    
    if not connection_string:
        print("Error: AZURE_STORAGE_CONNECTION_STRING environment variable not set")
        print("Please set it using: $env:AZURE_STORAGE_CONNECTION_STRING = 'your_connection_string'")
        return
    
    if args.file:
        # Send specific JSON file
        try:
            with open(args.file, 'r') as f:
                json_data = json.load(f)
            send_json_to_queue(connection_string, args.queue_name, json_data)
        except FileNotFoundError:
            print(f"Error: File '{args.file}' not found")
        except json.JSONDecodeError:
            print(f"Error: Invalid JSON in file '{args.file}'")
    else:
        # Send random JSON messages
        for i in range(args.count):
            json_data = generate_random_json()
            send_json_to_queue(connection_string, args.queue_name, json_data)
            if args.count > 1:
                print(f"--- Message {i + 1} of {args.count} ---")

if __name__ == "__main__":
    main()
