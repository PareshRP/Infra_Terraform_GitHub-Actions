exports.handler = async (event) => {
    console.log("LOG_LEVEL:", process.env.LOG_LEVEL);
    return {
        statusCode: 200,
        body: JSON.stringify({ message: "Hello from Lambda!" }),
    };
};
