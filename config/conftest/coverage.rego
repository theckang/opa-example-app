package main

codeCoverageThreshold := 1.0

deny[msg] {
    codeCoverage := to_number(input.codecoverage)
    codeCoverage < codeCoverageThreshold
    msg := sprintf("%v%% code coverage is unacceptable. Code coverage must be greater than or equal to %v%%.", [codeCoverage * 100, codeCoverageThreshold * 100])
}
