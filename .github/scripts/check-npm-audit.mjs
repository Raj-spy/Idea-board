import { readFileSync } from 'node:fs'

const [reportPath, lockPath, policyPath, npmExitCode] = process.argv.slice(2)
if (!reportPath || !lockPath || !policyPath || npmExitCode === undefined) {
  throw new Error('Usage: node check-npm-audit.mjs <report> <lockfile> <policy> <npm-exit-code>')
}

const readJson = (path) => JSON.parse(readFileSync(path, 'utf8').replace(/^\uFEFF/, ''))
const report = readJson(reportPath)
const lock = readJson(lockPath)
const policy = readJson(policyPath)
const auditStatus = Number(npmExitCode)
if (!Number.isInteger(auditStatus) || auditStatus < 0 || auditStatus > 1) {
  throw new Error(`npm audit failed before completing (exit ${npmExitCode}).`)
}
if (!Number.isInteger(report.auditReportVersion) || report.error) {
  throw new Error(`npm audit returned an invalid report: ${JSON.stringify(report.error ?? report)}`)
}

const vulnerabilities = Object.entries(report.vulnerabilities ?? {})
const counts = { critical: 0, high: 0, moderate: 0, low: 0, info: 0 }
for (const [, vulnerability] of vulnerabilities) {
  if (Object.hasOwn(counts, vulnerability.severity)) {
    counts[vulnerability.severity] += 1
  }
}

const lines = [
  '### npm audit',
  '',
  '| Severity | Affected package entries |',
  '| --- | ---: |',
  ...Object.entries(counts).map(([severity, count]) => `| ${severity} | ${count} |`),
  '',
]

const advisoriesFor = (name, visited = new Set()) => {
  if (visited.has(name)) return new Set()
  visited.add(name)
  const vulnerability = report.vulnerabilities?.[name]
  const advisories = new Set()
  for (const via of vulnerability?.via ?? []) {
    if (typeof via === 'string') {
      for (const advisory of advisoriesFor(via, visited)) advisories.add(advisory)
      continue
    }
    const id = via.url?.match(/GHSA-[\w-]+/i)?.[0]
    if (id) advisories.add(id.toUpperCase())
  }
  return advisories
}

const packageVersions = (vulnerability) =>
  (vulnerability.nodes ?? []).map((node) => lock.packages?.[node]?.version ?? null)

const accepted = new Map(
  (policy.advisories ?? []).map((advisory) => [advisory.id.toUpperCase(), advisory]),
)
const failures = []
const exceptionLines = []
const today = new Date().toISOString().slice(0, 10)

for (const [name, vulnerability] of vulnerabilities) {
  const severity = vulnerability.severity
  const advisoryIds = advisoriesFor(name)
  const issueText = `${name} (${(vulnerability.nodes ?? []).join(', ') || 'unresolved node'})`

  if (severity === 'critical') {
    failures.push(`CRITICAL: ${issueText}`)
    continue
  }
  if (severity !== 'high') continue

  const matchedExceptions = [...advisoryIds].map((id) => accepted.get(id)).filter(Boolean)
  const exception = matchedExceptions.length === 1 ? matchedExceptions[0] : null
  const versions = packageVersions(vulnerability)
  const packagesAllowed = new Set(exception?.affectedPackages ?? [])
  const exactNodesAllowed =
    exception &&
    packagesAllowed.has(name) &&
    versions.length > 0 &&
    versions.every((version) => exception.lockedVersions?.[name]?.includes(version))
  const advisorySetAllowed =
    exception &&
    advisoryIds.size === 1 &&
    advisoryIds.has(exception.id.toUpperCase())

  if (
    exactNodesAllowed &&
    advisorySetAllowed &&
    exception.package === 'picomatch' &&
    lock.packages?.[`node_modules/${exception.package}`]?.version === exception.version
  ) {
    if (today > exception.expiresOn) {
      failures.push(`EXPIRED HIGH-severity exception (${exception.id}, expired ${exception.expiresOn}): ${issueText}`)
    } else {
      const line = `Temporary HIGH-severity exception ${exception.id}: ${issueText}; expires ${exception.expiresOn}.`
      exceptionLines.push(line)
    }
    continue
  }

  const advisoryDescription = advisoryIds.size ? [...advisoryIds].join(', ') : 'advisory ID unavailable'
  failures.push(`HIGH: ${issueText}; ${advisoryDescription} is not covered by the reviewed exception.`)
}

for (const [, vulnerability] of vulnerabilities) {
  for (const via of vulnerability.via ?? []) {
    if (typeof via === 'object' && via.url) {
      lines.push(`- ${via.severity?.toUpperCase() ?? 'UNKNOWN'}: ${via.url} — ${via.title}`)
    }
  }
}
if (exceptionLines.length) {
  lines.push('', '**Documented temporary exception**', ...exceptionLines.map((line) => `- ${line}`))
}
if (failures.length) {
  lines.push('', '**Blocking findings**', ...failures.map((line) => `- ${line}`))
}

console.log(lines.join('\n'))
if (process.env.GITHUB_STEP_SUMMARY) {
  const { appendFileSync } = await import('node:fs')
  appendFileSync(process.env.GITHUB_STEP_SUMMARY, `${lines.join('\n')}\n`)
}

if (failures.length) {
  for (const failure of failures) console.error(failure)
  process.exitCode = 1
}
