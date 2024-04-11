export async function handleRequest(request) {
    if (request.method !== 'POST') {
        return {
            status: 405,
            headers: { "content-type": "text/plain" },
            body: "Method Not Allowed"
        }
    }
  

  try {
    let body = request.json()
    const hash = calculateHash(body.message);

    const responseData = {
        message: body.message,
        hash: hash
    };

    return {
        status: 200,
        headers: { "content-type": "application/json" },
        body: JSON.stringify(responseData)
    }
    } catch (error) {
        return {
            status: 400,
            headers: { "content-type": "text/plain" },
            body: "Bad Request: " + error.message
        }
    }
  }
  
  function calculateHash(message) {
    const hash = crypto.createHash('sha256', message).digest('hex');
    return hash;
  }