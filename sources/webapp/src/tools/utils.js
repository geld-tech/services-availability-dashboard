export function sanitizeString(input) {
  input = input.trim()
  input = input.replace(/[`~!$%^&*|+?;:'",\\]/gi, '')
  input = input.replace(/\/\//g, '_')
  input = input.replace('/', '')
  input = input.trim()
  return input
}
