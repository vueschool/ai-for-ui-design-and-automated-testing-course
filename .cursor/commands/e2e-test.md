1. Analyze the files related to my test request
2. Make a list of behaviors that you'll likely want to test
3. Add `data-testid` attributes as needed (don't rely on any other selectors, only data-testid)
4. Find the page(s) that should be visited to test said behavior
5. Visit that page in the browser
6. Interact as needed and observe existing behavior
7. Write e2e tests in tests/e2e to codify observed behaviors
8. Run the newly written tests (in CI mode) and iterate on them if any failed
