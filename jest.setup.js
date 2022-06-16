const path = require('path');
const dotenv = require('dotenv');

// Minimize console output when testing failure cases
global.console.error = jest.fn();

dotenv.config({ path: path.resolve(__dirname, './.env.test') });