exports.handler = async (event) => {
    return {
      statusCode: 200,
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        message: "Hola desde Lambda Proxy!",
        metodo: event.requestContext.http.method,
        ruta: event.rawPath
      })
    };
  };
  