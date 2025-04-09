const jwt = require("jsonwebtoken");
const jwksClient = require("jwks-rsa");

const client = jwksClient({
  jwksUri: "https://dev-7l5fw77acm7cntm1.us.auth0.com/.well-known/jwks.json"
});

function getKey(header, callback) {
  client.getSigningKey(header.kid, function (err, key) {
    const signingKey = key.getPublicKey();
    callback(null, signingKey);
  });
}

exports.handler = async (event) => {
  const token = event.headers.authorization?.replace("Bearer ", "");

  try {
    const decoded = await new Promise((resolve, reject) => {
      jwt.verify(token, getKey, {
        issuer: "https://dev-7l5fw77acm7cntm1.us.auth0.com/",
        audience: "https://mi-api-segura", // Identificador de tu API
        algorithms: ["RS256"]
      }, (err, decoded) => {
        if (err) return reject(err);
        resolve(decoded);
      });
    });

    return {
      isAuthorized: true,
      context: {
        user: JSON.stringify(decoded)
      }
    };
  } catch (error) {
    console.log("JWT inválido:", error.message);
    return {
      isAuthorized: false
    };
  }
};
