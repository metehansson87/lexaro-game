/**
 * Authentication middleware for REST API and Socket.io.
 * In production, this validates Firebase Auth tokens.
 */

/**
 * Express middleware to validate auth tokens.
 */
function authMiddleware(req, res, next) {
  // In production:
  // const token = req.headers.authorization?.split('Bearer ')[1];
  // if (!token) return res.status(401).json({ error: 'Unauthorized' });
  // const decoded = await admin.auth().verifyIdToken(token);
  // req.userId = decoded.uid;
  next();
}

/**
 * Socket.io middleware to validate auth on connection.
 */
function socketAuthMiddleware(socket, next) {
  // In production:
  // const token = socket.handshake.auth?.token;
  // if (!token) return next(new Error('Authentication required'));
  // const decoded = await admin.auth().verifyIdToken(token);
  // socket.userId = decoded.uid;
  next();
}

module.exports = { authMiddleware, socketAuthMiddleware };
