
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
