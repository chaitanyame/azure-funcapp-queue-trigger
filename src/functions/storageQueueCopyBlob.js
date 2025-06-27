const { app, input, output } = require("@azure/functions");

// input binding: message from the storage queue replaces {queueTrigger} text in the path
const blobInput = input.storageBlob({
  connection: "STORAGE_ACCOUNT_CONNECTION_STRING",
  path: "helloworld/{queueTrigger}",
});

// output binding: message from the storage queue replaces {queueTrigger} text in the path
const blobOutput = output.storageBlob({
  connection: "STORAGE_ACCOUNT_CONNECTION_STRING",
  path: "helloworld/{queueTrigger}-copy",
});

// trigger
app.storageQueue("storageQueueCopyBlob", {
  queueName: "copyblobqueue",
  connection: "STORAGE_ACCOUNT_CONNECTION_STRING",
  extraInputs: [blobInput],
  extraOutputs: [blobOutput],
  handler: (queueItem, context) => {
    context.log("Storage queue function processed work item:", queueItem);

    const blobInputValue = context.extraInputs.get(blobInput);
    context.extraOutputs.set(blobOutput, blobInputValue);
  },
});
