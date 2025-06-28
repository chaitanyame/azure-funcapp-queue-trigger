import azure.functions as func
import logging

app = func.FunctionApp()

@app.queue_trigger(arg_name="msg", queue_name="copyblobqueue",
                   connection="AzureWebJobsStorage")
def QueueTriggerFunction(msg: func.QueueMessage):
    """
    Simple function that just logs the received queue message
    """
    logging.info('Python queue trigger function processed a queue item')
    
    try:
        # Since messageEncoding is "none", get message as string directly
        message_content = msg.get_body().decode('utf-8')
        
        # Log the message content
        logging.info(f'Message received: {message_content}')
        
        # Print to console as well (will show in Application Insights)
        print(f"Queue message processed: {message_content}")
        
    except Exception as e:
        logging.error(f'Error processing message: {e}')
        print(f"Error processing queue message: {e}")
        # Don't re-raise to prevent retries
        logging.info('Message processing completed despite error')


@app.queue_trigger(arg_name="msg", queue_name="jsonprocessqueue",
                   connection="AzureWebJobsStorage")
@app.blob_output(arg_name="outblob",
                 path="json-messages/message-{rand-guid}.json",
                 connection="AzureWebJobsStorage")
def ProcessJsonQueueToBlob(msg: func.QueueMessage, outblob: func.Out[str]):
    """
    Function that processes JSON messages from queue and saves them directly to blob storage
    """
    logging.info('Processing JSON message from queue to blob storage')
    
    try:
        # Get message content directly
        message_content = msg.get_body().decode('utf-8')
        
        # Log what we're processing
        logging.info(f'JSON message received, length: {len(message_content)} characters')
        
        # Save directly to blob storage (no modifications)
        outblob.set(message_content)
        
        logging.info('Successfully saved JSON message to blob storage')
        print(f"JSON message processed and saved to blob: {len(message_content)} characters")
        
    except Exception as e:
        logging.error(f'Error processing JSON message: {e}')
        print(f"Error processing JSON message: {e}")
        # Don't re-raise to prevent retries
        logging.info('JSON message processing completed despite error')
