import os
import argparse
from azure.storage.queue import QueueClient, TextBase64EncodePolicy

def main():
    """
    Main function to parse arguments and send file content to the queue.
    """
    parser = argparse.ArgumentParser(description="Send a file's content to an Azure Storage Queue.")
    parser.add_argument("file_path", help="The path to the file to send.")
    parser.add_argument("--queue-name", default="copyblobqueue", help="The name of the storage queue.")
    args = parser.parse_args()

    # Get the connection string from an environment variable
    connect_str = os.environ.get('AZURE_STORAGE_CONNECTION_STRING')

    if not connect_str:
        print("Error: The environment variable AZURE_STORAGE_CONNECTION_STRING is not set.")
        print("Please set it to your Azure Storage connection string.")
        return

    send_file_to_queue(connect_str, args.queue_name, args.file_path)

def send_file_to_queue(connection_string, queue_name, file_path):
    """
    Connects to the Azure Storage Queue and sends the content of a file.

    :param connection_string: The connection string for the storage account.
    :param queue_name: The name of the queue.
    :param file_path: The path to the file to send.
    """
    try:
        # Instantiate a QueueClient
        queue_client = QueueClient.from_connection_string(
            connection_string,
            queue_name,
            message_encode_policy=TextBase64EncodePolicy()
        )

        # Read the file content
        with open(file_path, 'r') as f:
            file_content = f.read()

        # Send the message
        queue_client.send_message(file_content)
        print(f"Successfully sent content of '{file_path}' to queue '{queue_name}'.")

    except FileNotFoundError:
        print(f"Error: The file at '{file_path}' was not found.")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    main()
