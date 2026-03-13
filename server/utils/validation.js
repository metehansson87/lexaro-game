/**
 * Server-side validation utilities.
 * Never trust client data — validate everything server-side.
 */

/**
 * Validate that a value is a non-empty string.
 */
function isNonEmptyString(value) {
  return typeof value === 'string' && value.trim().length > 0;
}

/**
 * Validate difficulty level.
 */
function isValidDifficulty(difficulty) {
  return ['easy', 'medium', 'hard'].includes(difficulty);
}

/**
 * Validate supported language.
 */
function isValidLanguage(language) {
  return ['en', 'tr', 'de', 'it', 'fr', 'es'].includes(language);
}

/**
 * Validate gold amount (must be positive integer).
 */
function isValidGoldAmount(amount) {
  return Number.isInteger(amount) && amount > 0;
}

/**
 * Validate player display name.
 */
function isValidDisplayName(name) {
  if (typeof name !== 'string') return false;
  const trimmed = name.trim();
  return trimmed.length >= 2 && trimmed.length <= 20;
}

/**
 * Sanitize a string to prevent injection.
 */
function sanitizeString(str) {
  if (typeof str !== 'string') return '';
  return str.replace(/[<>&"']/g, '').trim();
}

module.exports = {
  isNonEmptyString,
  isValidDifficulty,
  isValidLanguage,
  isValidGoldAmount,
  isValidDisplayName,
  sanitizeString,
};
