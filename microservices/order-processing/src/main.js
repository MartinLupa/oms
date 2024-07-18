exports.handler = async (event) => {
  // Log the incoming event
  console.log("Received event:", JSON.stringify(event, null, 2));

  // Define the response
  const response = {
    statusCode: 200,
    body: JSON.stringify({
      message: "Hello from Lambda!",
      input: event,
    }),
  };

  // Return the response
  return response;
};
