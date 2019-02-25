export function sanitizeString(input) {
  input = input.trim()
  input = input.replace(/[`~!$%^&*|+?;:'",\\]/gi, '')
  input = input.replace('/', '')
  input = input.trim()
  return input
}
